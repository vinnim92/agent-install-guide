#!/usr/bin/env bash
# Claude Code macOS/Linux entry — auto-redirects to latest stable installer
# Usage: curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash
#   Or:  bash claude.sh --help / --dry-run

set -euo pipefail

VERSION="v3.1.2"
GITEE_ACCOUNT="${GITEE_ACCOUNT:-}"
SCRIPT="install-claude-code.sh"

TMPFILE=$(mktemp /tmp/agent-install-XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

downloaded=false

# Gitee 国内镜像（优先，需设置 GITEE_ACCOUNT 环境变量）
if [ -n "$GITEE_ACCOUNT" ]; then
    GITEE="https://gitee.com/${GITEE_ACCOUNT}/agent-install-guide/raw/main/scripts/${SCRIPT}"
    if curl -fsSL --connect-timeout 10 --max-time 30 "$GITEE" -o "$TMPFILE"; then
        downloaded=true
    fi
fi

# jsDelivr CDN
if [ "$downloaded" != true ]; then
    CDN="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@${VERSION}/scripts/${SCRIPT}"
    if curl -fsSL --connect-timeout 10 --max-time 30 "$CDN" -o "$TMPFILE"; then
        downloaded=true
    else
        echo "[WARN] Gitee / CDN 不可用，尝试 GitHub raw..."
    fi
fi

# GitHub raw（最终备用）
if [ "$downloaded" != true ]; then
    GITHUB="https://raw.githubusercontent.com/vinnim92/agent-install-guide/${VERSION}/scripts/${SCRIPT}"
    if curl -fsSL --connect-timeout 10 --max-time 30 "$GITHUB" -o "$TMPFILE"; then
        downloaded=true
    fi
fi

if [ "$downloaded" != true ]; then
    echo "[FAIL] 无法下载安装脚本，请检查网络或稍后重试。"
    echo "  国内用户可设置 Gitee 镜像: export GITEE_ACCOUNT='你的账号'"
    exit 1
fi

bash "$TMPFILE" "$@"
