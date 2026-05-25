#!/usr/bin/env bash
# ============================================================
# Agent 安装指南 · 一键安装器
# 支持: Claude Code / Codex / OpenClaw
# 平台: macOS / Linux（含 WSL）
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.sh | bash
#   或本地: bash install.sh
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

# 加载公共库
source "$LIB_DIR/utils.sh"
source "$LIB_DIR/check-prereqs.sh"
source "$LIB_DIR/install-claude-code.sh"
source "$LIB_DIR/install-codex.sh"
source "$LIB_DIR/install-openclaw.sh"

# ---------- 互动菜单 ----------
show_menu() {
    echo ""
    echo -e "${BOLD}请选择要安装的 AI Coding Agent:${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) ${BOLD}Claude Code${NC}    — Anthropic 出品，自带运行时，最省心"
    echo -e "  ${GREEN}2${NC}) ${BOLD}Codex CLI${NC}      — OpenAI 出品，需 Node.js 22+，ChatGPT 账号"
    echo -e "  ${GREEN}3${NC}) ${BOLD}OpenClaw${NC}       — 微软开源🦞，支持 75+ 模型，有免费模型"
    echo -e "  ${GREEN}4${NC}) ${BOLD}全部安装${NC}      — 一键装齐三款"
    echo -e "  ${GREEN}5${NC}) ${BOLD}查看对比${NC}      — 三款功能对比"
    echo -e "  ${GREEN}0${NC}) 退出"
    echo ""
}

# ---------- 功能对比 ----------
show_comparison() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  三款 Agent 功能对比${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${BOLD}功能${NC}          ${BOLD}Claude Code${NC}    ${BOLD}Codex${NC}          ${BOLD}OpenClaw${NC}"
    echo "  ──────────  ───────────  ────────────  ────────────"
    echo "  开发商       Anthropic     OpenAI        微软(开源)"
    echo "  免费可用     ✗ (需付费)   ✗ (Plus起步)  ✓ (免费模型)"
    echo "  运行环境     自带运行时    Node.js 22+   Node.js 22+"
    echo "  代码编辑     ✓            ✓             ✓"
    echo "  终端操作     ✓            ✓             ✓"
    echo "  Git 操作     ✓            ✓             ✓"
    echo "  CI/CD 集成   ✓            ✓             ✓"
    echo "  VS Code 插件 ✓            ✗             ✗"
    echo "  桌面应用     ✓            ✗             ✓ (Beta)"
    echo "  多模型支持   仅 Claude     仅 OpenAI      75+ 提供商"
    echo "  中文支持     ✓            ✓             ✓"
    echo "  渠道集成     ✗            ✗             微信/飞书/QQ等"
    echo ""
    echo -e "  ${BOLD}推荐选择:${NC}"
    echo "    追求体验  → Claude Code（最省心）"
    echo "    预算有限  → OpenClaw（有免费模型）"
    echo "    OpenAI 用户 → Codex（ChatGPT 生态）"
    echo ""
    read -r -p "  按回车返回菜单..."
}

# ---------- 安装单个 Agent ----------
install_single() {
    local choice="$1"
    case "$choice" in
        1) check_prereqs claude-code && install_claude_code ;;
        2) check_prereqs codex      && install_codex ;;
        3) check_prereqs openclaw   && install_openclaw ;;
    esac
}

# ---------- 全部安装 ----------
install_all() {
    echo ""
    echo -e "${YELLOW}将依次安装三款 Agent，过程中可随时 Ctrl+C 终止${NC}"
    echo ""

    # Claude Code（依赖最少，先装）
    echo -e "${BOLD}[1/3] Claude Code${NC}"
    check_prereqs claude-code && install_claude_code || {
        print_warning "Claude Code 安装失败，继续安装 Codex..."
    }
    echo ""

    # Codex
    echo -e "${BOLD}[2/3] Codex CLI${NC}"
    check_prereqs codex && install_codex || {
        print_warning "Codex 安装失败，继续安装 OpenClaw..."
    }
    echo ""

    # OpenClaw
    echo -e "${BOLD}[3/3] OpenClaw${NC}"
    check_prereqs openclaw && install_openclaw || {
        print_warning "OpenClaw 安装失败"
    }

    echo ""
    print_success "全部安装流程完成！"
}

# ---------- 主流程 ----------
main() {
    detect_os
    print_header
    check_network

    # 处理命令行参数
    case "${1:-}" in
        --update)
            print_step "更新脚本本身..."
            local tmp_install="/tmp/agent-install-update.sh"
            safe_download "${RAW_BASE}/scripts/install.sh" "$tmp_install"
            if [ -f "$tmp_install" ]; then
                cp "$tmp_install" "$SCRIPT_DIR/install.sh"
                chmod +x "$SCRIPT_DIR/install.sh"
                print_success "脚本已更新到最新版本"
            fi
            exit 0
            ;;
        claude|claude-code)
            check_prereqs claude-code && install_claude_code
            exit $?
            ;;
        codex)
            check_prereqs codex && install_codex
            exit $?
            ;;
        openclaw|opencode)
            check_prereqs openclaw && install_openclaw
            exit $?
            ;;
        --version|-v)
            echo "Agent Install Guide $CURRENT_VERSION"
            exit 0
            ;;
        --help|-h)
            echo "用法: bash install.sh [选项]"
            echo ""
            echo "选项:"
            echo "  无参数      互动菜单"
            echo "  claude      直接安装 Claude Code"
            echo "  codex       直接安装 Codex CLI"
            echo "  openclaw    直接安装 OpenClaw"
            echo "  --update    更新脚本本身"
            echo "  --version   查看版本"
            exit 0
            ;;
    esac

    check_self_update

    # 互动菜单循环
    while true; do
        show_menu
        read -r -p "$(echo -e "${BLUE}[?]${NC} 请输入选项 [0-5]: ")" choice

        case "$choice" in
            1|2|3) install_single "$choice" ;;
            4)     install_all ;;
            5)     show_comparison ;;
            0)     echo ""; echo -e "${GREEN}再见！如有问题请访问 ${REPO_URL}/issues${NC}"; exit 0 ;;
            *)     print_warning "无效选项，请输入 0-5" ;;
        esac

        echo ""
        read -r -p "  按回车返回菜单..."
    done
}

main "$@"
