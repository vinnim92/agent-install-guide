#!/usr/bin/env bash
# ============================================================
# Codex 安装脚本
# 支持系统: macOS / Linux
# 需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key
# 需要: Node.js >= 22（脚本会自动安装）
#
# 用法:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/scripts/install-codex.sh | bash
#   bash install-codex.sh --help
#   bash install-codex.sh --dry-run
#   AGENT_INSTALL_YES=1 bash install-codex.sh
# ============================================================

set -euo pipefail

# ---------- 颜色 ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

DRY_RUN=false
SKIP_CONFIRM=false
OS_TYPE=""
AGENT_NAME="Codex"
AGENT_BIN="codex"
OFFICIAL_URL="https://chatgpt.com/codex/install.sh"

# ---------- 输出函数 ----------
print_step()    { echo -e "${BLUE}[→]${NC} $1"; }
print_success() { echo -e "    ${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "    ${RED}❌ $1${NC}"; }
print_warning() { echo -e "    ${YELLOW}⚠️  $1${NC}"; }
print_tip()     { echo -e "    ${CYAN}💡 $1${NC}"; }
print_dryrun()  { echo -e "    ${YELLOW}[预演]${NC} 将执行: $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
version_gte()   { printf '%s\n%s\n' "$2" "$1" | sort -V -C; }

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
    echo "  Codex 安装脚本"
    echo "========================================"
    echo ""
    echo "安装: Codex CLI（OpenAI 出品）"
    echo "系统: macOS / Linux"
    echo "需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key"
    echo "      需要 Node.js >= 22（脚本会自动安装）"
    echo ""
    echo "用法:"
    echo "  bash install-codex.sh           正常安装（自动检查环境）"
    echo "  bash install-codex.sh --help    显示帮助"
    echo "  bash install-codex.sh --dry-run 排查/预览（只看不装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-codex.sh"
    echo ""
    echo "安装后启动:"
    echo "  终端输入: codex"
    echo ""
    echo "安装失败？"
    echo "  打开故障排查页面:"
    echo "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/docs/support.html"
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
        echo "  macOS:  xcode-select --install"
        echo "  Ubuntu: sudo apt install git"
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

    # 4. Node.js
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Node.js 版本 (需要 >= 22)"
    elif command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js v${node_ver} (满足要求)"
        else
            print_warning "Node.js v${node_ver} 版本较低，将自动安装 v22+"
        fi
    else
        print_warning "Node.js 未安装，将自动安装 v22+"
    fi

    # 5. 是否已安装
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

    # 6. 安装方式
    print_tip "将优先使用官方安装方式（${OFFICIAL_URL}）"

    echo ""
    echo -e "${GREEN}  ✅ 系统检查完成${NC}"
    echo -e "${GREEN}  ✅ 网络检查完成${NC}"
    echo -e "${GREEN}  ✅ 安装准备完成${NC}"
    echo ""

    # 7. 总结
    echo -e "  ${BOLD}接下来将安装:${NC} ${AGENT_NAME}"
    echo -e "  ${BOLD}可能需要:${NC} 自动安装 Node.js（如果需要）"
    echo -e "  ${BOLD}需要准备:${NC} ChatGPT 账号或 OpenAI API Key"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_tip "以上为环境检查结果（dry-run 模式，未执行实际安装）"
        exit 0
    fi

    if ! confirm "是否继续安装 ${AGENT_NAME}？"; then
        print_tip "已取消安装。有问题请看故障排查:"
        echo "  https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/docs/support.html"
        exit 0
    fi
}

# ---------- Node.js ----------
ensure_nodejs() {
    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        if version_gte "$node_ver" "22.0.0"; then
            return 0
        fi
    fi

    echo ""
    echo -e "${CYAN}  自动安装 Node.js v22+ ...${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_dryrun "通过包管理器安装 Node.js"
        return 0
    fi

    case "$OS_TYPE" in
        macOS)
            if ! command_exists brew; then
                print_step "安装 Homebrew..."
                run_cmd "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" 2>/dev/null || true"
                if [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
                if [ -f /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
            fi
            if command_exists brew; then
                run_cmd "brew install node@22 2>/dev/null && brew link --overwrite --force node@22 2>/dev/null || true"
            fi
            ;;
        linux)
            if command_exists apt-get; then
                run_cmd "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null"
                run_cmd "sudo apt-get install -y -qq nodejs 2>/dev/null || true"
            elif command_exists dnf; then
                run_cmd "curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash - 2>/dev/null"
                run_cmd "sudo dnf install -y nodejs 2>/dev/null || true"
            elif command_exists pacman; then
                run_cmd "sudo pacman -S --noconfirm nodejs npm 2>/dev/null || true"
            fi
            ;;
    esac

    if ! command_exists node; then
        print_error "Node.js 自动安装失败"
        echo "  请访问 https://nodejs.org 手动安装后重试"
        exit 1
    fi
    print_success "Node.js $(node -v) 安装成功"
}

ensure_npm_path() {
    if [ "$DRY_RUN" = true ]; then return 0; fi
    local npm_prefix
    npm_prefix=$(npm prefix -g 2>/dev/null || echo "")
    if [ -n "$npm_prefix" ] && [ -d "$npm_prefix/bin" ]; then
        export PATH="$npm_prefix/bin:$PATH"
    fi
}

fix_npm_permissions() {
    if [ "$DRY_RUN" = true ]; then return 0; fi
    if command_exists npm; then
        local npm_prefix
        npm_prefix=$(npm config get prefix 2>/dev/null || echo "")
        if [ -n "$npm_prefix" ] && [ ! -w "$npm_prefix" ]; then
            print_warning "npm 全局安装目录没有写权限"
            if confirm "是否修复权限（切换到 ~/.npm-global）？"; then
                local d="$HOME/.npm-global"
                mkdir -p "$d" 2>/dev/null || true
                npm config set prefix "$d" 2>/dev/null || true
                export PATH="$d/bin:$PATH"
                print_tip "已修复"
            fi
        fi
    fi
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

    ensure_nodejs
    fix_npm_permissions

    # 方法1: 官方 installer（优先）
    print_step "使用官方安装脚本..."
    if run_cmd "curl -fsSL ${OFFICIAL_URL} | bash 2>/dev/null"; then
        print_success "官方脚本安装成功"
    else
        # 方法2: npm fallback
        print_warning "官方脚本不可用，使用 npm..."
        if ! command_exists npm; then
            print_error "npm 不可用"
            echo "  排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/docs/support.html"
            exit 1
        fi
        local registry_flag=""
        if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
            print_tip "切换国内镜像"
            registry_flag="--registry https://registry.npmmirror.com"
        fi
        if run_cmd "npm install -g ${registry_flag} @openai/codex 2>/dev/null"; then
            print_success "npm 安装成功"
        else
            print_error "npm 安装失败"
            echo "  排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/docs/support.html"
            exit 1
        fi
    fi

    ensure_npm_path
    if command_exists "$AGENT_BIN"; then
        print_success "${AGENT_NAME} 安装完成！"
        $AGENT_BIN --version 2>/dev/null | head -1 | while read -r v; do echo -e "  ${v}"; done
    else
        print_error "找不到 ${AGENT_BIN} 命令"
        echo "  1. 关掉终端窗口，重新打开后再试"
        echo "  2. 故障排查: https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.5/docs/support.html"
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
echo -e "${CYAN}  Codex 安装助手${NC}"
echo -e "${CYAN}==========================================${NC}"

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 dry-run 模式 — 只看不装${NC}"
fi

# ---------- Codex 登录方式选择 ----------
configure_codex_login() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "提示选择 Codex 登录方式"
        return 0
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  Codex 登录方式${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  Codex 支持两种登录方式："
    echo ""
    echo -e "  ${BOLD}方式一：官方账号登录${NC}"
    echo "    适合已有 ChatGPT / OpenAI 账号的用户。"
    echo "    终端输入 codex login，浏览器自动弹出登录页。"
    echo ""
    echo -e "  ${BOLD}方式二：API Key 登录${NC}"
    echo "    适合使用 OpenAI API Key 的用户。"
    echo ""
    echo "    在终端依次运行:"
    echo "      export OPENAI_API_KEY=\"你的 OpenAI API Key\""
    echo "      printenv OPENAI_API_KEY | codex login --with-api-key"
    echo ""
    echo "  请选择适合你的方式。安装包负责安装和引导，不提供账号或 API Key。"
    echo ""
}

run_precheck
do_install

echo ""
print_success "${AGENT_NAME} 安装验证通过"
configure_codex_login

echo ""
echo -e "${GREEN}登录后启动:${NC}"
echo "  终端输入: ${AGENT_BIN}"
echo ""
echo -e "  常用命令:"
echo "    codex --version      查看版本"
echo "    codex login          手动登录"
echo "    codex \"任务描述\"      带初始提示启动"
echo "    codex exec \"...\"     非交互执行"
echo ""
