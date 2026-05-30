# ============================================================
# OpenClaw 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 需要: Node.js >= 22.19（推荐 24+，脚本会自动安装）
# OpenClaw 内置免费模型，无需 API Key 也能使用
#
# 用法:
#   iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.3/scripts/install-openclaw.ps1 | iex
#   .\install-openclaw.ps1 -Help
#   .\install-openclaw.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-openclaw.ps1
# ============================================================

param(
    [switch]$Help,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ---- Help ----
if ($Help) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  OpenClaw 安装脚本 (Windows)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "安装: OpenClaw（微软开源）"
    Write-Host "系统: Windows 10/11"
    Write-Host "需要: Node.js >= 22.19（推荐 24+，脚本会自动安装）"
    Write-Host "      内置免费模型，无需 API Key"
    Write-Host "      支持 75+ 模型提供商"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-openclaw.ps1           正常安装"
    Write-Host "  .\install-openclaw.ps1 -Help     显示帮助"
    Write-Host "  .\install-openclaw.ps1 -DryRun   预览步骤"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-openclaw.ps1'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: openclaw           进入交互式对话"
    Write-Host "  PowerShell 输入: openclaw dashboard 打开 Web 控制台"
    Write-Host ""
    Write-Host "常见失败原因:"
    Write-Host "  1. Node.js 版本不足 → 脚本会自动安装 v22+"
    Write-Host "  2. npm 网络问题 → 国内用户可尝试切换网络"
    Write-Host "  3. 安装后找不到 openclaw → 关掉 PowerShell 重开"
    Write-Host ""
    exit 0
}

# ---- 确认机制 ----
$skipConfirm = ($env:AGENT_INSTALL_YES -eq "1")

function Confirm-Action {
    param([string]$Prompt)
    if ($skipConfirm) {
        Write-Host "    [Auto] $Prompt → 自动确认 (AGENT_INSTALL_YES=1)" -ForegroundColor Cyan
        return $true
    }
    $response = Read-Host "    [?] $Prompt [Y/n]"
    if ($response -eq "" -or $response -eq "y" -or $response -eq "Y" -or $response -eq "yes") {
        return $true
    }
    return $false
}

function Write-DryRun { Write-Host "    [DRY-RUN] 将执行: $args" -ForegroundColor Yellow }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  [预览模式] 只显示步骤，不执行安装" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  本脚本将安装 OpenClaw" -ForegroundColor Cyan
Write-Host "  内置免费模型，无需 API Key" -ForegroundColor Cyan
Write-Host ""

# ---- 系统检测 ----
Write-Host "--- 检测系统环境 ---" -ForegroundColor Blue
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "  [OK] $($os.Caption)" -ForegroundColor Green
Write-Host "  [OK] 架构: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green

if (-not $DryRun) {
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    $hasScoop = Get-Command scoop -ErrorAction SilentlyContinue
    $hasChoco = Get-Command choco -ErrorAction SilentlyContinue
    if ($hasWinget) { Write-Host "  [OK] winget 可用" -ForegroundColor Green }
    if ($hasScoop)  { Write-Host "  [OK] Scoop 可用" -ForegroundColor Green }
} else {
    Write-DryRun "检测 winget/scoop/choco 包管理器"
}
Write-Host ""

# ---- 安装 Node.js ----
Write-Host "--- 安装 Node.js (需要 >= 22.19，推荐 24+) ---" -ForegroundColor Blue

if ($DryRun) {
    Write-DryRun "检查 node 版本 (需要 >= 22.19.0)"
    Write-DryRun "如需安装: winget install OpenJS.NodeJS.LTS"
    Write-DryRun "或: scoop install nodejs"
    Write-DryRun "或: choco install nodejs"
} else {
    $needNode = $true
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nodeVer = (node -v).TrimStart('v')
        $parts = $nodeVer.Split('.')
        $majorVer = [int]$parts[0]
        $minorVer = if ($parts.Count -ge 2) { [int]$parts[1] } else { 0 }
        $patchVer = if ($parts.Count -ge 3) { [int]$parts[2] } else { 0 }
        if ($majorVer -gt 22 -or ($majorVer -eq 22 -and $minorVer -ge 19)) {
            Write-Host "  [OK] Node.js $nodeVer 已就绪" -ForegroundColor Green
            $needNode = $false
        } else {
            Write-Host "  [!] Node.js 版本较旧 ($nodeVer)，需要 >= 22.19，推荐 24+" -ForegroundColor Yellow
        }
    }

    if ($needNode) {
        if (-not (Confirm-Action "即将安装 Node.js（推荐 v24+），是否继续？")) {
            Write-Host "  [FAIL] Node.js 是 OpenClaw 的必要依赖，无法跳过" -ForegroundColor Red
            exit 1
        }
        Write-Host "  正在安装 Node.js..." -ForegroundColor Cyan
        $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
        $hasScoop = Get-Command scoop -ErrorAction SilentlyContinue
        $hasChoco = Get-Command choco -ErrorAction SilentlyContinue

        if ($hasWinget) {
            winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>$null
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        } elseif ($hasScoop) {
            scoop install nodejs 2>$null
        } elseif ($hasChoco) {
            choco install nodejs -y 2>$null
        } else {
            Write-Host "  [!] 未找到包管理器，请手动安装 Node.js:" -ForegroundColor Yellow
            Write-Host "      访问 https://nodejs.org 下载 v24 LTS 安装包" -ForegroundColor Yellow
            Write-Host "      安装后关掉此窗口重新打开，再运行本脚本" -ForegroundColor Yellow
            exit 1
        }
        if (Get-Command node -ErrorAction SilentlyContinue) {
            Write-Host "  [OK] Node.js 安装成功" -ForegroundColor Green
        } else {
            Write-Host "  [!] Node.js 已安装但需重启后生效，继续尝试..." -ForegroundColor Yellow
        }
    }
}
Write-Host ""

