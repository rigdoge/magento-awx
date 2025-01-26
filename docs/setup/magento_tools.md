# Magento 自动化工具使用指南

本文档介绍如何使用 Magento 自动化工具进行安装、配置、维护和监控。

## 1. 工具安装

### 1.1 安装命令

```bash
ansible-playbook ansible/install/install-magento-tools.yml -e "namespace=magento"
```

### 1.2 安装内容

- 自动化脚本集合
- Magento 工具 Pod
- 配置文件

## 2. 可用工具

### 2.1 安装工具 (install.sh)

自动化安装 Magento，包括：
- 数据库配置
- Redis 缓存配置
- OpenSearch 配置
- RabbitMQ 配置
- 管理员账户设置

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/install.sh
```

### 2.2 备份工具 (backup.sh)

自动备份 Magento 数据：
- 数据库备份
- 代码备份
- 媒体文件备份
- 自动清理旧备份（保留7天）

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/backup.sh
```

### 2.3 缓存管理 (cache.sh)

缓存操作：
- clean: 清理缓存
- flush: 刷新缓存
- status: 查看状态
- enable/disable: 启用/禁用缓存

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/cache.sh clean
```

### 2.4 部署工具 (deploy.sh)

自动化部署流程：
- 启用维护模式
- 清理缓存
- 部署静态内容
- 编译代码
- 升级数据库
- 重建索引
- 关闭维护模式

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/deploy.sh
```

### 2.5 定时任务管理 (cron.sh)

Cron 任务操作：
- install: 安装定时任务
- run: 执行定时任务
- remove: 移除定时任务
- status: 查看状态

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/cron.sh status
```

### 2.6 监控工具 (monitor.sh)

系统监控：
- 系统状态检查
- 索引状态检查
- 缓存状态检查
- 队列状态检查
- Cron 任务状态检查

使用示例：
```bash
kubectl exec -n magento magento-tools -- magento-tools/monitor.sh
```

## 3. 环境变量配置

工具使用以下环境变量：

### 3.1 数据库配置
- DB_HOST: 数据库主机
- DB_NAME: 数据库名称
- DB_USER: 数据库用户
- DB_PASSWORD: 数据库密码

### 3.2 Redis 配置
- REDIS_HOST: Redis 主机
- REDIS_PORT: Redis 端口

### 3.3 OpenSearch 配置
- OPENSEARCH_HOST: OpenSearch 主机
- OPENSEARCH_PORT: OpenSearch 端口

### 3.4 RabbitMQ 配置
- RABBITMQ_HOST: RabbitMQ 主机
- RABBITMQ_PORT: RabbitMQ 端口
- RABBITMQ_USER: RabbitMQ 用户
- RABBITMQ_PASSWORD: RabbitMQ 密码

### 3.5 Magento 配置
- MAGENTO_URL: 站点 URL
- ADMIN_FIRSTNAME: 管理员名
- ADMIN_LASTNAME: 管理员姓
- ADMIN_EMAIL: 管理员邮箱
- ADMIN_USERNAME: 管理员用户名
- ADMIN_PASSWORD: 管理员密码
- LANGUAGE: 语言设置
- CURRENCY: 货币设置
- TIMEZONE: 时区设置

## 4. 最佳实践

### 4.1 定期备份
- 每天进行一次完整备份
- 在重要更新前进行备份
- 定期验证备份的完整性

### 4.2 缓存管理
- 开发环境可禁用部分缓存
- 生产环境保持所有缓存启用
- 代码更新后清理缓存

### 4.3 部署流程
- 使用维护模式进行更新
- 更新前后检查系统状态
- 分阶段部署大型更新

### 4.4 监控建议
- 定期检查系统状态
- 设置监控告警
- 保持日志记录

## 5. 故障排除

### 5.1 工具 Pod 无法启动
- 检查 PVC 是否正确创建
- 验证命名空间权限
- 查看 Pod 日志

### 5.2 脚本执行失败
- 检查环境变量设置
- 验证文件权限
- 查看执行日志

### 5.3 备份失败
- 检查存储空间
- 验证数据库连接
- 确认备份路径权限

## 6. 安全建议

1. 定期更新密码
2. 限制工具 Pod 访问权限
3. 加密敏感数据
4. 监控异常访问
5. 保护备份数据 