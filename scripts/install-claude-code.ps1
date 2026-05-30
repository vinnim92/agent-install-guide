# ============================================================
# Claude Code 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 推荐: DeepSeek API Key（国内获取方便、便宜）
# 也可: Claude 官方账号 或 Anthropic API Key
# Claude Code 自带运行时，无需单独安装 Node.js
#
# 用法:
#   iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.6/scripts/install-claude-code.ps1 | iex
#   .\install-claude-code.ps1 -Help
#   .\install-claude-code.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1
# ============================================================

param(
    [switch]$Help,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$AgentName = "Claude Code"
$AgentBin = "claude"
$OfficialUrl = "https://claude.ai/install.ps1"

# ---- Help ----
if ($Help) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Claude Code 安装脚本 (Windows)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "安装: Claude Code"
    Write-Host "系统: Windows 10/11"
    Write-Host "推荐: DeepSeek API Key"
    Write-Host "也可: Claude 官方账号 或 Anthropic API Key"
    Write-Host "      无需单独安装 Node.js"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-claude-code.ps1           正常安装（自动检查环境）"
    Write-Host "  .\install-claude-code.ps1 -Help     显示帮助"
    Write-Host "  .\install-claude-code.ps1 -DryRun   排查/预览（只看不装）"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: claude"
    Write-Host ""
    Write-Host "安装失败？"
    Write-Host "  打开故障排查页面:"
    Write-Host "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.6/docs/support.html"
    Write-Host ""
    exit 0
}

# ---- 确认机制 ----
$skipConfirm = ($env:AGENT_INSTALL_YES -eq "1")

function Confirm-Action {
    param([string]$Prompt)
    if ($skipConfirm) {
        Write-Host "    [自动] $Prompt → 自动确认" -ForegroundColor Cyan
        return $true
    }
    $response = Read-Host "    [?] $Prompt [Y/n]"
    if ($response -eq "" -or $response -eq "y" -or $response -eq "Y" -or $response -eq "yes") {
        return $true
    }
    return $false
}

function Write-DryRun { Write-Host "    [预演] 将执行: $args" -ForegroundColor Yellow }

# ============ 安装前自动检查 ============
function Start-PreCheck {
    Write-Host ""
    Write-Host "  正在检查你的电脑环境..." -ForegroundColor Cyan
    Write-Host ""

    # 1. 系统
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "    [OK] 系统: $($os.Caption)" -ForegroundColor Green
    Write-Host "    [OK] 架构: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green

    # 2. 包管理器
    if (-not $DryRun) {
        $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
        if ($hasWinget) { Write-Host "    [OK] winget 可用" -ForegroundColor Green }
    } else {
        Write-DryRun "检查 winget 是否可用"
    }

    # 3. 是否已安装
    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
        $ver = (& $AgentBin --version 2>$null | Select-Object -First 1) -join ''
        if (-not $ver) { $ver = "未知版本" }
        Write-Host "    [OK] $AgentName 已安装 ($ver)" -ForegroundColor Green
        Write-Host ""
        if (Confirm-Action "是否重新安装/升级到最新版？") {
            Write-Host "    将继续安装最新版..." -ForegroundColor Cyan
        } else {
            Write-Host "    已取消。在 PowerShell 输入 $AgentBin 即可启动。" -ForegroundColor Yellow
            exit 0
        }
    } else {
        Write-Host "    [→] $AgentName 尚未安装" -ForegroundColor Cyan
    }

    # 4. 安装方式
    Write-Host "    [i] 将优先使用官方安装方式 ($OfficialUrl)" -ForegroundColor Cyan
    Write-Host "    [OK] $AgentName 自带运行时，无需安装 Node.js" -ForegroundColor Green

    Write-Host ""
    Write-Host "  [OK] 系统检查完成" -ForegroundColor Green
    Write-Host "  [OK] 安装准备完成" -ForegroundColor Green
    Write-Host ""

    Write-Host "  接下来将安装: $AgentName" -ForegroundColor White
    Write-Host "  安装方式: 官方安装脚本" -ForegroundColor White
    Write-Host "  推荐配置: DeepSeek API Key（安装后可配置）" -ForegroundColor White
    Write-Host ""

    if ($DryRun) {
        Write-Host "  以上为环境检查结果（-DryRun 模式，未执行实际安装）" -ForegroundColor Yellow
        exit 0
    }

    if (-not (Confirm-Action "是否继续安装 $AgentName ？")) {
        Write-Host "  已取消安装。有问题请看故障排查:" -ForegroundColor Yellow
        Write-Host "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.6/docs/support.html"
        exit 0
    }
}

