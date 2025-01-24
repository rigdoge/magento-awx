# AWX Inventory 同步配置指南

## 1. 基础配置
### 1.1 创建 Inventory 文件
在你的 Git 仓库中创建 inventory 文件：
```yaml
# inventory/k3s-hosts.yml
all:
  children:
    k3s:
      hosts:
        k3s-master:
          ansible_host: 你的服务器IP
          ansible_user: ubuntu
          ansible_python_interpreter: /usr/bin/python3
      vars:
        ansible_connection: ssh
        ansible_become: yes
```

### 1.2 在 AWX 中配置
1. 进入 Inventory 设置
2. 点击 "编辑"
3. 修改以下设置：
   - Inventory Type: 选择 "Sourced from Project"
   - Project: 选择你的项目
   - Inventory File: 填写 `inventory/k3s-hosts.yml`
   - Update Options:
     - ✓ 覆盖
     - ✓ 项目更新时更新
     - ✓ 启动时更新

## 2. 同步选项
### 2.1 手动同步
1. 在 Inventory 详情页
2. 点击 "同步" 按钮
3. 查看同步日志

### 2.2 自动同步
配置以下触发条件：
1. 项目更新时
2. 定时任务
3. 通过 API 触发

## 3. 验证配置
### 3.1 检查主机
1. 同步后检查 "Hosts" 标签
2. 确认主机信息正确
3. 测试主机连接

### 3.2 检查变量
1. 查看 "Variables" 是否正确导入
2. 确认敏感信息是否正确处理
3. 验证变量优先级

## 4. 故障排除
### 4.1 同步失败
检查以下几点：
1. 项目访问权限
2. Inventory 文件格式
3. 文件路径是否正确
4. 查看详细错误日志

### 4.2 主机连接问题
验证以下配置：
1. SSH 凭据
2. 网络连接
3. Python 解释器
4. 权限设置

## 5. 最佳实践
1. 使用版本控制管理 inventory
2. 分环境管理 inventory 文件
3. 使用变量组织配置
4. 定期验证同步状态
5. 设置同步通知

## 6. 安全考虑
1. 避免在 inventory 中存储敏感信息
2. 使用 AWX 凭据管理敏感数据
3. 限制 inventory 访问权限
4. 审计同步历史 