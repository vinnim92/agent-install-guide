# ============================================================
# OpenClaw 🦞 · Windows 一键安装器
#
# 用法:
#   1. 按 ⊞+R → 输入 powershell → 回车
#   2. 粘贴下面这行 → 回车:
#      iwr -useb https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/windows/install-openclaw.ps1 | iex
# ============================================================

$ErrorActionPreference = "Continue"
Set-ExecutionPolicy Bypass -Scope Process -Force

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║       🦞  OpenClaw · Windows 一键安装器                ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  开源 AI 编程助手，自带免费模型，开箱即用                 ║" -ForegroundColor Cyan
Write-Host "║  整个过程大约需要 3-6 分钟                                ║" -ForegroundColor Cyan
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

# ==================== 检查是否已安装 ====================
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Write-Host "━━━ OpenClaw 已安装 ━━━" -ForegroundColor Blue
    try { $ver = (openclaw --version 2>$null | Select-Object -First 1) } catch { $ver = "已检测到" }
    Write-Host "  ✅ OpenClaw 已安装（$ver）" -ForegroundColor Green
    Write-Host ""
    Write-Host "  启动方法: PowerShell 输入 openclaw 回车" -ForegroundColor Cyan
    Write-Host "  更新方法: 重新运行此脚本" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "按回车键退出"
    return
}

# ==================== 检查/安装 Node.js ====================
Write-Host "━━━ 第二步：检查 Node.js 运行环境 ━━━" -ForegroundColor Blue
Write-Host ""

$hasNode = $false
$hasNpm = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = (node -v).TrimStart('v')
    $majorVer = [int]($nodeVer.Split('.')[0])
    if ($majorVer -ge 22) {
        Write-Host "  ✅ Node.js 已就绪（版本 v$nodeVer）" -ForegroundColor Green
        $hasNode = $true
        if (Get-Command npm -ErrorAction SilentlyContinue) { $hasNpm = $true }
    } else {
        Write-Host "  ⚠️  Node.js 版本较旧（v$nodeVer），OpenClaw 需要 v22+" -ForegroundColor Yellow
    }
} else {
    Write-Host "  📦 Node.js 未安装" -ForegroundColor Yellow
}

if (-not $hasNode) {
    $hasWinget = Get-Command winget -ErrorAction SilentlyContinue
    if ($hasWinget) {
        Write-Host "  📦 正在通过 winget 安装 Node.js..." -ForegroundColor Cyan
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>$null

        # 刷新 PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')

        if (Get-Command node -ErrorAction SilentlyContinue) {
            $hasNode = $true
            if (Get-Command npm -ErrorAction SilentlyContinue) { $hasNpm = $true }
            Write-Host "  ✅ Node.js 安装成功！" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Node.js 已安装，但当前窗口未生效" -ForegroundColor Yellow
            Write-Host "  👉 关掉此窗口，重新打开 PowerShell，再运行一次安装命令" -ForegroundColor Yellow
            Write-Host ""
            Read-Host "按回车键退出"
            return
        }
    } else {
        Write-Host "  ❌ 未找到 winget，无法自动安装 Node.js" -ForegroundColor Red
        Write-Host "  请手动安装：" -ForegroundColor Yellow
        Write-Host "    1. 浏览器打开 https://nodejs.org" -ForegroundColor Yellow
        Write-Host "    2. 下载 LTS 版本，双击安装（一直点下一步）" -ForegroundColor Yellow
        Write-Host "    3. 装好后重新运行本脚本" -ForegroundColor Yellow
        Write-Host ""
        Read-Host "按回车键退出"
        return
    }
}

if (-not $hasNpm) {
    Write-Host "  ❌ npm 未就绪，安装失败" -ForegroundColor Red
    Write-Host "  请重新打开 PowerShell 后重试" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
    return
}

Write-Host ""

# ==================== 安装 OpenClaw ====================
Write-Host "━━━ 第三步：安装 OpenClaw 🦞 ━━━" -ForegroundColor Blue
Write-Host ""

# 国内网络优化
try {
    $null = Invoke-WebRequest -Uri "https://registry.npmjs.org" -TimeoutSec 3 -UseBasicParsing 2>$null
} catch {
    npm config set registry https://registry.npmmirror.com 2>$null
    Write-Host "  💡 检测到国内网络，已切换淘宝镜像加速" -ForegroundColor Cyan
}

Write-Host "  📦 正在安装 openclaw（最新版）..." -ForegroundColor Cyan
Write-Host "  （如果卡住不动，说明网络较慢，耐心等待）" -ForegroundColor DarkGray
Write-Host ""

$installed = $false

# 方法1: npm 安装（主方法）
$npmOutput = cmd /c "npm install -g openclaw@latest" 2>&1
if ($LASTEXITCODE -eq 0) {
    if (Get-Command openclaw -ErrorAction SilentlyContinue) {
        $installed = $true
        Write-Host "  ✅ OpenClaw 安装成功！" -ForegroundColor Green
    }
}

# 方法2: 如果 npm 装好了但命令找不到，刷新 PATH 再试
if (-not $installed) {
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
    if (Get-Command openclaw -ErrorAction SilentlyContinue) {
        $installed = $true
        Write-Host "  ✅ OpenClaw 已安装（需刷新 PATH）" -ForegroundColor Green
    }
}

if ($installed) {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║              🎉  OpenClaw 安装完成！                    ║" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║  启动方法：                                              ║" -ForegroundColor Cyan
    Write-Host "║  1. 关掉此窗口，重新打开 PowerShell                     ║" -ForegroundColor Cyan
    Write-Host "║  2. 输入 openclaw 回车                                  ║" -ForegroundColor Cyan
    Write-Host "║  3. 首次使用按照提示完成初始化设置                      ║" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "║  更新方法：重新运行此安装脚本                            ║" -ForegroundColor Cyan
    Write-Host "║                                                          ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  ❌ 安装失败（可能是网络问题）" -ForegroundColor Red
    Write-Host ""
    Write-Host "  手动安装步骤：" -ForegroundColor Yellow
    Write-Host "  1. 断开 WiFi，换成手机热点" -ForegroundColor Yellow
    Write-Host "  2. 打开 PowerShell" -ForegroundColor Yellow
    Write-Host "  3. 输入: npm install -g openclaw@latest" -ForegroundColor Yellow
    Write-Host "  4. 如果还报错，截图发给卖家" -ForegroundColor Yellow
    Write-Host ""
}

Read-Host "按回车键退出"
