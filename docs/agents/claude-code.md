# Claude Code + DeepSeek API 小白安装教程

> Anthropic 出品 · DeepSeek API 优先 · 一条命令安装

---

## 适合谁

Claude Code 适合想要稳定、成熟、强代码能力体验的用户。本教程默认采用 **DeepSeek API** 方案——国内获取方便、价格便宜、无需翻墙。

如果你已有 Claude 官方账号，也可以使用官方登录方式（见 FAQ）。

---

## 安装前你需要知道什么

- 会复制粘贴就够了
- 不需要手动安装 Node.js（Claude Code 自带运行环境）
- 准备一个 DeepSeek API Key（去 platform.deepseek.com 注册获取）
- 全程 3-5 分钟

---

## macOS / Linux 安装

打开终端（Mac 右上角 🔍 搜索「终端」），粘贴下面这行，回车：

```bash
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash
```

屏幕上会滚动文字——这是脚本在自动工作。看到 `✅` 就是装好了。

安装完成后，脚本会询问你是否配置 DeepSeek API。输入 `y` 并粘贴你的 API Key 即可。

---

## Windows 安装

按 `⊞ + R`，输入 `powershell`，回车。粘贴下面这行，回车：

```powershell
irm https://vinnim92.github.io/agent-install-guide/i/claude.ps1 | iex
```

---

## dry-run 预演

先看脚本会做什么，再决定是否安装：

### macOS / Linux

```bash
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash -s -- --dry-run
```

### Windows

```powershell
irm https://vinnim92.github.io/agent-install-guide/i/claude.ps1 -OutFile claude.ps1
.\claude.ps1 -DryRun
```

---

## 安装后配置 DeepSeek API

安装完成后，脚本会自动引导你配置 DeepSeek API。你也可以稍后手动配置：

### macOS / Linux（在终端中运行）

```bash
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=<你的 DeepSeek API Key>
export ANTHROPIC_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_OPUS_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_SONNET_MODEL=deepseek-v4-pro
export ANTHROPIC_DEFAULT_HAIKU_MODEL=deepseek-v4-flash
export CLAUDE_CODE_SUBAGENT_MODEL=deepseek-v4-flash
export CLAUDE_CODE_EFFORT_LEVEL=max
```

### Windows（在 PowerShell 中运行）

```powershell
$env:ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
$env:ANTHROPIC_AUTH_TOKEN="<你的 DeepSeek API Key>"
$env:ANTHROPIC_MODEL="deepseek-v4-pro"
$env:ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"
$env:ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"
$env:ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
$env:CLAUDE_CODE_EFFORT_LEVEL="max"
```

---

## 启动

打开终端，输入：

```
claude
```

如果已配置 DeepSeek API，Claude Code 将直接使用 DeepSeek 作为后端模型。

---

## 第一次使用建议

试试对它说：

> "帮我做一个个人博客网站"

Claude Code 会立刻开始写代码。你会看到它在终端里一步步生成文件、解释思路。

---

## 常见问题

**Q：输入 `claude` 后提示"找不到命令"？**
A：关掉终端窗口，重新打开，再试一次。

**Q：安装过程中网络错误？**
A：断开当前 WiFi，换手机热点，重试。

**Q：需要 DeepSeek API Key 吗？**
A：本手册默认采用 DeepSeek API。去 platform.deepseek.com 注册获取，¥1 起充，按量付费。如果你已有 Claude 官方账号，可以跳过 DeepSeek 配置，用 `claude login` 登录。

**Q：怎么更新到最新版？**
A：重新运行一遍安装命令即可，自动覆盖升级。

**Q：怎么卸载？**
A：Mac / Linux：`rm -rf ~/.local/bin/claude ~/.claude/`
A：Windows：`winget uninstall Anthropic.ClaudeCode`

---

## 失败排查

1. **"找不到命令"** → 关掉终端重新打开，再试 `claude`
2. **网络错误** → 切换手机热点，重新运行安装命令
3. **API 配置不生效** → 关掉终端重新打开（环境变量需新窗口加载）
4. **其他问题** → 截图报错信息进行排查

---

> 📖 返回 [总教程](guide.md) · 查看 [常见问题排查](troubleshooting.md)
