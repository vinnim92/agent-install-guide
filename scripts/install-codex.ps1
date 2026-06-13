# ============================================================
# Codex 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key
# 需要: Node.js >= 22（脚本会提示安装）
#
# 用法:
#   .\install-codex.ps1           普通模式（自动 fallback）
#   .\install-codex.ps1 -China    国内镜像模式（强制 npmmirror）
#   .\install-codex.ps1 -Help
#   .\install-codex.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-codex.ps1
# ============================================================

param(
    [switch]$Help,
    [switch]$DryRun,
    [switch]$China
)

try {
    [Console]::InputEncoding = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.Encoding]::UTF8
    chcp 65001 > $null
} catch {
}

$ErrorActionPreference = "Stop"
$AgentName = "Codex"
$AgentBin = "codex"
$OfficialUrl = "https://chatgpt.com/codex/install.ps1"
$LogFile = Join-Path $env:TEMP "agent-install-codex.log"
$InstallPath = ""  # official | npm-official | npm-mirror

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
    Write-Host "      需要 Node.js >= 22"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-codex.ps1           普通模式（官方->npm->镜像 自动 fallback）"
    Write-Host "  .\install-codex.ps1 -China    国内镜像模式（强制 npmmirror）"
    Write-Host "  .\install-codex.ps1 -Help     显示帮助"
    Write-Host "  .\install-codex.ps1 -DryRun   排查/预览（只看不装）"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-codex.ps1'
    Write-Host ""
    Write-Host "国内网络一键安装:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-codex.ps1 -China'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: codex"
    Write-Host ""
    Write-Host "安装失败？"
    Write-Host "  打开故障排查页面:"
    Write-Host "  https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
    Write-Host ""
    exit 0
}

# ---- Logging ----
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -FilePath $LogFile -Append -Encoding UTF8
}

# ---- 确认机制 ----
$skipConfirm = ($env:AGENT_INSTALL_YES -eq "1")

function Confirm-Action {
    param([string]$Prompt)
    if ($skipConfirm) {
        Write-Host "    [自动] $Prompt -> 自动确认" -ForegroundColor Cyan
        return $true
    }
    $response = Read-Host "    [?] $Prompt [Y/n]"
    if ($response -eq "" -or $response -eq "y" -or $response -eq "Y" -or $response -eq "yes") {
        return $true
    }
    return $false
}

function Write-DryRun { Write-Host "    [预演] 将执行: $args" -ForegroundColor Yellow }

# ---- npm 调用辅助 ----
function Get-NpmCmd {
    $npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if ($npmCmd) { return $npmCmd.Source }
    $npmExe = Get-Command npm.exe -ErrorAction SilentlyContinue
    if ($npmExe) { return $npmExe.Source }
    return $null
}

function Invoke-Npm {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )
    $npm = Get-NpmCmd
    if (-not $npm) { throw "未找到 npm.cmd。请确认 Node.js 已安装，并重新打开 PowerShell。" }
    & $npm @Arguments 2>&1 | Tee-Object -FilePath $LogFile -Append
}

# ---------- 端点检测 ----------
function Test-Endpoint {
    param([string]$Url)
    try { $null = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop; return $true }
    catch { return $false }
}

# ============ 安装前检查 ============
function Start-PreCheck {
    Write-Host ""
    Write-Host "  正在检查你的电脑环境..." -ForegroundColor Cyan
    Write-Host ""

    $modeLabel = if ($China) { "China (force npmmirror)" } else { "Normal (auto-fallback)" }
    "===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Out-File -FilePath $LogFile -Encoding UTF8
    "Agent: $AgentName" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    "Mode: $modeLabel" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    # 系统
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "    [OK] 系统: $($os.Caption)" -ForegroundColor Green
    Write-Host "    [OK] 架构: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green
    "System: $($os.Caption) | $env:PROCESSOR_ARCHITECTURE" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    # Node.js 版本
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nodeVer = (node -v)
        "Node.js: $nodeVer" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        $nv = $nodeVer.TrimStart('v')
        $parts = $nv.Split('.')
        $majorVer = if ($parts.Count -ge 1) { [int]$parts[0] } else { 0 }
        if ($majorVer -ge 22) {
            Write-Host "    [OK] Node.js $nodeVer (满足要求，将跳过安装)" -ForegroundColor Green
        } else {
            Write-Host "    [!]  Node.js $nodeVer 版本较低，需要 >= 22" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    [!]  Node.js 未安装，将提示安装 v22+" -ForegroundColor Yellow
        "Node.js: NOT FOUND" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }
    if (Get-NpmCmd) { $npmVer = (npm -v 2>$null); "npm: $npmVer" | Out-File -FilePath $LogFile -Append -Encoding UTF8 }

    # 已安装？
    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
        $ver = (& $AgentBin --version 2>&1 | Select-Object -First 1) -join ''
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
        Write-Host "    [->] $AgentName 尚未安装" -ForegroundColor Cyan
    }

    # 安装路径说明
    if ($China) {
        Write-Host "    [i] 国内镜像模式：跳过官方安装器，直接使用 npmmirror" -ForegroundColor Cyan
    } else {
        Write-Host "    [i] 普通模式：官方安装器 -> npm 官方源 -> npmmirror（自动 fallback）" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "  [OK] 系统检查完成" -ForegroundColor Green
    Write-Host ""

    if ($DryRun) {
        Write-Host "  以上为环境检查结果（-DryRun 模式，未执行实际安装）" -ForegroundColor Yellow
        exit 0
    }

    if (-not (Confirm-Action "是否继续安装 $AgentName ？")) {
        Write-Host "  已取消安装。有问题请看故障排查:" -ForegroundColor Yellow
        Write-Host "  https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
        exit 0
    }
}

