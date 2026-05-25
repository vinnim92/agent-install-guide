# ============================================================
# AI 编程助手 · 零基础 Windows 一键安装器
#
# 用法:
#   1. 按 ⊞+R → 输入 powershell → 回车
#   2. 粘贴下面这行 → 回车:
#      iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.ps1 | iex
#
# 目标用户：完全不会电脑的普通人
# ============================================================

Clear-Host
Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║       🤖  AI 编程助手 · 零基础一键安装器（Windows 版）  ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  本脚本将自动为你安装：                                   ║" -ForegroundColor Cyan
Write-Host "║    🧠 Claude Code   — 最聪明的 AI 程序员               ║" -ForegroundColor Cyan
Write-Host "║    ⚡ Codex         — OpenAI 出品的编程利器            ║" -ForegroundColor Cyan
Write-Host "║    🦞 OpenClaw      — 微软开源，自带免费模型          ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║  你什么都不用懂，脚本全自动处理。                         ║" -ForegroundColor Cyan
Write-Host "║  整个过程大约需要 5-10 分钟。                            ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ==================== 系统检测 ====================
Write-Host "━━━ 第一步：检测你的电脑 ━━━" -ForegroundColor Blue
Write-Host ""

$os = Get-CimInstance Win32_OperatingSystem
Write-Host "  ✅ 你的系统：$($os.Caption)" -ForegroundColor Green
Write-Host "  ✅ 架构：$env:PROCESSOR_ARCHITECTURE" -ForegroundColor Green

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "  ⚠️  建议以管理员身份运行（部分安装需要）" -ForegroundColor Yellow
    Write-Host "      右键 PowerShell → 以管理员身份运行" -ForegroundColor Yellow
    Write-Host ""
}
Write-Host ""

# ==================== 检测安装方式 ====================
Write-Host "━━━ 第二步：检测可用工具 ━━━" -ForegroundColor Blue
Write-Host ""

$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
$hasScoop = Get-Command scoop -ErrorAction SilentlyContinue
$hasChoco = Get-Command choco -ErrorAction SilentlyContinue
$hasWSL = $false
$hasNode = Get-Command node -ErrorAction SilentlyContinue
$hasNpm = Get-Command npm -ErrorAction SilentlyContinue

try { wsl --status 2>$null | Out-Null; $hasWSL = ($LASTEXITCODE -eq 0) } catch {}

if ($hasWinget) { Write-Host "  ✅ winget（Windows 包管理器）已就绪" -ForegroundColor Green }
if ($hasScoop)  { Write-Host "  ✅ Scoop 已就绪" -ForegroundColor Green }
if ($hasWSL)    { Write-Host "  ✅ WSL（Linux 子系统）已安装" -ForegroundColor Green }

if (-not $hasWinget) {
    Write-Host "  ⚠️  未检测到 winget，建议先安装：" -ForegroundColor Yellow
    Write-Host "      访问 Microsoft Store 搜索"应用安装程序"安装" -ForegroundColor Yellow
}
Write-Host ""

# ==================== 安装 Node.js ====================
Write-Host "━━━ 第三步：安装运行环境（Node.js）━━━" -ForegroundColor Blue
Write-Host ""

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
}

if ($needNode) {
    Write-Host "  📦 正在自动安装 Node.js（一些 AI 助手需要它）..." -ForegroundColor Cyan

    if ($hasWinget) {
        Write-Host "      用 winget 安装..."
        winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Node.js 安装成功！" -ForegroundColor Green
            Write-Host "  ⚠️  请关掉这个窗口重新打开，然后重试安装" -ForegroundColor Yellow
            Write-Host "      （Node.js 装完后需要重启 PowerShell 才能生效）" -ForegroundColor Yellow
            exit 0
        }
    }

    if ($hasScoop) {
        Write-Host "      用 Scoop 安装..."
        scoop install nodejs 2>$null
    }

    if ($hasChoco) {
        Write-Host "      用 Chocolatey 安装..."
        choco install nodejs -y 2>$null
    }

    if (-not ($hasWinget -or $hasScoop -or $hasChoco)) {
        Write-Host "  ⚠️  请手动安装 Node.js：" -ForegroundColor Yellow
        Write-Host "      1. 打开浏览器访问 https://nodejs.org" -ForegroundColor Yellow
        Write-Host "      2. 点击绿色按钮"Download"下载安装包" -ForegroundColor Yellow
        Write-Host "      3. 双击安装（一直点"下一步"就行）" -ForegroundColor Yellow
        Write-Host "      4. 装好后关掉这个窗口重新打开，再运行安装脚本" -ForegroundColor Yellow
        exit 1
    }
}
Write-Host ""

