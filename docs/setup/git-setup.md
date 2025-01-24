# Ubuntu 服务器 Git 配置指南

## 1. Git 安装
```bash
# 更新包索引
sudo apt update

# 安装 Git
sudo apt install git -y

# 验证安装
git --version
```

## 2. Git 基础配置
```bash
# 配置用户名和邮箱
git config --global user.name "你的名字"
git config --global user.email "你的邮箱"

# 配置默认分支名
git config --global init.defaultBranch main

# 配置默认编辑器（如果需要）
git config --global core.editor vim

# 查看配置
git config --list
```

## 3. SSH 密钥配置
```bash
# 生成 SSH 密钥
ssh-keygen -t ed25519 -C "你的邮箱"

# 查看公钥
cat ~/.ssh/id_ed25519.pub

# 将公钥添加到 GitHub/GitLab
# 复制上面命令的输出，添加到 Git 平台的 SSH Keys 设置中
```

## 4. 仓库初始化
```bash
# 创建项目目录（如果还没有）
mkdir -p /path/to/your/project
cd /path/to/your/project

# 初始化 Git 仓库
git init

# 添加 .gitignore
cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg

# Kubernetes
kubeconfig
*.kubeconfig
.kube/

# AWX
*.key
*.crt
*.pem
credentials.yml
passwords.yml

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
.env
.venv
EOF

# 初始提交
git add .
git commit -m "Initial commit"
```

## 5. 远程仓库配置
```bash
# 添加远程仓库
git remote add origin <repository-url>

# 推送到远程仓库
git push -u origin main
```

## 6. 分支策略
### 主要分支
- `main`: 主分支，保持稳定可部署状态
- `develop`: 开发分支，用于集成功能

### 辅助分支
- `feature/*`: 新功能开发
- `hotfix/*`: 紧急修复
- `release/*`: 版本发布准备

## 7. 工作流程
1. 从 main 分支创建新特性分支
```bash
git checkout main
git pull
git checkout -b feature/new-feature
```

2. 开发和提交
```bash
git add .
git commit -m "描述性的提交信息"
```

3. 推送到远程
```bash
git push origin feature/new-feature
```

4. 合并回主分支
```bash
git checkout main
git pull
git merge feature/new-feature
git push origin main
```

## 8. 提交规范
- feat: 新功能
- fix: 修复问题
- docs: 文档变更
- style: 代码格式调整
- refactor: 代码重构
- test: 测试用例
- chore: 其他修改

示例：
```bash
git commit -m "feat: 添加 AWX 自动部署脚本"
git commit -m "fix: 修复 K3s 配置问题"
```

## 9. 安全注意事项
- 不要提交敏感信息（密码、密钥等）
- 使用 .gitignore 排除敏感文件
- 定期更新 SSH 密钥
- 及时更新 Git 版本 