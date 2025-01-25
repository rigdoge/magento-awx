# 安全工具安装指南

本文档介绍了项目中使用的安全工具的安装和配置方法。

## 安装架构

### fail2ban
- 安装位置：主机层面（服务器操作系统）
- 作用范围：整个服务器
- 配置要求：
  1. 需要在主机上安装
  2. 需要配置 Nginx 容器将日志输出到主机
  3. 一个服务器只需要安装一次
  4. 可以保护所有命名空间的 Nginx

### Certbot
- 安装位置：Nginx Pod 内部
- 作用范围：单个命名空间
- 配置要求：
  1. 每个需要 SSL 证书的命名空间都需要单独安装
  2. 只能配置安装它的那个命名空间中的 Nginx
  3. 如果有多个命名空间需要证书，需要多次运行安装脚本

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

1. fail2ban 安装在主机层面
   - 一个服务器只需要安装一次
   - 可以保护所有命名空间
   - 需要正确配置日志路径

2. Certbot 安装在 Nginx 容器中
   - 每个命名空间需要单独安装
   - 只能配置当前命名空间的 Nginx
   - 证书存储在容器中，需要持久化存储

3. 建议定期检查日志，了解安全状况

4. 证书自动续期默认启用，无需手动操作

## 多命名空间配置示例

### 为多个命名空间配置 SSL 证书
```bash
# 为 site1 命名空间配置
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-certbot.yml \
  -e "namespace=site1" \
  -e "certbot_email=admin@example.com" \
  -e "certbot_domains=['site1.com']"

# 为 site2 命名空间配置
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-certbot.yml \
  -e "namespace=site2" \
  -e "certbot_email=admin@example.com" \
  -e "certbot_domains=['site2.com']"
```

### fail2ban 保护多个命名空间
```bash
# 只需要在服务器上安装一次
ansible-playbook -i inventory/k3s-hosts.yml ansible/install/install-fail2ban.yml

# 然后配置每个命名空间的 Nginx 将日志输出到主机的指定位置
# 这部分配置已经包含在 Nginx 安装脚本中
``` 