#!/usr/bin/env bash
# ============================================================
# OpenClaw 安装脚本
# 支持系统: macOS / Linux
# 需要: Node.js >= 22.19（推荐 24+，脚本会自动安装）
# 安装阶段不需要 API Key；首次配置或正式使用时需要模型服务的 API Key
#
# 用法:
#   bash install-openclaw.sh --china   国内网络模式
#   bash install-openclaw.sh --help
#   bash install-openclaw.sh --dry-run
#   AGENT_INSTALL_YES=1 bash install-openclaw.sh
# ============================================================

set -euo pipefail

# ---------- 颜色 ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

DRY_RUN=false
SKIP_CONFIRM=false
CHINA_MODE=false
OS_TYPE=""
AGENT_NAME="OpenClaw"
AGENT_BIN="openclaw"
OFFICIAL_URL="https://openclaw.ai/install.sh"
NODE_MIN="22.19.0"
LOGFILE="$HOME/agent-install-openclaw.log"
NPM_REGISTRY="https://registry.npmjs.org"

# ---------- 输出函数 ----------
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
        print_tip "如果你确认继续，请使用：AGENT_INSTALL_YES=1 bash install-openclaw.sh --china"
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
    echo "  OpenClaw 安装脚本"
    echo "========================================"
    echo ""
    echo "安装: OpenClaw（微软开源）"
    echo "系统: macOS / Linux"
    echo "需要: Node.js >= 22.19（推荐 24+，脚本会自动安装）"
    echo "      安装阶段不需要 API Key；首次配置时需要模型服务的 API Key"
    echo ""
    echo "用法:"
    echo "  bash install-openclaw.sh           正常安装（自动检查环境）"
    echo "  bash install-openclaw.sh --china   国内网络模式（跳过官方源，使用镜像）"
    echo "  bash install-openclaw.sh --help    显示帮助"
    echo "  bash install-openclaw.sh --dry-run 排查/预览（只看不装）"
    echo ""
    echo "跳过确认:"
    echo "  AGENT_INSTALL_YES=1 bash install-openclaw.sh"
    echo ""
    echo "国内网络一键安装:"
    echo "  AGENT_INSTALL_YES=1 bash install-openclaw.sh --china"
    echo ""
    echo "安装后配置:"
    echo "  openclaw onboard --auth-choice deepseek-api-key"
    echo "  openclaw models list --provider deepseek"
    echo "  openclaw dashboard"
    echo ""
    echo "安装失败？"
    echo "  打开故障排查页面:"
    echo "  https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
    echo ""
    exit 0
}

# ---------- 多端点网络检测 ----------
check_network() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查网络连通性（4 个端点）"
        return 0
    fi

    print_step "检查网络连通性..."
    local ok=0

    for endpoint in "https://registry.npmmirror.com" "https://registry.npmjs.org" "https://api.deepseek.com" "https://github.com"; do
        if curl -fsSL --connect-timeout 5 "$endpoint" >/dev/null 2>&1; then
            print_success "可访问: $endpoint"
            ok=$((ok + 1))
        else
            print_warning "无法访问: $endpoint"
        fi
    done

    if [ "$ok" -eq 0 ]; then
        print_error "所有端点均无法访问，请检查网络连接"
        print_tip "可尝试切换手机热点、关闭/开启代理"
        if [ "$CHINA_MODE" = false ]; then
            print_tip "或使用国内网络模式: bash install-openclaw.sh --china"
        fi
    elif [ "$ok" -le 2 ]; then
        print_warning "部分端点不可达，安装可能受限"
        if [ "$CHINA_MODE" = false ]; then
            print_tip "建议使用国内网络模式: bash install-openclaw.sh --china"
        fi
    else
        print_success "网络连通性良好 ($ok/4)"
    fi
    echo ""
}

