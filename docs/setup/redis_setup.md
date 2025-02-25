# Redis 安装和配置指南

本文档介绍如何在 K3s 环境中安装和配置 Redis，以支持多个 Magento 站点。

## 1. 基础环境安装

### 1.1 安装命令

```bash
# 使用 StatefulSet 安装 Redis
ansible-playbook ansible/install/install-redis-statefulset.yml -e "namespace=magento memory=4Gi"

# 卸载 Redis
ansible-playbook ansible/install/install-redis-statefulset.yml -e "namespace=magento action=uninstall"
```

### 1.2 参数说明

- `namespace`: Kubernetes 命名空间（默认：default）
- `memory`: Redis 使用的内存大小（默认：1Gi）
- `nodeport`: 服务暴露的节点端口（默认：30379）
- `action`: 操作类型（install/uninstall，默认：install）

### 1.3 安装内容

- Redis 7.2 StatefulSet
- 持久化存储（10Gi）
- NodePort 类型的 Service
- 基础配置的 ConfigMap
- 自动化的 PVC 管理

## 2. 站点配置

### 2.1 配置命令

```bash
ansible-playbook ansible/install/configure-redis-site.yml \
  -e "namespace=magento" \
  -e "site_name=site1" \
  -e "db_offset=0"
```

### 2.2 参数说明

- `namespace`: Kubernetes 命名空间（默认：default）
- `site_name`: 站点名称（**必需参数**）
- `db_offset`: 数据库索引偏移量（默认：0）

### 2.3 数据库分配

每个站点使用 3 个数据库：
1. 默认缓存：db_offset + 0
2. 页面缓存：db_offset + 1
3. 会话存储：db_offset + 2

例如：
- site1: 使用 DB 0,1,2
- site2: 使用 DB 3,4,5
- site3: 使用 DB 6,7,8

## 3. 使用示例

### 3.1 安装基础环境

```bash
# 安装 Redis，分配 4GB 内存
ansible-playbook ansible/install/install-redis-statefulset.yml \
  -e "namespace=magento" \
  -e "memory=4Gi"
```

### 3.2 配置多个站点

```bash
# 配置第一个站点（使用 DB 0,1,2）
ansible-playbook ansible/install/configure-redis-site.yml \
  -e "namespace=magento" \
  -e "site_name=site1" \
  -e "db_offset=0"

# 配置第二个站点（使用 DB 3,4,5）
ansible-playbook ansible/install/configure-redis-site.yml \
  -e "namespace=magento" \
  -e "site_name=site2" \
  -e "db_offset=3"
```

## 4. 配置说明

### 4.1 基础配置

- 最大内存：由 memory 参数指定（自动转换为字节）
- 内存策略：allkeys-lru（删除最近最少使用的键）
- 持久化：AOF
  * appendonly yes
  * appendfsync everysec
  * 存储目录：/data
- 网络配置：
  * bind 0.0.0.0
  * protected-mode no
  * daemonize no

### 4.2 安全配置

- 禁用危险命令：
  * FLUSHALL
  * FLUSHDB
  * DEBUG

### 4.3 监控配置

- 存活探针：TCP 6379
- 就绪探针：TCP 6379

## 5. 维护操作

### 5.1 查看数据库信息

```bash
# 连接到 Redis
kubectl exec -it -n magento redis-pod -- redis-cli

# 查看数据库信息
redis-cli -h redis -p 6379 -n <db_number> GET db_info
```

### 5.2 清理缓存

```bash
# 清理特定站点的缓存
redis-cli -h redis -p 6379 -n <db_number> FLUSHDB
```

### 5.3 监控状态

```bash
# 查看内存使用情况
redis-cli -h redis -p 6379 INFO memory

# 查看数据库状态
redis-cli -h redis -p 6379 INFO keyspace
```

## 6. 注意事项

1. **内存管理**
   - 监控内存使用情况
   - 适时调整内存大小
   - 注意内存淘汰策略

2. **数据库规划**
   - 合理分配数据库索引
   - 记录数据库用途
   - 避免数据库冲突

3. **性能优化**
   - 适当设置过期时间
   - 定期清理无用数据
   - 监控命中率

4. **安全建议**
   - 限制访问来源
   - 禁用危险命令
   - 定期备份数据

## 7. 故障排除

### 7.1 内存问题
- 检查内存使用情况
- 查看内存淘汰日志
- 调整内存配置

### 7.2 连接问题
- 验证服务状态
- 检查网络连接
- 查看错误日志

### 7.3 性能问题
- 监控响应时间
- 检查慢查询日志
- 优化数据结构

## 8. StatefulSet 特性

### 8.1 优势
- 稳定的网络标识
- 有序部署和扩展
- 自动化的 PVC 管理
- 更好的数据持久性

### 8.2 注意事项
- PVC 不会自动删除
- 需要按顺序删除资源
- 建议使用卸载脚本

### 8.3 监控建议
- 监控 StatefulSet 状态
- 检查 PVC 状态
- 观察 Pod 事件

## 9. 完全卸载说明

### 9.1 使用脚本卸载
```bash
# 使用卸载脚本（推荐）
ansible-playbook ansible/install/install-redis-statefulset.yml \
  -e "namespace=magento" \
  -e "action=uninstall"
```

### 9.2 手动卸载步骤
如果脚本卸载失败，可以按以下顺序手动删除：

```bash
# 1. 删除 StatefulSet
kubectl delete statefulset redis -n magento

# 2. 删除 Service
kubectl delete svc redis -n magento

# 3. 删除 ConfigMap
kubectl delete configmap redis-config -n magento

# 4. 删除 PVC（注意：这将永久删除数据）
kubectl delete pvc redis-data-redis-0 -n magento

# 5. 检查是否还有遗留资源
kubectl get all,pvc,configmap -l app=redis -n magento
```

### 9.3 注意事项
1. PVC 删除后数据将永久丢失，请确保数据已备份
2. 如果要保留数据，可以不删除 PVC
3. 删除 PVC 前请确保相关的 Pod 已经被删除
4. 如果 PVC 处于 Terminating 状态，可能需要强制删除：
   ```bash
   kubectl patch pvc redis-data-redis-0 -n magento -p '{"metadata":{"finalizers":null}}'
   ``` 