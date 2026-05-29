#!/usr/bin/env bash
# ============================================================
# OpenClaw 🦞 · Mac/Linux 一键安装器
#
# 用法（复制下面这行到终端回车）:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/mac-linux/install-openclaw.sh | bash
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
echo -e "${CYAN}║  开源 AI 编程助手，自带免费模型，开箱即用                 ║${NC}"
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

# ==================== 检查是否已安装 ====================
if command -v openclaw &>/dev/null; then
    echo -e "  ✅ OpenClaw 已安装（$(openclaw --version 2>/dev/null | head -1 || echo '检测到')）"
    echo ""
    echo -e "  启动方法: 终端输入 ${GREEN}openclaw${NC}"
    echo -e "  更新方法: 重新运行此脚本"
    echo ""
    exit 0
fi

# ==================== 安装 Node.js（如果需要）====================
echo -e "${BLUE}━━━ 第二步：检查 Node.js 运行环境 ━━━${NC}"
echo ""

NODE_OK=false
NODE_MIN_VER=22

if command -v node &>/dev/null; then
    NODE_VER=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -ge "$NODE_MIN_VER" ] 2>/dev/null; then
        echo -e "  ✅ Node.js 已就绪（版本 $(node -v)）"
        NODE_OK=true
    else
        echo -e "  ⚠️  Node.js 版本较旧（$(node -v)），OpenClaw 需要 v${NODE_MIN_VER}+"
    fi
else
    echo -e "  📦 Node.js 未安装"
fi

if [ "$NODE_OK" = false ]; then
    echo -e "  📦 正在自动安装 Node.js v${NODE_MIN_VER}..."
    case "$OS_TYPE" in
        mac)
            if ! command -v brew &>/dev/null; then
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
                [ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
                [ -f /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
            fi
            if command -v brew &>/dev/null; then
                brew install node@22 2>/dev/null || true
                brew link --overwrite --force node@22 2>/dev/null || true
                command -v node &>/dev/null && NODE_OK=true
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - 2>/dev/null
                sudo apt-get install -y -qq nodejs 2>/dev/null && NODE_OK=true
            elif command -v dnf &>/dev/null; then
                curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash - 2>/dev/null
                sudo dnf install -y nodejs 2>/dev/null && NODE_OK=true
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm nodejs npm 2>/dev/null && NODE_OK=true
            fi
            ;;
    esac

    if [ "$NODE_OK" = true ] && command -v node &>/dev/null; then
        echo -e "  ✅ Node.js 安装成功！版本：$(node -v)"
    else
        echo -e "  ${RED}❌ Node.js 安装失败${NC}"
        echo -e "  请手动安装：访问 https://nodejs.org 下载安装包"
        exit 1
    fi
fi

echo ""

# ==================== 安装 OpenClaw ====================
echo -e "${BLUE}━━━ 第三步：安装 OpenClaw 🦞 ━━━${NC}"
echo ""

# 修复 npm 权限
if command -v npm &>/dev/null; then
    NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
    if [ -n "$NPM_PREFIX" ] && [ ! -w "$NPM_PREFIX" ]; then
        NPM_GLOBAL_DIR="$HOME/.npm-global"
        mkdir -p "$NPM_GLOBAL_DIR" 2>/dev/null || true
        npm config set prefix "$NPM_GLOBAL_DIR" 2>/dev/null || true
        export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
        echo -e "  💡 已调整 npm 安装位置（避免权限问题）"
    fi
fi

# 国内网络优化
if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
    npm config set registry https://registry.npmmirror.com 2>/dev/null || true
    echo -e "  💡 检测到国内网络，已切换淘宝镜像加速"
fi

echo -e "  📦 正在安装 openclaw（最新版）..."
echo -e "  （如果卡住不动，说明网络较慢，耐心等待）"

INSTALLED=false

if npm install -g openclaw@latest 2>/dev/null; then
    INSTALLED=true
    echo -e "  ${GREEN}✅ npm 安装成功！${NC}"
else
    echo -e "  ${YELLOW}npm 安装失败，尝试备用方式...${NC}"
    # 备用: 官方脚本
    if curl -fsSL --connect-timeout 30 https://openclaw.ai/install.sh 2>/dev/null | bash 2>/dev/null; then
        INSTALLED=true
        echo -e "  ${GREEN}✅ 官方脚本安装成功！${NC}"
    fi
fi

if [ "$INSTALLED" = true ]; then
    # 确保 PATH 包含 npm 全局 bin
    NPM_BIN=$(npm bin -g 2>/dev/null || echo "$HOME/.npm-global/bin")
    SHELL_RC=""
    case "$SHELL" in
        */zsh)  SHELL_RC="$HOME/.zshrc" ;;
        */bash) SHELL_RC="$HOME/.bashrc" ;;
        *)      SHELL_RC="$HOME/.profile" ;;
    esac
    if [ -d "$NPM_BIN" ] && ! echo "$PATH" | grep -q "$NPM_BIN"; then
        export PATH="$NPM_BIN:$PATH"
        if ! grep -q "$NPM_BIN" "$SHELL_RC" 2>/dev/null; then
            echo "export PATH=\"$NPM_BIN:\$PATH\"" >> "$SHELL_RC"
        fi
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║              🎉  OpenClaw 安装完成！                    ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  启动方法：                                              ║${NC}"
    echo -e "${CYAN}║  1. 关掉此窗口，重新打开终端                            ║${NC}"
    echo -e "${CYAN}║  2. 输入 ${GREEN}openclaw${CYAN} 回车                                ║${NC}"
    echo -e "${CYAN}║  3. 首次使用按照提示完成初始化设置                      ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  更新方法：重新运行此安装脚本                            ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
else
    echo ""
    echo -e "  ${RED}❌ 安装失败（可能是网络问题）${NC}"
    echo -e "  ${YELLOW}手动安装步骤：${NC}"
    echo -e "  ${YELLOW}1. 断开 WiFi，换手机热点${NC}"
    echo -e "  ${YELLOW}2. 终端输入: npm install -g openclaw@latest${NC}"
    echo -e "  ${YELLOW}3. 如果还不行，截图联系卖家${NC}"
    echo ""
    exit 1
fi
