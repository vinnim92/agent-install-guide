#!/usr/bin/env bash
# ============================================================
# Codex 安装脚本
# 支持系统: macOS / Linux
# 需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key
# 需要: Node.js >= 22（脚本会自动安装）
#
# 用法:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.0.3/scripts/install-codex.sh | bash
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

# ---------- 输出函数 ----------
print_step()    { echo -e "${BLUE}[→]${NC} $1"; }
print_success() { echo -e "    ${GREEN}✅ $1${NC}"; }
print_error()   { echo -e "    ${RED}❌ $1${NC}"; }
print_warning() { echo -e "    ${YELLOW}⚠️  $1${NC}"; }
print_tip()     { echo -e "    ${CYAN}💡 $1${NC}"; }
print_dryrun()  { echo -e "    ${YELLOW}[DRY-RUN]${NC} 将执行: $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
version_gte()   { printf '%s\n%s\n' "$2" "$1" | sort -V -C; }

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
    echo "  bash install-codex.sh           正常安装"
    echo "  bash install-codex.sh --help    显示帮助"
    echo "  bash install-codex.sh --dry-run 预览步骤（不安装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-codex.sh"
    echo ""
    echo "安装后启动:"
    echo "  终端输入: codex"
    echo "  浏览器会自动弹出 ChatGPT 登录页"
    echo ""
    echo "常见失败原因:"
    echo "  1. Node.js 版本不足 → 脚本会自动安装 v22+"
    echo "  2. npm 网络问题 → 脚本会自动切换国内镜像"
    echo "  3. npm 权限问题 → 脚本会自动修复 npm prefix"
    echo "  4. 安装后找不到 codex → 关掉终端重新打开"
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

ensure_npm_path() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检测 npm 全局 bin 目录并加入 PATH"
        return 0
    fi
    local npm_prefix
    npm_prefix=$(npm prefix -g 2>/dev/null || echo "")
    if [ -n "$npm_prefix" ] && [ -d "$npm_prefix/bin" ]; then
        export PATH="$npm_prefix/bin:$PATH"
    fi
}

check_git() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Git 是否安装"
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
}

# ---------- Node.js 安装 ----------
ensure_nodejs() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  检查 Node.js 环境${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        echo -e "  当前 Node.js 版本: v${node_ver}"
        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js 版本满足要求 (>= 22)"
            return 0
        else
            print_warning "Node.js 版本过低: v${node_ver} (需要 >= 22)"
        fi
    else
        print_warning "Node.js 未安装 (Codex 需要 >= 22)"
    fi

    if [ "$DRY_RUN" = true ]; then
        case "$OS_TYPE" in
            macOS) print_dryrun "通过 Homebrew 安装 node@22" ;;
            linux) print_dryrun "通过 apt/dnf/pacman 安装 nodejs" ;;
        esac
        return 0
    fi

    if ! confirm "即将安装 Node.js v22+（系统级软件），是否继续？"; then
        print_error "Node.js 是 Codex 的必要依赖，无法跳过"
        exit 1
    fi

    print_step "正在自动安装 Node.js..."

    case "$OS_TYPE" in
        macOS)
            if ! command_exists brew; then
                print_step "安装 Homebrew（Mac 软件管家）..."
                if confirm "将会安装 Homebrew（约需 2 分钟），是否继续？"; then
                    run_cmd "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" 2>/dev/null || true"
                    if [ -f /opt/homebrew/bin/brew ]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [ -f /usr/local/bin/brew ]; then
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                else
                    print_tip "已跳过 Homebrew 安装，请手动安装 Node.js"
                    exit 1
                fi
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

    if command_exists node; then
        print_success "Node.js 安装成功！版本: $(node -v)"
    else
        print_error "Node.js 自动安装失败"
        echo ""
        echo "  请手动安装 Node.js:"
        echo "    访问 https://nodejs.org 下载安装包"
        echo "    安装后重新运行本脚本即可"
        exit 1
    fi
}

# ---------- 修复 npm 权限 ----------
fix_npm_permissions() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 npm 全局目录权限，必要时切换到 ~/.npm-global"
        return 0
    fi
    if command_exists npm; then
        local npm_prefix
        npm_prefix=$(npm config get prefix 2>/dev/null || echo "")
        if [ -n "$npm_prefix" ] && [ ! -w "$npm_prefix" ]; then
            print_warning "npm 全局安装目录没有写权限: ${npm_prefix}"
            print_tip "将把 npm 全局安装目录切换到你用户目录下"
            if confirm "是否修改 npm prefix 到 ~/.npm-global（避免权限问题）？"; then
                local npm_global_dir="$HOME/.npm-global"
                mkdir -p "$npm_global_dir" 2>/dev/null || true
                npm config set prefix "$npm_global_dir" 2>/dev/null || true
                export PATH="$npm_global_dir/bin:$PATH"
                print_tip "已将 npm 全局安装路径改为 ~/.npm-global"
            else
                print_tip "已跳过，如遇权限错误可手动: npm config set prefix ~/.npm-global"
            fi
        fi
    fi
}

