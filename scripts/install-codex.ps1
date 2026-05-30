# ============================================================
# Codex 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key
# 需要: Node.js >= 22（脚本会自动安装）
#
# 用法:
#   iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/scripts/install-codex.ps1 | iex
#   .\install-codex.ps1 -Help
#   .\install-codex.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-codex.ps1
# ============================================================

param(
    [switch]$Help,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$AgentName = "Codex"
$AgentBin = "codex"
$OfficialUrl = "https://chatgpt.com/codex/install.ps1"

# ---- Help ----
if ($Help) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  Codex 安装脚本 (Windows)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "安装: Codex CLI（OpenAI 出品）"
    Write-Host "系统: Windows 10/11"
    Write-Host "需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key"
    Write-Host "      需要 Node.js >= 22（脚本会自动安装）"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-codex.ps1           正常安装（自动检查环境）"
    Write-Host "  .\install-codex.ps1 -Help     显示帮助"
    Write-Host "  .\install-codex.ps1 -DryRun   排查/预览（只看不装）"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-codex.ps1'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: codex"
    Write-Host ""
    Write-Host "安装失败？"
    Write-Host "  打开故障排查页面:"
    Write-Host "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/docs/support.html"
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
        $hasScoop = Get-Command scoop -ErrorAction SilentlyContinue
        if ($hasWinget) { Write-Host "    [OK] winget 可用" -ForegroundColor Green }
        if ($hasScoop)  { Write-Host "    [OK] Scoop 可用" -ForegroundColor Green }
    } else {
        Write-DryRun "检查 winget/scoop 包管理器"
    }

    # 3. Node.js
    if ($DryRun) {
        Write-DryRun "检查 Node.js 版本 (需要 >= 22)"
    } else {
        $hasNode = Get-Command node -ErrorAction SilentlyContinue
        if ($hasNode) {
            $nodeVer = (node -v).TrimStart('v')
            $majorVer = [int]($nodeVer.Split('.')[0])
            if ($majorVer -ge 22) {
                Write-Host "    [OK] Node.js v$nodeVer (满足要求)" -ForegroundColor Green
            } else {
                Write-Host "    [!] Node.js v$nodeVer 版本较低，将自动安装 v22+" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    [!] Node.js 未安装，将自动安装 v22+" -ForegroundColor Yellow
        }
    }

    # 4. 是否已安装
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

    # 5. 安装方式
    Write-Host "    [i] 将优先使用官方安装方式 ($OfficialUrl)" -ForegroundColor Cyan

    Write-Host ""
    Write-Host "  [OK] 系统检查完成" -ForegroundColor Green
    Write-Host "  [OK] 安装准备完成" -ForegroundColor Green
    Write-Host ""

    Write-Host "  接下来将安装: $AgentName" -ForegroundColor White
    Write-Host "  可能需要: 自动安装 Node.js（如果需要）" -ForegroundColor White
    Write-Host "  需要准备: ChatGPT 账号或 OpenAI API Key" -ForegroundColor White
    Write-Host ""

    if ($DryRun) {
        Write-Host "  以上为环境检查结果（-DryRun 模式，未执行实际安装）" -ForegroundColor Yellow
        exit 0
    }

    if (-not (Confirm-Action "是否继续安装 $AgentName ？")) {
        Write-Host "  已取消安装。有问题请看故障排查:" -ForegroundColor Yellow
        Write-Host "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/docs/support.html"
        exit 0
    }
}

