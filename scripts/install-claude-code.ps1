# ============================================================
# Claude Code 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 推荐: DeepSeek API Key（国内获取方便、便宜）
# 也可: Claude 官方账号 或 Anthropic API Key
# Claude Code 自带运行时，无需单独安装 Node.js
#
# 用法:
#   .\install-claude-code.ps1           普通模式（自动 fallback）
#   .\install-claude-code.ps1 -China    国内镜像模式（强制 npmmirror）
#   .\install-claude-code.ps1 -Help
#   .\install-claude-code.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1
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
$AgentName = "Claude Code"
$AgentBin = "claude"
$OfficialUrl = "https://claude.ai/install.ps1"
$LogFile = Join-Path $env:TEMP "agent-install-claude-code.log"
$InstallPath = ""  # official | npm-official | npm-mirror

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
    Write-Host "  .\install-claude-code.ps1           普通模式（官方→npm→镜像 自动 fallback）"
    Write-Host "  .\install-claude-code.ps1 -China    国内镜像模式（强制 npmmirror）"
    Write-Host "  .\install-claude-code.ps1 -Help     显示帮助"
    Write-Host "  .\install-claude-code.ps1 -DryRun   排查/预览（只看不装）"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1'
    Write-Host ""
    Write-Host "国内网络一键安装:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-claude-code.ps1 -China'
    Write-Host ""
    Write-Host "安装后启动:"
    Write-Host "  PowerShell 输入: claude"
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

# ---- npm 调用辅助（避免 npm.ps1 执行策略拦截） ----
function Get-NpmCmd {
    $npmCmd = Get-Command npm.cmd -ErrorAction SilentlyContinue
    if ($npmCmd) {
        return $npmCmd.Source
    }

    $npmExe = Get-Command npm.exe -ErrorAction SilentlyContinue
    if ($npmExe) {
        return $npmExe.Source
    }

    return $null
}

function Invoke-Npm {
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Arguments
    )

    $npm = Get-NpmCmd

    if (-not $npm) {
        throw "未找到 npm.cmd。请确认 Node.js 已安装，并重新打开 PowerShell。"
    }

    & $npm @Arguments 2>&1 | Tee-Object -FilePath $LogFile -Append
}

