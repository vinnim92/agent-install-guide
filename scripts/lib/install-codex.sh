#!/usr/bin/env bash
# ============================================================
# OpenAI Codex CLI 安装模块
# 要求: Node.js >= 22
# 支持: macOS / Linux（含 WSL）
# Windows 原生: 请使用 install.ps1
# ============================================================

install_codex() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  安装 OpenAI Codex CLI${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [ "$OS_TYPE" = "windows-gitbash" ]; then
        print_warning "Codex 在 Windows 原生环境下支持有限"
        print_tip "强烈推荐在 WSL2 中安装"
        if ! confirm "是否继续在当前环境安装？" "n"; then
            print_tip "请先安装 WSL2: wsl --install"
            print_tip "然后在 WSL2 中重新运行本脚本"
            return 1
        fi
    fi

    # 前置检查
    if ! check_prereqs codex; then
        return 1
    fi

    # 检查是否已安装
    if command_exists codex; then
        local existing_ver
        existing_ver=$(codex --version 2>/dev/null | head -1 || echo "未知")
        print_success "Codex 已安装"
        echo -e "  当前版本: ${existing_ver}"
        if ! confirm "是否重新安装/升级到最新版？" "n"; then
            return 0
        fi
    fi

    print_step "安装 Codex CLI..."

    # 检测国内网络，自动切镜像
    if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
        print_warning "npm 官方源访问慢，切换淘宝镜像..."
        npm config set registry https://registry.npmmirror.com 2>/dev/null || true
    fi

    # npm 全局安装
    if npm install -g @openai/codex 2>/dev/null; then
        print_success "Codex 安装成功"
    else
        print_error "npm 安装失败"
        echo ""
        echo "  排查步骤:"
        echo "    1. 检查 Node 版本: node -v (需要 >= 22)"
        echo "    2. 检查 npm 权限"
        echo "    3. 重试: npm install -g @openai/codex"
        echo ""
        echo "  如果 EACCES 权限错误:"
        echo "    mkdir -p ~/.npm-global"
        echo "    npm config set prefix '~/.npm-global'"
        echo "    export PATH=~/.npm-global/bin:\$PATH"
        return 1
    fi

    verify_codex
}

verify_codex() {
    print_step "验证安装..."

    if command_exists codex; then
        local ver
        ver=$(codex --version 2>/dev/null | head -1 || echo "安装成功")
        print_success "Codex CLI 安装完成！"
        echo -e "  ${ver}"
        echo ""
        echo -e "${GREEN}下一步:${NC}"
        echo "  1. 运行 codex 启动，浏览器会弹出 ChatGPT 登录页"
        echo "  2. 或使用 API Key: export OPENAI_API_KEY=sk-..."
        echo "  3. 开始使用: codex"
        echo ""
        echo -e "  常用命令:"
        echo "    codex --version      查看版本"
        echo "    codex login          手动登录"
        echo "    codex \"任务描述\"      带初始提示启动"
        echo "    codex exec \"...\"     非交互执行"
    else
        print_error "找不到 codex 命令"
        print_tip "请重新打开终端，或检查 npm 全局安装路径"
        echo "  npm prefix -g  # 查看 npm 全局路径"
        echo "  export PATH=\"\$(npm prefix -g)/bin:\$PATH\""
        return 1
    fi
}