# ---- DeepSeek API 配置 ----
function Start-DeepSeekConfig {
    if ($DryRun) {
        Write-Host "    [预演] 将执行: 提示配置 DeepSeek API（可选）" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  DeepSeek API 配置（可选）" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  本手册默认采用 DeepSeek API 方案。" -ForegroundColor White
    Write-Host "  DeepSeek 对国内用户更友好：注册方便、价格便宜。" -ForegroundColor White
    Write-Host "  你需要准备自己的 DeepSeek API Key。" -ForegroundColor White
    Write-Host ""
    Write-Host "  获取方式: 浏览器访问 platform.deepseek.com" -ForegroundColor Cyan
    Write-Host "           注册 -> API Keys -> 创建 Key（以 sk- 开头）" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Confirm-Action "是否现在配置 DeepSeek API？")) {
        Write-Host ""
        Write-Host "  已跳过 DeepSeek API 配置。" -ForegroundColor Yellow
        Write-Host "  稍后可以重新运行本脚本，或在 PowerShell 手动设置环境变量。" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  如果你已有 Claude 官方账号，也可以直接运行:" -ForegroundColor Yellow
        Write-Host "    claude login" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "  请输入你的 DeepSeek API Key（以 sk- 开头）:" -ForegroundColor Cyan

    $apiKey = Read-Host -AsSecureString "  API Key"
    $apiKeyPlain = [System.Net.NetworkCredential]::new("", $apiKey).Password

    if ([string]::IsNullOrWhiteSpace($apiKeyPlain)) {
        Write-Host "  [FAIL] API Key 不能为空，已跳过配置。" -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "  正在配置环境变量..." -ForegroundColor Cyan

    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://api.deepseek.com/anthropic", "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_AUTH_TOKEN", $apiKeyPlain, "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", "deepseek-v4-pro", "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_DEFAULT_OPUS_MODEL", "deepseek-v4-pro", "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_DEFAULT_SONNET_MODEL", "deepseek-v4-pro", "User")
    [System.Environment]::SetEnvironmentVariable("ANTHROPIC_DEFAULT_HAIKU_MODEL", "deepseek-v4-flash", "User")
    [System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_SUBAGENT_MODEL", "deepseek-v4-flash", "User")
    [System.Environment]::SetEnvironmentVariable("CLAUDE_CODE_EFFORT_LEVEL", "max", "User")

    # 当前会话立即生效
    $env:ANTHROPIC_BASE_URL = "https://api.deepseek.com/anthropic"
    $env:ANTHROPIC_AUTH_TOKEN = $apiKeyPlain
    $env:ANTHROPIC_MODEL = "deepseek-v4-pro"
    $env:ANTHROPIC_DEFAULT_OPUS_MODEL = "deepseek-v4-pro"
    $env:ANTHROPIC_DEFAULT_SONNET_MODEL = "deepseek-v4-pro"
    $env:ANTHROPIC_DEFAULT_HAIKU_MODEL = "deepseek-v4-flash"
    $env:CLAUDE_CODE_SUBAGENT_MODEL = "deepseek-v4-flash"
    $env:CLAUDE_CODE_EFFORT_LEVEL = "max"

    Write-Host ""
    Write-Host "  [OK] DeepSeek API 配置完成！" -ForegroundColor Green
    Write-Host "  配置已写入用户环境变量（永久生效）" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  现在可以输入 claude 启动，它将使用 DeepSeek 作为后端模型。" -ForegroundColor Green
    Write-Host ""
}

# ---- 安装 ----
function Start-Install {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装 $AgentName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-DryRun "winget install Anthropic.ClaudeCode"
        Write-DryRun "Invoke-RestMethod $OfficialUrl | Invoke-Expression"
        Write-DryRun "验证: Get-Command $AgentBin"
        return
    }

    $installed = $false
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    $hasNpm = Get-Command npm -ErrorAction SilentlyContinue

    # 方法1: winget
    if ($hasWinget -and -not $installed) {
        Write-Host "  尝试 winget 安装..." -ForegroundColor Cyan
        winget install Anthropic.ClaudeCode --silent --accept-package-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
    }

    # 方法2: 官方 PowerShell 脚本
    if (-not $installed) {
        Write-Host "  尝试官方脚本安装..." -ForegroundColor Cyan
        try {
            Invoke-RestMethod -Uri $OfficialUrl -TimeoutSec 30 | Invoke-Expression 2>$null
            $localBin = Join-Path $env:USERPROFILE ".local\bin"
            $env:Path = "$localBin;$env:Path"
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
        } catch {
            Write-Host "  [!] 官方脚本不可用，改用 npm..." -ForegroundColor Yellow
        }
    }

    # 方法3: npm fallback
    if (-not $installed -and $hasNpm) {
        Write-Host "  通过 npm 安装..." -ForegroundColor Cyan
        npm install -g @anthropic-ai/claude-code@latest 2>$null
        if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
    }

    if ($installed) {
        Write-Host "  [OK] $AgentName 安装成功!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 安装失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "  排查建议:" -ForegroundColor Yellow
        Write-Host "  1. 确保网络通畅，可尝试切换手机热点" -ForegroundColor Yellow
        Write-Host "  2. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.6/docs/support.html" -ForegroundColor Yellow
        exit 1
    }
}

# ---- 验证 ----
function Start-Verify {
    Write-Host ""
    Write-Host "--- 验证安装 ---" -ForegroundColor Blue

    if ($DryRun) {
        Write-DryRun "验证: Get-Command $AgentBin"
        return
    }

    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
        Write-Host "  [OK] $AgentName 安装验证通过" -ForegroundColor Green
        Write-Host ""
        Write-Host "  启动方式:" -ForegroundColor Green
        Write-Host "    PowerShell 中输入 claude 并回车" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 找不到 claude 命令" -ForegroundColor Red
        Write-Host "  1. 关闭 PowerShell 窗口，重新打开后再试" -ForegroundColor Yellow
        Write-Host "  2. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.6/docs/support.html" -ForegroundColor Yellow
        exit 1
    }
}

# ==================== 主流程 ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "  [dry-run 模式] 只看不装" -ForegroundColor Yellow
}

Start-PreCheck
Start-Install
Start-Verify
Start-DeepSeekConfig

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] dry-run 完成 — 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-claude-code.ps1" -ForegroundColor Cyan
}
Write-Host ""