# ---------- 端点连通性检测 ----------
function Test-Endpoint {
    param([string]$Url)
    try {
        $null = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ============ 安装前自动检查 ============
function Start-PreCheck {
    Write-Host ""
    Write-Host "  正在检查你的电脑环境..." -ForegroundColor Cyan
    Write-Host ""

    # 初始化日志
    $modeLabel = if ($China) { "China (force npmmirror)" } else { "Normal (auto-fallback)" }
    "===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Out-File -FilePath $LogFile -Encoding UTF8
    "Agent: $AgentName" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    "Mode: $modeLabel" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    # 1. 系统
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "    [OK] 系统: $($os.Caption)" -ForegroundColor Green
    Write-Host "    [OK] 架构: $env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green
    "System: $($os.Caption) | $env:PROCESSOR_ARCHITECTURE" | Out-File -FilePath $LogFile -Append -Encoding UTF8

    # 2. Node.js / npm 版本（仅记录）
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nodeVer = (node -v)
        "Node.js: $nodeVer" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }
    if (Get-NpmCmd) {
        $npmVer = (npm -v 2>$null)
        "npm: $npmVer" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    }

    # 3. 是否已安装
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

    # 4. 安装路径说明
    if ($China) {
        Write-Host "    [i] 国内镜像模式：跳过官方安装器，直接使用 npmmirror" -ForegroundColor Cyan
    } else {
        Write-Host "    [i] 普通模式：官方安装器 -> npm 官方源 -> npmmirror（自动 fallback）" -ForegroundColor Cyan
    }
    Write-Host "    [OK] $AgentName 自带运行时，无需安装 Node.js" -ForegroundColor Green

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

# ---- 网络探测 + 安装路径决策 ----
function Start-Install {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装 $AgentName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        if ($China) {
            Write-DryRun "China 模式: npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com"
        } else {
            Write-DryRun "普通模式: winget/官方脚本 -> npm 官方源 -> npmmirror (auto-fallback)"
        }
        return
    }

    # --- 网络探测 ---
    "=== Network Probe ===" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    $OfficialOk = $false; $NpmjsOk = $false; $NpmMirrorOk = $false

    Write-Host "  检测网络端点..." -ForegroundColor Cyan

    if (Test-Endpoint "https://claude.ai") {
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

    # --- China 模式：强制 npmmirror ---
    if ($China) {
        Write-Host "  国内镜像模式：使用 npmmirror 安装..." -ForegroundColor Cyan
        "Install path: npm-mirror (China mode)" | Out-File -FilePath $LogFile -Append -Encoding UTF8

        $hasNpm = Get-NpmCmd
        if (-not $hasNpm) {
            Write-Host "  [FAIL] 未找到 npm。国内镜像模式需要 Node.js/npm" -ForegroundColor Red
            "ERROR: npm not found, China mode cannot proceed" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            Write-Host ""
            Write-Host "  请先安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
            Write-Host "  下载 MSI 安装后，重新运行本脚本。" -ForegroundColor Yellow
            exit 1
        }

        if (-not $NpmMirrorOk) {
            Write-Host "  [FAIL] npmmirror 国内镜像不可达" -ForegroundColor Red
            "ERROR: npmmirror unreachable in China mode" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            Write-Host ""
            Write-Host "  国内网络排查建议:" -ForegroundColor Yellow
            Write-Host "  1. 切换手机热点 -> 重试" -ForegroundColor Yellow
            Write-Host "  2. 关闭/开启代理 -> 重试" -ForegroundColor Yellow
            Write-Host "  3. 重启路由器 -> 重试" -ForegroundColor Yellow
            Write-Host "  4. 稍后重试（镜像可能临时故障）" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  日志: $LogFile" -ForegroundColor Yellow
            exit 1
        }

        "  Install command: npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        try {
            Invoke-Npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
                $script:InstallPath = "npm-mirror"
                Write-Host "  [OK] npm 镜像安装成功" -ForegroundColor Green
                return
            }
        } catch {
            Write-Host "  [FAIL] npm 镜像安装失败: $($_.Exception.Message)" -ForegroundColor Red
            "ERROR: npm mirror install failed" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }

        Write-Host ""
        Write-Host "  排查: 查看日志 $LogFile" -ForegroundColor Yellow
        Write-Host "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
        exit 1
    }

    # --- 普通模式：3 层自动 fallback ---
    # Tier 1: 官方安装器（winget + 官方脚本）
    if ($OfficialOk) {
        Write-Host "  路径 1/3：使用官方安装器..." -ForegroundColor Cyan
        "Install path: official installer" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        $script:InstallPath = "official"

        $installed = $false

        # winget
        $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
        if ($hasWinget) {
            "  Install command: winget install Anthropic.ClaudeCode --silent" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                winget install Anthropic.ClaudeCode --silent --accept-package-agreements --accept-source-agreements --disable-interactivity 2>&1 | Tee-Object -FilePath $LogFile -Append
                $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
            } catch {
                Write-Log "winget failed: $($_.Exception.Message)"
            }
        }

        # 官方 PowerShell 脚本
        if (-not $installed) {
            "  Install command: Invoke-RestMethod $OfficialUrl | Invoke-Expression" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                Invoke-RestMethod -Uri $OfficialUrl -TimeoutSec 30 | Invoke-Expression 2>&1 | Tee-Object -FilePath $LogFile -Append
                $localBin = Join-Path $env:USERPROFILE ".local\bin"
                $env:Path = "$localBin;$env:Path"
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
            } catch {
                Write-Log "Official PS installer failed: $($_.Exception.Message)"
            }
        }

        if ($installed) {
            Write-Host "  [OK] 官方安装器安装成功" -ForegroundColor Green
            return
        }
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

            "  Install command: npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmjs.org" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                Invoke-Npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmjs.org
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
                    Write-Host "  [OK] npm 官方源安装成功" -ForegroundColor Green
                    return
                }
            } catch {
                Write-Log "npm-official failed: $($_.Exception.Message)"
            }
            Write-Host "    [!]  npm 官方源安装失败，自动尝试下一路径..." -ForegroundColor Yellow
            "  npm-official FAILED, falling back" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        } else {
            Write-Host "    [!]  npm 官方源可达，但未找到 npm，跳过此路径" -ForegroundColor Yellow
            "  npm-official SKIPPED (npm not found)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }
    }

    # Tier 3: npmmirror 国内镜像
    if ($NpmMirrorOk) {
        $hasNpm = Get-NpmCmd
        if ($hasNpm) {
            Write-Host "  路径 3/3：使用 npmmirror 国内镜像安装..." -ForegroundColor Cyan
            "Install path: npm-mirror (auto-fallback)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            $script:InstallPath = "npm-mirror"

            "  Install command: npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com" | Out-File -FilePath $LogFile -Append -Encoding UTF8
            try {
                Invoke-Npm install -g @anthropic-ai/claude-code@latest --registry=https://registry.npmmirror.com
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
                    Write-Host "  [OK] npmmirror 镜像安装成功" -ForegroundColor Green
                    return
                }
            } catch {
                Write-Log "npm-mirror failed: $($_.Exception.Message)"
            }
            Write-Host "    [FAIL] npmmirror 安装也失败了" -ForegroundColor Red
            "  npm-mirror FAILED" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        } else {
            Write-Host "    [!]  npmmirror 可达，但未找到 npm，跳过此路径" -ForegroundColor Yellow
            "  npm-mirror SKIPPED (npm not found)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        }
    }

    # 全都失败
    Write-Host "  [FAIL] 所有安装路径均不可用" -ForegroundColor Red
    "FATAL: All install paths exhausted" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    Write-Host ""
    Write-Host "  网络排查建议:" -ForegroundColor Yellow
    Write-Host "  1. 切换手机热点 -> 重试" -ForegroundColor Yellow
    Write-Host "  2. 关闭/开启代理 -> 重试" -ForegroundColor Yellow
    Write-Host "  3. 确认已安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
    Write-Host "  4. 使用国内镜像模式: .\install-claude-code.ps1 -China" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  日志文件: $LogFile" -ForegroundColor Yellow
    Write-Host "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
    exit 1
}

