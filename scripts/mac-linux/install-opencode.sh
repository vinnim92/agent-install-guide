#!/usr/bin/env bash
# ============================================================
# OpenClaw (OpenCode) · Mac/Linux 一键安装器
#
# 用法（复制下面这行到终端回车）:
#   curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/mac-linux/install-openclaw.sh | bash
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
echo -e "${CYAN}║       🦞  OpenClaw · Mac/Linux 一键安装器              ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║  微软开源，自带免费模型，开箱即用                         ║${NC}"
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

# ==================== 安装 OpenClaw ====================
echo -e "${BLUE}━━━ 第二步：安装 OpenClaw (OpenCode) ━━━${NC}"
echo ""

if command -v opencode &>/dev/null; then
    echo -e "  ✅ OpenClaw 已安装（$(opencode --version 2>/dev/null | head -1 || echo '')）"
    echo ""
    echo -e "  启动方法: 终端输入 ${GREEN}opencode${NC}"
    echo -e "  更新方法: 重新运行此脚本"
    echo ""
    exit 0
elif command -v openclaw &>/dev/null; then
    echo -e "  ✅ OpenClaw 已安装（$(openclaw --version 2>/dev/null | head -1 || echo '')）"
    echo ""
    echo -e "  启动方法: 终端输入 ${GREEN}openclaw${NC}"
    echo -e "  更新方法: 重新运行此脚本"
    echo ""
    exit 0
fi

INSTALLED=false

# 方法1: 平台原生安装
case "$OS_TYPE" in
    mac)
        echo -e "  方法1: Homebrew 安装..."
        if command -v brew &>/dev/null; then
            brew install opencode 2>/dev/null && INSTALLED=true
        else
            echo -e "  📦 正在安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
            if [ -f /opt/homebrew/bin/brew ]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -f /usr/local/bin/brew ]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            if command -v brew &>/dev/null; then
                brew install opencode 2>/dev/null && INSTALLED=true
            fi
        fi
        if [ "$INSTALLED" = true ]; then
            echo -e "  ${GREEN}✅ Homebrew 安装成功！${NC}"
        else
            echo -e "  ${YELLOW}⚠️  Homebrew 安装失败，尝试其他方式...${NC}"
        fi
        ;;
    linux)
        echo -e "  方法1: 官方脚本安装..."
        if curl -fsSL --connect-timeout 30 https://opencode.ai/install 2>/dev/null | bash 2>/dev/null; then
            INSTALLED=true
            echo -e "  ${GREEN}✅ 官方脚本安装成功！${NC}"
        else
            echo -e "  ${YELLOW}⚠️  官方脚本不可用，尝试 npm...${NC}"
        fi
        ;;
esac

# 方法2: npm 安装（兜底方案）
if [ "$INSTALLED" = false ]; then
    # 确保 Node.js 可用
    if ! command -v node &>/dev/null; then
        echo -e "  📦 需要先安装 Node.js..."
        case "$OS_TYPE" in
            mac)
                if command -v brew &>/dev/null; then
                    brew install node@22 2>/dev/null || true
                    brew link --overwrite --force node@22 2>/dev/null || true
                fi
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

    if command -v npm &>/dev/null; then
        # 修复 npm 权限
        NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
        if [ -n "$NPM_PREFIX" ] && [ ! -w "$NPM_PREFIX" ]; then
            NPM_GLOBAL_DIR="$HOME/.npm-global"
            mkdir -p "$NPM_GLOBAL_DIR" 2>/dev/null || true
            npm config set prefix "$NPM_GLOBAL_DIR" 2>/dev/null || true
            export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
            echo -e "  💡 已自动调整 npm 安装位置（避免权限问题）"
        fi

        # 国内网络自动切镜像
        if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
            npm config set registry https://registry.npmmirror.com 2>/dev/null || true
            echo -e "  💡 已切换至国内镜像加速"
        fi

        echo -e "  方法2: npm 安装 opencode-ai ..."
        if npm install -g opencode-ai@latest 2>/dev/null; then
            INSTALLED=true
            echo -e "  ${GREEN}✅ npm 安装成功！${NC}"
        fi
    fi
fi

if [ "$INSTALLED" = true ]; then
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║              🎉  OpenClaw 安装完成！                    ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  启动方法：                                              ║${NC}"
    echo -e "${CYAN}║  终端输入 opencode → 回车                               ║${NC}"
    echo -e "${CYAN}║  第一次使用会弹出浏览器登录 GitHub 账号                  ║${NC}"
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
    echo -e "  手动安装: npm install -g opencode-ai@latest"
    echo -e "  如有问题请截图联系卖家。"
    echo ""
    exit 1
fi
