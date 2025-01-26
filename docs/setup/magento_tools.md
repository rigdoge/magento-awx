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