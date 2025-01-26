# Varnish 安装配置指南

## 1. 基本信息
- 版本：Varnish 7.5
- 部署方式：Kubernetes Pod
- 默认端口：
  - K8s NodePort：30180
  - 标准安装：
    - HTTP 端口：6081
    - 管理端口：6082
- 推荐内存配置：
  - 小型站点（<5000 SKU）：2GB
  - 中型站点（5000-50000 SKU）：4GB
  - 大型站点（>50000 SKU）：8GB 或更多
  - 注意：实际内存需求取决于产品数量、页面大小和并发访问量

## 2. 安装方法

### 2.1 基本安装
使用默认配置安装：
```bash
ansible-playbook ansible/install/install-varnish.yml
```

### 2.2 自定义安装
使用自定义参数安装：
```bash
ansible-playbook ansible/install/install-varnish.yml -e "namespace=magento nodeport=30182 backend=nginx backend_port=80 memory=2G"
```

### 2.3 可配置参数
| 参数 | 说明 | 默认值 | 示例 |
|------|------|--------|------|
| namespace | 部署的命名空间 | default | magento |
| nodeport | 服务端口 | 30180 | 30182 |
| backend | 后端服务名称 | nginx | web-server |
| backend_port | 后端服务端口 | 80 | 8080 |
| memory | Varnish 内存大小 | 1G | 2G |

## 3. 配置说明

### 3.1 VCL 配置
默认 VCL 配置包含：
- 健康检查 (/health_check.php)
- 静态资源缓存规则
- Cookie 处理规则
- 缓存时间设置

### 3.2 缓存策略
- CSS/JS 文件：缓存 24 小时
- 图片文件：缓存 48 小时
- 其他内容：缓存 1 小时

### 3.3 健康检查配置
```vcl
.probe = {
    .url = "/health_check.php";
    .timeout = 2s;
    .interval = 5s;
    .window = 10;
    .threshold = 5;
}
```

## 4. 验证部署

### 4.1 检查 Pod 状态
```bash
kubectl get pods -n <namespace> -l app=varnish
```

### 4.2 检查服务状态
```bash
kubectl get svc -n <namespace> -l app=varnish
```

### 4.3 验证缓存
```bash
# 检查缓存状态
curl -I http://<node-ip>:<nodeport>/

# 查看缓存命中信息
# X-Cache: HIT/MISS
# X-Cache-Hits: 数字
```

## 5. 故障排除

### 5.1 Pod 无法启动
检查以下内容：
1. 资源配额是否充足
2. ConfigMap 是否正确创建
3. 查看 Pod 日志：
```bash
kubectl logs -n <namespace> -l app=varnish
```

### 5.2 缓存未生效
检查以下内容：
1. VCL 配置是否正确加载
2. 后端服务是否可访问
3. 请求头中是否包含不缓存标记

### 5.3 常见问题
1. 内存不足
   - 症状：Pod 频繁重启
   - 解决：增加 memory 参数值

2. 后端连接失败
   - 症状：健康检查失败
   - 解决：确认 backend_host 和 backend_port 配置

3. 端口冲突
   - 症状：Service 创建失败
   - 解决：更换 nodeport 值

## 6. 维护操作

### 6.1 清理缓存
```bash
kubectl exec -n <namespace> <varnish-pod> -- varnishadm "ban req.url ~ ."
```

### 6.2 查看缓存统计
```bash
kubectl exec -n <namespace> <varnish-pod> -- varnishstat
```

### 6.3 更新配置
1. 修改 ConfigMap
2. 重启 Pod 使配置生效

## 7. 最佳实践
1. Magento 环境内存配置：
   - 最小配置：2GB（开发环境）
   - 建议配置：4GB（生产环境）
   - 大型站点：8GB 或更多
   - 监控内存使用率，适时调整
2. 为不同环境使用不同的命名空间
3. 定期监控缓存命中率
4. 根据业务需求调整缓存策略 