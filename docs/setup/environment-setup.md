# 环境配置说明

## 本地开发环境 (Mac)
### 系统信息
- 操作系统：darwin 24.1.0
- Shell：/bin/zsh
- Git 版本：2.48.1

### 必要工具
- [ ] kubectl（用于远程管理 K3s 集群）
- [ ] SSH 密钥配置
- [ ] VS Code 或其他 IDE
- [ ] 远程开发扩展

### 配置文件
```bash
# ~/.kube/config 配置（用于远程访问 K3s）
# 需要从远程服务器复制
```

## 远程服务器环境 (Ubuntu 24.04)
### 系统要求
- CPU: 4 cores
- 内存: 8GB RAM
- 存储: 40GB
- 网络: 可访问外网

### 已安装组件
1. K3s
   - [ ] 验证安装版本
   - [ ] 检查配置文件位置
   - [ ] 确认服务状态

2. AWX Operator
   - [ ] 验证安装状态
   - [ ] 检查 Pod 运行情况
   - [ ] 确认版本信息

### 远程访问配置
```bash
# SSH 配置示例（添加到 ~/.ssh/config）
Host awx-server
    HostName <服务器IP>
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    Port 22
```

## 环境连接验证
```bash
# 1. SSH 连接测试
ssh awx-server

# 2. K3s 集群访问测试
kubectl get nodes

# 3. AWX 访问测试
curl http://<服务器IP>:80  # 或配置的其他端口
```

## 开发工作流程
1. 本地开发
   - 代码编写和测试
   - Git 版本控制
   - 文档更新

2. 远程部署
   - 通过 kubectl 部署到 K3s
   - 通过 AWX API 进行配置
   - 监控部署状态

3. 验证和测试
   - 功能验证
   - 性能测试
   - 日志检查

## 安全注意事项
- [ ] 确保 SSH 密钥安全
- [ ] K3s 配置文件权限设置
- [ ] AWX 访问凭证管理
- [ ] 网络访问控制

## 备份策略
- [ ] K3s 配置备份
- [ ] AWX 数据备份
- [ ] 证书备份（如果有）
- [ ] 定期备份计划 