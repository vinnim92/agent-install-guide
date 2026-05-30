#!/usr/bin/env bash
# ============================================================
# Claude Code 安装脚本
# 支持系统: macOS / Linux
# 需要: Claude 账号（Pro/Max/Team/Enterprise）或 Anthropic API Key
# Claude Code 自带运行时，无需单独安装 Node.js
#
# 用法:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/scripts/install-claude-code.sh | bash
#   bash install-claude-code.sh --help
#   bash install-claude-code.sh --dry-run
#   AGENT_INSTALL_YES=1 bash install-claude-code.sh
# ============================================================

set -euo pipefail

# ---------- 颜色 ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

DRY_RUN=false
SKIP_CONFIRM=false
OS_TYPE=""
AGENT_NAME="Claude Code"
AGENT_BIN="claude"
OFFICIAL_URL="https://claude.ai/install.sh"

# ---------- 输出函数 ----------
print_step()    { echo -e "${BLUE}[→]${NC} $1"; }
print_success() { echo -e "    ${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "    ${RED}❌ $1${NC}"; }
print_warning() { echo -e "    ${YELLOW}⚠️  $1${NC}"; }
print_tip()     { echo -e "    ${CYAN}💡 $1${NC}"; }
print_dryrun()  { echo -e "    ${YELLOW}[预演]${NC} 将执行: $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ---------- 确认机制 ----------
confirm() {
    local prompt="$1"
    if [ "$SKIP_CONFIRM" = true ]; then
        echo -e "    ${CYAN}💡${NC} ${prompt} → 自动确认"
        return 0
    fi
    local yn
    read -r -p "$(echo -e "${BLUE}[?]${NC} ${prompt} [Y/n]: ")" yn
    yn=${yn:-y}
    case "$yn" in
        [Yy]*|[Yy][Ee][Ss]*|是|是的|对|对的) return 0 ;;
        *) return 1 ;;
    esac
}

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "$*"
        return 0
    else
        eval "$@"
    fi
}

# ---------- --help ----------
show_help() {
    echo ""
    echo "========================================"
    echo "  Claude Code 安装脚本"
    echo "========================================"
    echo ""
    echo "安装: Claude Code（Anthropic 出品）"
    echo "系统: macOS / Linux"
    echo "需要: Claude 账号（Pro/Max/Team/Enterprise）或 Anthropic API Key"
    echo "      无需单独安装 Node.js（Claude Code 自带运行时）"
    echo ""
    echo "用法:"
    echo "  bash install-claude-code.sh           正常安装（自动检查环境）"
    echo "  bash install-claude-code.sh --help    显示帮助"
    echo "  bash install-claude-code.sh --dry-run 排查/预览（只看不装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-claude-code.sh"
    echo ""
    echo "安装后启动:"
    echo "  终端输入: claude"
    echo ""
    echo "安装失败？"
    echo "  打开故障排查页面:"
    echo "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/docs/support.html"
    echo ""
    exit 0
}

# ============ 安装前自动检查 ============
run_precheck() {
    echo ""
    echo -e "${CYAN}  正在检查你的电脑环境...${NC}"
    echo ""

    # 1. 操作系统
    case "$(uname -s)" in
        Darwin) OS_TYPE="macOS" ;;
        Linux)  OS_TYPE="linux" ;;
        *)
            print_error "不支持的操作系统: $(uname -s)"
            print_tip "Windows 用户请使用 PowerShell 版本安装脚本"
            exit 1
            ;;
    esac
    print_success "系统: ${OS_TYPE} · 架构: $(uname -m)"

    # 2. Git
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Git 是否安装"
    elif command_exists git; then
        print_success "Git 已安装"
    else
        print_error "Git 未安装"
        echo ""
        echo "  请先安装 Git:"
        echo "    macOS:  xcode-select --install"
        echo "    Ubuntu: sudo apt install git"
        exit 1
    fi

    # 3. 网络
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查网络连通性"
    elif curl -fsSL --connect-timeout 5 https://github.com >/dev/null 2>&1; then
        print_success "网络连接正常"
    else
        print_warning "网络访问受限，安装可能受影响"
    fi

    # 4. 是否已安装
    if command_exists "$AGENT_BIN"; then
        local ver
        ver=$($AGENT_BIN --version 2>/dev/null | head -1 || echo '未知版本')
        print_success "${AGENT_NAME} 已安装 (${ver})"
        echo ""
        if confirm "是否重新安装/升级到最新版？"; then
            print_step "将继续安装最新版..."
        else
            print_tip "已取消。在终端输入 ${AGENT_BIN} 即可启动。"
            exit 0
        fi
    else
        print_step "${AGENT_NAME} 尚未安装"
    fi

    # 5. 安装方式
    print_tip "将使用官方安装方式（${OFFICIAL_URL}）"
    print_success "Claude Code 自带运行时，无需安装 Node.js"

    echo ""
    echo -e "${GREEN}  ✅ 系统检查完成${NC}"
    echo -e "${GREEN}  ✅ 网络检查完成${NC}"
    echo -e "${GREEN}  ✅ 安装准备完成${NC}"
    echo ""

    # 6. 总结
    echo -e "  ${BOLD}接下来将安装:${NC} ${AGENT_NAME}"
    echo -e "  ${BOLD}安装方式:${NC} 官方安装脚本"
    echo -e "  ${BOLD}需要准备:${NC} Claude 账号或 Anthropic API Key"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_tip "以上为环境检查结果（dry-run 模式，未执行实际安装）"
        exit 0
    fi

    if ! confirm "是否继续安装 ${AGENT_NAME}？"; then
        print_tip "已取消安装。有问题请看故障排查:"
        echo "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/docs/support.html"
        exit 0
    fi
}