# ==================== 安装 AI 助手 ====================
Write-Host "━━━ 第四步：安装 AI 编程助手 ━━━" -ForegroundColor Blue
Write-Host ""

$installed = 0

# ---- Claude Code ----
Write-Host "  🧠 安装 Claude Code ..." -ForegroundColor White
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "    ✅ Claude Code 已安装" -ForegroundColor Green
    $installed++
} else {
    try {
        if ($hasWinget) {
            winget install Anthropic.ClaudeCode --silent --accept-package-agreements 2>$null
        }
        if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
            Invoke-RestMethod -Uri "https://claude.ai/install.ps1" | Invoke-Expression
        }
        $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
        if (Get-Command claude -ErrorAction SilentlyContinue) {
            Write-Host "    ✅ Claude Code 安装成功！" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "    ⚠️  安装可能未生效，请重启 PowerShell 后检查" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "    ⚠️  安装失败（可能是网络问题）" -ForegroundColor Yellow
    }
}

# ---- Codex ----
Write-Host "  ⚡ 安装 Codex ..." -ForegroundColor White
if (Get-Command codex -ErrorAction SilentlyContinue) {
    Write-Host "    ✅ Codex 已安装" -ForegroundColor Green
    $installed++
} elseif ($hasNpm) {
    npm install -g @openai/codex 2>$null
    if (Get-Command codex -ErrorAction SilentlyContinue) {
        Write-Host "    ✅ Codex 安装成功！" -ForegroundColor Green
        $installed++
    } else {
        Write-Host "    ⚠️  Codex 安装失败（可能是网络问题）" -ForegroundColor Yellow
    }
} else {
    Write-Host "    ⏭️  跳过（Node.js 未安装）" -ForegroundColor Yellow
}

# ---- OpenClaw ----
Write-Host "  🦞 安装 OpenClaw ..." -ForegroundColor White
if ((Get-Command openclaw -ErrorAction SilentlyContinue) -or (Get-Command opencode -ErrorAction SilentlyContinue)) {
    Write-Host "    ✅ OpenClaw 已安装" -ForegroundColor Green
    $installed++
} else {
    try {
        if ($hasWinget) { winget install Microsoft.OpenClaw --silent --accept-package-agreements 2>$null }
        if ($hasScoop -and -not (Get-Command openclaw -ErrorAction SilentlyContinue)) { scoop install opencode 2>$null }
        if ($hasNpm -and -not (Get-Command openclaw -ErrorAction SilentlyContinue) -and -not (Get-Command opencode -ErrorAction SilentlyContinue)) {
            npm install -g opencode-ai@latest 2>$null
        }
        if ((Get-Command openclaw -ErrorAction SilentlyContinue) -or (Get-Command opencode -ErrorAction SilentlyContinue)) {
            Write-Host "    ✅ OpenClaw 安装成功！" -ForegroundColor Green
            $installed++
        } else {
            Write-Host "    ⚠️  OpenClaw 安装失败" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "    ⚠️  安装失败（可能是网络问题）" -ForegroundColor Yellow
    }
}

Write-Host ""

# ==================== 完成 ====================
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║                  🎉  安装完成！                          ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan

if ($installed -eq 3) {
    Write-Host "║       三款 AI 助手全部安装成功！                         ║" -ForegroundColor Cyan
} elseif ($installed -ge 1) {
    Write-Host "║       已安装 $installed 款 AI 助手                      ║" -ForegroundColor Cyan
} else {
    Write-Host "║       安装遇到问题，截图发给卖家排查                     ║" -ForegroundColor Cyan
}

Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║   启动方法：                                             ║" -ForegroundColor Cyan
Write-Host "║   PowerShell 里输入 claude / codex / openclaw            ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║   ❓ 输入命令提示『找不到』→ 关掉窗口重开即可           ║" -ForegroundColor Cyan
Write-Host "║   🌐 网络慢 → 换手机热点试试                             ║" -ForegroundColor Cyan
Write-Host "║   📩 其他问题 → 截图发给卖家                             ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "║   更新方法：重新运行此安装脚本                           ║" -ForegroundColor Cyan
Write-Host "║                                                          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "感谢购买！如有问题请截图联系卖家。" -ForegroundColor Green
Write-Host ""
