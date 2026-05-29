# ============================================================
# Claude Code · Windows 一键安装器
#
# 用法:
#   1. 按 ⊞+R → 输入 powershell → 回车
#   2. 粘贴下面这行 → 回车:
#      iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/windows/install-claude-code.ps1 | iex
# ============================================================

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║       🧠  Claude Code · Windows 一键安装器              ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  Anthropic 出品，最聪明的 AI 编程助手                     ║" -ForegroundColor Cyan
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

# ==================== 检测工具 ====================
Write-Host "━━━ 第二步：检测安装工具 ━━━" -ForegroundColor Blue
Write-Host ""

$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
$hasNpm = Get-Command npm -ErrorAction SilentlyContinue
$hasNode = Get-Command node -ErrorAction SilentlyContinue

if ($hasWinget) { Write-Host "  ✅ winget 已就绪" -ForegroundColor Green }
if ($hasNpm) { Write-Host "  ✅ npm 已就绪" -ForegroundColor Green }

if (-not $hasWinget -and -not $hasNpm) {
    Write-Host "  ⚠️  未检测到 winget 或 npm" -ForegroundColor Yellow
    Write-Host "      脚本会尝试自动处理，请稍候..." -ForegroundColor Yellow
}
Write-Host ""

# ==================== 安装 Node.js（npm 安装需要） ====================
if (-not $hasNpm) {
    Write-Host "━━━ 第三步：安装 npm（Claude Code 备选安装方式需要）━━━" -ForegroundColor Blue
    Write-Host ""

    if ($hasWinget) {
        Write-Host "  📦 通过 winget 安装 Node.js..." -ForegroundColor Cyan
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>$null
        $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
        if (Get-Command node -ErrorAction SilentlyContinue) {
            $hasNpm = Get-Command npm -ErrorAction SilentlyContinue
            Write-Host "  ✅ Node.js 安装成功！" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Node.js 已安装但需重启 PowerShell 后生效" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ⚠️  未检测到 winget，请手动安装 Node.js：" -ForegroundColor Yellow
        Write-Host "      1. 浏览器访问 https://nodejs.org" -ForegroundColor Yellow
        Write-Host "      2. 下载安装包，一直点「下一步」" -ForegroundColor Yellow
        Write-Host "      3. 装好后关掉这个窗口重新打开，再运行此脚本" -ForegroundColor Yellow
        exit 1
    }
    Write-Host ""
}

# ==================== 安装 Claude Code ====================
Write-Host "━━━ 安装 Claude Code ━━━" -ForegroundColor Blue
Write-Host ""

if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ Claude Code 已安装（$(claude --version 2>$null | Select-Object -First 1)）" -ForegroundColor Green
    Write-Host ""
    Write-Host "  启动方法: 终端输入 claude" -ForegroundColor Cyan
    Write-Host "  更新方法: 重新运行此脚本" -ForegroundColor Cyan
    Write-Host ""
    exit 0
}

try {
    $installed = $false

    # 方法1: winget（从 GitHub Storage 下载，国内可用）
    if ($hasWinget -and -not $installed) {
        Write-Host "  方法1: winget 安装..." -ForegroundColor Cyan
        winget install Anthropic.ClaudeCode --silent --accept-package-agreements 2>$null
        if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true; Write-Host "  ✅ winget 安装成功！" -ForegroundColor Green }
    }

    # 方法2: 官方脚本（境外可用）
    if (-not $installed) {
        Write-Host "  方法2: 官方脚本安装..." -ForegroundColor Cyan
        try {
            Invoke-RestMethod -Uri "https://claude.ai/install.ps1" -TimeoutSec 30 | Invoke-Expression 2>$null
            $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
            if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true; Write-Host "  ✅ 官方脚本安装成功！" -ForegroundColor Green }
        } catch {
            Write-Host "  ⚠️  官方脚本不可用（地域限制），改用 npm..." -ForegroundColor Yellow
        }
    }

    # 方法3: npm 安装（国内可用，无需代理）
    if (-not $installed -and $hasNpm) {
        Write-Host "  方法3: npm 安装 @anthropic-ai/claude-code ..." -ForegroundColor Cyan
        npm install -g @anthropic-ai/claude-code@latest 2>$null
        if (Get-Command claude -ErrorAction SilentlyContinue) { $installed = $true; Write-Host "  ✅ npm 安装成功！" -ForegroundColor Green }
    }

    if ($installed) {
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║              🎉  Claude Code 安装完成！                 ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║  启动方法：                                              ║" -ForegroundColor Cyan
        Write-Host "║  PowerShell 中输入 claude → 回车                        ║" -ForegroundColor Cyan
        Write-Host "║  第一次使用会弹出浏览器登录 Claude 账号                  ║" -ForegroundColor Cyan
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
    Write-Host "  手动安装: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    Write-Host "  如有问题请截图联系卖家。" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