# ============ 安装前自动检查 ============
run_precheck() {
    echo ""
    echo -e "${CYAN}  正在检查你的电脑环境...${NC}" | tee -a "$LOGFILE"
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

    # 2. Git（仅警告，不阻断）
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Git 是否安装"
    elif command_exists git; then
        print_success "Git 已安装"
    else
        print_warning "Git 未安装（不影响安装，但后续可能需要）"
        print_tip "如需安装: macOS 运行 xcode-select --install，Ubuntu 运行 sudo apt install git"
    fi

    # 3. 多端点网络检测
    check_network

    # 4. Node.js
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "检查 Node.js 版本 (需要 >= ${NODE_MIN})"
    elif command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        if version_gte "$node_ver" "$NODE_MIN"; then
            print_success "Node.js v${node_ver} (满足要求，将跳过安装)"
        else
            print_warning "Node.js v${node_ver} 版本较低，将提示安装（推荐 v24+）"
        fi
    else
        print_warning "Node.js 未安装，将提示安装（推荐 v24+）"
    fi

    # 5. Linux 编译依赖
    if [ "$OS_TYPE" = "linux" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_dryrun "检查 gcc g++ make"
        else
            local missing=""
            for cmd in gcc g++ make; do
                command_exists "$cmd" || missing="$missing $cmd"
            done
            if [ -n "$missing" ]; then
                print_warning "缺少编译依赖:${missing}"
                print_tip "Ubuntu: sudo apt install -y gcc g++ make python3-venv libssl-dev"
            else
                print_success "编译依赖已就绪"
            fi
        fi
    fi

    # 6. 是否已安装
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

    # 7. 安装方式
    if [ "$CHINA_MODE" = true ]; then
        print_tip "国内网络模式：跳过官方安装器，直接使用 npm 镜像源"
    else
        print_tip "将优先使用官方安装方式（${OFFICIAL_URL}）"
    fi

    echo ""
    echo -e "${GREEN}  ✅ 系统检查完成${NC}" | tee -a "$LOGFILE"
    echo -e "${GREEN}  ✅ 网络检查完成${NC}" | tee -a "$LOGFILE"
    echo -e "${GREEN}  ✅ 安装准备完成${NC}" | tee -a "$LOGFILE"
    echo ""

    # 8. 总结
    echo -e "  ${BOLD}接下来将安装:${NC} ${AGENT_NAME}"
    echo -e "  ${BOLD}可能需要:${NC} 安装 Node.js（如果版本不满足要求）"
    echo -e "  ${BOLD}需要准备:${NC} 安装阶段不需要 API Key；首次配置时可能需要模型服务的 API Key"
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

# ---------- Node.js ----------
ensure_nodejs() {
    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        if version_gte "$node_ver" "$NODE_MIN"; then
            print_success "Node.js v${node_ver} 已满足要求，跳过安装"
            return 0
        fi
    fi

    echo ""
    echo -e "${CYAN}  Node.js 版本不满足要求（需要 >= ${NODE_MIN}）${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        print_dryrun "提示安装 Node.js（推荐手动下载安装包）"
        return 0
    fi

    # 优先引导手动下载安装包（最可靠的方式）
    echo "  推荐方式: 手动下载 Node.js 安装包"
    echo "    macOS:  https://nodejs.org (下载 macOS Installer .pkg)"
    echo "    Linux:  https://nodejs.org (下载 Linux Binaries .tar.xz)"
    echo ""
    echo "    macOS .pkg SHA256 校验:"
    echo "      下载后可在 https://nodejs.org 查看对应版本的 SHASUMS256.txt"
    echo "    Linux .tar.xz 校验:"
    echo "      sha256sum node-v*.tar.xz"
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
                    run_cmd "brew install node@24 && brew link --overwrite --force node@24 || brew install node@22 && brew link --overwrite --force node@22 || true"
                fi
                ;;
            linux)
                if command_exists apt-get; then
                    run_cmd "curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash - || curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -"
                    run_cmd "sudo apt-get install -y -qq nodejs || true"
                elif command_exists dnf; then
                    run_cmd "curl -fsSL https://rpm.nodesource.com/setup_24.x | sudo bash - || curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -"
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

# ---------- npm 缓存权限诊断 ----------
diagnose_npm_cache_perms() {
    local logfile="$1"
    if [ ! -f "$logfile" ]; then return 1; fi

    if grep -qE 'EACCES|permission denied|\.npm/_cacache|errno -13' "$logfile" 2>/dev/null; then
        return 0
    fi
    return 1
}

fix_npm_cache_perms() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  检测到 npm 缓存权限异常${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  这通常是以前使用 sudo npm 或安装器异常"
    echo "  导致 ~/.npm 目录中部分文件不属于当前用户。"
    echo ""

    local auto_fix=false
    if [ "$SKIP_CONFIRM" = true ]; then
        auto_fix=true
        print_tip "AGENT_INSTALL_YES=1 已设置，将自动尝试修复"
    elif [ -r /dev/tty ]; then
        local yn
        read -r -p "$(echo -e "${BLUE}[?]${NC} 是否自动修复 npm 缓存权限？ [Y/n]: ")" yn < /dev/tty
        yn=${yn:-y}
        case "$yn" in
            [Yy]*|[Yy][Ee][Ss]*|是|是的|对|对的) auto_fix=true ;;
            *) print_tip "已跳过自动修复，请手动执行修复命令后重试"; return 1 ;;
        esac
    else
        print_tip "当前环境无法读取键盘输入，请手动执行修复命令后重试"
        print_tip "或使用: AGENT_INSTALL_YES=1 bash install-openclaw.sh --china"
        return 1
    fi

    if [ "$auto_fix" = true ]; then
        echo ""
        print_step "正在修复 npm 缓存权限..."
        echo "  （可能需要输入你的电脑开机密码）"
        echo ""

        if sudo chown -R "$(id -u):$(id -g)" "$HOME/.npm" 2>/dev/null; then
            print_success "已修复 ~/.npm 目录所有权"
        else
            print_warning "sudo chown 执行失败，请手动执行"
            return 1
        fi

        if chmod -R u+rwX "$HOME/.npm" 2>/dev/null; then
            print_success "已修复 ~/.npm 目录权限"
        else
            print_warning "chmod 执行失败"
        fi

        if npm cache verify 2>/dev/null; then
            print_success "npm cache verify 通过"
        else
            print_warning "npm cache verify 失败，继续尝试安装"
        fi
    fi

    return 0
}

