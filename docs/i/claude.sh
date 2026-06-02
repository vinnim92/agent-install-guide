#!/usr/bin/env bash
# Claude Code macOS/Linux short entry — auto-redirects to latest stable installer
# Usage: curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash
#   Or:  bash claude.sh --help / --dry-run

set -euo pipefail

VERSION="v3.1.1"
BASE="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@${VERSION}/scripts"
SCRIPT="install-claude-code.sh"

PRIMARY="${BASE}/${SCRIPT}"
FALLBACK="https://raw.githubusercontent.com/vinnim92/agent-install-guide/${VERSION}/scripts/${SCRIPT}"

TMPFILE=$(mktemp /tmp/agent-install-XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

if curl -fsSL --connect-timeout 10 --max-time 30 "$PRIMARY" -o "$TMPFILE"; then
    bash "$TMPFILE" "$@"
elif curl -fsSL --connect-timeout 10 --max-time 30 "$FALLBACK" -o "$TMPFILE"; then
    echo "[WARN] CDN 访问失败，已切换 GitHub raw 备用源"
    bash "$TMPFILE" "$@"
else
    echo "[FAIL] 无法下载安装脚本，请检查网络或稍后重试。"
    echo "  主源: $PRIMARY"
    echo "  备用: $FALLBACK"
    exit 1
fi