# ---- Node.js 安装 ----
function Ensure-NodeJs {
    if ($DryRun) {
        $hasNode = Get-Command node -ErrorAction SilentlyContinue
        if ($hasNode) {
            $nv = (node -v).TrimStart('v'); $parts = $nv.Split('.'); $maj = if ($parts.Count -ge 1) { [int]$parts[0] } else { 0 }
            if ($maj -ge 22) { Write-DryRun "Node.js $nv 已满足，跳过" } else { Write-DryRun "提示安装 Node.js >= 22" }
        } else { Write-DryRun "提示安装 Node.js >= 22" }
        return
    }

    $needNode = $true
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nv = (node -v).TrimStart('v'); $parts = $nv.Split('.'); $maj = if ($parts.Count -ge 1) { [int]$parts[0] } else { 0 }
        if ($maj -ge 22) { $needNode = $false }
    }

    if ($needNode) {
        Write-Host ""
        Write-Host "  Node.js 版本不满足要求（需要 >= 22）" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  推荐方式: 手动下载 Node.js MSI 安装包（最可靠）" -ForegroundColor White
        Write-Host "    下载地址: https://nodejs.org" -ForegroundColor Cyan
        Write-Host "    选择 LTS (64-bit) .msi 下载并双击安装" -ForegroundColor Cyan
        Write-Host "    SHA256 校验码可在 https://nodejs.org 查看 SHASUMS256.txt" -ForegroundColor Cyan
        Write-Host ""

        if (Confirm-Action "是否尝试自动安装 Node.js？(推荐选 N，手动下载 MSI 更可靠)") {
            Write-Host "  正在安装 Node.js..." -ForegroundColor Cyan
            $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
            $hasScoop = Get-Command scoop -ErrorAction SilentlyContinue
            $hasChoco = Get-Command choco -ErrorAction SilentlyContinue

            if ($hasWinget) {
                winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Tee-Object -FilePath $LogFile -Append
                $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
            } elseif ($hasScoop) {
                scoop install nodejs 2>&1 | Tee-Object -FilePath $LogFile -Append
            } elseif ($hasChoco) {
                choco install nodejs -y 2>&1 | Tee-Object -FilePath $LogFile -Append
            } else {
                Write-Host "  [!] 未找到包管理器，请手动安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
                exit 1
            }
            if (Get-Command node -ErrorAction SilentlyContinue) {
                Write-Host "  [OK] Node.js 安装成功" -ForegroundColor Green
            } else {
                Write-Host "  [!] 已安装但需重启 PowerShell 后生效..." -ForegroundColor Yellow
            }
        } else {
            Write-Host "  请手动安装 Node.js 后重新运行本脚本" -ForegroundColor Yellow
            Write-Host "  下载地址: https://nodejs.org" -ForegroundColor Cyan
            exit 1
        }
    }
}

