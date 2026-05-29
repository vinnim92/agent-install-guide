#!/usr/bin/env bash
# ============================================================
# Claude Code · Mac/Linux 一键安装器
#
# 用法（复制下面这行到终端回车）:
#   curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/mac-linux/install-claude-code.sh | bash
# ============================================================

set -e

# ==================== 颜色 ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# ==================== 欢迎 ====================
[ -n "$TERM" ] && clear || true
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║       🧠  Claude Code · Mac/Linux 一键安装器            ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║  Anthropic 出品，最聪明的 AI 编程助手                     ║${NC}"
echo -e "${CYAN}║  整个过程大约需要 2-5 分钟                                ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==================== 系统检测 ====================
echo -e "${BLUE}━━━ 第一步：检测你的电脑 ━━━${NC}"
echo ""

OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
    Darwin)
        echo -e "  ✅ 检测到你的电脑是 ${GREEN}Mac（苹果电脑）${NC}"
        OS_TYPE="mac"
        ;;
    Linux)
        echo -e "  ✅ 检测到你的电脑是 ${GREEN}Linux 系统${NC}"
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo -e "     具体版本：${GREEN}${NAME:-Linux}${NC}"
        fi
        ;;
    *)
        echo -e "  ⚠️  抱歉，本脚本暂不支持当前操作系统。"
        echo -e "     如果你是 Windows 用户，请使用 Windows 版安装器。"
        exit 1
        ;;
esac

echo -e "  ✅ 处理器架构：${GREEN}${ARCH}${NC}"
echo ""

# ==================== 安装 Claude Code ====================
echo -e "${BLUE}━━━ 第二步：安装 Claude Code ━━━${NC}"
echo ""

if command -v claude &>/dev/null; then
    echo -e "  ✅ Claude Code 已安装（$(claude --version 2>/dev/null | head -1 || echo '')）"
    echo ""
    echo -e "  启动方法: 终端输入 ${GREEN}claude${NC}"
    echo -e "  更新方法: 重新运行此脚本"
    echo ""
    exit 0
fi

CLAUDE_OK=false

# 方法1: 官方脚本
echo -e "  方法1: 官方脚本安装..."
if curl -fsSL --connect-timeout 30 https://claude.ai/install.sh 2>/dev/null | bash 2>/dev/null; then
    export PATH="$HOME/.local/bin:$PATH"
    if command -v claude &>/dev/null; then
        CLAUDE_OK=true
        echo -e "  ${GREEN}✅ 官方脚本安装成功！${NC}"
    fi
fi

# 方法2: npm 安装（国内可用，无需代理）
if [ "$CLAUDE_OK" = false ]; then
    echo -e "  ${YELLOW}官方脚本不可用（地域限制），改用 npm 安装...${NC}"

    # 检查 npm
    if ! command -v npm &>/dev/null; then
        echo -e "  📦 需要先安装 Node.js..."
        case "$OS_TYPE" in
            mac)
                if ! command -v brew &>/dev/null; then
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
                    if [ -f /opt/homebrew/bin/brew ]; then
                        eval "$(/opt/homebrew/bin/brew shellenv)"
                    elif [ -f /usr/local/bin/brew ]; then
                        eval "$(/usr/local/bin/brew shellenv)"
                    fi
                fi
                brew install node@22 2>/dev/null || true
                brew link --overwrite --force node@22 2>/dev/null || true
                ;;
            linux)
                if command -v apt-get &>/dev/null; then
                    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null
                    sudo apt-get install -y -qq nodejs 2>/dev/null || true
                elif command -v dnf &>/dev/null; then
                    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash - 2>/dev/null
                    sudo dnf install -y nodejs 2>/dev/null || true
                elif command -v pacman &>/dev/null; then
                    sudo pacman -S --noconfirm nodejs npm 2>/dev/null || true
                fi
                ;;
        esac
    fi

    # 修复 npm 权限
    if command -v npm &>/dev/null; then
        NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
        if [ -n "$NPM_PREFIX" ] && [ ! -w "$NPM_PREFIX" ]; then
            NPM_GLOBAL_DIR="$HOME/.npm-global"
            mkdir -p "$NPM_GLOBAL_DIR" 2>/dev/null || true
            npm config set prefix "$NPM_GLOBAL_DIR" 2>/dev/null || true
            export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
            echo -e "  💡 已自动调整 npm 安装位置（避免权限问题）"
        fi
    fi

    if command -v npm &>/dev/null; then
        echo -e "  方法2: npm 安装 @anthropic-ai/claude-code ..."
        if npm install -g @anthropic-ai/claude-code@latest 2>/dev/null; then
            CLAUDE_OK=true
            echo -e "  ${GREEN}✅ npm 安装成功！${NC}"
        fi
    fi
fi

if [ "$CLAUDE_OK" = true ]; then
    # 确保 PATH 包含安装位置
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *)      SHELL_RC="$HOME/.profile" ;;
    esac

    if [ -d "$HOME/.local/bin" ] && ! echo "$PATH" | grep -q ".local/bin"; then
        export PATH="$HOME/.local/bin:$PATH"
        if ! grep -q ".local/bin" "$SHELL_RC" 2>/dev/null; then
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        fi
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║              🎉  Claude Code 安装完成！                 ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  启动方法：                                              ║${NC}"
    echo -e "${CYAN}║  终端输入 claude → 回车                                 ║${NC}"
    echo -e "${CYAN}║  第一次使用会弹出浏览器登录 Claude 账号                  ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  更新方法：重新运行此安装脚本                            ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}感谢购买！如有问题请截图联系卖家。${NC}"
    echo ""
else
    echo ""
    echo -e "  ${RED}❌ 安装失败（可能是网络问题）${NC}"
    echo -e "  手动安装: npm install -g @anthropic-ai/claude-code"
    echo -e "  如有问题请截图联系卖家。"
    echo ""
    exit 1
fi