# ---------- npm 安装 OpenClaw ----------
npm_install_openclaw() {
    local logfile
    logfile=$(mktemp /tmp/openclaw-npm-install.XXXXXX.log)
    local registry="${1:-$NPM_REGISTRY}"

    # 步骤1: 测试包是否存在
    print_step "测试 openclaw 包是否存在（npm view）..."
    local pkg_ver
    if pkg_ver=$(npm view openclaw version --registry="$registry" 2>>"$LOGFILE"); then
        print_success "openclaw 包存在，最新版本: ${pkg_ver}"
    else
        print_warning "无法查询 openclaw 版本，将继续尝试安装"
    fi

    # 步骤2: npm 安装
    print_step "通过 npm 安装 openclaw (${registry})..."
    if run_cmd "npm install -g openclaw@latest --registry=${registry} --no-audit --no-fund 2>\"${logfile}\""; then
        rm -f "$logfile"
        return 0
    fi

    # 安装失败，检查日志
    print_error "npm 安装失败"

    if [ -f "$logfile" ] && [ -s "$logfile" ]; then
        echo ""
        print_tip "最后 30 行安装日志:"
        echo "  ----------------------------------------"
        tail -30 "$logfile" 2>/dev/null | while IFS= read -r line; do
            echo "  $line"
        done
        echo "  ----------------------------------------"

        # 检查是否是 npm 缓存权限异常
        if diagnose_npm_cache_perms "$logfile"; then
            rm -f "$logfile"
            if fix_npm_cache_perms; then
                echo ""
                print_step "重新尝试安装 OpenClaw..."
                local logfile2
                logfile2=$(mktemp /tmp/openclaw-npm-retry.XXXXXX.log)
                if run_cmd "npm install -g openclaw@latest --registry=${registry} --no-audit --no-fund 2>\"${logfile2}\""; then
                    rm -f "$logfile2"
                    print_success "npm 缓存权限已修复，OpenClaw 安装成功"
                    return 0
                fi
                rm -f "$logfile2"
                print_error "权限修复后安装仍然失败"

                print_tip "权限修复后仍失败，建议重建 npm 缓存目录:"
                echo ""
                echo "  mv \"\$HOME/.npm\" \"\$HOME/.npm.bak.\$(date +%Y%m%d_%H%M%S)\""
                echo "  npm install -g openclaw@latest --registry=${registry} --no-audit --no-fund"
                echo ""
                return 1
            fi
            return 1
        fi

        # 不是权限问题，尝试 clean cache
        print_tip "未检测到权限异常，尝试清理 npm 缓存..."
        rm -f "$logfile"
        npm cache clean --force 2>/dev/null || true
        print_step "重新尝试 npm 安装..."
        if run_cmd "npm install -g openclaw@latest --registry=${registry} --no-audit --no-fund"; then
            print_success "npm 缓存清理后安装成功"
            return 0
        fi
    else
        rm -f "$logfile"
        npm cache clean --force 2>/dev/null || true
        if run_cmd "npm install -g openclaw@latest --registry=${registry} --no-audit --no-fund"; then
            print_success "npm 安装成功"
            return 0
        fi
    fi

    print_error "npm 安装失败"
    return 1
}

