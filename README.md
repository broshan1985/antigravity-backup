# Antigravity 备份与换机迁移指南

本项目用于将 Google Antigravity 的 **项目配置、MCP 服务设置、历史对话记录与产物（Artifacts）** 完整备份至 GitHub 私有仓库，实现换电脑后的一键恢复。

> ⚠️ 注意：各项目具体的工作区代码（如 `DevOPS-Tools`）由于本身已关联各自独立的 Git 仓库，因此**不**包含在此备份中。

---

## 包含的备份内容

1. **项目定义与偏好**：
   - `projects/`：Antigravity 界面左侧的项目配置与工作区路径绑定。
   - `config.json`：全局权限模式（TURBO）、主题与执行策略。
   - `mcp_config.json`：已配置的 MCP 服务器（GitHub MCP、Playwright 等）。
2. **对话历史与产物**：
   - `conversation_summaries.db`：对话索引数据库。
   - `conversations/`：所有历史会话数据。
   - `brain/`：会话的深度思考、日志与生成的文档产物。

---

## 使用方法

### 1. 日常/换机前：一键备份

在终端中运行：
```bash
cd ~/antigravity-backup
./backup.sh
```
该脚本会自动同步最新数据并 `git push` 到你的 GitHub 私有仓库。

---

### 2. 换新电脑后：一键恢复

在新 Mac 上安装 Antigravity 后，打开终端执行：

```bash
# 1. 克隆备份仓库
git clone git@github.com:broshan1985/antigravity-backup.git ~/antigravity-backup

# 2. 执行恢复
cd ~/antigravity-backup
./restore.sh
```

恢复完成后，启动 Antigravity，所有的项目、历史记录和 MCP 工具将完全复原！
