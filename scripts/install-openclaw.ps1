# ============================================================
# OpenClaw 安装脚本（Windows PowerShell）
#
# 支持系统: Windows 10/11
# 需要: Node.js >= 22.19（推荐 24+，脚本会提示安装）
# 安装阶段不需要 API Key；首次配置或正式使用时需要模型服务的 API Key
#
# 用法:
#   .\install-openclaw.ps1 -China   国内网络模式
#   .\install-openclaw.ps1 -Help
#   .\install-openclaw.ps1 -DryRun
#   $env:AGENT_INSTALL_YES="1"; .\install-openclaw.ps1
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
$AgentName = "OpenClaw"
$AgentBin = "openclaw"
$OfficialUrl = "https://openclaw.ai/install.ps1"
$LogFile = Join-Path $env:TEMP "agent-install-openclaw.log"

# ---- Help ----
if ($Help) {
    Write-Host ""
    Write-Host "========================================"
    Write-Host "  OpenClaw 安装脚本 (Windows)"
    Write-Host "========================================"
    Write-Host ""
    Write-Host "安装: OpenClaw（微软开源）"
    Write-Host "系统: Windows 10/11"
    Write-Host "需要: Node.js >= 22.19（推荐 24+，脚本会提示安装）"
    Write-Host "      安装阶段不需要 API Key；首次配置时需要模型服务的 API Key"
    Write-Host ""
    Write-Host "用法:"
    Write-Host "  .\install-openclaw.ps1           正常安装（自动检查环境）"
    Write-Host "  .\install-openclaw.ps1 -China    国内网络模式（跳过官方源，使用镜像）"
    Write-Host "  .\install-openclaw.ps1 -Help     显示帮助"
    Write-Host "  .\install-openclaw.ps1 -DryRun   排查/预览（只看不装）"
    Write-Host ""
    Write-Host "跳过确认:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-openclaw.ps1'
    Write-Host ""
    Write-Host "国内网络一键安装:"
    Write-Host '  $env:AGENT_INSTALL_YES="1"; .\install-openclaw.ps1 -China'
    Write-Host ""
    Write-Host "安装后配置:"
    Write-Host "  openclaw onboard --auth-choice deepseek-api-key"
    Write-Host "  openclaw models list --provider deepseek"
    Write-Host "  openclaw dashboard"
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

# ============ 多端点网络检测 ============
function Test-NetworkEndpoints {
    if ($DryRun) {
        Write-DryRun "检查网络连通性（4 个端点）"
        return
    }

    Write-Host "  检查网络连通性..." -ForegroundColor Cyan
    $ok = 0
    $endpoints = @(
        "https://registry.npmmirror.com",
        "https://registry.npmjs.org",
        "https://api.deepseek.com",
        "https://github.com"
    )

    foreach ($ep in $endpoints) {
        try {
            $null = Invoke-WebRequest -Uri $ep -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            Write-Host "    [OK] 可访问: $ep" -ForegroundColor Green
            Write-Log "Network OK: $ep"
            $ok++
        } catch {
            Write-Host "    [!]  无法访问: $ep" -ForegroundColor Yellow
            Write-Log "Network FAIL: $ep"
        }
    }

    if ($ok -eq 0) {
        Write-Host "    [FAIL] 所有端点均无法访问，请检查网络连接" -ForegroundColor Red
        Write-Host "    可尝试切换手机热点、关闭/开启代理" -ForegroundColor Yellow
        if (-not $China) {
            Write-Host "    或使用国内网络模式: .\install-openclaw.ps1 -China" -ForegroundColor Yellow
        }
    } elseif ($ok -le 2) {
        Write-Host "    [!]  部分端点不可达，安装可能受限" -ForegroundColor Yellow
        if (-not $China) {
            Write-Host "    建议使用国内网络模式: .\install-openclaw.ps1 -China" -ForegroundColor Yellow
        }
    } else {
        Write-Host "    [OK] 网络连通性良好 ($ok/4)" -ForegroundColor Green
    }
    Write-Host ""
}

# ============ 安装前自动检查 ============
function Start-PreCheck {
    Write-Host ""
    Write-Host "  正在检查你的电脑环境..." -ForegroundColor Cyan
    Write-Host ""

    # 初始化日志
    "===== $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') =====" | Out-File -FilePath $LogFile -Encoding UTF8
    "Agent: $AgentName | China Mode: $China" | Out-File -FilePath $LogFile -Append -Encoding UTF8

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

    # 3. 多端点网络检测
    Test-NetworkEndpoints

    # 4. Node.js
    if ($DryRun) {
        Write-DryRun "检查 Node.js 版本 (需要 >= 22.19)"
    } else {
        $hasNode = Get-Command node -ErrorAction SilentlyContinue
        if ($hasNode) {
            $nodeVer = (node -v).TrimStart('v')
            $parts = $nodeVer.Split('.')
            $majorVer = if ($parts.Count -ge 1) { [int]$parts[0] } else { 0 }
            $minorVer = if ($parts.Count -ge 2) { [int]$parts[1] } else { 0 }
            if ($majorVer -gt 22 -or ($majorVer -eq 22 -and $minorVer -ge 19)) {
                Write-Host "    [OK] Node.js v$nodeVer (满足要求，将跳过安装)" -ForegroundColor Green
            } else {
                Write-Host "    [!] Node.js v$nodeVer 版本较低，将提示安装（推荐 v24+）" -ForegroundColor Yellow
            }
        } else {
            Write-Host "    [!] Node.js 未安装，将提示安装（推荐 v24+）" -ForegroundColor Yellow
        }
    }

    # 5. 是否已安装
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
        Write-Host "    [→] $AgentName 尚未安装" -ForegroundColor Cyan
    }

    # 6. 安装方式
    if ($China) {
        Write-Host "    [i] 国内网络模式：跳过官方安装器，直接使用 npm 镜像源" -ForegroundColor Cyan
    } else {
        Write-Host "    [i] 将优先使用官方安装方式 ($OfficialUrl)" -ForegroundColor Cyan
    }

    Write-Host ""
    Write-Host "  [OK] 系统检查完成" -ForegroundColor Green
    Write-Host "  [OK] 安装准备完成" -ForegroundColor Green
    Write-Host ""

    Write-Host "  接下来将安装: $AgentName" -ForegroundColor White
    Write-Host "  可能需要: 安装 Node.js（如果版本不满足要求）" -ForegroundColor White
    Write-Host "  需要准备: 安装阶段不需要 API Key；首次配置时可能需要模型服务的 API Key" -ForegroundColor White
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

# ---- 安装 Node.js ----
function Install-NodeIfNeeded {
    if ($DryRun) {
        Write-DryRun "检查 node 版本 (需要 >= 22.19)，如需安装则提示手动下载 MSI"
        return
    }

    $needNode = $true
    $hasNode = Get-Command node -ErrorAction SilentlyContinue
    if ($hasNode) {
        $nodeVer = (node -v).TrimStart('v')
        $parts = $nodeVer.Split('.')
        $majorVer = if ($parts.Count -ge 1) { [int]$parts[0] } else { 0 }
        $minorVer = if ($parts.Count -ge 2) { [int]$parts[1] } else { 0 }
        if ($majorVer -gt 22 -or ($majorVer -eq 22 -and $minorVer -ge 19)) {
            $needNode = $false
        }
    }

    if ($needNode) {
        Write-Host ""
        Write-Host "  Node.js 版本不满足要求（需要 >= 22.19，推荐 v24+）" -ForegroundColor Cyan
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

# ---- 安装 ----
function Start-Install {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  开始安装 $AgentName" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""

    if ($DryRun) {
        if ($China) {
            Write-DryRun "npm 镜像: Invoke-Npm install -g openclaw@latest --registry=https://registry.npmmirror.com"
        } else {
            Write-DryRun "官方脚本: Invoke-RestMethod $OfficialUrl | Invoke-Expression"
            Write-DryRun "fallback: Invoke-Npm install -g openclaw@latest"
        }
        Write-DryRun "验证: Get-Command $AgentBin"
        return
    }

    Install-NodeIfNeeded

    $installed = $false

    if ($China) {
        # 国内模式: 跳过官方安装器，直接使用 npm 镜像
        $hasNpm = Get-NpmCmd
        if ($hasNpm) {
            Write-Host "  国内网络模式：使用 npm 镜像源安装..." -ForegroundColor Cyan

            # 测试包是否存在
            try {
                $pkgVer = Invoke-Npm view openclaw version --registry=https://registry.npmmirror.com
                if ($pkgVer) {
                    Write-Host "    openclaw 包存在，最新版本: $pkgVer" -ForegroundColor Green
                }
            } catch {
                Write-Host "  [!] 无法查询 npm 包信息: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Log "npm view failed: $($_.Exception.Message)"
            }

            try {
                Invoke-Npm install -g openclaw@latest --registry=https://registry.npmmirror.com --no-audit --no-fund
                if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
                    $installed = $true
                } else {
                    # npm cache clean and retry
                    try { Invoke-Npm cache clean --force } catch { }
                    Invoke-Npm install -g openclaw@latest --registry=https://registry.npmmirror.com --no-audit --no-fund
                    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
                }
            } catch {
                Write-Host "  [!] npm 镜像安装失败: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Log "npm mirror install failed: $($_.Exception.Message)"
            }
        } else {
            Write-Host "  [FAIL] 未找到 npm，无法使用国内镜像安装" -ForegroundColor Red
            Write-Host "  请先安装 Node.js: https://nodejs.org" -ForegroundColor Yellow
            exit 1
        }
    } else {
        # 标准模式: 官方安装器优先
        # 方法1: 官方 installer
        Write-Host "  尝试官方脚本安装..." -ForegroundColor Cyan
        try {
            Invoke-RestMethod -Uri $OfficialUrl -TimeoutSec 30 | Invoke-Expression 2>&1 | Tee-Object -FilePath $LogFile -Append
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
            if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
        } catch {
            Write-Host "  [!] 官方脚本安装失败: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Log "Official installer failed: $($_.Exception.Message)"
        }

        # 方法2: npm fallback
        if (-not $installed) {
            $hasNpm = Get-NpmCmd
            if ($hasNpm) {
                Write-Host "  通过 npm 安装..." -ForegroundColor Cyan

                try {
                    $pkgVer = Invoke-Npm view openclaw version --registry=https://registry.npmjs.org/
                    if ($pkgVer) {
                        Write-Host "    openclaw 包存在，最新版本: $pkgVer" -ForegroundColor Green
                    }
                } catch {
                    Write-Host "  [!] 无法查询 npm 包信息: $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Log "npm view failed: $($_.Exception.Message)"
                }

                try {
                    Invoke-Npm install -g openclaw@latest --registry=https://registry.npmjs.org/ --no-audit --no-fund
                    if (Get-Command $AgentBin -ErrorAction SilentlyContinue) {
                        $installed = $true
                    } else {
                        try { Invoke-Npm cache clean --force } catch { }
                        Invoke-Npm install -g openclaw@latest --registry=https://registry.npmjs.org/ --no-audit --no-fund
                        if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
                    }
                } catch {
                    Write-Host "  [!] npm 官方源安装失败: $($_.Exception.Message)" -ForegroundColor Yellow
                    Write-Log "npm install failed: $($_.Exception.Message)"
                }

                # npmmirror fallback
                if (-not $installed) {
                    Write-Host "  [!] 尝试国内镜像..." -ForegroundColor Yellow
                    try {
                        Invoke-Npm install -g openclaw@latest --registry=https://registry.npmmirror.com --no-audit --no-fund
                        if (Get-Command $AgentBin -ErrorAction SilentlyContinue) { $installed = $true }
                    } catch {
                        Write-Host "  [!] npm 镜像安装失败: $($_.Exception.Message)" -ForegroundColor Yellow
                        Write-Log "npm mirror fallback failed: $($_.Exception.Message)"
                    }
                }
            }
        }
    }

    if ($installed) {
        Write-Host "  [OK] $AgentName 安装成功!" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 安装失败" -ForegroundColor Red
        Write-Host ""
        Write-Host "  排查建议:" -ForegroundColor Yellow
        Write-Host "  1. 确保网络通畅，可尝试切换手机热点" -ForegroundColor Yellow
        Write-Host "  2. 检查 Node.js: node -v (需要 >= 22.19)" -ForegroundColor Yellow
        Write-Host "  3. 如果报 EACCES / permission denied，说明 npm 缓存权限异常" -ForegroundColor Yellow
        Write-Host "     查看故障排查页面的 EACCES 修复指引" -ForegroundColor Yellow
        Write-Host "  4. 查看安装日志: $LogFile" -ForegroundColor Yellow
        Write-Host "  5. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
        exit 1
    }
}

# ---- OpenClaw DeepSeek onboarding ----
function Start-OpenClawConfig {
    if ($DryRun) {
        Write-Host "    [预演] 将执行: 提示 OpenClaw DeepSeek API Key 配置引导" -ForegroundColor Yellow
        return
    }

    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  OpenClaw 首次配置（推荐）" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  OpenClaw 支持 75+ 模型提供商。" -ForegroundColor White
    Write-Host "  安装阶段不需要 API Key；首次配置或正式使用时需要。" -ForegroundColor White
    Write-Host ""
    Write-Host "  对于国内用户，推荐使用 DeepSeek API Key：" -ForegroundColor White
    Write-Host "    注册方便、价格便宜" -ForegroundColor White
    Write-Host ""
    Write-Host "  获取方式: 浏览器访问 platform.deepseek.com" -ForegroundColor Cyan
    Write-Host "           注册 -> API Keys -> 创建 Key（以 sk- 开头）" -ForegroundColor Cyan
    Write-Host ""

    if (-not (Confirm-Action "是否现在配置 OpenClaw？")) {
        Write-Host ""
        Write-Host "  已跳过配置。稍后可以手动运行:" -ForegroundColor Yellow
        Write-Host "    openclaw onboard --auth-choice deepseek-api-key" -ForegroundColor Yellow
        Write-Host ""
        return
    }

    Write-Host ""
    Write-Host "  运行 OpenClaw onboarding（DeepSeek API Key）..." -ForegroundColor Cyan
    Write-Host "  （按终端提示输入你的 DeepSeek API Key）" -ForegroundColor Cyan
    Write-Host ""

    try {
        & $AgentBin onboard --auth-choice deepseek-api-key 2>&1 | Tee-Object -FilePath $LogFile -Append
        Write-Host "  [OK] OpenClaw 配置完成" -ForegroundColor Green
        Write-Host ""
        Write-Host "  验证:" -ForegroundColor White
        Write-Host "    openclaw models list --provider deepseek" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  启动控制面板:" -ForegroundColor White
        Write-Host "    openclaw dashboard" -ForegroundColor Cyan
    } catch {
        Write-Host "  [!] onboard 未完成，你可以稍后手动运行:" -ForegroundColor Yellow
        Write-Host "    openclaw onboard --auth-choice deepseek-api-key" -ForegroundColor Yellow
    }

    Write-Host ""
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
        Write-Host "  首次配置（推荐 DeepSeek API Key）:" -ForegroundColor Green
        Write-Host "    openclaw onboard --auth-choice deepseek-api-key" -ForegroundColor Green
        Write-Host ""
        Write-Host "  启动:" -ForegroundColor Green
        Write-Host "    openclaw           进入交互式对话" -ForegroundColor Green
        Write-Host "    openclaw dashboard 打开 Web 控制台" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] 找不到 openclaw 命令" -ForegroundColor Red
        Write-Host "  1. 关闭 PowerShell 窗口，重新打开后再试" -ForegroundColor Yellow
        Write-Host "  2. 查看安装日志: $LogFile" -ForegroundColor Yellow
        Write-Host "  3. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html" -ForegroundColor Yellow
        exit 1
    }
}

# ==================== 主流程 ====================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  OpenClaw 安装助手 (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($China) {
    Write-Host "  国内网络模式 — 跳过官方源，使用 npm 镜像" -ForegroundColor Yellow
}
if ($DryRun) {
    Write-Host "  [dry-run 模式] 只看不装" -ForegroundColor Yellow
}

Start-PreCheck
Start-Install
Start-OpenClawConfig
Start-Verify

if ($DryRun) {
    Write-Host ""
    Write-Host "  [OK] dry-run 完成 — 以上步骤未实际执行" -ForegroundColor Green
    Write-Host ""
    Write-Host "  如需正式安装，请运行:" -ForegroundColor Cyan
    Write-Host "    .\install-openclaw.ps1" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "  安装日志: $LogFile" -ForegroundColor Cyan
Write-Host ""
