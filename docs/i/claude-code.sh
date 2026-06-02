#!/usr/bin/env bash
# Claude Code macOS/Linux compatibility alias — forwards to claude.sh
# 推荐主入口: curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash
# 此别名保留用于兼容旧版文档中的 claude-code.sh 链接。

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
