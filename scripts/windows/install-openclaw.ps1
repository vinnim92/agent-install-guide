# ============================================================
# OpenClaw (OpenCode) · Windows 一键安装器
#
# 用法:
#   1. 按 ⊞+R → 输入 powershell → 回车
#   2. 粘贴下面这行 → 回车:
#      iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/windows/install-openclaw.ps1 | iex
# ============================================================

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║       🦞  OpenClaw · Windows 一键安装器              ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  微软开源，自带免费模型，开箱即用                    ║" -ForegroundColor Cyan
Write-Host "║  整个过程大约需要 2-5 分钟                                ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ==================== 系统检测 ====================
Write-Host "━━━ 第一步：检测你的电脑 ━━━" -ForegroundColor Blue
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
Write-Host "  ✅ 你的系统：$($os.Caption)" -ForegroundColor Green
Write-Host "  ✅ 架构：$env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green
Write-Host ""

# ==================== 检测安装工具 ====================
Write-Host "━━━ 第二步：检测运行环境 ━━━" -ForegroundColor Blue
Write-Host ""

$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
$hasNode = Get-Command node -ErrorAction SilentlyContinue
$hasNpm = Get-Command npm -ErrorAction SilentlyContinue

if ($hasWinget) { Write-Host "  ✅ winget 已就绪" -ForegroundColor Green }

# ==================== 安装 Node.js ====================
$needNode = $true
if ($hasNode) {
    $nodeVer = (node -v).TrimStart('v')
    $majorVer = [int]($nodeVer.Split('.')[0])
    if ($majorVer -ge 22) {
        Write-Host "  ✅ Node.js 已就绪（版本 $nodeVer）" -ForegroundColor Green
        $needNode = $false
    } else {
        Write-Host "  ⚠️  Node.js 版本较旧（$nodeVer），需要 v22+" -ForegroundColor Yellow
    }
} else {
    Write-Host "  📦 Node.js 未安装" -ForegroundColor Yellow
}

if ($needNode) {
    Write-Host "━━━ 第三步：安装 Node.js（OpenClaw 运行需要）━━━" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  📦 正在自动安装 Node.js..." -ForegroundColor Cyan

    if ($hasWinget) {
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command node -ErrorAction SilentlyContinue) { $hasNpm = Get-Command npm -ErrorAction SilentlyContinue }
        if (Get-Command node -ErrorAction SilentlyContinue) {
            Write-Host "  ✅ Node.js 安装成功！" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Node.js 已安装但需重启 PowerShell 后生效" -ForegroundColor Yellow
            Write-Host "      请关掉这个窗口重新打开后重试" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "  ⚠️  请手动安装 Node.js：" -ForegroundColor Yellow
        Write-Host "      1. 浏览器访问 https://nodejs.org" -ForegroundColor Yellow
        Write-Host "      2. 下载安装包，一直点「下一步」" -ForegroundColor Yellow
        Write-Host "      3. 装好后重新运行此脚本" -ForegroundColor Yellow
        exit 1
    }
    Write-Host ""
}

Write-Host ""

# ==================== 安装 OpenClaw ====================
Write-Host "━━━ 安装 OpenClaw (OpenCode) ━━━" -ForegroundColor Blue
Write-Host ""

if ((Get-Command openclaw -ErrorAction SilentlyContinue) -or (Get-Command opencode -ErrorAction SilentlyContinue)) {
    $ver = ""
    try { $ver = (opencode --version 2>$null) } catch { try { $ver = (openclaw --version 2>$null) } catch {} }
    Write-Host "  ✅ OpenClaw 已安装（$ver）" -ForegroundColor Green
    Write-Host ""
    Write-Host "  启动方法: 终端输入 opencode" -ForegroundColor Cyan
    Write-Host "  更新方法: 重新运行此脚本" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

if (-not $hasNpm) {
    Write-Host "  ❌ npm 未就绪，无法安装 OpenClaw" -ForegroundColor Red
    Write-Host "  请确保 Node.js 已正确安装后重试" -ForegroundColor Yellow
    exit 1
}

try {
    $installed = $false

    # 方法1: winget
    if ($hasWinget -and -not $installed) {
        Write-Host "  方法1: winget 安装..." -ForegroundColor Cyan
        winget install SST.opencode --silent --accept-package-agreements 2>$null
        if ((Get-Command opencode -ErrorAction SilentlyContinue) -or (Get-Command openclaw -ErrorAction SilentlyContinue)) {
            $installed = $true
            Write-Host "  ✅ winget 安装成功！" -ForegroundColor Green
        }
    }

    # 方法2: npm 安装
    if (-not $installed -and $hasNpm) {
        Write-Host "  方法2: npm 安装 opencode-ai ..." -ForegroundColor Cyan

        # 国内网络自动切镜像
        if (-not (Test-Connection -ComputerName registry.npmjs.org -Count 1 -Quiet -TimeoutSeconds 3 2>$null)) {
            npm config set registry https://registry.npmmirror.com 2>$null
            Write-Host "  💡 已切换至国内镜像加速" -ForegroundColor Cyan
        }

        npm install -g opencode-ai@latest 2>$null
        if ((Get-Command opencode -ErrorAction SilentlyContinue) -or (Get-Command openclaw -ErrorAction SilentlyContinue)) {
            $installed = $true
            Write-Host "  ✅ npm 安装成功！" -ForegroundColor Green
        }
    }

    if ($installed) {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║           🎉  OpenClaw 安装完成！               ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║  启动方法：                                              ║" -ForegroundColor Cyan
        Write-Host "║  PowerShell 中输入 opencode → 回车                         ║" -ForegroundColor Cyan
        Write-Host "║  第一次使用会弹出浏览器登录 GitHub 账号                 ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║  更新方法：重新运行此安装脚本                            ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
    } else {
        throw "所有安装方式均失败"
    }
} catch {
    Write-Host ""
    Write-Host "  ❌ 安装失败（可能是网络问题）" -ForegroundColor Red
    Write-Host "  手动安装: npm install -g opencode-ai@latest" -ForegroundColor Yellow
    Write-Host "  如有问题请截图联系卖家。" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