# ---------- 安装 ----------
do_install() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  开始安装 ${AGENT_NAME}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$DRY_RUN" = true ]; then
        if [ "$CHINA_MODE" = true ]; then
            print_dryrun "npm 镜像: npm install -g openclaw@latest --registry=https://registry.npmmirror.com"
        else
            print_dryrun "官方脚本: curl -fsSL ${OFFICIAL_URL} | bash"
            print_dryrun "fallback: npm install -g openclaw@latest"
        fi
        print_dryrun "验证: command -v ${AGENT_BIN}"
        return 0
    fi

    # 初始化日志
    echo "===== $(date) =====" > "$LOGFILE"
    echo "Agent: $AGENT_NAME | China Mode: $CHINA_MODE" >> "$LOGFILE"

    ensure_nodejs
    fix_npm_permissions

    # China 模式: 直接使用 npm 镜像
    if [ "$CHINA_MODE" = true ]; then
        print_step "国内网络模式：使用 npm 镜像源安装..."
        if ! command_exists npm; then
            print_error "npm 不可用，无法继续安装"
            echo "  排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
            exit 1
        fi
        if npm_install_openclaw "https://registry.npmmirror.com"; then
            : # success
        else
            print_error "npm 镜像安装失败"
            echo ""
            echo "  排查: 查看日志 $LOGFILE"
            echo "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
            exit 1
        fi
    else
        # 方法1: 官方 installer（优先）
        print_step "使用官方安装脚本..."
        if run_cmd "curl -fsSL ${OFFICIAL_URL} | bash"; then
            print_success "官方脚本安装成功"
        else
            # 方法2: npm fallback with enhanced diagnostics
            print_warning "官方脚本不可用，使用 npm..."
            if ! command_exists npm; then
                print_error "npm 不可用"
                echo "  排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
                exit 1
            fi
            if npm_install_openclaw "https://registry.npmjs.org"; then
                : # success
            else
                # 尝试 npmmirror 兜底
                print_warning "npm 官方源失败，尝试国内镜像..."
                if npm_install_openclaw "https://registry.npmmirror.com"; then
                    : # success
                else
                    print_error "所有安装方式均失败"
                    echo ""
                    echo "  排查: 查看日志 $LOGFILE"
                    echo "  故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
                    exit 1
                fi
            fi
        fi
    fi

    ensure_npm_path
    if command_exists "$AGENT_BIN"; then
        print_success "${AGENT_NAME} 安装完成！"
        $AGENT_BIN --version 2>/dev/null | head -1 | while read -r v; do echo -e "  ${v}" | tee -a "$LOGFILE"; done
    else
        print_error "找不到 ${AGENT_BIN} 命令"
        echo "  1. 关掉终端窗口，重新打开后再试"
        echo "  2. 故障排查: https://vinnim92.github.io/agent-install-guide/troubleshooting.html"
        exit 1
    fi
}

