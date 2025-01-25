#!/bin/bash

# 设置 Git 配置
git config --global user.name "rigdoge"
git config --global user.email "rigdoge@users.noreply.github.com"

# 添加所有更改
git add .

# 获取提交信息
commit_message=${1:-"更新 AWX 配置"}

# 提交更改
git commit -m "$commit_message"

# 推送到 GitHub
git push origin main

echo "代码已成功推送到 GitHub" 