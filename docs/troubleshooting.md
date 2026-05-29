# 常见问题排查（零基础版）

> 遇到问题不要慌。7 个最常见的情况，每个都有手把手的解决方案。
> 还不行？截图发闲鱼卖家，24 小时内回复。

---

## 问题 1：提示"找不到命令"

输入 `claude` / `codex` / `openclaw` 后，提示 `command not found` 或"不是内部命令"。

**怎么办**：

1. 把终端窗口关掉
2. 重新打开终端
3. 再试一次

如果还不行，在终端里输入这行：

```bash
export PATH="$HOME/.local/bin:$PATH"
```

然后重试。

> Windows 用户：如果还不行，重启电脑一次就好了。

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

点 **"安装"** 按钮。大约 2 分钟后装好，脚本会自动继续。

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

### Claude Code

**Mac / Linux**：`rm -rf ~/.local/bin/claude ~/.claude/`

**Windows**：`winget uninstall Anthropic.ClaudeCode`

### Codex

**所有平台**：`npm uninstall -g @openai/codex`

### OpenClaw

**Mac**：`brew uninstall opencode` 或 `npm uninstall -g opencode-ai`

**Windows**：`winget uninstall SST.opencode` 或 `npm uninstall -g opencode-ai`

---

## 问题 7：都不是我的问题，怎么办？

把终端窗口里的文字**截图**，发给闲鱼卖家。24 小时内回复。

或者去这里提交问题（需要 GitHub 账号）：
https://github.com/vinnim92/agent-install-guide/issues

---

> 📖 **版本：v3.0 ｜ 永远保持更新**