# ---- 安装 OpenClaw ----
Write-Host "--- 安装 OpenClaw ---" -ForegroundColor Blue

if (-not $DryRun -and (Get-Command openclaw -ErrorAction SilentlyContinue)) {
    Write-Host "  [OK] OpenClaw 已安装" -ForegroundColor Green
    openclaw --version 2>$null | ForEach-Object { Write-Host "  $_" }
} elseif ($DryRun) {
    Write-DryRun "Invoke-RestMethod https://openclaw.ai/install.ps1 | Invoke-Expression"
    Write-DryRun "fallback: npm install -g openclaw@latest"
    Write-DryRun "验证: Get-Command openclaw"
} else {
    if (-not (Confirm-Action "即将安装 OpenClaw，是否继续？")) {
        Write-Host "  已取消" -ForegroundColor Yellow
        exit 0
    }

    $installed = $false

    # 方法1: 官方 installer（优先）
    Write-Host "  尝试官方脚本安装（openclaw.ai/install.ps1）..." -ForegroundColor Cyan
    try {
        Invoke-RestMethod -Uri "https://openclaw.ai/install.ps1" -TimeoutSec 30 | Invoke-Expression 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command openclaw -ErrorAction SilentlyContinue) { $installed = $true }
    } catch {
        Write-Host "  [!] 官方脚本不可用，改用 npm..." -ForegroundColor Yellow
    }

    # 方法2: npm fallback
    if (-not $installed) {
        $hasNpm = Get-Command npm -ErrorAction SilentlyContinue
        if ($hasNpm) {
            Write-Host "  通过 npm 安装 openclaw ..." -ForegroundColor Cyan
            npm install -g openclaw@latest 2>$null
            if (Get-Command openclaw -ErrorAction SilentlyContinue) { $installed = $true }
        }
    }

    if ($installed) {
        Write-Host "  [OK] OpenClaw 安装成功!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] OpenClaw 安装失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "  排查建议:" -ForegroundColor Yellow
        Write-Host "  1. 确保网络通畅，可尝试切换手机热点" -ForegroundColor Yellow
        Write-Host "  2. 检查 Node.js: node -v (需要 >= 22.19)" -ForegroundColor Yellow
        Write-Host "  3. 手动安装: npm install -g openclaw@latest" -ForegroundColor Yellow
        Write-Host "  4. 查看官方文档: https://github.com/microsoft/openclaw" -ForegroundColor Yellow
        exit 1
    }
}

# ---- 验证 ----
Write-Host ""
Write-Host "--- 验证安装 ---" -ForegroundColor Blue

if ($DryRun) {
    Write-DryRun "验证: Get-Command openclaw"
} elseif (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] OpenClaw 安装验证通过" -ForegroundColor Green
    Write-Host ""
    Write-Host "  第一次启动:" -ForegroundColor Green
    Write-Host "    PowerShell 中输入 openclaw 进入交互式对话" -ForegroundColor Green
    Write-Host "    或输入 openclaw dashboard 打开 Web 控制台" -ForegroundColor Green
    Write-Host ""
    Write-Host "  推荐初始化:" -ForegroundColor Green
    Write-Host "    openclaw config set gateway.mode local" -ForegroundColor Green
    Write-Host "    openclaw gateway install" -ForegroundColor Green
    Write-Host "    openclaw gateway start" -ForegroundColor Green
    Write-Host "    然后访问 http://localhost:18789" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] 找不到 openclaw 命令" -ForegroundColor Red
    Write-Host "  请关闭 PowerShell 窗口重新打开后再试" -ForegroundColor Yellow
    exit 1
}

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] 预览完成 — 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-openclaw.ps1" -ForegroundColor Cyan
}
Write-Host ""
