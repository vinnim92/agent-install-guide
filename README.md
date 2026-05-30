# AI Agent 小白一键安装包

不会配环境？复制一行命令，把 Claude Code / Codex / OpenClaw 装进你的电脑。

---

## 你只需要复制粘贴

你不需要研究英文文档。
你不需要手动配置 Node、npm、PATH。
你不需要在各种教程之间来回跳转。

你只需要选择自己的系统和想安装的 Agent，复制对应命令，跟着提示完成安装。

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
- 支持 dry-run 预演，先看它会做什么再执行
- 每个 Agent 独立安装，互不干扰

---

## 选择你要安装的 Agent

**Claude Code**
适合想要稳定、成熟、强代码能力体验的用户。由 Anthropic 出品，是目前综合能力最强的 AI 编程助手之一。

**Codex**
适合 ChatGPT 用户，尤其是想把 OpenAI 能力接入本地开发流程的人。由 OpenAI 出品，与 ChatGPT 生态深度打通。

**OpenClaw**
适合想尝试开源 Agent 工作流、希望有更多可玩性的用户。由微软开源，内置免费模型，支持 75+ 模型提供商。

---

## 快速开始

### macOS / Linux

打开终端，复制你要装的 Agent 对应的命令，回车：

**Claude Code：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-claude-code.sh | bash
```

**Codex：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.sh | bash
```

**OpenClaw：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-openclaw.sh | bash
```

### Windows

按 `⊞ + R`，输入 `powershell`，回车。粘贴你要装的 Agent 对应的命令：

**Claude Code：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-claude-code.ps1 | iex
```

**Codex：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.ps1 | iex
```

**OpenClaw：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-openclaw.ps1 | iex
```

---

## 小白推荐流程

**第一步：** 先选 Agent
**第二步：** 复制对应命令
**第三步：** 按提示确认，等待安装完成

安装完成后，在终端或 PowerShell 输入对应命令启动：

| Agent | 启动命令 |
|-------|---------|
| Claude Code | `claude` |
| Codex | `codex` |
| OpenClaw | `openclaw` |

---

## 不敢直接安装？先预演

这个功能让你先看一遍安装脚本要做什么，不会改动你的电脑任何东西。

### macOS / Linux

在命令后面加 `--dry-run`：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.sh | bash -s -- --dry-run
```

### Windows

先将脚本下载到本地，再以 dry-run 模式执行：

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.ps1 -OutFile install-codex.ps1
.\install-codex.ps1 -DryRun
```

把 `install-codex` 换成你想要的 Agent 名即可。

---

## 想更省事？开启自动确认模式

默认情况下，涉及系统环境修改的步骤会询问你确认。如果你不想一次次手动确认，可以把这行加到命令前面：

### macOS / Linux

```bash
AGENT_INSTALL_YES=1 bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.sh)"
```

### Windows

打开 PowerShell，先设置环境变量，再运行脚本：

```powershell
$env:AGENT_INSTALL_YES = "1"
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-codex.ps1 | iex
```

---

## 为什么这个安装包更适合小白

- 每个 Agent 独立脚本，不会装一堆不需要的东西
- 安装前有提示，安装后有启动命令，不会装完了不知道怎么用
- 脚本自包含，只需要复制一条命令，不需要下载整个仓库
- 通过 jsDelivr CDN 分发，国内访问更顺畅
- 支持 dry-run，先看流程再执行
- 出错时给中文提示，不再对着英文报错发懵

---

## 常见问题

**Q：我需要先安装 GitHub 吗？**
A：不需要。复制命令即可，不需要任何准备工作。

**Q：我需要先下载这个仓库吗？**
A：不需要。脚本会从云端加载，你只复制那一条命令就够了。

**Q：可以同时安装多个 Agent 吗？**
A：可以，但建议分开安装。每个 Agent 设计为独立安装，逐个来更清楚、更稳定。

**Q：安装后怎么启动？**
A：在终端输入 `claude`、`codex` 或 `openclaw` 即可。安装完成的最后一行也会提示你。

**Q：我需要账号吗？**
A：Claude Code、Codex 和 OpenClaw 的实际使用需要你准备对应账号、订阅或 API Key。安装包负责安装和引导，不负责账号注册。

**Q：国内网络能用吗？**
A：安装脚本通过 jsDelivr CDN 分发，对国内用户友好。具体 Agent 的登录和模型访问取决于对应服务本身的网络情况。

**Q：安装失败怎么办？**
A：先运行 dry-run 查看预演提示；也可以截图报错信息进行排查。

**Q：可以重复运行吗？**
A：可以。脚本会检测已安装的内容，不会重复安装。也可以用来更新到最新版。

---

## 安全说明

- 每个脚本只安装一个 Agent，不会多装其他东西
- 脚本支持 dry-run 预演，安装前可以先看清楚每一步
- 涉及环境修改（如安装 Node.js、修改 PATH）时会提示你确认
- 所有脚本在 GitHub 开源，代码随时可查看
- 可以通过 `AGENT_INSTALL_YES=1` 跳过确认，适合信任脚本后批量部署

---

选一个你想体验的 AI Agent，复制命令，开始你的第一步。

别再卡在安装环境上，把时间留给真正使用 AI。
