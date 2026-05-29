# ============================================================
# OpenAI Codex CLI · Windows 一键安装器
#
# 用法:
#   1. 按 ⊞+R → 输入 powershell → 回车
#   2. 粘贴下面这行 → 回车:
#      iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/windows/install-codex.ps1 | iex
# ============================================================

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║       ⚡  OpenAI Codex CLI · Windows 一键安装器          ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  OpenAI 出品，ChatGPT 用户首选编程助手                    ║" -ForegroundColor Cyan
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
    Write-Host "━━━ 第三步：安装 Node.js（Codex 运行需要）━━━" -ForegroundColor Blue
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
            Read-Host "按回车键退出"
        }
    } else {
        Write-Host "  ⚠️  请手动安装 Node.js：" -ForegroundColor Yellow
        Write-Host "      1. 浏览器访问 https://nodejs.org" -ForegroundColor Yellow
        Write-Host "      2. 下载安装包，一直点「下一步」" -ForegroundColor Yellow
        Write-Host "      3. 装好后重新运行此脚本" -ForegroundColor Yellow
        Read-Host "按回车键退出"
    }
    Write-Host ""
}

Write-Host ""

# ==================== 安装 Codex ====================
Write-Host "━━━ 安装 OpenAI Codex CLI ━━━" -ForegroundColor Blue
Write-Host ""

if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host "  ✅ Codex 已安装（$(codex --version 2>$null)）" -ForegroundColor Green
    Write-Host ""
    Write-Host "  启动方法: 终端输入 codex" -ForegroundColor Cyan
    Write-Host "  更新方法: 重新运行此脚本" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "按回车键退出"
}

if (-not $hasNpm) {
    Write-Host "  ❌ npm 未就绪，无法安装 Codex" -ForegroundColor Red
    Write-Host "  请确保 Node.js 已正确安装后重试" -ForegroundColor Yellow
    Read-Host "按回车键退出"
}

Write-Host "  📦 通过 npm 安装 @openai/codex ..." -ForegroundColor Cyan

# 国内网络自动切镜像
if (-not (Test-Connection -ComputerName registry.npmjs.org -Count 1 -Quiet -TimeoutSeconds 3 2>$null)) {
    npm config set registry https://registry.npmmirror.com 2>$null
    Write-Host "  💡 已切换至国内镜像加速" -ForegroundColor Cyan
}

try {
    npm install -g @openai/codex@latest 2>$null

    if (Get-Command codex -ErrorAction SilentlyContinue) {
        Write-Host "  ✅ Codex 安装成功！" -ForegroundColor Green
        Write-Host ""
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║           🎉  OpenAI Codex CLI 安装完成！               ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║  启动方法：                                              ║" -ForegroundColor Cyan
        Write-Host "║  PowerShell 中输入 codex → 回车                         ║" -ForegroundColor Cyan
        Write-Host "║  第一次使用会弹出浏览器登录 ChatGPT 账号                 ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "║  更新方法：重新运行此安装脚本                            ║" -ForegroundColor Cyan
        Write-Host "║                                                          ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
    } else {
        # 重试安装（处理可选平台依赖缺失的情况）
        Write-Host "  💡 首次安装后未检测到命令，重试安装平台依赖..." -ForegroundColor Cyan
        npm install -g @openai/codex@latest 2>$null
        if (Get-Command codex -ErrorAction SilentlyContinue) {
            Write-Host "  ✅ Codex 安装成功！" -ForegroundColor Green
        } else {
            throw "安装后未找到命令"
        }
    }
} catch {
    Write-Host ""
    Write-Host "  ❌ 安装失败（可能是网络问题）" -ForegroundColor Red
    Write-Host "  手动安装: npm install -g @openai/codex@latest" -ForegroundColor Yellow
    Write-Host "  如有问题请截图联系卖家。" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "按回车键退出"
}