# ---- 验证 ----
function Start-Verify {
    Write-Host ""
    Write-Host "--- 验证安装 ---" -ForegroundColor Blue

    if ($DryRun) {
        Write-DryRun "验证: Get-Command $AgentBin"
        return
    }

    $localBin = Join-Path $env:USERPROFILE ".local\bin"
    $env:Path = "$localBin;$env:Path"

    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
        $ver = (& $AgentBin --version 2>&1 | Select-Object -First 1) -join ''
        Write-Host "  [OK] $AgentName 安装完成！$ver" -ForegroundColor Green
        "Result: SUCCESS | Version: $ver | Install path: $InstallPath" | Out-File -FilePath $LogFile -Append -Encoding UTF8
    } else {
        Write-Host "  [FAIL] 找不到 $AgentBin 命令" -ForegroundColor Red
        "Result: FAILED (binary not found after install)" | Out-File -FilePath $LogFile -Append -Encoding UTF8
        Write-Host "  1. 关闭 PowerShell 窗口，重新打开后再试" -ForegroundColor Yellow
        Write-Host "  2. 日志: $LogFile" -ForegroundColor Yellow
        Write-Host "  3. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
        exit 1
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

# ==================== 主流程 ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Claude Code 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($China) {
    Write-Host "  国内镜像模式 - 强制 npmmirror" -ForegroundColor Yellow
} else {
    Write-Host "  普通模式 - 官方 -> npm -> 镜像 自动 fallback" -ForegroundColor Green
}
if ($DryRun) {
    Write-Host "  [dry-run 模式] 只看不装" -ForegroundColor Yellow
}

Start-PreCheck
Start-Install
Start-Verify
Start-DeepSeekConfig

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] dry-run 完成 - 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-claude-code.ps1" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "  安装日志: $LogFile" -ForegroundColor Cyan
Write-Host ""
