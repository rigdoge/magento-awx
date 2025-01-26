# Varnish 安装和配置指南

本文档介绍如何在 K3s 环境中安装和配置 Varnish 缓存服务器。安装过程分为两个步骤：基础环境安装和站点配置。

## 1. 基础环境安装

首先需要安装 Varnish 的基础环境。这一步会创建 Varnish 的基本 Kubernetes 资源，包括 Deployment、Service 和 ConfigMap。

### 1.1 安装命令

```bash
ansible-playbook ansible/install/install-varnish-base.yml -e "namespace=magento memory=4G nodeport=30180"
```

### 1.2 参数说明

- `namespace`: Kubernetes 命名空间（默认：default）
- `memory`: Varnish 使用的内存大小（默认：1G）
- `nodeport`: 服务暴露的节点端口（默认：30180）

### 1.3 安装内容

- Varnish 7.5 容器
- NodePort 类型的 Service
- 基础 VCL 配置的 ConfigMap

## 2. 站点配置

安装完基础环境后，可以为特定的站点配置 Varnish 缓存规则。

### 2.1 配置命令

```bash
ansible-playbook ansible/install/configure-varnish-site.yml \
  -e "namespace=magento" \
  -e "site_name=site1" \
  -e "backend=site1-nginx" \
  -e "backend_port=80"
```

### 2.2 参数说明

- `namespace`: Kubernetes 命名空间（默认：default）
- `site_name`: 站点名称（**必需参数**）
- `backend`: 后端服务名称（默认：nginx）
- `backend_port`: 后端服务端口（默认：80）

### 2.3 配置内容

- 更新 VCL 配置
- 设置后端服务
- 配置缓存规则
- 自动重启 Pod 以应用新配置

## 3. 使用示例

### 3.1 安装基础环境

```bash
# 在 magento 命名空间中安装 Varnish，分配 4GB 内存
ansible-playbook ansible/install/install-varnish-base.yml \
  -e "namespace=magento" \
  -e "memory=4G"
```

### 3.2 配置多个站点

```bash
# 配置第一个站点
ansible-playbook ansible/install/configure-varnish-site.yml \
  -e "namespace=magento" \
  -e "site_name=site1" \
  -e "backend=site1-nginx" \
  -e "backend_port=80"

# 配置第二个站点
ansible-playbook ansible/install/configure-varnish-site.yml \
  -e "namespace=magento" \
  -e "site_name=site2" \
  -e "backend=site2-nginx" \
  -e "backend_port=80"
```

## 4. 缓存规则说明

默认的 VCL 配置包含以下规则：

### 4.1 不缓存的情况

- POST 请求
- 带有认证信息的请求
- 非 GET/HEAD 请求

### 4.2 缓存时间设置

- CSS/JS 文件：24 小时
- 图片文件：48 小时
- 其他内容：1 小时

### 4.3 Cookie 处理

- 静态资源请求（CSS/JS/图片等）会移除 Cookie
- 其他请求保留 Cookie

## 5. 监控和维护

### 5.1 查看 Pod 状态

```bash
kubectl get pods -n <namespace> -l app=varnish
```

### 5.2 查看日志

```bash
kubectl logs -n <namespace> -l app=varnish
```

### 5.3 重启 Varnish

```bash
kubectl rollout restart deployment varnish -n <namespace>
```

### 5.4 查看配置

```bash
kubectl get configmap varnish-config -n <namespace> -o yaml
```

## 6. 注意事项

1. 确保有足够的内存资源
2. 建议在生产环境使用至少 4GB 内存
3. 配置新站点时会重启 Varnish Pod
4. 重启过程中可能会有短暂的服务中断
5. 建议在低峰期进行配置更改

## 7. 故障排除

### 7.1 Pod 无法启动

检查事项：
- 内存资源是否足够
- ConfigMap 是否正确创建
- 后端服务是否可访问

### 7.2 缓存未生效

检查事项：
- VCL 配置是否正确应用
- 请求是否符合缓存规则
- 后端服务响应头是否正确

### 7.3 性能问题

优化建议：
- 适当增加内存配置
- 调整缓存时间
- 优化后端服务响应时间 