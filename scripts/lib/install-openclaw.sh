#!/usr/bin/env bash
# ============================================================
# OpenClaw 安装模块
# 要求: Node.js >= 22
# 支持: macOS / Linux（含 WSL）
# 官方: https://github.com/microsoft/openclaw
# ============================================================

install_openclaw() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  安装 OpenClaw 🦞${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$OS_TYPE" = "windows-gitbash" ]; then
        print_warning "OpenClaw 在 Windows 原生下推荐用 PowerShell 脚本安装"
        print_tip "或使用 WSL2: wsl --install"
        if ! confirm "是否继续在当前环境安装？" "n"; then
            return 1
        fi
    fi

    # 前置检查
    if ! check_prereqs openclaw; then
        return 1
    fi

    # 检查是否已安装
    if command_exists openclaw; then
        local existing_ver
        existing_ver=$(openclaw --version 2>/dev/null | head -1 || echo "未知")
        print_success "OpenClaw 已安装"
        echo -e "  当前版本: ${existing_ver}"
        if ! confirm "是否重新安装/升级到最新版？" "n"; then
            return 0
        fi
    fi

    print_step "安装 OpenClaw..."

    case "$OS_TYPE" in
        macOS)
            install_openclaw_macos
            ;;
        linux)
            install_openclaw_linux
            ;;
        windows-gitbash)
            install_openclaw_npm
            ;;
    esac

    verify_openclaw
}

install_openclaw_macos() {
    # 优先 Homebrew
    if command_exists brew; then
        print_step "通过 Homebrew 安装..."
        if brew install openclaw 2>/dev/null; then
            print_success "Homebrew 安装成功"
            return 0
        fi
        print_warning "Homebrew 安装失败，改用 npm..."
    fi

    install_openclaw_npm
}

install_openclaw_linux() {
    # 尝试官方 npm 包（openclaw 目前主要通过 npm 发布）
    install_openclaw_npm
}

install_openclaw_npm() {
    print_step "通过 npm 全局安装..."

    # 国内镜像
    if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
        npm config set registry https://registry.npmmirror.com 2>/dev/null || true
    fi

    if npm install -g openclaw@latest 2>/dev/null; then
        print_success "npm 安装成功"
    else
        print_error "npm 安装失败"
        echo ""
        echo "  手动安装:"
        echo "    macOS: brew install openclaw"
        echo "    通用:  npm install -g openclaw@latest"
        echo ""
        echo "  查看官方文档: https://github.com/microsoft/openclaw"
        return 1
    fi
}

verify_openclaw() {
    print_step "验证安装..."

    if command_exists openclaw 2>/dev/null; then
        local ver
        ver=$(openclaw --version 2>/dev/null | head -1 || echo "安装成功")
        print_success "OpenClaw 安装完成！"
        echo -e "  ${ver}"
        echo ""
        echo -e "${GREEN}下一步:${NC}"
        echo "  1. 初始化为本地模式:"
        echo "     openclaw config set gateway.mode local"
        echo "  2. 安装守护进程（开机自启）:"
        echo "     openclaw gateway install"
        echo "     openclaw gateway start"
        echo "  3. 访问 Web 控制台: http://localhost:18789"
        echo "  4. 或交互式向导: openclaw onboard --install-daemon"
        echo ""
        echo -e "  不配置 API Key 也能用——OpenClaw 内置免费模型"
    else
        print_error "找不到 openclaw 命令"
        print_tip "请重新打开终端后重试"
        echo "  export PATH=\"\$(npm prefix -g)/bin:\$PATH\""
        return 1
    fi
}
