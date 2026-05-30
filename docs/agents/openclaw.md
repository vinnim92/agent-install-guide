# OpenClaw 小白安装教程

> 微软开源 · 内置免费模型 · 一条命令安装

---

## 适合谁

OpenClaw 适合想尝试开源 Agent 工作流、希望有更多可玩性的用户。由微软开源，内置免费模型，不花钱就能体验 AI 编程助手。

支持 75+ 模型提供商，除了免费模型，也可以接入 Claude、GPT 等付费模型。

---

## 安装前你需要知道什么

- 会复制粘贴就够了
- 脚本会自动安装 Node.js（如果你没有或版本不够）
- 内置免费模型，无需 API Key 也能使用
- 全程约 5 分钟

---

## macOS / Linux 安装

打开终端（Mac 右上角 🔍 搜索「终端」），粘贴下面这行，回车：

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-openclaw.sh | bash
```

屏幕上会滚动文字——这是脚本在自动工作。看到 `✅` 就是装好了。

---

## Windows 安装

按 `⊞ + R`，输入 `powershell`，回车。粘贴下面这行，回车：

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-openclaw.ps1 | iex
```

---

## dry-run 预演

先看脚本会做什么，再决定是否安装：

### macOS / Linux

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-openclaw.sh | bash -s -- --dry-run
```

### Windows

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-openclaw.ps1 -OutFile install-openclaw.ps1
.\install-openclaw.ps1 -DryRun
```

---

## 安装后启动

打开终端，输入：

```
openclaw
```

回车即可进入交互式对话。

也可以打开 Web 控制台：

```
openclaw dashboard
```

浏览器访问显示的地址，在网页上选择你想用的 AI 模型（内置免费模型可直接使用）。

---

## 第一次使用建议

OpenClaw 默认使用免费模型，不用配置任何 API Key 就能开始对话。试试对它说：

> "帮我写一个 Python 脚本，自动整理桌面文件"

觉得免费模型不够用？可以用命令添加 Claude 或 GPT 的 API Key，切换到更强模型。

---

## 常见问题

**Q：输入 `openclaw` 后提示"找不到命令"？**
A：关掉终端窗口，重新打开，再试一次。

**Q：安装过程中网络错误？**
A：断开当前 WiFi，换手机热点，重试。脚本在网络不佳时会自动切换国内 npm 镜像。

**Q：真的免费吗？**
A：OpenClaw 内置免费模型，日常写代码、写文档够用。复杂项目建议接入 Claude 或 GPT 等付费模型。

**Q：需要 API Key 吗？**
A：内置免费模型不需要。如果想用 Claude、GPT 等付费模型，需要自行准备对应 API Key。

**Q：怎么更新到最新版？**
A：重新运行一遍安装命令即可，自动覆盖升级。

**Q：怎么卸载？**
A：Mac：`brew uninstall openclaw` 或 `npm uninstall -g openclaw@latest`
A：Windows：`npm uninstall -g openclaw@latest`

---

## 失败排查

1. **"找不到命令"** → 关掉终端重新打开，再试 `openclaw`
2. **网络错误** → 切换手机热点，重新运行安装命令
3. **权限错误（EACCES）** → 脚本会自动检测并修复 npm 权限
4. **Node.js 版本不够** → 脚本会自动安装 Node.js v22+
5. **Linux 编译报错** → 终端运行 `sudo apt install -y gcc g++ make python3-venv libssl-dev`，再重试
6. **其他问题** → 截图报错信息进行排查

---

> 📖 返回 [总教程](guide.md) · 查看 [常见问题排查](troubleshooting.md)
