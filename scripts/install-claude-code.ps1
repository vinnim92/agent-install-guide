# ============================================================
# Claude Code 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 需要: Claude 账号（Pro/Max/Team/Enterprise）或 Anthropic API Key
# Claude Code 自带运行时，无需单独安装 Node.js
#
# 用法:
#   iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.ps1 | iex
#   .\install-claude-code.ps1 -Help
#   .\install-claude-code.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1
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
    Write-Host "  Claude Code 安装脚本 (Windows)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "安装: Claude Code"
    Write-Host "系统: Windows 10/11"
    Write-Host "需要: Claude 账号或 Anthropic API Key"
    Write-Host "      无需单独安装 Node.js"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-claude-code.ps1           正常安装"
    Write-Host "  .\install-claude-code.ps1 -Help     显示帮助"
    Write-Host "  .\install-claude-code.ps1 -DryRun   预览步骤"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: claude"
    Write-Host ""
    Write-Host "常见失败原因:"
    Write-Host "  1. 网络问题 → 切换手机热点试试"
    Write-Host "  2. winget 不可用 → 微软商店搜索""应用安装程序"""
    Write-Host "  3. 安装后找不到 claude → 关掉 PowerShell 重开"
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

# ---- 输出函数 ----
function Write-DryRun { Write-Host "    [DRY-RUN] 将执行: $args" -ForegroundColor Yellow }

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  [预览模式] 只显示步骤，不执行安装" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  本脚本将安装 Claude Code" -ForegroundColor Cyan
Write-Host "  需要 Claude 账号或 Anthropic API Key" -ForegroundColor Cyan
Write-Host ""

# ---- 系统检测 ----
Write-Host "--- 检测系统环境 ---" -ForegroundColor Blue
$os = Get-CimInstance Win32_OperatingSystem
Write-Host "  [OK] $($os.Caption)" -ForegroundColor Green
Write-Host "  [OK] 架构: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green

if ($DryRun) {
    Write-DryRun "检测 winget 是否可用"
    Write-DryRun "检测 npm 是否可用"
} else {
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    $hasNpm = Get-Command npm -ErrorAction SilentlyContinue
    if ($hasWinget) { Write-Host "  [OK] winget 可用" -ForegroundColor Green }
}
Write-Host ""

# ---- 安装 Claude Code ----
Write-Host "--- 安装 Claude Code ---" -ForegroundColor Blue

if (-not $DryRun -and (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "  [OK] Claude Code 已安装" -ForegroundColor Green
    claude --version 2>$null | ForEach-Object { Write-Host "  $_" }
} elseif ($DryRun) {
    Write-DryRun "方法1: winget install Anthropic.ClaudeCode"
    Write-DryRun "方法2: Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression"
    Write-DryRun "方法3: npm install -g @anthropic-ai/claude-code"
    Write-DryRun "验证: Get-Command claude"
    Write-DryRun "将刷新 PATH 环境变量（当前会话）"
    Write-DryRun "可能会将 ~\.local\bin 加入 PATH"
} else {
    if (-not (Confirm-Action "即将安装 Claude Code，是否继续？")) {
        Write-Host "  已取消" -ForegroundColor Yellow
        exit 0
    }

    $installed = $false
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    $hasNpm = Get-Command npm -ErrorAction SilentlyContinue

    # 方法1: winget
    if ($hasWinget -and -not $installed) {
        Write-Host "  尝试 winget 安装..." -ForegroundColor Cyan
        winget install Anthropic.ClaudeCode --silent --accept-package-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true }
    }

    # 方法2: 官方 PowerShell 脚本
    if (-not $installed) {
        Write-Host "  尝试官方脚本安装..." -ForegroundColor Cyan
        try {
            Invoke-RestMethod -Uri "https://claude.ai/install.ps1" -TimeoutSec 30 | Invoke-Expression 2>$null
            $localBin = Join-Path $env:USERPROFILE ".local\bin"
            $env:Path = "$localBin;$env:Path"
            if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true }
        } catch {
            Write-Host "  [!] 官方脚本不可用，改用 npm..." -ForegroundColor Yellow
        }
    }

    # 方法3: npm
    if (-not $installed -and $hasNpm) {
        Write-Host "  通过 npm 安装 @anthropic-ai/claude-code ..." -ForegroundColor Cyan
        npm install -g @anthropic-ai/claude-code@latest 2>$null
        if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true }
    }

    if ($installed) {
        Write-Host "  [OK] Claude Code 安装成功!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 安装失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "  排查建议:" -ForegroundColor Yellow
        Write-Host "  1. 确保网络通畅，可尝试切换手机热点" -ForegroundColor Yellow
        Write-Host "  2. 手动安装: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
        Write-Host "  3. 或访问 https://claude.ai/download 下载安装包" -ForegroundColor Yellow
        exit 1
    }
}

# ---- 验证 ----
Write-Host ""
Write-Host "--- 验证安装 ---" -ForegroundColor Blue

if ($DryRun) {
    Write-DryRun "验证: Get-Command claude"
} elseif (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  [OK] Claude Code 安装验证通过" -ForegroundColor Green
    Write-Host ""
    Write-Host "  第一次启动:" -ForegroundColor Green
    Write-Host "    PowerShell 中输入 claude 并回车" -ForegroundColor Green
    Write-Host "    浏览器会自动弹出，登录 Claude 账号即可" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] 找不到 claude 命令" -ForegroundColor Red
    Write-Host "  请关闭 PowerShell 窗口重新打开后再试" -ForegroundColor Yellow
    exit 1
}

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] 预览完成 — 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-claude-code.ps1" -ForegroundColor Cyan
}
Write-Host ""
