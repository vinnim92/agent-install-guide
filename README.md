# AI Agent 小白安装包

不会配环境？下载 zip，双击或拖拽，把 Claude Code / Codex / OpenClaw 装进你的电脑。

---

## 当前主交付方式：本地脚本包

从 v3.2.0 开始，**小白用户的默认安装方式改为本地脚本包**：

**Windows：**
下载 Windows zip → 解压 → 打开 windows 文件夹 → 双击 install-xxx.cmd

**macOS / Linux：**
下载 macOS/Linux zip → 解压 → 打开终端 → 进入 mac-linux 文件夹 → bash install-xxx.sh

安装包已内置所有安装脚本，不需要从 GitHub Pages / jsDelivr 复制远程命令。

---

## 下载

访问 [Releases](https://github.com/vinnim92/agent-install-guide/releases) 页面，下载最新版本的安装包：

- `AI-Agent-Windows-vX.X.X.zip` — Windows 安装包（含 .cmd 启动器 + PDF 手册）
- `AI-Agent-macOS-Linux-vX.X.X.zip` — macOS/Linux 安装包（含 .sh 脚本 + PDF 手册）

---

## 适合谁

- 想用 AI 编程助手，但卡在安装环境的人
- 看不懂官方英文文档的人
- 不知道 Claude Code、Codex、OpenClaw 怎么装的人
- 不想折腾 Node、npm、终端配置的人
- 想快速体验 AI Agent 的小白用户

---

## 这个工具能帮你做什么

- 自动检测你的系统环境
- 自动检查基础依赖
- 自动安装对应 Agent
- 自动处理常见 npm 权限问题
- 自动给出启动命令
- 支持自动确认模式，一键安装到底
- 每个 Agent 独立安装，互不干扰

---

## 选择你要安装的 Agent

**Claude Code + DeepSeek API**
采用 DeepSeek API 优先方案，国内获取方便、价格便宜。由 Anthropic 出品，是目前综合能力最强的 AI 编程助手之一。

**Codex**
适合 ChatGPT 用户或 OpenAI API 用户。支持官方账号登录和 API Key 登录两种方式。由 OpenAI 出品，与 ChatGPT 生态深度打通。

**OpenClaw**
适合想尝试开源 Agent 工作流、希望有更多可玩性的用户。由微软开源，支持 75+ 模型提供商。推荐使用 DeepSeek API Key。

---

## 安装完成后

在终端或 PowerShell 输入对应命令启动：

| Agent | 启动命令 |
|-------|---------|
| Claude Code | `claude` |
| Codex | `codex` |
| OpenClaw | `openclaw` |

---

## 安装失败？

1. 关掉终端 → 重新打开 → 重试
2. 切换网络（手机热点）→ 重试
3. 重启电脑 → 重试

详细排查：[故障排查页面](https://vinnim92.github.io/agent-install-guide/troubleshooting.html)

---

## 高级备用：开发者在线安装入口

以下在线入口供开发者或自动化场景使用，小白用户请优先使用上方的本地安装包。

### macOS / Linux

```bash
# Claude Code
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash

# Codex
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/codex.sh | bash

# OpenClaw
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/openclaw.sh | bash
```

### Windows

```powershell
# Claude Code
irm https://vinnim92.github.io/agent-install-guide/i/claude.ps1 | iex

# Codex
irm https://vinnim92.github.io/agent-install-guide/i/codex.ps1 | iex

# OpenClaw
irm https://vinnim92.github.io/agent-install-guide/i/openclaw.ps1 | iex
```

在线入口通过 jsDelivr CDN 分发，支持 GITEE_ACCOUNT 环境变量配置国内镜像（参见 `GITEE_MIRROR.md`）。

---

## 安全说明

- 每个脚本只安装一个 Agent，不会多装其他东西
- 涉及环境修改（如安装 Node.js、修改 PATH）时会提示确认
- 所有脚本在 GitHub 开源，代码随时可查看
- 支持 `AGENT_INSTALL_YES=1` 跳过确认，适合信任脚本后批量部署

---

## GitHub 仓库定位

本仓库当前定位：**开发仓库 + 云端更新库**。

小白用户直接下载 Release 中的本地安装包即可，不需要 clone 本仓库或访问 GitHub Pages。