# ---------- npm 安装（带国内镜像自动切换） ----------
install_via_npm() {
    local pkg="$1"
    local bin_name="$2"

    print_step "通过 npm 全局安装 ${pkg}..."

    # 先检查官方 registry 是否可达
    local registry_flag=""
    if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
        print_tip "npm 官方源不可达，本次使用国内镜像"
        registry_flag="--registry https://registry.npmmirror.com"
    fi

    run_cmd "npm install -g ${registry_flag} ${pkg} 2>/dev/null"
}

# ---------- 安装 Codex ----------
install_codex() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  安装 Codex CLI${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if command_exists codex; then
        print_success "Codex 已安装 ($(codex --version 2>/dev/null | head -1 || echo '未知版本'))"
        return 0
    fi

    if [ "$DRY_RUN" = true ]; then
        print_dryrun "curl -fsSL https://chatgpt.com/codex/install.sh | bash"
        print_dryrun "验证: command -v codex"
        return 0
    fi

    if ! confirm "即将安装 Codex CLI，是否继续？"; then
        print_tip "已取消安装"
        exit 0
    fi

    # 方法1: 官方 standalone installer（优先）
    print_step "使用官方安装脚本（chatgpt.com/codex/install.sh）..."
    if run_cmd "curl -fsSL https://chatgpt.com/codex/install.sh | bash 2>/dev/null"; then
        print_success "官方脚本安装成功"
        verify_installation
        return 0
    fi

    # 方法2: npm fallback
    print_warning "官方脚本不可用，改用 npm 安装..."
    if ! command_exists npm; then
        print_error "npm 不可用，无法安装 Codex"
        echo ""
        echo "  请先安装 Node.js: https://nodejs.org"
        exit 1
    fi

    if install_via_npm "@openai/codex" "codex"; then
        print_success "Codex npm 安装成功"
    else
        print_error "npm 安装失败"
        echo ""
        echo "  排查步骤:"
        echo "  1. 检查 Node 版本: node -v (需要 >= 22)"
        echo "  2. 如果 EACCES 权限错误:"
        echo "     mkdir -p ~/.npm-global"
        echo "     npm config set prefix '~/.npm-global'"
        echo "     export PATH=~/.npm-global/bin:\$PATH"
        echo "  3. 重试: npm install -g @openai/codex"
        exit 1
    fi

    verify_installation
}

verify_installation() {
    print_step "验证安装..."
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "验证: command -v codex"
        return 0
    fi
    ensure_npm_path

    if command_exists codex; then
        print_success "Codex CLI 安装完成！"
        codex --version 2>/dev/null | head -1 | while read -r v; do echo -e "  ${v}"; done
    else
        print_error "找不到 codex 命令"
        print_tip "请重新打开终端，或检查 npm 全局安装路径"
        echo "  npm prefix -g  # 查看 npm 全局路径"
        echo "  export PATH=\"\$(npm prefix -g)/bin:\$PATH\""
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
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 预览模式 — 只显示步骤，不执行安装${NC}"
    echo ""
fi

echo -e "  本脚本将安装 ${BOLD}Codex${NC}"
echo -e "  需要 ChatGPT 账号或 OpenAI API Key"
echo ""

detect_os
check_network
check_git
ensure_nodejs
fix_npm_permissions
install_codex

if [ "$DRY_RUN" = true ]; then
    echo ""
    print_success "预览完成 — 以上步骤未实际执行"
    echo ""
    echo "  如需正式安装，请运行:"
    echo "    bash install-codex.sh"
    echo ""
    exit 0
fi

echo ""
print_success "Codex 安装验证通过"
echo ""
echo -e "${GREEN}第一次启动:${NC}"
echo "  在终端输入 codex 并回车"
echo "  浏览器会自动弹出 ChatGPT 登录页"
echo ""
echo -e "  或使用 API Key 方式:"
echo "    export OPENAI_API_KEY=sk-..."
echo "    codex"
echo ""
echo -e "  常用命令:"
echo "    codex --version      查看版本"
echo "    codex login          手动登录"
echo "    codex \"任务描述\"      带初始提示启动"
echo "    codex exec \"...\"     非交互执行"
echo ""
