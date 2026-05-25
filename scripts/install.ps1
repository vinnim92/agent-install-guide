# ============================================================
# Agent 安装指南 · Windows PowerShell 一键安装器
# 支持: Claude Code / Codex / OpenClaw
# 平台: Windows 10/11
# 用法:
#   iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.ps1 | iex
# ============================================================

param(
    [string]$Action = ""
)

$Script:RepoUrl = "https://github.com/vinnim92/agent-install-guide"
$Script:RawBase = "https://raw.githubusercontent.com/vinnim92/agent-install-guide/main"
$Script:CurrentVersion = "v1.0.0"

# ==================== 工具函数 ====================

function Write-Header {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "  Agent 安装指南 · Windows 一键部署" -ForegroundColor Cyan
    Write-Host "  $Script:RepoUrl" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host "[→] $Text" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Text)
    Write-Host "    ✅ $Text" -ForegroundColor Green
}

function Write-Error {
    param([string]$Text)
    Write-Host "    ❌ $Text" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Text)
    Write-Host "    ⚠️  $Text" -ForegroundColor Yellow
}

function Write-Tip {
    param([string]$Text)
    Write-Host "    💡 $Text" -ForegroundColor Cyan
}

function Test-Command {
    param([string]$Cmd)
    return Get-Command $Cmd -ErrorAction SilentlyContinue
}

# ==================== 系统检测 ====================

function Get-OSInfo {
    Write-Step "检测系统环境..."
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "    OS: $($os.Caption)"
    Write-Host "    架构: $env:PROCESSOR_ARCHITECTURE"
    Write-Host "    PowerShell: $($PSVersionTable.PSVersion)"

    # 检查是否以管理员运行
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Warning "建议以管理员身份运行 PowerShell（某些安装需要管理员权限）"
        Write-Tip "右键 PowerShell 图标 → 以管理员身份运行"
    }
}

# ==================== 前置检查 ====================

function Test-Git {
    Write-Step "检查 Git..."
    if (Test-Command "git") {
        Write-Success "Git 已安装: $(git --version)"
        return $true
    } else {
        Write-Error "Git 未安装"
        Write-Tip "下载: https://git-scm.com/download/win"
        return $false
    }
}

function Test-Node {
    param([string]$MinVersion = "22")

    Write-Step "检查 Node.js (需要 >= $MinVersion)..."
    if (Test-Command "node") {
        $ver = (node -v).TrimStart('v')
        Write-Host "    当前版本: v$ver"
        if ([version]$ver -ge [version]"$MinVersion.0.0") {
            Write-Success "Node.js 版本满足要求"
            return $true
        } else {
            Write-Error "Node.js 版本过低: v$ver (需要 >= $MinVersion)"
            Write-Tip "下载安装: https://nodejs.org (选择 LTS 版本)"
            return $false
        }
    } else {
        Write-Error "Node.js 未安装"
        Write-Tip "下载安装: https://nodejs.org (选择 LTS 版本)"
        return $false
    }
}

function Test-WSL {
    Write-Step "检查 WSL..."
    try {
        $wsl = wsl --status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Success "WSL 已安装"
            return $true
        }
    } catch {}
    Write-Warning "WSL 未安装或未配置"
    Write-Tip "安装: wsl --install (管理员 PowerShell)"
    Write-Tip "Codex 在 WSL2 中体验更好"
    return $false
}

# ==================== 安装函数 ====================

function Install-ClaudeCode {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  安装 Claude Code" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    if (Test-Command "claude") {
        Write-Success "Claude Code 已安装: $(claude --version 2>$null)"
        $confirm = Read-Host "是否重新安装？(y/N)"
        if ($confirm -notmatch '^[Yy]') { return }
    }

    # 检查 Git
    if (-not (Test-Git)) { return }

    Write-Step "安装 Claude Code..."

    try {
        # 首选 winget
        if (Test-Command "winget") {
            Write-Step "通过 winget 安装..."
            winget install Anthropic.ClaudeCode --silent --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Success "winget 安装成功"
                Verify-ClaudeCode
                return
            }
            Write-Warning "winget 安装失败，改用官方脚本..."
        }

        # 官方 PowerShell 脚本
        Write-Step "使用官方安装脚本..."
        Invoke-RestMethod -Uri "https://claude.ai/install.ps1" | Invoke-Expression
        Write-Success "安装完成"
        Verify-ClaudeCode
    } catch {
        Write-Error "安装失败: $_"
        Write-Tip "手动安装: 访问 https://claude.ai/download"
    }
}

function Verify-ClaudeCode {
    Write-Step "验证安装..."
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
    if (Test-Command "claude") {
        Write-Success "Claude Code 安装完成！"
        Write-Host ""
        Write-Host "下一步:" -ForegroundColor Green
        Write-Host "  1. 打开 PowerShell/CMD，输入 claude"
        Write-Host "  2. 浏览器弹出后登录 Claude 账号"
    } else {
        Write-Error "验证失败，请关闭并重新打开终端后重试"
    }
}

function Install-Codex {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  安装 Codex CLI" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    Write-Warning "Codex 在 Windows 原生环境为实验性支持"
    Write-Tip "推荐在 WSL2 中安装以获得最佳体验"

    $useWsl = Read-Host "是否使用 WSL2 安装？(Y/n)"
    if ($useWsl -notmatch '^[Nn]') {
        Install-Codex-WSL
        return
    }

    # 原生 Windows 安装
    if (-not (Test-Node "22")) { return }

    if (Test-Command "codex") {
        Write-Success "Codex 已安装"
        $confirm = Read-Host "是否升级到最新版？(y/N)"
        if ($confirm -notmatch '^[Yy]') { return }
    }

    Write-Step "通过 npm 安装 Codex..."
    npm install -g @openai/codex
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Codex 安装完成"
        Write-Host ""
        Write-Host "下一步: codex (登录 ChatGPT 账号)" -ForegroundColor Green
    } else {
        Write-Error "安装失败，请检查 Node.js 版本 (>= 22)"
    }
}

