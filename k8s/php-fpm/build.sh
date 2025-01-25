#!/bin/bash

# 设置镜像名称和标签
IMAGE_NAME="magento-php-fpm"
IMAGE_TAG="8.3"

# 构建镜像
echo "=== 开始构建 PHP-FPM 镜像 ==="
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# 标记镜像
echo "=== 标记镜像 ==="
docker tag ${IMAGE_NAME}:${IMAGE_TAG} localhost:5000/${IMAGE_NAME}:${IMAGE_TAG}

# 推送到本地仓库
echo "=== 推送镜像到本地仓库 ==="
docker push localhost:5000/${IMAGE_NAME}:${IMAGE_TAG}

echo "=== 构建完成 ==="
echo "镜像地址: localhost:5000/${IMAGE_NAME}:${IMAGE_TAG}" 