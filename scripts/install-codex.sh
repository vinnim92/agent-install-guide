#!/usr/bin/env bash
# ============================================================
# Codex 安装脚本
# 支持系统: macOS / Linux
# 需要: ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key
# 需要: Node.js >= 22（脚本会提示安装）
#
# 用法:
#   bash install-codex.sh           普通模式（自动 fallback）
#   bash install-codex.sh --china   国内镜像模式（强制 npmmirror）
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
CHINA_MODE=false
OS_TYPE=""
AGENT_NAME="Codex"
AGENT_BIN="codex"
OFFICIAL_URL="https://chatgpt.com/codex/install.sh"
LOGFILE="$HOME/agent-install-codex.log"
INSTALL_PATH=""  # official | npm-official | npm-mirror

# ---------- 输出函数（同时写日志）----------
print_step()    { echo -e "${BLUE}[→]${NC} $1" | tee -a "$LOGFILE"; }
print_success() { echo -e "    ${GREEN}✅ $1${NC}" | tee -a "$LOGFILE"; }
print_error()   { echo -e "    ${RED}❌ $1${NC}" | tee -a "$LOGFILE"; }
print_warning() { echo -e "    ${YELLOW}⚠️  $1${NC}" | tee -a "$LOGFILE"; }
print_tip()     { echo -e "    ${CYAN}💡 $1${NC}" | tee -a "$LOGFILE"; }
print_dryrun()  { echo -e "    ${YELLOW}[预演]${NC} 将执行: $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }
version_gte()   { printf '%s\n%s\n' "$2" "$1" | sort -V -C; }

# ---------- 确认机制 ----------
confirm() {
    local prompt="$1"
    if [ "$SKIP_CONFIRM" = true ]; then
        echo -e "    ${CYAN}💡${NC} ${prompt} → 自动确认" | tee -a "$LOGFILE"
        return 0
    fi
    local yn
    if [ -r /dev/tty ]; then
        read -r -p "$(echo -e "${BLUE}[?]${NC} ${prompt} [Y/n]: ")" yn < /dev/tty
    else
        print_warning "当前环境无法读取键盘输入"
        print_tip "如果你确认继续，请使用：AGENT_INSTALL_YES=1 bash install-codex.sh --china"
        return 1
    fi
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
        echo "  [RUN] $*" >> "$LOGFILE"
        eval "$@" 2>>"$LOGFILE"
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
    echo "      需要 Node.js >= 22"
    echo ""
    echo "用法:"
    echo "  bash install-codex.sh           普通模式（官方→npm→镜像 自动 fallback）"
    echo "  bash install-codex.sh --china   国内镜像模式（强制 npmmirror）"
    echo "  bash install-codex.sh --help    显示帮助"
    echo "  bash install-codex.sh --dry-run 排查/预览（只看不装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-codex.sh"
    echo ""
    echo "国内网络一键安装:"
    echo "  AGENT_INSTALL_YES=1 bash install-codex.sh --china"
    echo ""
    echo "安装后启动:"
    echo "  终端输入: codex"
    echo ""
    echo "安装失败？"
    echo "  打开故障排查页面:"
    echo "  https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
    echo ""
    exit 0
}

# ---------- 端点连通性检测 ----------
check_endpoint() {
    local url="$1"
    curl -fsSL --connect-timeout 5 "$url" >/dev/null 2>&1
}

# ============ 安装前自动检查 ============
run_precheck() {
    echo ""
    echo -e "${CYAN}  正在检查你的电脑环境...${NC}" | tee -a "$LOGFILE"
    echo ""

    # 初始化日志
    {
        echo "===== $(date) ====="
        echo "Agent: $AGENT_NAME"
        echo "Mode: $([ "$CHINA_MODE" = true ] && echo 'China (force npmmirror)' || echo 'Normal (auto-fallback)')"
        echo "System: $(uname -s) · $(uname -m)"
        echo "Shell: ${SHELL:-unknown}"
    } >> "$LOGFILE"

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

    # 2. Git（仅警告）
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Git 是否安装"
    elif command_exists git; then
        print_success "Git 已安装"
        echo "Git: $(git --version 2>/dev/null)" >> "$LOGFILE"
    else
        print_warning "Git 未安装（不影响安装，但后续可能需要）"
        print_tip "如需安装: macOS 运行 xcode-select --install，Ubuntu 运行 sudo apt install git"
    fi

    # 3. Node.js 版本
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Node.js 版本 (需要 >= 22)"
    elif command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        echo "Node.js: v${node_ver}" >> "$LOGFILE"
        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js v${node_ver} (满足要求，将跳过安装)"
        else
            print_warning "Node.js v${node_ver} 版本较低，需要 >= 22"
        fi
    else
        print_warning "Node.js 未安装，将提示安装 v22+"
        echo "Node.js: NOT FOUND" >> "$LOGFILE"
    fi
    if command_exists npm; then
        echo "npm: $(npm -v 2>/dev/null)" >> "$LOGFILE"
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

    # 5. 安装路径说明
    if [ "$CHINA_MODE" = true ]; then
        print_tip "国内镜像模式：跳过官方安装器，直接使用 npmmirror"
    else
        print_tip "普通模式：官方安装器 → npm 官方源 → npmmirror（自动 fallback）"
    fi

    echo ""
    echo -e "${GREEN}  ✅ 系统检查完成${NC}" | tee -a "$LOGFILE"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_tip "以上为环境检查结果（dry-run 模式，未执行实际安装）"
        exit 0
    fi

    if ! confirm "是否继续安装 ${AGENT_NAME}？"; then
        print_tip "已取消安装。有问题请看故障排查:"
        echo "  https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
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
    if ! grep -q "$dir" "$rc_file" 2>/dev/null; then
        echo "export PATH=\"$dir:\$PATH\"" >> "$rc_file"
    fi
    export PATH="$dir:$PATH"
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

# ---------- Node.js ----------
ensure_nodejs() {
    if [ "$DRY_RUN" = true ]; then
        if command_exists node; then
            local nv
            nv=$(node -v | sed 's/v//')
            if version_gte "$nv" "22.0.0"; then
                print_dryrun "Node.js v${nv} 已满足，跳过"
            else
                print_dryrun "提示安装 Node.js >= 22"
            fi
        else
            print_dryrun "提示安装 Node.js >= 22"
        fi
        return 0
    fi

    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js v${node_ver} 已满足要求，跳过安装"
            return 0
        fi
    fi

    echo ""
    echo -e "${CYAN}  Node.js 版本不满足要求（需要 >= 22）${NC}"
    echo ""

    # 优先引导手动下载安装包
    echo "  推荐方式: 手动下载 Node.js 安装包"
    echo "    macOS:  https://nodejs.org (下载 macOS Installer .pkg)"
    echo "    Linux:  https://nodejs.org (下载 Linux Binaries .tar.xz)"
    echo ""
    echo "    SHA256 校验信息可在 https://nodejs.org 查看对应版本的 SHASUMS256.txt"
    echo ""

    if confirm "是否尝试自动安装 Node.js？(推荐选 N，手动下载更可靠)"; then
        case "$OS_TYPE" in
            macOS)
                if ! command_exists brew; then
                    print_step "安装 Homebrew..."
                    run_cmd "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" || true"
                    if [ -f /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"; fi
                    if [ -f /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
                fi
                if command_exists brew; then
                    print_step "通过 Homebrew 安装 Node.js..."
                    run_cmd "brew install node@22 && brew link --overwrite --force node@22 || true"
                fi
                ;;
            linux)
                if command_exists apt-get; then
                    run_cmd "curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -"
                    run_cmd "sudo apt-get install -y -qq nodejs || true"
                elif command_exists dnf; then
                    run_cmd "curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -"
                    run_cmd "sudo dnf install -y nodejs || true"
                elif command_exists pacman; then
                    run_cmd "sudo pacman -S --noconfirm nodejs npm || true"
                fi
                ;;
        esac

        if ! command_exists node; then
            print_warning "自动安装未成功，请手动安装 Node.js"
            echo "  下载地址: https://nodejs.org"
            exit 1
        fi
        print_success "Node.js $(node -v) 自动安装成功"
    else
        print_tip "请手动安装 Node.js 后重新运行本脚本"
        echo "  下载地址: https://nodejs.org"
        exit 1
    fi
}

# ---------- 网络探测 + 安装路径决策 ----------
probe_and_install() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  开始安装 ${AGENT_NAME}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        if [ "$CHINA_MODE" = true ]; then
            print_dryrun "China 模式: npm install -g @openai/codex --registry=https://registry.npmmirror.com"
        else
            print_dryrun "普通模式: 官方 installer → npm 官方源 → npmmirror (auto-fallback)"
        fi
        return 0
    fi

    # --- 确保 Node.js ---
    ensure_nodejs
    fix_npm_permissions

    # --- 网络探测 ---
    echo "=== Network Probe ===" >> "$LOGFILE"
    local OFFICIAL_OK=false NPMJS_OK=false NPMIRROR_OK=false

    print_step "检测网络端点..."
    if check_endpoint "https://chatgpt.com"; then
        OFFICIAL_OK=true
        print_success "官方安装器可达"
        echo "  official installer: REACHABLE" >> "$LOGFILE"
    else
        print_warning "官方安装器不可达"
        echo "  official installer: UNREACHABLE" >> "$LOGFILE"
    fi

    if check_endpoint "https://registry.npmjs.org"; then
        NPMJS_OK=true
        print_success "npm 官方源可达"
        echo "  registry.npmjs.org: REACHABLE" >> "$LOGFILE"
    else
        print_warning "npm 官方源不可达"
        echo "  registry.npmjs.org: UNREACHABLE" >> "$LOGFILE"
    fi

    if check_endpoint "https://registry.npmmirror.com"; then
        NPMIRROR_OK=true
        print_success "npmmirror 国内镜像可达"
        echo "  registry.npmmirror.com: REACHABLE" >> "$LOGFILE"
    else
        print_warning "npmmirror 国内镜像不可达"
        echo "  registry.npmmirror.com: UNREACHABLE" >> "$LOGFILE"
    fi

    check_endpoint "https://api.deepseek.com" && echo "  api.deepseek.com: REACHABLE" >> "$LOGFILE" || echo "  api.deepseek.com: UNREACHABLE" >> "$LOGFILE"
    check_endpoint "https://github.com" && echo "  github.com: REACHABLE" >> "$LOGFILE" || echo "  github.com: UNREACHABLE" >> "$LOGFILE"

    echo "=========================" >> "$LOGFILE"
    echo ""

    # --- China 模式：强制 npmmirror ---
    if [ "$CHINA_MODE" = true ]; then
        print_step "国内镜像模式：使用 npmmirror 安装..."
        echo "Install path: npm-mirror (China mode)" >> "$LOGFILE"

        if ! command_exists npm; then
            print_error "未找到 npm。国内镜像模式需要 Node.js/npm"
            echo "ERROR: npm not found, China mode cannot proceed" >> "$LOGFILE"
            echo ""
            echo "  请先安装 Node.js: https://nodejs.org"
            echo "  下载 macOS .pkg 或 Linux 二进制包安装后，重新运行本脚本。"
            echo "  SHA256 校验码可在 https://nodejs.org 查看 SHASUMS256.txt"
            exit 1
        fi

        if ! $NPMIRROR_OK; then
            print_error "npmmirror 国内镜像不可达"
            echo "ERROR: npmmirror unreachable in China mode" >> "$LOGFILE"
            echo ""
            echo "  国内网络排查建议:"
            echo "  1. 切换手机热点 → 重试"
            echo "  2. 关闭/开启代理 → 重试"
            echo "  3. 重启路由器 → 重试"
            echo "  4. 稍后重试（镜像可能临时故障）"
            echo ""
            echo "  日志: $LOGFILE"
            exit 1
        fi

        echo "  Install command: npm install -g @openai/codex --registry=https://registry.npmmirror.com" >> "$LOGFILE"
        if run_cmd "npm install -g @openai/codex --registry=https://registry.npmmirror.com"; then
            print_success "npm 镜像安装成功"
            INSTALL_PATH="npm-mirror"
        else
            print_error "npm 镜像安装失败"
            echo "ERROR: npm mirror install failed" >> "$LOGFILE"
            echo ""
            echo "  排查: 查看日志 $LOGFILE"
            echo "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
            exit 1
        fi
        return 0
    fi

    # --- 普通模式：3 层自动 fallback ---
    # Tier 1: 官方安装器
    if $OFFICIAL_OK; then
        print_step "路径 1/3：使用官方安装器..."
        echo "Install path: official installer" >> "$LOGFILE"
        INSTALL_PATH="official"

        echo "  Install command: curl -fsSL ${OFFICIAL_URL} | bash" >> "$LOGFILE"
        if run_cmd "curl -fsSL ${OFFICIAL_URL} | bash"; then
            print_success "官方安装器安装成功"
            return 0
        fi
        print_warning "官方安装器失败，自动尝试下一路径..."
        echo "  official installer FAILED, falling back" >> "$LOGFILE"
    fi

    # Tier 2: npm 官方源
    if $NPMJS_OK; then
        if command_exists npm; then
            print_step "路径 2/3：使用 npm 官方源安装..."
            echo "Install path: npm-official" >> "$LOGFILE"
            INSTALL_PATH="npm-official"

            echo "  Install command: npm install -g @openai/codex --registry=https://registry.npmjs.org" >> "$LOGFILE"
            if run_cmd "npm install -g @openai/codex --registry=https://registry.npmjs.org"; then
                print_success "npm 官方源安装成功"
                return 0
            fi
            print_warning "npm 官方源安装失败，自动尝试下一路径..."
            echo "  npm-official FAILED, falling back" >> "$LOGFILE"
        else
            print_warning "npm 官方源可达，但未找到 npm，跳过此路径"
            echo "  npm-official SKIPPED (npm not found)" >> "$LOGFILE"
        fi
    fi

    # Tier 3: npmmirror 国内镜像
    if $NPMIRROR_OK; then
        if command_exists npm; then
            print_step "路径 3/3：使用 npmmirror 国内镜像安装..."
            echo "Install path: npm-mirror (auto-fallback)" >> "$LOGFILE"
            INSTALL_PATH="npm-mirror"

            echo "  Install command: npm install -g @openai/codex --registry=https://registry.npmmirror.com" >> "$LOGFILE"
            if run_cmd "npm install -g @openai/codex --registry=https://registry.npmmirror.com"; then
                print_success "npmmirror 镜像安装成功"
                return 0
            fi
            print_error "npmmirror 安装也失败了"
            echo "  npm-mirror FAILED" >> "$LOGFILE"
        else
            print_warning "npmmirror 可达，但未找到 npm，跳过此路径"
            echo "  npm-mirror SKIPPED (npm not found)" >> "$LOGFILE"
        fi
    fi

    # 全都失败
    print_error "所有安装路径均不可用"
    echo "FATAL: All install paths exhausted" >> "$LOGFILE"
    echo ""
    echo "  网络排查建议:"
    echo "  1. 切换手机热点 → 重试"
    echo "  2. 关闭/开启代理 → 重试"
    echo "  3. 确认已安装 Node.js >= 22: https://nodejs.org"
    echo "  4. 使用国内镜像模式: bash install-codex.sh --china"
    echo ""
    echo "  日志文件: $LOGFILE"
    echo "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
    exit 1
}

# ---------- 验证 ----------
verify_install() {
    if [ "$DRY_RUN" = true ]; then return 0; fi

    ensure_npm_path
    ensure_path "$HOME/.local/bin"
    hash -r 2>/dev/null || true

    if command_exists "$AGENT_BIN"; then
        local ver
        ver=$($AGENT_BIN --version 2>/dev/null | head -1 || echo 'ok')
        print_success "${AGENT_NAME} 安装完成！${ver}"
        echo "Result: SUCCESS | Version: ${ver} | Install path: ${INSTALL_PATH}" >> "$LOGFILE"
    else
        print_error "找不到 ${AGENT_BIN} 命令"
        echo "Result: FAILED (binary not found after install)" >> "$LOGFILE"
        echo ""
        echo "  1. 关掉终端窗口，重新打开后再试"
        echo "  2. 日志: $LOGFILE"
        echo "  3. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
        exit 1
    fi
}

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

# ==================== 主流程 ====================

for arg in "$@"; do
    case "$arg" in
        --help|-h) show_help ;;
        --dry-run) DRY_RUN=true ;;
        --china) CHINA_MODE=true ;;
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

if [ "$CHINA_MODE" = true ]; then
    echo -e "  ${YELLOW}🌏 国内镜像模式 — 强制 npmmirror${NC}"
else
    echo -e "  ${GREEN}📡 普通模式 — 官方 → npm → 镜像 自动 fallback${NC}"
fi
if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 dry-run 模式 — 只看不装${NC}"
fi

run_precheck
probe_and_install
verify_install

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
echo -e "  安装日志: ${LOGFILE}"
echo ""