function Install-Codex-WSL {
    Test-WSL | Out-Null

    Write-Step "在 WSL2 中安装 Codex..."
    Write-Tip "请在 WSL 终端中执行以下命令:"
    Write-Host ""
    Write-Host "  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -" -ForegroundColor Yellow
    Write-Host "  sudo apt install -y nodejs" -ForegroundColor Yellow
    Write-Host "  npm install -g @openai/codex" -ForegroundColor Yellow
    Write-Host "  codex" -ForegroundColor Yellow
    Write-Host ""
}

function Install-OpenClaw {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  安装 OpenClaw" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Test-Node "22")) { return }

    if (Test-Command "openclaw") {
        Write-Success "OpenClaw 已安装"
        $confirm = Read-Host "是否升级到最新版？(y/N)"
        if ($confirm -notmatch '^[Yy]') { return }
    }

    Write-Step "安装 OpenClaw..."

    try {
        # 尝试 winget
        if (Test-Command "winget") {
            winget install Microsoft.OpenClaw --silent --accept-package-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-Success "winget 安装成功"
                Verify-OpenClaw
                return
            }
        }

        # Scoop
        if (Test-Command "scoop") {
            scoop install opencode
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Scoop 安装成功"
                Verify-OpenClaw
                return
            }
        }

        # npm 兜底
        npm install -g opencode-ai@latest
        Write-Success "npm 安装完成"
        Verify-OpenClaw
    } catch {
        Write-Error "安装失败: $_"
        Write-Tip "也可以考虑用 WSL2 安装 (推荐)"
    }
}

function Verify-OpenClaw {
    Write-Step "验证安装..."
    if (Test-Command "openclaw") {
        Write-Success "OpenClaw 安装完成！"
        Write-Host ""
        Write-Host "下一步:" -ForegroundColor Green
        Write-Host "  openclaw config set gateway.mode local"
        Write-Host "  openclaw gateway install"
        Write-Host "  openclaw gateway start"
    } else {
        Write-Error "验证失败，请重启终端后重试"
    }
}

# ==================== 主菜单 ====================

function Show-Menu {
    Write-Host ""
    Write-Host "请选择要安装的 AI Coding Agent:" -ForegroundColor White
    Write-Host ""
    Write-Host "  1) Claude Code  — Anthropic 出品，自带运行时，最省心" -ForegroundColor Gray
    Write-Host "  2) Codex CLI    — OpenAI 出品，需 Node.js 22+，ChatGPT 账号" -ForegroundColor Gray
    Write-Host "  3) OpenClaw     — 微软开源，75+ 模型支持，有免费模型" -ForegroundColor Gray
    Write-Host "  4) 全部安装     — 一键装齐三款" -ForegroundColor Gray
    Write-Host "  5) 查看对比     — 三款功能对比" -ForegroundColor Gray
    Write-Host "  0) 退出" -ForegroundColor Gray
    Write-Host ""
}

function Show-Comparison {
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "  三款 Agent 功能对比" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "               Claude Code     Codex           OpenClaw"
    Write-Host "  ──────────  ───────────  ────────────  ────────────"
    Write-Host "  开发商       Anthropic       OpenAI          微软(开源)"
    Write-Host "  免费可用     ✗ (需付费)     ✗ (Plus起步)    ✓ (免费模型)"
    Write-Host "  运行环境     自带运行时      Node.js 22+     Node.js 22+"
    Write-Host "  IDE 插件     VS Code/JetBrains  ✗           ✗"
    Write-Host "  桌面应用     ✓               ✗               ✓ (Beta)"
    Write-Host "  多模型       仅 Claude        仅 OpenAI        75+ 提供商"
    Write-Host ""
    Write-Host "  推荐选择:" -ForegroundColor Yellow
    Write-Host "    追求体验  → Claude Code（最省心）"
    Write-Host "    预算有限  → OpenClaw（有免费模型）"
    Write-Host "    OpenAI 用户 → Codex（ChatGPT 生态）"
    Write-Host ""
    Pause
}

# ==================== 入口 ====================

function Main {
    Write-Header
    Get-OSInfo

    # 命令行参数快捷安装
    switch ($Action.ToLower()) {
        "claude"    { Install-ClaudeCode; return }
        "codex"     { Install-Codex; return }
        "openclaw"  { Install-OpenClaw; return }
        "--version" { Write-Host "Agent Install Guide $Script:CurrentVersion"; return }
    }

    while ($true) {
        Show-Menu
        $choice = Read-Host "请输入选项 [0-5]"

        switch ($choice) {
            "1" { Install-ClaudeCode }
            "2" { Install-Codex }
            "3" { Install-OpenClaw }
            "4" {
                Install-ClaudeCode
                Install-Codex
                Install-OpenClaw
                Write-Success "全部安装流程完成！"
            }
            "5" { Show-Comparison }
            "0" { Write-Host "再见！" -ForegroundColor Green; return }
            default { Write-Warning "无效选项，请输入 0-5" }
        }
        Write-Host ""
        Pause
    }
}

Main
