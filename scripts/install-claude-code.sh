#!/usr/bin/env bash
# ============================================================
# Claude Code 安装脚本
# 支持系统: macOS / Linux
# 需要: Claude 账号（Pro/Max/Team/Enterprise）或 Anthropic API Key
# Claude Code 自带运行时，无需单独安装 Node.js
#
# 用法:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.sh | bash
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

# ---------- 输出函数 ----------
print_step()    { echo -e "${BLUE}[→]${NC} $1"; }
print_success() { echo -e "    ${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "    ${RED}❌ $1${NC}"; }
print_warning() { echo -e "    ${YELLOW}⚠️  $1${NC}"; }
print_tip()     { echo -e "    ${CYAN}💡 $1${NC}"; }
print_dryrun()  { echo -e "    ${YELLOW}[DRY-RUN]${NC} 将执行: $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# ---------- 确认机制 ----------
confirm() {
    local prompt="$1"
    if [ "$SKIP_CONFIRM" = true ]; then
        echo -e "    ${CYAN}💡${NC} ${prompt} → 自动确认（AGENT_INSTALL_YES=1）"
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

# ---------- dry-run 执行包装 ----------
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
    echo "  bash install-claude-code.sh           正常安装"
    echo "  bash install-claude-code.sh --help    显示帮助"
    echo "  bash install-claude-code.sh --dry-run 预览步骤（不安装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-claude-code.sh"
    echo ""
    echo "安装后启动:"
    echo "  终端输入: claude"
    echo ""
    echo "常见失败原因:"
    echo "  1. 网络无法访问 claude.ai → 尝试切换网络或使用代理"
    echo "  2. 未安装 Git → macOS: xcode-select --install"
    echo "  3. 安装后找不到 claude → 关掉终端重新打开"
    echo "  4. 登录失败 → 确认有 Claude Pro/Max/Team 订阅"
    echo ""
    exit 0
}

# ---------- 系统检测 ----------
detect_os() {
    case "$(uname -s)" in
        Darwin) OS_TYPE="macOS" ;;
        Linux)  OS_TYPE="linux" ;;
        *)
            print_error "不支持的操作系统: $(uname -s)"
            print_tip "Windows 用户请使用 PowerShell 版本安装脚本"
            exit 1
            ;;
    esac
    echo -e "  ${GREEN}✅${NC} 操作系统: ${OS_TYPE}"
    echo -e "  ${GREEN}✅${NC} 架构: $(uname -m)"
}

# ---------- 网络检查 ----------
check_network() {
    print_step "检查网络连通性..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "curl -fsSL --connect-timeout 5 https://github.com"
        return 0
    fi
    if curl -fsSL --connect-timeout 5 https://github.com >/dev/null 2>&1; then
        print_success "GitHub 可访问"
    else
        print_warning "GitHub 访问受限，安装可能受影响"
        print_tip "可尝试使用代理或 VPN"
    fi
}

# ---------- PATH 配置 ----------
ensure_path() {
    local dir="$1"
    if [ "$DRY_RUN" = true ]; then
        print_step "将会把 ${dir} 加入 PATH"
        local rc_file=""
        case "$SHELL" in */zsh) rc_file="$HOME/.zshrc" ;; */bash) rc_file="$HOME/.bashrc" ;; *) rc_file="$HOME/.profile" ;; esac
        print_dryrun "echo 'export PATH=\"${dir}:\$PATH\"' >> ${rc_file}"
        return 0
    fi

    local rc_file=""
    case "$SHELL" in
        */zsh)  rc_file="$HOME/.zshrc" ;;
        */bash) rc_file="$HOME/.bashrc" ;;
        *)      rc_file="$HOME/.profile" ;;
    esac

    print_step "配置 PATH（将 ${dir} 加入 ${rc_file}）..."

    if ! confirm "是否将 ${dir} 加入 PATH（写入 ${rc_file}）？"; then
        print_tip "已跳过 PATH 配置，你可以稍后手动添加:"
        echo "  echo 'export PATH=\"${dir}:\$PATH\"' >> ${rc_file}"
        export PATH="$dir:$PATH"
        return 0
    fi

    if ! grep -q "$dir" "$rc_file" 2>/dev/null; then
        echo "export PATH=\"$dir:\$PATH\"" >> "$rc_file"
        print_tip "已将 $dir 加入 $rc_file"
    fi
    export PATH="$dir:$PATH"
}