# ---- 网络探测 + 安装路径决策 ----
function Start-Install {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装 $AgentName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        if ($China) {
            Write-DryRun "China 模式: npm install -g @openai/codex --registry=https://registry.npmmirror.com"
        } else {
            Write-DryRun "普通模式: 官方脚本 -> npm 官方源 -> npmmirror (auto-fallback)"
        }
        return
    }

    Ensure-NodeJs

    # --- 网络探测 ---
    "=== Network Probe ===" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    $OfficialOk = $false; $NpmjsOk = $false; $NpmMirrorOk = $false

    Write-Host "  检测网络端点..." -ForegroundColor Cyan

    if (Test-Endpoint "https://chatgpt.com") {
        $OfficialOk = $true
        Write-Host "    [OK] 官方安装器可达" -ForegroundColor Green
        "  official installer: REACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } else {
        Write-Host "    [!]  官方安装器不可达" -ForegroundColor Yellow
        "  official installer: UNREACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    if (Test-Endpoint "https://registry.npmjs.org") {
        $NpmjsOk = $true
        Write-Host "    [OK] npm 官方源可达" -ForegroundColor Green
        "  registry.npmjs.org: REACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } else {
        Write-Host "    [!]  npm 官方源不可达" -ForegroundColor Yellow
        "  registry.npmjs.org: UNREACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    if (Test-Endpoint "https://registry.npmmirror.com") {
        $NpmMirrorOk = $true
        Write-Host "    [OK] npmmirror 国内镜像可达" -ForegroundColor Green
        "  registry.npmmirror.com: REACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } else {
        Write-Host "    [!]  npmmirror 国内镜像不可达" -ForegroundColor Yellow
        "  registry.npmmirror.com: UNREACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    if (Test-Endpoint "https://api.deepseek.com") { "  api.deepseek.com: REACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8 } else { "  api.deepseek.com: UNREACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8 }
    if (Test-Endpoint "https://github.com") { "  github.com: REACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8 } else { "  github.com: UNREACHABLE" | Out-File -FilePath $LogFile -Append -Encoding UTF8 }

    "=========================" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host ""

    # --- China 模式 ---
    if ($China) {
        Write-Host "  国内镜像模式：使用 npmmirror 安装..." -ForegroundColor Cyan
        "Install path: npm-mirror (China mode)" | Out-File -FilePath $LogFile -Append -Encoding UTF8

        $hasNpm = Get-NpmCmd
        if (-not $hasNpm) {
            Write-Host "  [FAIL] 未找到 npm。国内镜像模式需要 Node.js/npm" -ForegroundColor Red
            "ERROR: npm not found" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            Write-Host "  请先安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
            exit 1
        }
        if (-not $NpmMirrorOk) {
            Write-Host "  [FAIL] npmmirror 不可达" -ForegroundColor Red
            "ERROR: npmmirror unreachable" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            Write-Host "  国内网络排查建议:" -ForegroundColor Yellow
            Write-Host "  1. 切换手机热点 -> 重试" -ForegroundColor Yellow
            Write-Host "  2. 关闭/开启代理 -> 重试" -ForegroundColor Yellow
            Write-Host "  3. 重启路由器 -> 重试" -ForegroundColor Yellow
            exit 1
        }

        "  Install command: npm install -g @openai/codex --registry=https://registry.npmmirror.com" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        try {
            Invoke-Npm install -g @openai/codex --registry=https://registry.npmmirror.com
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $script:InstallPath = "npm-mirror"; Write-Host "  [OK] npm 镜像安装成功" -ForegroundColor Green; return }
        } catch { Write-Log "npm mirror install failed: $($_.Exception.Message)" }
        Write-Host "  [FAIL] npm 镜像安装失败" -ForegroundColor Red
        Write-Host "  排查: 查看日志 $LogFile" -ForegroundColor Yellow
        exit 1
    }

    # --- 普通模式：3 层 fallback ---
    # Tier 1: 官方安装器
    if ($OfficialOk) {
        Write-Host "  路径 1/3：使用官方安装器..." -ForegroundColor Cyan
        "Install path: official installer" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        $script:InstallPath = "official"
        $installed = $false

        "  Install command: Invoke-RestMethod $OfficialUrl | Invoke-Expression" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        try {
            Invoke-RestMethod -Uri $OfficialUrl -TimeoutSec 30 | Invoke-Expression 2>&1 | Tee-Object -FilePath $LogFile -Append
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
        } catch { Write-Log "Official PS installer failed: $($_.Exception.Message)" }

        if ($installed) { Write-Host "  [OK] 官方安装器安装成功" -ForegroundColor Green; return }
        Write-Host "    [!]  官方安装器失败，自动尝试下一路径..." -ForegroundColor Yellow
        "  official installer FAILED, falling back" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    # Tier 2: npm 官方源
    if ($NpmjsOk) {
        $hasNpm = Get-NpmCmd
        if ($hasNpm) {
            Write-Host "  路径 2/3：使用 npm 官方源安装..." -ForegroundColor Cyan
            "Install path: npm-official" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            $script:InstallPath = "npm-official"

            "  Install command: npm install -g @openai/codex --registry=https://registry.npmjs.org" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                Invoke-Npm install -g @openai/codex --registry=https://registry.npmjs.org
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { Write-Host "  [OK] npm 官方源安装成功" -ForegroundColor Green; return }
            } catch { Write-Log "npm-official failed: $($_.Exception.Message)" }
            Write-Host "    [!]  npm 官方源安装失败，自动尝试下一路径..." -ForegroundColor Yellow
            "  npm-official FAILED, falling back" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        } else {
            Write-Host "    [!]  npm 官方源可达，但未找到 npm，跳过此路径" -ForegroundColor Yellow
            "  npm-official SKIPPED (npm not found)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }
    }

    # Tier 3: npmmirror
    if ($NpmMirrorOk) {
        $hasNpm = Get-NpmCmd
        if ($hasNpm) {
            Write-Host "  路径 3/3：使用 npmmirror 国内镜像安装..." -ForegroundColor Cyan
            "Install path: npm-mirror (auto-fallback)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            $script:InstallPath = "npm-mirror"

            "  Install command: npm install -g @openai/codex --registry=https://registry.npmmirror.com" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                Invoke-Npm install -g @openai/codex --registry=https://registry.npmmirror.com
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { Write-Host "  [OK] npmmirror 镜像安装成功" -ForegroundColor Green; return }
            } catch { Write-Log "npm-mirror failed: $($_.Exception.Message)" }
            Write-Host "    [FAIL] npmmirror 安装也失败了" -ForegroundColor Red
            "  npm-mirror FAILED" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        } else {
            "  npm-mirror SKIPPED (npm not found)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }
    }

    # 全失败
    Write-Host "  [FAIL] 所有安装路径均不可用" -ForegroundColor Red
    "FATAL: All install paths exhausted" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host ""
    Write-Host "  网络排查建议:" -ForegroundColor Yellow
    Write-Host "  1. 切换手机热点 -> 重试" -ForegroundColor Yellow
    Write-Host "  2. 关闭/开启代理 -> 重试" -ForegroundColor Yellow
    Write-Host "  3. 确认已安装 Node.js >= 22: https://nodejs.org" -ForegroundColor Yellow
    Write-Host "  4. 使用国内镜像模式: .\install-codex.ps1 -China" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  日志文件: $LogFile" -ForegroundColor Yellow
    Write-Host "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
    exit 1
}

# ---- 验证 ----
function Start-Verify {
    Write-Host ""
    Write-Host "--- 验证安装 ---" -ForegroundColor Blue

    if ($DryRun) { Write-DryRun "验证: Get-Command $AgentBin"; return }

    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
        $ver = (& $AgentBin --version 2>&1 | Select-Object -First 1) -join ''
        Write-Host "  [OK] $AgentName 安装完成！$ver" -ForegroundColor Green
        "Result: SUCCESS | Version: $ver | Install path: $InstallPath" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } else {
        Write-Host "  [FAIL] 找不到 $AgentBin 命令" -ForegroundColor Red
        "Result: FAILED (binary not found)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        Write-Host "  1. 关闭 PowerShell 窗口，重新打开后再试" -ForegroundColor Yellow
        Write-Host "  2. 日志: $LogFile" -ForegroundColor Yellow
        Write-Host "  3. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
        exit 1
    }
}

