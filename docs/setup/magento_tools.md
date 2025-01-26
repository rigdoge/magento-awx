# Magento 管理工具说明

本文档说明在我们的 K3s 环境中管理 Magento 的工具选择。

## 1. 工具选择

### 1.1 核心工具
- **Ansible**: 自动化部署和配置
- **Composer**: 包管理和依赖控制
- **Git**: 代码版本控制
- **kubectl/k3s**: 容器编排和管理

### 1.2 专用工具
- **Redis CLI**: 缓存管理
- **Percona**: 数据库管理
- **AWX**: 任务编排和调度

### 1.3 不使用的工具
- **n98-magerun2**: 由于以下原因不使用：
  * 容器环境集成复杂
  * 功能与现有工具重叠
  * 可能影响自动化流程

## 2. 常见操作对照表

### 2.1 缓存管理
```bash
# 传统方式（n98-magerun2）
n98-magerun2 cache:clean
n98-magerun2 cache:flush

# 我们的方式
ansible-playbook ansible/install/configure-redis-site.yml \
  -e "namespace=magento" \
  -e "site_name=site1" \
  -e "db_offset=0"
```

### 2.2 数据库操作
```bash
# 传统方式（n98-magerun2）
n98-magerun2 db:dump
n98-magerun2 db:import

# 我们的方式
kubectl exec -it -n magento percona-0 -- mysqldump
kubectl exec -it -n magento percona-0 -- mysql
```

### 2.3 配置管理
```bash
# 传统方式（n98-magerun2）
n98-magerun2 config:set

# 我们的方式
ansible-playbook ansible/configure/magento-config.yml \
  -e "site_name=site1" \
  -e "config_path=path/to/config" \
  -e "config_value=value"
```

## 3. 优势说明

1. **标准化**
   - 统一的工具链
   - 一致的操作方式
   - 可复制的流程

2. **自动化**
   - 批量操作支持
   - 定时任务集成
   - 错误处理机制

3. **安全性**
   - 权限精细控制
   - 操作审计
   - 环境隔离

4. **可扩展性**
   - 易于添加新站点
   - 配置模板化
   - 资源动态调整

## 4. 最佳实践

1. **使用 Ansible Playbook**
   - 所有配置更改通过 Playbook 进行
   - 保持配置文件版本控制
   - 使用变量模板

2. **数据库操作**
   - 使用 Percona 工具链
   - 定期备份
   - 监控性能

3. **缓存管理**
   - 使用 Redis 专用工具
   - 监控缓存效率
   - 定期清理

4. **日志管理**
   - 集中式日志收集
   - 错误监控
   - 性能分析

## 5. 故障排除

### 5.1 缓存问题
```bash
# 检查 Redis 状态
kubectl exec -it -n magento redis-0 -- redis-cli INFO

# 清理特定数据库
kubectl exec -it -n magento redis-0 -- redis-cli -n 0 FLUSHDB
```

### 5.2 数据库问题
```bash
# 检查数据库状态
kubectl exec -it -n magento percona-0 -- mysql -e "SHOW STATUS"

# 查看慢查询
kubectl exec -it -n magento percona-0 -- mysql -e "SHOW PROCESSLIST"
```

### 5.3 应用问题
```bash
# 查看应用日志
kubectl logs -n magento magento-pod

# 检查配置
kubectl exec -it -n magento magento-pod -- php bin/magento config:show
```

## 6. 数据库备份策略

### 6.1 XtraBackup 工具
- **安装理由**：
  * 支持热备份（在线备份）
  * 增量备份支持
  * 并行备份提高效率
  * 压缩和加密支持
  * 支持时间点恢复

### 6.2 备份类型
```bash
# 完整备份
kubectl exec -it -n magento percona-0 -- xtrabackup --backup \
  --target-dir=/backup/full \
  --user=root \
  --password=$MYSQL_ROOT_PASSWORD

# 增量备份
kubectl exec -it -n magento percona-0 -- xtrabackup --backup \
  --target-dir=/backup/inc1 \
  --incremental-basedir=/backup/full \
  --user=root \
  --password=$MYSQL_ROOT_PASSWORD
```

### 6.3 备份策略
1. **定时备份**
   - 每日凌晨完整备份
   - 每4小时增量备份
   - 保留7天的备份历史

2. **备份验证**
   ```bash
   # 准备备份
   kubectl exec -it -n magento percona-0 -- xtrabackup --prepare \
     --target-dir=/backup/full

   # 验证备份
   kubectl exec -it -n magento percona-0 -- xtrabackup --check \
     --target-dir=/backup/full
   ```

3. **恢复流程**
   ```bash
   # 停止数据库
   kubectl scale statefulset percona --replicas=0 -n magento

   # 恢复数据
   kubectl exec -it -n magento percona-0 -- xtrabackup --copy-back \
     --target-dir=/backup/full \
     --datadir=/var/lib/mysql

   # 启动数据库
   kubectl scale statefulset percona --replicas=1 -n magento
   ```

### 6.4 自动化配置
```yaml
# ansible/install/install-percona-backup.yml
---
- name: 安装 Percona XtraBackup
  hosts: all
  tasks:
    - name: 创建备份 PVC
      k8s:
        state: present
        definition:
          apiVersion: v1
          kind: PersistentVolumeClaim
          metadata:
            name: percona-backup
            namespace: "{{ use_namespace }}"
          spec:
            accessModes: ["ReadWriteOnce"]
            resources:
              requests:
                storage: 50Gi

    - name: 配置备份 CronJob
      k8s:
        state: present
        definition:
          apiVersion: batch/v1
          kind: CronJob
          metadata:
            name: percona-backup
            namespace: "{{ use_namespace }}"
          spec:
            schedule: "0 0 * * *"  # 每天凌晨执行
            jobTemplate:
              spec:
                template:
                  spec:
                    containers:
                      - name: xtrabackup
                        image: percona/percona-xtrabackup:8.0
                        command: ["/bin/bash", "-c"]
                        args:
                          - |
                            xtrabackup --backup \
                              --target-dir=/backup/$(date +%Y%m%d) \
                              --user=root \
                              --password=$MYSQL_ROOT_PASSWORD
                        volumeMounts:
                          - name: backup
                            mountPath: /backup
                    volumes:
                      - name: backup
                        persistentVolumeClaim:
                          claimName: percona-backup
```

### 6.5 监控和维护
1. **空间监控**
   ```bash
   # 检查备份大小
   kubectl exec -it -n magento percona-0 -- du -sh /backup/*

   # 清理旧备份
   kubectl exec -it -n magento percona-0 -- find /backup -mtime +7 -delete
   ```

2. **备份状态检查**
   ```bash
   # 检查最近备份状态
   kubectl exec -it -n magento percona-0 -- xtrabackup --stats \
     --target-dir=/backup/$(date +%Y%m%d)
   ```

3. **告警设置**
   - 备份失败通知
   - 空间不足预警
   - 备份时间异常告警 