# ---------- 前置条件检查 ----------
check_prereqs() {
    print_step "检查系统环境..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Git 是否安装"
        print_dryrun "检查系统架构和操作系统"
        return 0
    fi
    if command_exists git; then
        print_success "Git $(git --version | awk '{print $3}')"
    else
        print_error "Git 未安装"
        echo ""
        echo "  请先安装 Git:"
        echo "    macOS:  xcode-select --install"
        echo "    Ubuntu: sudo apt install git"
        exit 1
    fi
    print_success "Claude Code 自带完整运行时，无额外依赖"
    print_tip "需要 Claude 账号（Pro/Max/Team/Enterprise）或 Anthropic API Key"
}

# ---------- 安装 Claude Code ----------
install_claude_code() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  安装 Claude Code${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        if command_exists claude; then
            print_success "Claude Code 已安装"
            return 0
        fi
        case "$OS_TYPE" in
            macOS)
                if command_exists brew; then
                    print_dryrun "brew install --cask claude-code"
                else
                    print_dryrun "curl -fsSL https://claude.ai/install.sh | bash"
                fi
                ;;
            linux)
                print_dryrun "curl -fsSL https://claude.ai/install.sh | bash"
                ;;
        esac
        print_dryrun "验证: command -v claude"
        return 0
    fi

    if command_exists claude; then
        print_success "Claude Code 已安装 ($(claude --version 2>/dev/null | head -1 || echo '未知版本'))"
        return 0
    fi

    if ! confirm "即将安装 Claude Code，是否继续？"; then
        print_tip "已取消安装"
        exit 0
    fi

    print_step "开始安装 Claude Code..."

    case "$OS_TYPE" in
        macOS)
            if command_exists brew; then
                print_step "通过 Homebrew 安装..."
                if run_cmd "brew install --cask claude-code 2>/dev/null"; then
                    print_success "Homebrew 安装成功"
                else
                    print_warning "Homebrew 安装失败，改用官方脚本..."
                    install_via_official_script
                fi
            else
                install_via_official_script
            fi
            ;;
        linux)
            install_via_official_script
            ;;
    esac

    verify_installation
}

install_via_official_script() {
    print_step "使用官方安装脚本..."
    if run_cmd "curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null"; then
        print_success "官方脚本安装成功"
    else
        print_warning "官方脚本不可用，尝试 npm 安装..."
        if command_exists npm; then
            if confirm "将通过 npm 安装 Claude Code（全局），是否继续？"; then
                run_cmd "npm install -g @anthropic-ai/claude-code@latest 2>/dev/null" && print_success "npm 安装成功" || {
                    print_error "安装失败"
                    return 1
                }
            else
                print_tip "已取消"
                exit 0
            fi
        else
            print_error "安装失败，且未找到 npm"
            echo ""
            echo "  手动安装: 访问 https://claude.ai/download 下载安装包"
            exit 1
        fi
    fi
}

# ---------- 验证安装 ----------
verify_installation() {
    print_step "验证安装..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "确保 ~/.local/bin 在 PATH 中"
        print_dryrun "验证: command -v claude"
        return 0
    fi
    ensure_path "$HOME/.local/bin"
    hash -r 2>/dev/null || true

    if command_exists claude; then
        print_success "Claude Code 安装完成！"
        claude --version 2>/dev/null | head -1 | while read -r v; do echo -e "  ${v}"; done
    else
        print_error "找不到 claude 命令"
        echo ""
        echo "  排查建议:"
        echo "  1. 关闭当前终端窗口，重新打开后再试"
        echo "  2. 手动执行: export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "  3. 手动安装: npm install -g @anthropic-ai/claude-code"
        echo "  4. 访问 https://claude.ai/download 下载安装包"
        exit 1
    fi
}

# ==================== 主流程 ====================

# 参数解析
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
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 预览模式 — 只显示步骤，不执行安装${NC}"
    echo ""
fi

echo -e "  本脚本将安装 ${BOLD}Claude Code${NC}"
echo -e "  需要 Claude 账号或 Anthropic API Key"
echo ""

detect_os
check_network
check_prereqs
install_claude_code

if [ "$DRY_RUN" = true ]; then
    echo ""
    print_success "预览完成 — 以上步骤未实际执行"
    echo ""
    echo "  如需正式安装，请运行:"
    echo "    bash install-claude-code.sh"
    echo ""
    echo "  或在管道中远程执行:"
    echo "    curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install-claude-code.sh | bash"
    exit 0
fi

echo ""
print_success "Claude Code 安装验证通过"
echo ""
echo -e "${GREEN}第一次启动:${NC}"
echo "  在终端输入 claude 并回车"
echo "  浏览器会自动弹出，登录你的 Claude 账号即可"
echo ""
echo -e "  常用命令:"
echo "    claude             启动交互式对话"
echo "    claude --version   查看版本"
echo "    claude doctor      运行诊断"
echo ""
