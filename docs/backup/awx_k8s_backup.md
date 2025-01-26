# AWX K8s 资源备份和还原指南

本文档介绍如何使用 Ansible playbook 备份和还原 AWX 的 Kubernetes 资源配置。

## 功能特点

1. 自动备份
   - 备份所有 K8s 资源配置(CR、Secrets、ConfigMaps 等)
   - 自动创建带时间戳的备份目录(精确到秒)
   - 自动清理 7 天前的备份
   - YAML 格式存储，便于版本控制

2. 选择性还原
   - 支持指定日期还原
   - 自动按正确顺序还原各组件
   - 等待服务就绪后再继续

## 备份内容

以下 K8s 资源会被备份：

1. AWX CR (Custom Resource)
2. Secrets (密钥)
3. ConfigMaps (配置映射)
4. PVCs (持久卷声明)
5. 其他 K8s 资源(Deployments、Services 等)

## 使用方法

### 执行备份

运行备份脚本：
```bash
ansible-playbook ansible/backup/backup-k8s.yml
```

备份文件将保存在 `/backup/awx/YYYYMMDD_HHMMSS/` 目录下，例如：
```
/backup/awx/20240326_143022/
├── awx-cr.yaml
├── secrets.yaml
├── configmaps.yaml
├── pvcs.yaml
└── resources.yaml
```

### 执行还原

1. 查看可用的备份目录：
```bash
ls -l /backup/awx/
```

2. 选择要还原的备份时间戳并执行还原：
```bash
ansible-playbook ansible/backup/restore-k8s.yml -e "backup_timestamp=20240326_143022"
```

## 备份策略

1. 自动清理
   - 系统自动保留最近 7 天的备份
   - 超过 7 天的备份目录会被自动删除

2. 建议的备份频率
   - 生产环境：每天一次
   - 测试环境：每周一次
   - 重要变更前：手动执行一次

## 注意事项

1. 备份前：
   - 确保有足够的存储空间
   - 建议在低峰期执行备份

2. 还原时：
   - 建议先备份当前配置
   - 确保指定的备份目录存在且完整
   - 注意还原过程不可中断
   - 还原时会临时停止 AWX 服务

3. 安全建议：
   - 定期验证备份的完整性
   - 将重要备份异地存储
   - 控制备份目录的访问权限

## 故障排除

1. 备份失败：
   - 检查存储空间
   - 确认 K8s 集群状态
   - 查看详细错误日志

2. 还原失败：
   - 确认备份目录完整性
   - 检查 K8s 集群状态
   - 查看 Pod 状态和日志

## 开发说明

1. 备份脚本位置：`ansible/backup/backup-k8s.yml`
2. 还原脚本位置：`ansible/backup/restore-k8s.yml`
3. 支持的环境变量：
   - `backup_dir`: 备份目录路径(默认: /backup/awx)
   - `backup_timestamp`: 还原时指定的备份时间戳(格式: YYYYMMDD_HHMMSS) 