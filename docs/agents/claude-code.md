# Claude Code 小白安装教程

> Anthropic 出品 · 综合能力最强 · 一条命令安装

---

## 适合谁

Claude Code 适合想要稳定、成熟、强代码能力体验的用户。如果你想要一个聪明、可靠的 AI 编程助手，这是目前最好的选择之一。

需要 Claude 账号（Pro / Max / Team / Enterprise）或 Anthropic API Key。

---

## 安装前你需要知道什么

- 会复制粘贴就够了
- 不需要手动安装 Node.js（Claude Code 自带运行环境）
- 全程 3-5 分钟

---

## macOS / Linux 安装

打开终端（Mac 右上角 🔍 搜索「终端」），粘贴下面这行，回车：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.sh | bash
```

屏幕上会滚动文字——这是脚本在自动工作。看到 `✅` 就是装好了。

---

## Windows 安装

按 `⊞ + R`，输入 `powershell`，回车。粘贴下面这行，回车：

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.ps1 | iex
```

---

## dry-run 预演

先看脚本会做什么，再决定是否安装：

### macOS / Linux

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.sh | bash -s -- --dry-run
```

### Windows

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.ps1 -OutFile install-claude-code.ps1
.\install-claude-code.ps1 -DryRun
```

---

## 安装后启动

打开终端，输入：

```
claude
```

回车。第一次会弹出浏览器让你登录 Claude 账号。登录后回到终端，就可以和 Claude Code 对话了。

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

**Q：需要账号吗？**
A：需要 Claude 账号。Pro 订阅 $20/月，Max $100/月（用量更大），Team 和 Enterprise 按团队计费。

**Q：怎么更新到最新版？**
A：重新运行一遍安装命令即可，自动覆盖升级。

**Q：怎么卸载？**
A：Mac / Linux：`rm -rf ~/.local/bin/claude ~/.claude/`
A：Windows：`winget uninstall Anthropic.ClaudeCode`

---

## 失败排查

1. **"找不到命令"** → 关掉终端重新打开，再试 `claude`
2. **网络错误** → 切换手机热点，重新运行安装命令
3. **登录失败** → 确认 Claude 账号订阅有效
4. **其他问题** → 截图报错信息进行排查

---

> 📖 返回 [总教程](guide.md) · 查看 [常见问题排查](troubleshooting.md)
