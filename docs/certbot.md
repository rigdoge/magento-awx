# Certbot 安装指南

本文档介绍如何在 AWX 中安装和配置 Certbot，用于自动管理 SSL 证书。

## 功能特性

- 自动安装 Certbot 及其依赖
- 自动申请 SSL 证书
- 配置自动续期机制
- 支持自定义域名和邮箱
- 自动处理续期时的 Nginx 停止/启动

## 在 AWX 中配置

### 1. 创建模板

1. 进入 AWX 管理界面
2. 点击 "Templates" -> "Add" -> "Job Template"
3. 填写以下信息：
   - Name: `Install Certbot`
   - Job Type: `Run`
   - Inventory: 选择包含目标主机的清单
   - Project: 选择包含 Ansible 脚本的项目
   - Playbook: `ansible/install/install-certbot.yml`
   - Credentials: 选择可以访问目标主机的凭证

### 2. 配置变量

在模板的 "EXTRA VARIABLES" 部分添加以下变量：

```yaml
---
# Kubernetes 命名空间配置
namespace: awx                      # 替换为你的 Nginx 所在的命名空间

# 域名配置
domain_name: awx.tschenfeng.com    # 替换为你的域名

# 邮箱配置（用于证书到期提醒）
email_address: ssl@tschenfeng.com   # 替换为你的邮箱
```

> **注意**: 如果你的 Nginx 运行在特定的 Kubernetes 命名空间中，请确保设置正确的 `namespace` 变量。

### 3. 运行安装

1. 在模板列表中找到 "Install Certbot"
2. 点击运行按钮（火箭图标）
3. 确认变量设置
4. 点击 "Launch" 开始安装

### 4. 验证安装

安装完成后，可以通过以下方式验证：

1. 检查证书状态：
```bash
certbot certificates
```

2. 测试自动续期：
```bash
certbot renew --dry-run
```

3. 访问网站验证 HTTPS：
```
https://your-domain.com
```

## 自动续期说明

本安装脚本已配置自动续期机制：

1. 证书有效期为 90 天
2. Certbot 会自动在到期前 30 天尝试续期
3. 续期过程：
   - 自动停止 Nginx
   - 续期证书
   - 自动启动 Nginx

## 故障排除

### 1. 证书申请失败

可能的原因：
- 域名 DNS 未正确解析
- 80/443 端口被占用
- 网络连接问题

解决方案：
1. 检查域名解析
2. 确保端口未被占用
3. 检查网络连接

### 2. 自动续期失败

可能的原因：
- Certbot 服务未运行
- 续期脚本权限问题
- Nginx 服务异常

解决方案：
1. 检查 Certbot 服务状态
2. 验证续期脚本权限
3. 手动测试续期流程

## 注意事项

1. 确保域名已正确解析到服务器
2. 安装过程中会短暂停止 Nginx 服务
3. 使用真实有效的邮箱地址（用于接收证书过期提醒）
4. 定期检查证书状态和自动续期日志

## 相关命令

```bash
# 查看证书状态
certbot certificates

# 手动续期测试
certbot renew --dry-run

# 查看续期日志
tail -f /var/log/letsencrypt/letsencrypt.log

# 撤销证书
certbot revoke --cert-path /etc/letsencrypt/live/your-domain.com/cert.pem

# 删除证书
certbot delete --cert-name your-domain.com
``` 