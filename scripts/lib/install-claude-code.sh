#!/usr/bin/env bash
# ============================================================
# Claude Code 安装模块
# 支持: macOS / Linux（含 WSL）/ Windows Git Bash
# ============================================================

install_claude_code() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  安装 Claude Code${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # 检查是否已安装
    if command_exists claude; then
        local existing_ver
        existing_ver=$(claude --version 2>/dev/null | head -1 || echo "未知")
        print_success "Claude Code 已安装"
        echo -e "  当前版本: ${existing_ver}"
        echo ""
        if confirm "是否重新安装/覆盖？" "n"; then
            print_step "继续覆盖安装..."
        else
            return 0
        fi
    fi

    print_step "安装 Claude Code..."

    case "$OS_TYPE" in
        macOS)
            install_claude_code_macos
            ;;
        linux|windows-gitbash)
            install_claude_code_linux
            ;;
    esac

    # 验证安装
    verify_claude_code
}

install_claude_code_macos() {
    # 优先尝试 Homebrew Cask
    if command_exists brew; then
        print_step "通过 Homebrew 安装（支持自动更新）..."
        if brew install --cask claude-code 2>/dev/null; then
            print_success "Homebrew 安装成功"
            return 0
        else
            print_warning "Homebrew 安装失败，改用官方脚本..."
        fi
    fi

    # 官方脚本
    print_step "使用官方安装脚本..."
    if curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null; then
        print_success "官方脚本安装成功"
    else
        print_error "安装失败"
        echo ""
        print_tip "手动安装: 访问 https://claude.ai/download 下载安装包"
        return 1
    fi
}

install_claude_code_linux() {
    # 官方脚本（Linux / WSL 通用）
    print_step "使用官方安装脚本..."
    if curl -fsSL https://claude.ai/install.sh | bash 2>/dev/null; then
        print_success "官方脚本安装成功"
    else
        print_error "安装失败"
        echo ""
        echo "  请尝试手动安装:"
        echo "    1. 确保已安装 Git"
        if [ "$OS_TYPE" = "linux" ]; then
            echo "    2. Alpine: apk add libgcc libstdc++ ripgrep"
        fi
        echo "    3. 重试: curl -fsSL https://claude.ai/install.sh | bash"
        return 1
    fi
}

verify_claude_code() {
    print_step "验证安装..."

    # Claude Code 安装在 ~/.local/bin
    ensure_path "$HOME/.local/bin"

    # 等待 PATH 生效
    hash -r 2>/dev/null || true

    if command_exists claude; then
        local ver
        ver=$(claude --version 2>/dev/null | head -1 || echo "安装成功")
        print_success "Claude Code 安装完成！"
        echo -e "  ${ver}"
        echo ""
        echo -e "${GREEN}下一步:${NC}"
        echo "  1. 在终端输入 claude 启动"
        echo "  2. 浏览器会弹出，登录你的 Claude 账号"
        echo "  3. 开始使用: claude"
        echo ""
        echo -e "  常用命令:"
        echo "    claude --version    查看版本"
        echo "    claude doctor       运行诊断"
        echo "    /help               查看帮助"
    else
        print_error "找不到 claude 命令"
        echo ""
        print_tip "请重新打开终端，或手动执行:"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "  source ~/.zshrc (或 ~/.bashrc)"
        return 1
    fi
}
