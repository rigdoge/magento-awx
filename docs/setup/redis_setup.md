# Redis 安装和配置指南

本文档介绍如何在 K3s 环境中安装和配置 Redis，以支持多个 Magento 站点。

## 1. 基础环境安装

### 1.1 安装命令

```bash
ansible-playbook ansible/install/install-redis-base.yml -e "namespace=magento memory=4Gi"
```

### 1.2 参数说明

- `namespace`: Kubernetes 命名空间（默认：default）
- `memory`: Redis 使用的内存大小（默认：1Gi）
- `nodeport`: 服务暴露的节点端口（默认：30379）

### 1.3 安装内容

- Redis 7.2 容器
- 持久化存储（10Gi）
- NodePort 类型的 Service
- 基础配置的 ConfigMap

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
ansible-playbook ansible/install/install-redis-base.yml \
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

- 最大内存：由 memory 参数指定
- 内存策略：allkeys-lru（删除最近最少使用的键）
- 持久化：RDB
  * 900秒内至少1个变更
  * 300秒内至少10个变更
  * 60秒内至少10000个变更

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