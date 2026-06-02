# OpenClaw Windows entry — auto-redirects to latest stable installer
# Usage: irm https://vinnim92.github.io/agent-install-guide/i/openclaw.ps1 | iex
#   Or:  .\openclaw.ps1 -Help / -DryRun

param([switch]$Help, [switch]$DryRun)

$Version = "v3.1.2"

$sources = @()

if ($env:GITEE_ACCOUNT) {
    $sources += @{Name="Gitee 国内镜像"; Url="https://gitee.com/$env:GITEE_ACCOUNT/agent-install-guide/raw/main/scripts/install-openclaw.ps1"}
}

$sources += @{Name="jsDelivr CDN"; Url="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@$Version/scripts/install-openclaw.ps1"}

$sources += @{Name="GitHub raw"; Url="https://raw.githubusercontent.com/vinnim92/agent-install-guide/$Version/scripts/install-openclaw.ps1"}

$content = $null
foreach ($src in $sources) {
    try {
        $content = Invoke-RestMethod -Uri $src.Url -UseBasicParsing -TimeoutSec 30
        if ($content) { break }
    } catch {
        Write-Host " [WARN] $($src.Name) 访问失败，尝试下一源..." -ForegroundColor Yellow
    }
}

if (-not $content) {
    Write-Host " [FAIL] 所有下载源均失败，请检查网络或稍后重试。" -ForegroundColor Red
    Write-Host "  国内用户可设置 Gitee 镜像: `$env:GITEE_ACCOUNT='你的账号'"
    foreach ($src in $sources) { Write-Host "  $($src.Name): $($src.Url)" }
    exit 1
}

$content = $content.TrimStart([char]0xFEFF)

$extraArgs = @()
if ($Help)    { $extraArgs += "-Help" }
if ($DryRun)  { $extraArgs += "-DryRun" }

$block = [scriptblock]::Create($content)
& $block @extraArgs
