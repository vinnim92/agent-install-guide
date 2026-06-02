# OpenClaw Windows short entry — auto-redirects to latest stable installer
# Usage: irm https://vinnim92.github.io/agent-install-guide/i/openclaw.ps1 | iex
#   Or:  .\openclaw.ps1 -Help / -DryRun

param([switch]$Help, [switch]$DryRun)

$Version = "v3.1.1"
$Primary  = "https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@$Version/scripts/install-openclaw.ps1"
$Fallback = "https://raw.githubusercontent.com/vinnim92/agent-install-guide/$Version/scripts/install-openclaw.ps1"

try {
    $content = Invoke-RestMethod -Uri $Primary -UseBasicParsing -TimeoutSec 30
} catch {
    Write-Host " [WARN] CDN 访问失败，正在切换 GitHub raw..." -ForegroundColor Yellow
    try {
        $content = Invoke-RestMethod -Uri $Fallback -UseBasicParsing -TimeoutSec 30
    } catch {
        Write-Host " [FAIL] 无法下载安装脚本，请检查网络或稍后重试。" -ForegroundColor Red
        Write-Host "  主源: $Primary"
        Write-Host "  备用: $Fallback"
        exit 1
    }
}

$content = $content.TrimStart([char]0xFEFF)

$extraArgs = @()
if ($Help)    { $extraArgs += "-Help" }
if ($DryRun)  { $extraArgs += "-DryRun" }

$block = [scriptblock]::Create($content)
& $block @extraArgs
