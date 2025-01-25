# 安全工具安装指南

本文档介绍了项目中使用的安全工具的安装和配置方法。

## fail2ban

fail2ban 是一个入侵防御工具，可以保护服务器免受暴力破解攻击。

### 功能特点
- 监控 SSH 登录尝试
- 监控 Nginx 认证失败
- 自动封禁可疑 IP

### 默认配置
- 封禁时间：1小时（3600秒）
- 检测时间范围：10分钟（600秒）
- 最大失败次数：5次
- 忽略的 IP：127.0.0.1/8

### 安装方法
```bash
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-fail2ban.yml
```

### 常用命令
```bash
# 查看 fail2ban 状态
sudo systemctl status fail2ban

# 查看被封禁的 IP
sudo fail2ban-client status sshd
sudo fail2ban-client status nginx-http-auth

# 手动解封 IP
sudo fail2ban-client set sshd unbanip IP地址
```

## Certbot

Certbot 是一个自动化工具，用于获取和更新 Let's Encrypt SSL 证书。

### 功能特点
- 自动申请 SSL 证书
- 自动配置 Nginx
- 支持多域名
- 自动更新证书

### 安装方法
```bash
# 基本安装（不申请证书）
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-certbot.yml

# 安装并申请证书
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-certbot.yml \
  -e "namespace=your-namespace" \
  -e "certbot_email=your@email.com" \
  -e "certbot_domains=['domain1.com','domain2.com']"
```

### 参数说明
- `namespace`: Nginx 所在的命名空间（默认：magento-shared）
- `certbot_email`: 用于接收证书过期通知的邮箱
- `certbot_domains`: 需要申请证书的域名列表

### 常用命令
```bash
# 在 Nginx Pod 中执行以下命令

# 查看证书列表
certbot certificates

# 手动更新证书
certbot renew

# 添加新域名
certbot --nginx -d new-domain.com

# 删除证书
certbot delete --cert-name example.com
```

## 注意事项

1. fail2ban 安装在主机层面，而不是容器中
2. Certbot 安装在 Nginx 容器中
3. 建议定期检查日志，了解安全状况
4. 证书自动续期默认启用，无需手动操作 