# ---------- OpenClaw DeepSeek API Key onboarding ----------
configure_openclaw() {
    if [ "$DRY_RUN" = true ]; then
        print_dryrun "提示 OpenClaw DeepSeek API Key 配置引导"
        return 0
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  OpenClaw 首次配置（推荐）${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "  OpenClaw 支持 75+ 模型提供商。"
    echo "  安装阶段不需要 API Key；首次配置或正式使用时需要。"
    echo ""
    echo "  对于国内用户，推荐使用 DeepSeek API Key："
    echo "    注册方便、价格便宜"
    echo ""
    echo "  获取方式: 打开浏览器访问 platform.deepseek.com"
    echo "           注册 → API Keys → 创建 Key（以 sk- 开头）"
    echo ""

    if ! confirm "是否现在配置 OpenClaw？"; then
        echo ""
        print_tip "已跳过配置。稍后可以手动运行:"
        echo "  openclaw onboard --auth-choice deepseek-api-key"
        echo ""
        return 0
    fi

    echo ""
    print_step "运行 OpenClaw onboarding（DeepSeek API Key）..."
    echo "  （按终端提示输入你的 DeepSeek API Key）"
    echo ""

    if run_cmd "openclaw onboard --auth-choice deepseek-api-key"; then
        print_success "OpenClaw 配置完成"
        echo ""
        echo "  验证:"
        echo "    openclaw models list --provider deepseek"
        echo ""
        echo "  启动控制面板:"
        echo "    openclaw dashboard"
    else
        print_warning "onboard 未完成，你可以稍后手动运行:"
        echo "  openclaw onboard --auth-choice deepseek-api-key"
    fi

    echo ""
}

# ==================== 主流程 ====================

for arg in "$@"; do
    case "$arg" in
        --help|-h) show_help ;;
        --dry-run) DRY_RUN=true ;;
        --china) CHINA_MODE=true; NPM_REGISTRY="https://registry.npmmirror.com" ;;
        *) ;;
    esac
done

if [ "${AGENT_INSTALL_YES:-0}" = "1" ]; then
    SKIP_CONFIRM=true
fi

echo ""
echo -e "${CYAN}==========================================${NC}"
echo -e "${CYAN}  OpenClaw 安装助手${NC}"
echo -e "${CYAN}==========================================${NC}"

if [ "$CHINA_MODE" = true ]; then
    echo -e "  ${YELLOW}🌏 国内网络模式 — 跳过官方源，使用 npm 镜像${NC}"
fi
if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}🔍 dry-run 模式 — 只看不装${NC}"
fi

run_precheck
do_install
configure_openclaw

echo ""
print_success "${AGENT_NAME} 安装验证通过"
echo ""
echo -e "${GREEN}首次配置（推荐 DeepSeek API Key）:${NC}"
echo "  openclaw onboard --auth-choice deepseek-api-key"
echo ""
echo -e "${GREEN}启动:${NC}"
echo "  openclaw           进入交互式对话"
echo "  openclaw dashboard 打开 Web 控制台"
echo ""
echo -e "  常用命令:"
echo "    openclaw models list --provider deepseek  查看可用模型"
echo "    openclaw dashboard                        打开控制面板"
echo ""
echo -e "  安装日志: ${LOGFILE}"
echo ""
