# Percona XtraBackup 安装和使用指南

本文档介绍如何在 K3s 环境中安装和使用 Percona XtraBackup 进行数据库备份。

## 1. 安装说明

### 1.1 基本安装
```bash
# 使用默认配置安装
ansible-playbook ansible/install/install-percona-backup.yml \
  -e "namespace=magento"
```

### 1.2 自定义安装
```bash
# 自定义配置安装
ansible-playbook ansible/install/install-percona-backup.yml \
  -e "namespace=magento" \
  -e "size=100Gi" \
  -e "retention=14" \
  -e "full_schedule=0 1 * * *" \
  -e "inc_schedule=0 */6 * * *"
```

### 1.3 配置参数说明
- `namespace`: Kubernetes 命名空间（默认：magento）
- `size`: 备份存储大小（默认：50Gi）
- `retention`: 备份保留天数（默认：7）
- `full_schedule`: 完整备份计划（默认：每天凌晨 0 点）
- `inc_schedule`: 增量备份计划（默认：每 4 小时）

## 2. 备份说明

### 2.1 备份类型
1. **完整备份**
   - 每天凌晨自动执行
   - 包含所有数据库数据
   - 自动验证备份完整性
   - 存储在 `/backup/full/YYYYMMDD` 目录

2. **增量备份**
   - 每 4 小时自动执行
   - 仅包含变更数据
   - 基于最新的完整备份
   - 存储在 `/backup/inc/YYYYMMDD/HHMM` 目录

### 2.2 备份内容
- 数据文件
- 表结构
- 索引文件
- 配置文件
- 事务日志

### 2.3 存储结构
```
/backup/
├── full/
│   ├── 20240126/
│   ├── 20240127/
│   └── ...
└── inc/
    ├── 20240126/
    │   ├── 0400/
    │   ├── 0800/
    │   └── ...
    └── 20240127/
```

## 3. 维护操作

### 3.1 查看备份状态
```bash
# 查看备份任务状态
kubectl get cronjob -n magento

# 查看正在运行的备份
kubectl get pod -n magento | grep backup

# 查看备份日志
kubectl logs -n magento percona-full-backup-xxxxx
```

### 3.2 手动触发备份
```bash
# 触发完整备份
kubectl create job --from=cronjob/percona-full-backup \
  manual-backup-$(date +%s) -n magento

# 触发增量备份
kubectl create job --from=cronjob/percona-incremental-backup \
  manual-inc-backup-$(date +%s) -n magento
```

### 3.3 检查备份大小
```bash
# 查看备份使用空间
kubectl exec -it -n magento percona-0 -- du -sh /backup/*

# 查看各备份目录大小
kubectl exec -it -n magento percona-0 -- du -sh /backup/full/*
kubectl exec -it -n magento percona-0 -- du -sh /backup/inc/*
```

## 4. 恢复操作

### 4.1 完整备份恢复
```bash
# 1. 停止数据库
kubectl scale statefulset percona --replicas=0 -n magento

# 2. 恢复数据
kubectl exec -it -n magento percona-0 -- xtrabackup \
  --copy-back \
  --target-dir=/backup/full/YYYYMMDD \
  --datadir=/var/lib/mysql

# 3. 启动数据库
kubectl scale statefulset percona --replicas=1 -n magento
```

### 4.2 增量备份恢复
```bash
# 1. 准备完整备份
kubectl exec -it -n magento percona-0 -- xtrabackup \
  --prepare \
  --target-dir=/backup/full/YYYYMMDD

# 2. 应用增量备份
kubectl exec -it -n magento percona-0 -- xtrabackup \
  --prepare \
  --target-dir=/backup/full/YYYYMMDD \
  --incremental-dir=/backup/inc/YYYYMMDD/HHMM

# 3. 执行恢复
kubectl exec -it -n magento percona-0 -- xtrabackup \
  --copy-back \
  --target-dir=/backup/full/YYYYMMDD \
  --datadir=/var/lib/mysql
```

## 5. 故障排除

### 5.1 备份失败
1. **检查存储空间**
   ```bash
   kubectl exec -it -n magento percona-0 -- df -h
   ```

2. **检查权限**
   ```bash
   kubectl exec -it -n magento percona-0 -- ls -la /backup
   ```

3. **查看详细日志**
   ```bash
   kubectl logs -n magento percona-full-backup-xxxxx
   ```

### 5.2 恢复失败
1. **检查数据目录**
   ```bash
   kubectl exec -it -n magento percona-0 -- ls -la /var/lib/mysql
   ```

2. **验证备份完整性**
   ```bash
   kubectl exec -it -n magento percona-0 -- xtrabackup \
     --check --target-dir=/backup/full/YYYYMMDD
   ```

### 5.3 常见问题
1. **空间不足**
   - 检查 PVC 大小
   - 清理旧备份
   - 考虑增加存储容量

2. **备份超时**
   - 检查数据库大小
   - 调整备份时间窗口
   - 考虑优化备份策略

3. **权限问题**
   - 检查 Pod 权限
   - 验证密钥配置
   - 检查存储挂载权限

## 6. 最佳实践

1. **备份策略**
   - 根据数据量调整备份频率
   - 定期验证备份可用性
   - 保持适当的备份保留期

2. **存储管理**
   - 监控存储使用情况
   - 定期清理过期备份
   - 预留足够的存储空间

3. **安全建议**
   - 加密备份数据
   - 限制备份访问权限
   - 异地备份关键数据 