# ---- 安装 Node.js ----
function Install-NodeIfNeeded {
    if ($DryRun) {
        Write-DryRun "检查 node 版本，如需安装则 winget install OpenJS.NodeJS.LTS"
        return
    }

    $needNode = $true
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nodeVer = (node -v).TrimStart('v')
        $majorVer = [int]($nodeVer.Split('.')[0])
        if ($majorVer -ge 22) {
            $needNode = $false
        }
    }

    if ($needNode) {
        if (-not (Confirm-Action "即将安装 Node.js v22+，是否继续？")) {
            Write-Host "  [FAIL] Node.js 是 $AgentName 的必要依赖，无法跳过" -ForegroundColor Red
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
            Write-Host "  [!] 未找到包管理器，请手动安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
            exit 1
        }
        if (Get-Command node -ErrorAction SilentlyContinue) {
            Write-Host "  [OK] Node.js 安装成功" -ForegroundColor Green
        } else {
            Write-Host "  [!] 已安装但需重启后生效..." -ForegroundColor Yellow
        }
    }
}

# ---- 安装 ----
function Start-Install {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装 $AgentName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        Write-DryRun "官方脚本: Invoke-RestMethod $OfficialUrl | Invoke-Expression"
        Write-DryRun "fallback: npm install -g @openai/codex"
        Write-DryRun "验证: Get-Command $AgentBin"
        return
    }

    Install-NodeIfNeeded

    $installed = $false

    # 方法1: 官方 installer（优先）
    Write-Host "  尝试官方脚本安装..." -ForegroundColor Cyan
    try {
        Invoke-RestMethod -Uri $OfficialUrl -TimeoutSec 30 | Invoke-Expression 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
    } catch {
        Write-Host "  [!] 官方脚本不可用，改用 npm..." -ForegroundColor Yellow
    }

    # 方法2: npm fallback
    if (-not $installed) {
        $hasNpm = Get-Command npm -ErrorAction SilentlyContinue
        if ($hasNpm) {
            Write-Host "  通过 npm 安装..." -ForegroundColor Cyan
            npm install -g @openai/codex 2>$null
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
        }
    }

    if ($installed) {
        Write-Host "  [OK] $AgentName 安装成功!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 安装失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "  排查建议:" -ForegroundColor Yellow
        Write-Host "  1. 确保网络通畅，可尝试切换手机热点" -ForegroundColor Yellow
        Write-Host "  2. 检查 Node.js: node -v (需要 >= 22)" -ForegroundColor Yellow
        Write-Host "  3. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/docs/support.html" -ForegroundColor Yellow
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
    } else {
        Write-Host "  [FAIL] 找不到 codex 命令" -ForegroundColor Red
        Write-Host "  1. 关闭 PowerShell 窗口，重新打开后再试" -ForegroundColor Yellow
        Write-Host "  2. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.7/docs/support.html" -ForegroundColor Yellow
        exit 1
    }
}

# ---- Codex 登录方式选择 ----
function Start-CodexLogin {
    if ($DryRun) {
        Write-Host "    [预演] 将执行: 提示选择 Codex 登录方式" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Codex 登录方式" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Codex 支持两种登录方式：" -ForegroundColor White
    Write-Host ""
    Write-Host "  方式一：官方账号登录" -ForegroundColor Yellow
    Write-Host "    适合已有 ChatGPT / OpenAI 账号的用户。" -ForegroundColor White
    Write-Host "    PowerShell 输入 codex login，浏览器自动弹出登录页。" -ForegroundColor White
    Write-Host ""
    Write-Host "  方式二：API Key 登录" -ForegroundColor Yellow
    Write-Host "    适合使用 OpenAI API Key 的用户。" -ForegroundColor White
    Write-Host ""
    Write-Host "    在 PowerShell 依次运行:" -ForegroundColor White
    Write-Host '      $env:OPENAI_API_KEY="你的 OpenAI API Key"' -ForegroundColor Cyan
    Write-Host '      $env:OPENAI_API_KEY | codex login --with-api-key' -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  请选择适合你的方式。安装包负责安装和引导，不提供账号或 API Key。" -ForegroundColor White
    Write-Host ""
}

# ==================== 主流程 ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Codex 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "  [dry-run 模式] 只看不装" -ForegroundColor Yellow
}

Start-PreCheck
Start-Install
Start-Verify
Start-CodexLogin

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] dry-run 完成 — 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-codex.ps1" -ForegroundColor Cyan
}
Write-Host ""
