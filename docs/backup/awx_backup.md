# AWX 配置备份和恢复指南

本文档介绍如何使用 Ansible playbook 备份和恢复 AWX 的配置。

## 功能特点

1. 自动备份
   - 支持所有关键配置的备份
   - 自动创建带时间戳的备份文件
   - 自动清理过期备份
   - JSON 格式存储，便于版本控制

2. 选择性恢复
   - 支持指定备份文件恢复
   - 自动解压和导入配置
   - 按正确顺序恢复各组件

## 备份内容

以下配置会被备份：

1. 组织配置 (Organizations)
2. 项目配置 (Projects)
3. 作业模板 (Job Templates)
4. 资产清单 (Inventories)
5. 凭据配置 (Credentials)

## 使用方法

### 前置条件

1. 安装 AWX CLI 工具：
   ```bash
   pip install awxkit
   ```

2. 配置 AWX CLI：
   ```bash
   awx config
   # 输入以下信息：
   # host: https://your-awx-host
   # username: your-username
   # password: your-password
   ```

3. 创建备份目录：
   ```bash
   mkdir -p /backup/awx
   chmod 755 /backup/awx
   ```

### 执行备份

运行备份脚本：
```bash
ansible-playbook ansible/backup/backup-awx.yml
```

备份文件将保存在 `/backup/awx` 目录下，格式为：`awx-backup-YYYY-MM-DD.tar.gz`

### 执行恢复

1. 查看可用的备份文件：
   ```bash
   ls -l /backup/awx
   ```

2. 选择要恢复的备份文件并执行恢复：
   ```bash
   ansible-playbook ansible/backup/restore-awx.yml -e "backup_file=awx-backup-2025-01-26.tar.gz"
   ```

## 备份策略

1. 自动清理
   - 系统自动保留最近 7 天的备份
   - 超过 7 天的备份文件会被自动删除

2. 建议的备份频率
   - 生产环境：每天一次
   - 测试环境：每周一次
   - 重要变更前：手动执行一次

## 注意事项

1. 备份前：
   - 确保 AWX CLI 工具已正确安装和配置
   - 确保备份目录存在且有足够的存储空间
   - 建议在低峰期执行备份

2. 恢复时：
   - 建议先备份当前配置
   - 确保指定的备份文件存在且完整
   - 注意恢复过程不可中断

3. 安全建议：
   - 定期验证备份文件的完整性
   - 将重要备份异地存储
   - 控制备份文件的访问权限

## 故障排除

1. 备份失败：
   - 检查 AWX CLI 配置
   - 确认备份目录权限
   - 查看磁盘空间

2. 恢复失败：
   - 确认备份文件完整性
   - 检查 AWX 服务状态
   - 查看详细错误日志

## 开发说明

1. 备份脚本位置：`ansible/backup/backup-awx.yml`
2. 恢复脚本位置：`ansible/backup/restore-awx.yml`
3. 支持的环境变量：
   - `backup_dir`: 备份目录路径
   - `backup_file`: 要恢复的备份文件名 