# AWX Webhook 配置指南

## 1. 在 AWX 中获取 Webhook 密钥
1. 进入 AWX 管理界面
2. 导航到 "设置" -> "作业设置"
3. 找到 "WEBHOOK SECRET KEY" 部分
4. 如果没有密钥，点击生成新密钥

## 2. 在 GitHub 中配置 Webhook
1. 访问你的 GitHub 仓库
2. 点击 "Settings" -> "Webhooks" -> "Add webhook"
3. 配置以下信息：
   - Payload URL: `https://你的AWX域名/api/v2/projects/N/update/`
     (将 N 替换为你的项目 ID，可以在项目 URL 中找到)
   - Content type: `application/json`
   - Secret: 填入 AWX 中的 Webhook 密钥
   - 选择触发事件：
     - 选择 "Just the push event"
     - 勾选 "Active"

## 3. 测试配置
1. 在 GitHub 仓库中进行一次提交和推送
2. 检查 AWX 中的项目是否自动更新
3. 查看 GitHub Webhook 的发送记录
4. 检查 AWX 的项目更新日志

## 4. 故障排除
如果自动更新没有触发，请检查：
1. Webhook URL 是否正确
2. 密钥是否匹配
3. AWX 服务器是否可以从 GitHub 访问
4. 查看 AWX 的日志是否有错误信息

## 5. 安全建议
1. 使用 HTTPS 进行 Webhook 通信
2. 定期轮换 Webhook 密钥
3. 限制 IP 访问（如果可能）
4. 监控 Webhook 事件日志

## 6. 自动化工作流
配置完 Webhook 后，工作流程如下：
1. 开发者推送代码到 GitHub
2. GitHub 发送 Webhook 到 AWX
3. AWX 自动更新项目
4. 如果配置了作业模板的 "启动时更新修订"，相关作业也会自动运行

## 7. 最佳实践
1. 在测试环境验证 Webhook 配置
2. 设置通知，当项目更新失败时发送警报
3. 定期检查 Webhook 的健康状态
4. 记录所有自动更新的审计日志 