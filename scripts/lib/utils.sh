#!/usr/bin/env bash
# ============================================================
# Agent Install Guide - 公共函数库
# ============================================================

set -euo pipefail

# ---------- 颜色定义 ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ---------- 全局变量 ----------
REPO_URL="https://github.com/vinnim92/agent-install-guide"
RAW_BASE="https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main"
VERSION_URL="${RAW_BASE}/VERSION"
CURRENT_VERSION="v2.0.0"
OS_TYPE=""
OS_ARCH=""

# ---------- 输出函数 ----------
print_header() {
    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}  Agent 安装指南 · 一键部署工具${NC}"
    echo -e "${CYAN}  ${REPO_URL}${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[→]${NC} $1"
}

print_success() {
    echo -e "    ${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "    ${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "    ${YELLOW}⚠️  $1${NC}"
}

print_tip() {
    echo -e "    ${CYAN}💡 $1${NC}"
}

# ---------- 系统检测 ----------
detect_os() {
    case "$(uname -s)" in
        Darwin)  OS_TYPE="macOS" ;;
        Linux)   OS_TYPE="linux" ;;
        MINGW*|MSYS*|CYGWIN*)
            OS_TYPE="windows-gitbash"
            print_warning "检测到 Git Bash 环境"
            print_tip "Windows 用户请使用 PowerShell 脚本: install.ps1"
            print_tip "或在 WSL2 中运行本脚本以获得最佳体验"
            echo ""
            ;;
        *)
            print_error "不支持的操作系统: $(uname -s)"
            exit 1
            ;;
    esac
    OS_ARCH=$(uname -m)
}

# ---------- 版本自检 ----------
check_self_update() {
    print_step "检查脚本版本..."
    local remote_version
    remote_version=$(curl -fsSL --connect-timeout 5 "$VERSION_URL" 2>/dev/null || echo "")
    if [ -n "$remote_version" ] && [ "$remote_version" != "$CURRENT_VERSION" ]; then
        print_warning "发现新版本: $remote_version (当前: $CURRENT_VERSION)"
        print_tip "建议更新: curl -fsSL ${RAW_BASE}/scripts/install.sh | bash"
        echo ""
    else
        print_success "脚本已是最新版本 ($CURRENT_VERSION)"
    fi
}

# ---------- 命令检查 ----------
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ---------- 确认对话框 ----------
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    local yn

    if [ "$default" = "y" ]; then
        read -r -p "$(echo -e "${BLUE}[?]${NC} ${prompt} [Y/n]: ")" yn
        yn=${yn:-y}
    else
        read -r -p "$(echo -e "${BLUE}[?]${NC} ${prompt} [y/N]: ")" yn
        yn=${yn:-n}
    fi

    case "$yn" in
        [Yy]*|[Yy][Ee][Ss]*|是|是的|对|对的) return 0 ;;
        *) return 1 ;;
    esac
}

# ---------- 带超时的下载 ----------
safe_download() {
    local url="$1"
    local output="$2"
    curl -fsSL --connect-timeout 30 --retry 3 "$url" -o "$output" 2>/dev/null
}

# ---------- 网络连通性检查 ----------
check_network() {
    print_step "检查网络连通性..."
    # 检查能否访问 GitHub
    if curl -fsSL --connect-timeout 5 https://github.com >/dev/null 2>&1; then
        print_success "GitHub 可访问"
    else
        print_warning "GitHub 访问受限，安装可能受影响"
        print_tip "可尝试使用代理或 VPN"
        print_tip "国内用户可设置镜像源（脚本会自动尝试）"
    fi
}

# ---------- 写 PATH 到配置 ----------
ensure_path() {
    local dir="$1"
    local rc_file=""
    case "$SHELL" in
        */zsh)  rc_file="$HOME/.zshrc" ;;
        */bash) rc_file="$HOME/.bashrc" ;;
        *)      rc_file="$HOME/.profile" ;;
    esac

    if ! grep -q "$dir" "$rc_file" 2>/dev/null; then
        echo "export PATH=\"$dir:\$PATH\"" >> "$rc_file"
        print_tip "已将 $dir 加入 $rc_file"
    fi
    export PATH="$dir:$PATH"
}

# ---------- 节点版本比较 ----------
version_gte() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}
