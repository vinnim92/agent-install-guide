#!/usr/bin/env bash
# Claude Code macOS/Linux short entry — auto-redirects to latest stable installer
# Usage: curl -fsSL https://vinnim92.github.io/agent-install-guide/i/claude.sh | bash
#   Or:  bash claude.sh --help / --dry-run

set -euo pipefail

VERSION="v3.1.0"
BASE="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@${VERSION}/scripts"
SCRIPT="${BASE}/install-claude-code.sh"

curl -fsSL "${SCRIPT}" | bash -s -- "$@"
