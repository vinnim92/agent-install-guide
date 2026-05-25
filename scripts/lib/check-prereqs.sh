#!/usr/bin/env bash
# ============================================================
# 前置条件检查模块
# 用法: source check-prereqs.sh && check_prereqs <agent_name>
# agent_name: claude-code | codex | openclaw
# ============================================================

check_prereqs() {
    local agent="$1"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  环境检查 · ${agent}${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # ---- OS 信息 ----
    echo -e "${BOLD}系统信息${NC}"
    echo -e "  操作系统: ${OS_TYPE}"
    echo -e "  架构:     ${OS_ARCH}"
    echo -e "  Shell:    ${SHELL}"
    echo ""

    # ---- Git ----
    print_step "检查 Git..."
    if command_exists git; then
        print_success "Git $(git --version | awk '{print $3}')"
    else
        print_error "Git 未安装"
        echo ""
        echo "  请先安装 Git:"
        echo "    macOS:  brew install git 或 xcode-select --install"
        echo "    Ubuntu: sudo apt install git"
        echo "    CentOS: sudo yum install git"
        return 1
    fi

    # ---- 按 Agent 检查专属依赖 ----
    case "$agent" in
        claude-code)
            check_prereqs_claude_code
            ;;
        codex)
            check_prereqs_codex
            ;;
        openclaw)
            check_prereqs_openclaw
            ;;
    esac

    echo ""
    print_success "环境检查通过"
    return 0
}

check_prereqs_claude_code() {
    # Claude Code 自带运行时，无需 Node.js
    print_step "检查 Claude Code 依赖..."
    print_success "Claude Code 自带完整运行时，无额外依赖"
    print_tip "需要 Claude 账号（Pro/Max/Team/Enterprise）"
    print_tip "或 Anthropic API Key"
}

check_prereqs_codex() {
    # Codex 需要 Node.js >= 22
    print_step "检查 Node.js (Codex 要求 >= 22)..."

    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        echo -e "  当前版本: v${node_ver}"

        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js 版本满足要求"
        else
            print_error "Node.js 版本过低: v${node_ver} (需要 >= 22)"
            echo ""
            echo "  升级方法:"
            echo "    使用 nvm:  nvm install 22 && nvm use 22"
            echo "    使用 fnm:  fnm install 22 && fnm use 22"
            echo "    直接安装: https://nodejs.org"
            return 1
        fi
    else
        print_error "Node.js 未安装 (Codex 要求 >= 22)"
        echo ""
        echo "  安装方法:"
        echo "    macOS:  brew install node@22"
        echo "    Ubuntu: curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs"
        echo "    通用:   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && nvm install 22"
        return 1
    fi

    # 检查 npm
    if command_exists npm; then
        print_success "npm $(npm -v)"
    fi

    print_tip "需要 ChatGPT Plus/Pro/Team 账号，或 OpenAI API Key"
}

check_prereqs_openclaw() {
    # OpenClaw 需要 Node.js >= 22
    print_step "检查 Node.js (OpenClaw 要求 >= 22)..."

    if command_exists node; then
        local node_ver
        node_ver=$(node -v | sed 's/v//')
        echo -e "  当前版本: v${node_ver}"

        if version_gte "$node_ver" "22.0.0"; then
            print_success "Node.js 版本满足要求"
        else
            print_error "Node.js 版本过低: v${node_ver} (需要 >= 22)"
            echo ""
            echo "  升级方法:"
            echo "    使用 nvm:  nvm install 22 && nvm use 22"
            echo "    使用 fnm:  fnm install 22 && fnm use 22"
            return 1
        fi
    else
        print_error "Node.js 未安装 (OpenClaw 要求 >= 22)"
        echo ""
        echo "  安装方法:"
        echo "    macOS:  brew install node@22"
        echo "    Ubuntu: curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && sudo apt install -y nodejs"
        return 1
    fi

    # Linux 额外依赖
    if [ "$OS_TYPE" = "linux" ]; then
        print_step "检查 Linux 编译依赖..."
        local missing=""
        for cmd in gcc g++ make; do
            if ! command_exists "$cmd"; then
                missing="$missing $cmd"
            fi
        done
        if [ -n "$missing" ]; then
            print_warning "缺少编译依赖:${missing}"
            print_tip "Ubuntu: sudo apt install -y gcc g++ make python3-venv libssl-dev"
        else
            print_success "编译依赖已就绪"
        fi
    fi

    print_tip "OpenClaw 支持 75+ 模型提供商，有免费模型可用，无需 API Key 也能用"
}