# ---------- PATH 配置 ----------
ensure_path() {
    local dir="$1"
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "将 ${dir} 加入 PATH"
        return 0
    fi
    local rc_file=""
    case "$SHELL" in */zsh) rc_file="$HOME/.zshrc" ;; */bash) rc_file="$HOME/.bashrc" ;; *) rc_file="$HOME/.profile" ;; esac
    print_step "配置 PATH..."
    if ! grep -q "$dir" "$rc_file" 2>/dev/null; then
        echo "export PATH=\"$dir:\$PATH\"" >> "$rc_file"
    fi
    export PATH="$dir:$PATH"
}

# ---------- 安装 ----------
do_install() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  开始安装 ${AGENT_NAME}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_dryrun "官方脚本: curl -fsSL ${OFFICIAL_URL} | bash"
        print_dryrun "验证: command -v ${AGENT_BIN}"
        return 0
    fi

    # 方法1: 官方 installer（优先）
    print_step "使用官方安装脚本..."
    if run_cmd "curl -fsSL ${OFFICIAL_URL} | bash 2>/dev/null"; then
        print_success "官方脚本安装成功"
    else
        print_warning "官方脚本不可用，尝试 npm..."
        if command_exists npm; then
            run_cmd "npm install -g @anthropic-ai/claude-code@latest 2>/dev/null" && print_success "npm 安装成功" || {
                print_error "安装失败"
                echo ""
                echo "  排查: 访问 https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/docs/support.html"
                exit 1
            }
        else
            print_error "安装失败，且未找到 npm"
            echo "  手动安装: 访问 https://claude.ai/download"
            echo "  排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/docs/support.html"
            exit 1
        fi
    fi

    # 验证
    ensure_path "$HOME/.local/bin"
    hash -r 2>/dev/null || true

    if command_exists "$AGENT_BIN"; then
        print_success "${AGENT_NAME} 安装完成！"
        $AGENT_BIN --version 2>/dev/null | head -1 | while read -r v; do echo -e "  ${v}"; done
    else
        print_error "找不到 ${AGENT_BIN} 命令"
        echo ""
        echo "  1. 关掉终端窗口，重新打开后再试"
        echo "  2. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.4/docs/support.html"
        exit 1
    fi
}

# ==================== 主流程 ====================

for arg in "$@"; do
    case "$arg" in
        --help|-h) show_help ;;
        --dry-run) DRY_RUN=true ;;
        *) ;;
    esac
done

if [ "${AGENT_INSTALL_YES:-0}" = "1" ]; then
    SKIP_CONFIRM=true
fi

echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}  Claude Code 安装助手${NC}"
echo -e "${CYAN}==========================================${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 dry-run 模式 — 只看不装${NC}"
fi

run_precheck
do_install

echo ""
print_success "${AGENT_NAME} 安装验证通过"
echo ""
echo -e "${GREEN}第一次启动:${NC}"
echo "  终端输入: ${AGENT_BIN}"
echo "  浏览器会自动弹出 Claude 登录页"
echo ""
echo -e "  常用命令:"
echo "    claude             启动交互式对话"
echo "    claude --version   查看版本"
echo "    claude doctor      运行诊断"
echo ""
