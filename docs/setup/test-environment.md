# AWX 测试环境准备清单

## 1. 环境要求
- Ubuntu 24.04 LTS
- 最小配置要求：
  - CPU: 4 cores
  - 内存: 8GB RAM
  - 存储: 40GB
  - 网络: 可访问外网

## 2. 前置软件
- [ ] Git
- [ ] curl 或 wget
- [ ] kubectl
- [ ] K3s
- [ ] helm (可选)

## 3. 安装验证步骤

### 3.1 Git 安装验证
```bash
git --version
```
预期输出：显示 Git 版本号

### 3.2 K3s 集群验证
```bash
# 检查节点状态
kubectl get nodes

# 检查系统 Pod 状态
kubectl get pods -A
```

### 3.3 AWX Operator 验证
```bash
# 检查 AWX 命名空间
kubectl get ns | grep awx

# 检查 AWX Operator Pod
kubectl -n awx get pods | grep operator

# 检查 AWX 实例状态
kubectl -n awx get awx
```

## 4. 网络端口要求
- 22/TCP: SSH 访问
- 6443/TCP: Kubernetes API
- 80/TCP: HTTP 访问
- 443/TCP: HTTPS 访问
- 30000-32767/TCP: NodePort 服务（如果使用）

## 5. 存储准备
- [ ] 确认存储类可用
- [ ] 验证 PV/PVC 创建权限
- [ ] 检查默认存储类

## 6. 安全配置
- [ ] 防火墙规则配置
- [ ] SELinux/AppArmor 配置（如果启用）
- [ ] 证书准备（如果需要 HTTPS）

## 7. 备份准备
- [ ] 确定备份策略
- [ ] 准备备份存储位置
- [ ] 测试备份/恢复流程

## 8. 监控准备
- [ ] 配置日志收集
- [ ] 设置资源监控
- [ ] 配置告警规则 