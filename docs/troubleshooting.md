# 常见问题排查（零基础版）

## 问题 1：提示"找不到命令"

输入 `claude` 或 `codex` 后，提示 `command not found` 或"不是内部命令"。

**怎么办**：

1. 把终端窗口关掉
2. 重新打开终端
3. 再试一次

如果还不行，在终端里输入这行：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

然后重试。

---

## 问题 2：安装脚本跑到一半卡住了

**怎么办**：

1. 按键盘 `Ctrl + C`（Mac 和 Windows 都是这个键）
2. 重新运行安装命令

---

## 问题 3：安装时报网络错误

比如提示 `curl: (7) Failed to connect` 或 `Connection refused`。

**原因**：你当前的网络访问国外服务器较慢。

**解决办法**：
- 断开当前 WiFi
- 打开手机热点
- 电脑连上手机热点
- 重新运行安装命令

---

## 问题 4：Mac 弹出"需要安装开发者工具"

安装过程中可能会弹出一个小窗口：

> "需要安装命令行开发者工具"

点**"安装"**按钮。大约 2 分钟后装好，脚本会自动继续。

---

## 问题 5：Windows 提示"执行策略限制"

运行 PowerShell 脚本时提示：

> "无法加载文件，因为在此系统上禁止运行脚本"

**怎么办**：先输入下面这行，回车，然后再运行安装命令：

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

---

## 问题 6：如何卸载

### Mac / Linux 用户

打开终端，输入：

```bash
# 卸载 Claude Code
rm -rf ~/.local/bin/claude ~/.claude/

# 卸载 Codex
npm uninstall -g @openai/codex

# 卸载 OpenClaw
npm uninstall -g opencode-ai
```

### Windows 用户

```powershell
# 卸载 Claude Code
winget uninstall Anthropic.ClaudeCode

# 卸载 Codex
npm uninstall -g @openai/codex

# 卸载 OpenClaw
npm uninstall -g opencode-ai
```

---

## 问题 7：都不是我的问题，怎么办？

把终端窗口里的文字截图，发给卖家。24 小时内回复。

或者去这里提交问题（需要 GitHub 账号）：
https://github.com/vinnim92/agent-install-guide/issues
