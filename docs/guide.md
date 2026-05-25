# AI Coding Agent 全平台安装指南

> 三款主流 AI 编程助手 · Windows / macOS / Linux · 从零到能用

---

## 目录

1. [总览：三款 Agent 怎么选](#总览)
2. [Claude Code 安装](#一claude-code)
3. [Codex CLI 安装](#二codex-cli)
4. [OpenClaw 安装](#三openclaw)
5. [常见问题速查](#四常见问题速查)

---

## 总览

| | Claude Code | Codex | OpenClaw |
|---|---|---|---|
| **开发商** | Anthropic | OpenAI | 微软（开源）|
| **一句话** | 最省心 | OpenAI 原生 | 最灵活 |
| **免费可用** | ✗（需付费） | ✗（Plus 起步） | ✓（有免费模型） |
| **Node.js 要求** | 无（自带运行时） | ≥ v22 | ≥ v22 |
| **适合谁** | 追求体验、预算充足 | ChatGPT 深度用户 | 想省钱、爱折腾 |

**快速决策**：预算充足 → Claude Code / 有 ChatGPT Plus → Codex / 想免费体验 → OpenClaw

---

## 一、Claude Code

### 前置条件

- **账号**：Claude Pro/Max/Team/Enterprise，或 Anthropic API Key
- **系统**：macOS 13+ / Ubuntu 20.04+ / Windows 10/11（需 Git for Windows）
- **Git**：必须安装（Windows 需 [Git for Windows](https://git-scm.com/download/win)）

### macOS 安装

**方法一：官方脚本（推荐）**
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

**方法二：Homebrew**
```bash
brew install --cask claude-code
```

**验证**：
```bash
claude --version
# 如果提示 command not found:
export PATH="$HOME/.local/bin:$PATH"
source ~/.zshrc
```

### Linux 安装（含 WSL2）

```bash
curl -fsSL https://claude.ai/install.sh | bash
```

Alpine Linux 额外步骤：
```bash
apk add libgcc libstdc++ ripgrep
```

### Windows 安装

**PowerShell（推荐）**：
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://claude.ai/install.ps1 | iex
```

**CMD**：
```cmd
curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd
```

**WinGet**：
```powershell
winget install Anthropic.ClaudeCode
```

### 首次启动

```bash
claude                # 弹出浏览器 → 登录 → 复制授权码 → 完成
claude doctor         # 环境诊断
```

---

## 二、Codex CLI

### 前置条件

- **Node.js ≥ v22**（硬性要求）
- **账号**：ChatGPT Plus/Pro/Team，或 OpenAI API Key
- **Windows 用户**：强烈推荐 WSL2

### Step 1: 安装 Node.js 22

**macOS**：
```bash
brew install node@22
```

**Ubuntu/Debian**：
```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
```

**Windows**：访问 https://nodejs.org 下载 LTS 安装包。

**使用 nvm（所有平台通用）**：
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc   # 或 ~/.zshrc
nvm install 22
nvm use 22
nvm alias default 22
```

### Step 2: 安装 Codex

```bash
npm install -g @openai/codex
codex --version
```

**国内用户**：先切镜像：
```bash
npm config set registry https://registry.npmmirror.com
```

### Step 3: 登录使用

```bash
codex                    # 弹浏览器登录 ChatGPT
# 或 API Key:
export OPENAI_API_KEY="sk-xxxxxxxx"
codex login --with-api-key    # 输 API Key
```

### Windows 用户特别注意

Codex 在 Windows 原生环境为实验性支持，**推荐在 WSL2 中安装**：

```powershell
# 管理员 PowerShell
wsl --install                # 安装 WSL2
```
然后进入 WSL 终端，按 Linux 流程安装。

---

## 三、OpenClaw

### 前置条件

- **Node.js ≥ v22**（推荐 v24 LTS）
- **账号**：无需！OpenClaw 内置免费模型，零成本上手

### macOS 安装

```bash
# 推荐
brew install opencode

# 或 GitHub 桌面版
brew install --cask opencode-desktop
```

### Linux 安装

```bash
# 推荐
curl -fsSL https://opencode.ai/install | bash

# Arch Linux
sudo pacman -S opencode

# NixOS
nix-env -iA nixpkgs.opencode
```

### Windows 安装

```powershell
# Scoop
scoop install opencode

# Chocolatey
choco install opencode

# npm
npm install -g opencode-ai@latest
```

### 初始化（安装后必须）

```bash
# 配置本地模式
openclaw config set gateway.mode local

# 安装守护进程（开机自启）
openclaw gateway install
openclaw gateway start

# 验证
openclaw --version
```

访问 Web 控制台：http://localhost:18789

---

## 四、常见问题速查

### 网络相关

| 问题 | 解决 |
|------|------|
| GitHub 连不上 | 开 VPN / 换手机热点 |
| npm 下载慢 | `npm config set registry https://registry.npmmirror.com` |
| 国内 Windows 用 OpenClaw | `iwr -useb https://clawd.org.cn/install.ps1 \| iex` |

### 命令找不到

```bash
# Claude Code
export PATH="$HOME/.local/bin:$PATH"

# Codex / OpenClaw
export PATH="$(npm prefix -g)/bin:$PATH"
```

### 版本不对

```bash
# 多版本冲突时，找到所有安装位置
which -a claude    # Claude Code
which -a codex     # Codex
which -a openclaw  # OpenClaw
```

### 详细排查

更多问题请参考随包附带的 `troubleshooting.md`，或提 Issue：
https://github.com/vinnim92/agent-install-guide/issues

---

> **版本**：v1.0.0 ｜ **更新日期**：2026-05-25 ｜ **来源**：https://github.com/vinnim92/agent-install-guide
