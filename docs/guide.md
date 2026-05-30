# AI Agent 小白安装教程

> 选系统、选 Agent、复制命令、完成安装、启动使用。全程 5 分钟。

---

## 你能用这个教程做什么

这个教程会手把手带你：

1. 选择你的操作系统（macOS/Linux 或 Windows）
2. 从三个 AI Agent 中选一个你想要的
3. 复制对应安装命令
4. 等待自动安装完成
5. 输入一条命令启动你的 AI Agent

全程不需要懂技术。会复制粘贴就能搞定。

---

## 第一步：选择你的系统

找到你电脑对应的操作方式：

| 你的系统 | 打开哪个 |
|---------|---------|
| Mac | 点右上角 🔍 搜索「终端」，打开 |
| Linux | 打开系统自带的「终端」 |
| Windows | 按 `⊞ + R`，输入 `powershell`，回车 |

---

## 第二步：选择你要安装的 Agent

| Agent | 适合谁 | 一句话 |
|-------|-------|--------|
| **Claude Code** | 追求稳定、成熟代码体验的用户 | Anthropic 出品，综合能力最强的 AI 编程助手之一 |
| **Codex** | ChatGPT 用户 | OpenAI 出品，与 ChatGPT 生态深度打通 |
| **OpenClaw** | 想尝试开源工作流的用户 | 微软开源，推荐 DeepSeek API Key，支持 75+ 模型提供商 |

不确定选哪个？建议从 Claude Code 开始体验。

---

## 第三步：复制命令安装

### macOS / Linux

打开终端，复制你要装的 Agent 对应的命令，回车：

**安装 Claude Code：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-claude-code.sh | bash
```

**安装 Codex：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.sh | bash
```

**安装 OpenClaw：**

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.sh | bash
```

### Windows

按 `⊞ + R`，输入 `powershell`，回车。粘贴你要装的 Agent 对应的命令：

**安装 Claude Code：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-claude-code.ps1 | iex
```

**安装 Codex：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.ps1 | iex
```

**安装 OpenClaw：**

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.ps1 | iex
```

脚本会自动检测系统、安装依赖、完成配置。看到 `✅` 就是装好了。

---

## 第四步：启动 Agent

安装完成后，在终端或 PowerShell 中输入对应命令启动：

| Agent | 启动命令 |
|-------|---------|
| Claude Code | `claude` |
| Codex | `codex` |
| OpenClaw | `openclaw` |

第一次启动可能会弹出浏览器让你登录账号。登录后回到终端，就可以和 AI 对话了。

---

## 不敢直接安装？先预演

dry-run 模式让你先看一遍安装脚本要做什么，不会改动你的电脑任何东西。

### macOS / Linux

在命令后面加 `--dry-run`：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.sh | bash -s -- --dry-run
```

把 `install-codex` 换成其他 Agent 名即可。

### Windows

先将脚本下载到本地，再以 dry-run 模式执行：

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.ps1 -OutFile install-codex.ps1
.\install-codex.ps1 -DryRun
```

---

## 想一路自动确认？

在命令前加上 `AGENT_INSTALL_YES=1`，脚本会自动确认所有提示：

### macOS / Linux

```bash
AGENT_INSTALL_YES=1 bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.sh)"
```

### Windows

```powershell
$env:AGENT_INSTALL_YES = "1"
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.ps1 | iex
```

---

## 常见问题

**Q：我需要懂 GitHub 吗？**
A：不需要。复制命令即可，完全不需要懂任何技术。

**Q：我需要先下载这个仓库吗？**
A：不需要。脚本从云端加载，只用复制那一条命令。

**Q：为什么一次只装一个 Agent？**
A：每个 Agent 独立安装，更清楚、更稳定。装完一个想再装另一个，再复制对应的命令就行。

**Q：安装后怎么启动？**
A：终端输入 `claude`、`codex` 或 `openclaw`。安装完成时最后一行也会提示你。

**Q：安装失败怎么办？**
A：先运行 dry-run 查看预演；也可以截图报错信息。排查文档见 [常见问题排查](troubleshooting.md)。

**Q：需要账号吗？**
A：Claude Code、Codex、OpenClaw 的实际使用需要你准备对应账号、订阅或 API Key。安装包负责安装和引导。

**Q：国内网络能用吗？**
A：安装脚本通过 jsDelivr CDN 分发，对国内用户友好。Agent 登录和模型访问取决于对应服务本身。

**Q：可以重复运行脚本吗？**
A：可以。脚本会检测已安装的内容，不会重复安装。也可以用来升级到最新版。

---

## 看到什么才算成功？

- 终端最后显示 `✅ 安装验证通过` 或类似成功提示
- 输入 `claude`、`codex` 或 `openclaw` 有响应
- 能进入对应 Agent 的交互界面

看到这些，就说明你装好了。开始用 AI 吧。

---

> 📖 每个 Agent 还有独立的详细教程：[Claude Code](agents/claude-code.md) · [Codex](agents/codex.md) · [OpenClaw](agents/openclaw.md)
