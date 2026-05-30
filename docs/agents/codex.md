# Codex 小白安装教程

> OpenAI 出品 · ChatGPT 用户首选 · 一条命令安装

---

## 适合谁

Codex 适合 ChatGPT 用户，尤其是想把 OpenAI 能力接入本地开发流程的人。如果你已经是 ChatGPT Plus 会员，Codex 是最自然的选择。

需要 ChatGPT Plus / Pro / Team 账号，或 OpenAI API Key。

---

## 安装前你需要知道什么

- 会复制粘贴就够了
- 脚本会自动安装 Node.js（如果你没有或版本不够）
- 全程约 5 分钟

---

## macOS / Linux 安装

打开终端（Mac 右上角 🔍 搜索「终端」），粘贴下面这行，回车：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-codex.sh | bash
```

屏幕上会滚动文字——这是脚本在自动工作。看到 `✅` 就是装好了。

---

## Windows 安装

按 `⊞ + R`，输入 `powershell`，回车。粘贴下面这行，回车：

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-codex.ps1 | iex
```

---

## dry-run 预演

先看脚本会做什么，再决定是否安装：

### macOS / Linux

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-codex.sh | bash -s -- --dry-run
```

### Windows

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-codex.ps1 -OutFile install-codex.ps1
.\install-codex.ps1 -DryRun
```

---

## 安装后启动

Codex 支持两种登录方式：

### 方式一：官方账号登录

适合已有 ChatGPT / OpenAI 账号的用户：

```
codex login
```

浏览器会自动弹出 ChatGPT 登录页，登录后即可使用。

### 方式二：API Key 登录

适合使用 OpenAI API Key 的用户：

**macOS / Linux：**

```bash
export OPENAI_API_KEY="你的 OpenAI API Key"
printenv OPENAI_API_KEY | codex login --with-api-key
```

**Windows：**

```powershell
$env:OPENAI_API_KEY="你的 OpenAI API Key"
$env:OPENAI_API_KEY | codex login --with-api-key
```

---

## 第一次使用建议

试试对它说：

> "帮我写一个 Python 脚本，自动整理桌面文件"

Codex 会立刻开始写代码，并在终端里展示运行结果。

---

## 常见问题

**Q：输入 `codex` 后提示"找不到命令"？**
A：关掉终端窗口，重新打开，再试一次。

**Q：安装过程中网络错误？**
A：断开当前 WiFi，换手机热点，重试。脚本在网络不佳时会自动切换国内 npm 镜像。

**Q：需要 ChatGPT Plus 吗？**
A：有两种方式：① 官方账号登录需要 Plus（$20/月）、Pro（$200/月）或 Team 订阅；② 使用 OpenAI API Key 登录（按量计费），不需要订阅。

**Q：怎么更新到最新版？**
A：重新运行一遍安装命令即可，自动覆盖升级。

**Q：怎么卸载？**
A：终端输入：`npm uninstall -g @openai/codex`

---

## 失败排查

1. **"找不到命令"** → 关掉终端重新打开，再试 `codex`
2. **网络错误** → 切换手机热点，重新运行安装命令
3. **权限错误（EACCES）** → 脚本会自动检测并修复 npm 权限
4. **Node.js 版本不够** → 脚本会自动安装 Node.js v22+
5. **登录失败** → 确认 ChatGPT 订阅有效
6. **其他问题** → 截图报错信息进行排查

---

> 📖 返回 [总教程](guide.md) · 查看 [常见问题排查](troubleshooting.md)
