# OpenClaw 小白安装教程

> 微软开源 · 一条命令安装 · 推荐 DeepSeek API Key

---

## 适合谁

OpenClaw 适合想尝试开源 Agent 工作流、希望有更多可玩性的用户。由微软开源，支持 75+ 模型提供商。

安装阶段不需要 API Key；首次配置或正式使用时，可能需要模型服务的 API Key（推荐 DeepSeek API Key，国内获取方便、价格便宜）。

---

## 安装前你需要知道什么

- 会复制粘贴就够了
- 脚本会自动安装 Node.js（如果你没有或版本不够）
- 安装阶段不需要 API Key；首次配置时需要模型服务的 API Key
- 全程约 5 分钟

---

## macOS / Linux 安装

打开终端（Mac 右上角 🔍 搜索「终端」），粘贴下面这行，回车：

```bash
curl -fsSL "https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.sh" | AGENT_INSTALL_YES=1 bash
```

屏幕上会滚动文字——这是脚本在自动工作。看到 `✅` 就是装好了。

---

## Windows 安装

按 `⊞ + R`，输入 `powershell`，回车。粘贴下面这行，回车：

```powershell
iwr -useb "https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.ps1" | iex
```

---

## dry-run 预演

先看脚本会做什么，再决定是否安装：

### macOS / Linux

```bash
curl -fsSL "https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.sh" | bash -s -- --dry-run
```

### Windows

```powershell
iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-openclaw.ps1 -OutFile install-openclaw.ps1
.\install-openclaw.ps1 -DryRun
```

---

## 安装后配置（推荐 DeepSeek API Key）

安装完成后，推荐使用 DeepSeek API Key 配置 OpenClaw：

```
openclaw onboard --auth-choice deepseek-api-key
```

按终端提示输入你的 DeepSeek API Key（在 platform.deepseek.com 注册获取）。

验证配置：

```
openclaw models list --provider deepseek
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

浏览器访问显示的地址，在网页上选择你想用的 AI 模型。

---

## 第一次使用建议

配置好 DeepSeek API Key 后，试试对它说：

> "帮我写一个 Python 脚本，自动整理桌面文件"

想切换其他模型？可以在控制台添加其他提供商的 API Key。

---

## 常见问题

**Q：输入 `openclaw` 后提示"找不到命令"？**
A：关掉终端窗口，重新打开，再试一次。

**Q：安装过程中网络错误？**
A：断开当前 WiFi，换手机热点，重试。脚本在网络不佳时会自动切换国内 npm 镜像。

**Q：需要 API Key 吗？**
A：安装阶段不需要 API Key。首次配置或正式使用时，推荐使用 DeepSeek API Key，在 platform.deepseek.com 注册获取。

**Q：npm install 报 EACCES / permission denied？**
A：这是 npm 缓存权限异常，通常是以前用 sudo npm 或安装器异常导致。修复方法见故障排查页面。

**Q：怎么更新到最新版？**
A：重新运行一遍安装命令即可，自动覆盖升级。

**Q：怎么卸载？**
A：Mac：`brew uninstall openclaw` 或 `npm uninstall -g openclaw@latest`
A：Windows：`npm uninstall -g openclaw@latest`

---

## 失败排查

1. **"找不到命令"** → 关掉终端重新打开，再试 `openclaw`
2. **网络错误** → 切换手机热点，重新运行安装命令
3. **权限错误（EACCES）** → 查看故障排查页面的 npm 缓存权限修复指引
4. **Node.js 版本不够** → 脚本会自动安装 Node.js v24+
5. **Linux 编译报错** → 终端运行 `sudo apt install -y gcc g++ make python3-venv libssl-dev`，再重试
6. **OpenAI Codex OAuth 报 unsupported_region** → 改用 DeepSeek API Key：`openclaw onboard --auth-choice deepseek-api-key`
7. **其他问题** → 查看故障排查页面

---

> 📖 查看 [常见问题排查](../support.html)
