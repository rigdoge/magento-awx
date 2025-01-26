# AWX 手动还原操作指南

本文档介绍如何使用 k3s kubectl 命令手动还原 AWX 配置。

## 前置条件

1. 确保有可用的备份文件
2. 确保有足够的权限执行 k3s kubectl 命令
3. 建议在执行还原前先备份当前配置

## 操作步骤

### 1. 查看可用备份

```bash
# 列出所有备份文件
ls -l /backup/awx/*.tar.gz

# 示例输出:
# -rw-r--r-- 1 root root 1234567 Jan 26 14:30 /backup/awx/20240126143022.tar.gz
```

### 2. 准备还原环境

```bash
# 创建临时目录
mkdir -p /tmp/awx-restore

# 解压备份文件 (替换为实际的时间戳)
cd /tmp/awx-restore && tar xzf /backup/awx/20240126143022.tar.gz

# 进入备份目录
cd /tmp/awx-restore/20240126143022
```

### 3. 停止 AWX 服务

```bash
# 获取 deployment 名称
WEB_DEPLOYMENT=$(grep "kind: Deployment" -A 1 resources.yaml | grep "name:" | head -n 1 | awk '{print $2}')
TASK_DEPLOYMENT=$(grep "kind: Deployment" -A 1 resources.yaml | grep "name:" | tail -n 1 | awk '{print $2}')

# 显示找到的 deployment 名称
echo "Web Deployment: $WEB_DEPLOYMENT"
echo "Task Deployment: $TASK_DEPLOYMENT"

# 停止服务
k3s kubectl scale deployment -n awx $WEB_DEPLOYMENT --replicas=0
k3s kubectl scale deployment -n awx $TASK_DEPLOYMENT --replicas=0

# 等待 Pod 停止
k3s kubectl wait --for=delete pod -l app=awx-web -n awx --timeout=60s
k3s kubectl wait --for=delete pod -l app=awx-task -n awx --timeout=60s
```

### 4. 还原资源

按照以下顺序还原各种资源：

```bash
# 1. 还原 AWX CR
echo "还原 AWX CR..."
k3s kubectl apply -f awx-cr.yaml

# 2. 还原 Secrets
echo "还原 Secrets..."
k3s kubectl apply -f secrets.yaml

# 3. 还原 ConfigMaps
echo "还原 ConfigMaps..."
k3s kubectl apply -f configmaps.yaml

# 4. 还原 PVCs
echo "还原 PVCs..."
k3s kubectl apply -f pvcs.yaml

# 5. 还原其他资源
echo "还原其他资源..."
k3s kubectl apply -f resources.yaml
```

### 5. 启动 AWX 服务

```bash
# 启动服务
k3s kubectl scale deployment -n awx $WEB_DEPLOYMENT --replicas=1
k3s kubectl scale deployment -n awx $TASK_DEPLOYMENT --replicas=1

# 等待 Pod 就绪
k3s kubectl wait --for=condition=ready pod -l app=awx-web -n awx --timeout=300s
k3s kubectl wait --for=condition=ready pod -l app=awx-task -n awx --timeout=300s
```

### 6. 清理临时文件

```bash
# 清理
rm -rf /tmp/awx-restore
```

## 验证还原结果

1. 检查 Pod 状态：
```bash
k3s kubectl get pods -n awx
```

2. 检查服务状态：
```bash
k3s kubectl get deployment -n awx
```

3. 访问 AWX Web 界面验证功能是否正常

## 故障排除

1. 如果 Pod 无法启动：
```bash
# 查看 Pod 详细信息
k3s kubectl describe pod <pod-name> -n awx

# 查看 Pod 日志
k3s kubectl logs <pod-name> -n awx
```

2. 如果资源还原失败：
```bash
# 检查资源状态
k3s kubectl get all -n awx

# 查看事件
k3s kubectl get events -n awx
```

## 注意事项

1. 还原过程会暂时中断 AWX 服务，请在维护时间执行
2. 建议在还原前备份当前配置
3. 确保备份文件完整且可用
4. 按照文档指定的顺序还原资源
5. 如果还原失败，可以查看相应的错误信息进行排查

## 回滚方案

如果还原后出现问题，可以：

1. 使用还原前的备份重新执行还原过程
2. 或者使用 `kubectl delete` 删除有问题的资源，然后重新应用配置 