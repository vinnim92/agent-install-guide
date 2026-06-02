# Claude Code Windows short entry — auto-redirects to latest stable installer
# Usage: irm https://vinnim92.github.io/agent-install-guide/i/claude.ps1 | iex
#   Or:  .\claude.ps1 -Help / -DryRun

param([switch]$Help, [switch]$DryRun)

$Version = "v3.1.0"
$Base    = "https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@$Version/scripts"
$Script  = "$Base/install-claude-code.ps1"

$content = Invoke-RestMethod -Uri $Script -UseBasicParsing

$extraArgs = @()
if ($Help)    { $extraArgs += "-Help" }
if ($DryRun)  { $extraArgs += "-DryRun" }

$block = [scriptblock]::Create($content)
& $block @extraArgs