# ---- Codex 登录方式 ----
function Start-CodexLoginConfig {
    if ($DryRun) { Write-Host "    [预演] 将执行: 提示选择 Codex 登录方式" -ForegroundColor Yellow; return }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Codex 登录方式" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Codex 支持两种登录方式：" -ForegroundColor White
    Write-Host ""
    Write-Host "  方式一：官方账号登录" -ForegroundColor White
    Write-Host "    适合已有 ChatGPT / OpenAI 账号的用户。" -ForegroundColor White
    Write-Host "    终端输入 codex login，浏览器自动弹出登录页。" -ForegroundColor White
    Write-Host ""
    Write-Host "  方式二：API Key 登录" -ForegroundColor White
    Write-Host "    适合使用 OpenAI API Key 的用户。" -ForegroundColor White
    Write-Host ""
    Write-Host "    在终端依次运行:" -ForegroundColor White
    Write-Host '      $env:OPENAI_API_KEY="你的 OpenAI API Key"' -ForegroundColor Cyan
    Write-Host "      codex login --with-api-key" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  请选择适合你的方式。安装包负责安装和引导，不提供账号或 API Key。" -ForegroundColor White
    Write-Host ""
}

# ==================== 主流程 ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Codex 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($China) {
    Write-Host "  国内镜像模式 - 强制 npmmirror" -ForegroundColor Yellow
} else {
    Write-Host "  普通模式 - 官方 -> npm -> 镜像 自动 fallback" -ForegroundColor Green
}
if ($DryRun) { Write-Host "  [dry-run 模式] 只看不装" -ForegroundColor Yellow }

Start-PreCheck
Start-Install
Start-Verify
Start-CodexLoginConfig

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] dry-run 完成 - 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-codex.ps1" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "  安装日志: $LogFile" -ForegroundColor Cyan
Write-Host ""
