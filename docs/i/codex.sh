#!/usr/bin/env bash
# Codex macOS/Linux short entry — auto-redirects to latest stable installer
# Usage: curl -fsSL https://vinnim92.github.io/agent-install-guide/i/codex.sh | bash
#   Or:  bash codex.sh --help / --dry-run

set -euo pipefail

VERSION="v3.1.0"
BASE="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@${VERSION}/scripts"
SCRIPT="${BASE}/install-codex.sh"

curl -fsSL "${SCRIPT}" | bash -s -- "$@"
