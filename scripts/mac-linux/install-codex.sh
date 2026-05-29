#!/usr/bin/env bash
# ============================================================
# OpenAI Codex CLI · Mac/Linux 一键安装器
#
# 用法（复制下面这行到终端回车）:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/mac-linux/install-codex.sh | bash
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
echo -e "${CYAN}║       ⚡  OpenAI Codex CLI · Mac/Linux 一键安装器       ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║  OpenAI 出品，ChatGPT 用户首选编程助手                    ║${NC}"
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
            # Node.js 22 requires Ubuntu 20.04+ / Debian 11+
            case "$ID" in
                ubuntu)
                    if [ "${VERSION_ID:-0}" = "18.04" ] || [ "$(echo "$VERSION_ID" | cut -d. -f1)" -lt 20 ] 2>/dev/null; then
                        echo -e "  ${RED}Ubuntu ${VERSION_ID} 太旧，需要 20.04+${NC}"
                        echo -e "     升级: https://ubuntu.com/download"
                        exit 1
                    fi
                    ;;
                debian)
                    if [ "${VERSION_ID:-0}" -lt 11 ] 2>/dev/null; then
                        echo -e "  ${RED}Debian ${VERSION_ID} 太旧，需要 11+${NC}"
                        exit 1
                    fi
                    ;;
            esac
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

# ==================== 检测/安装 Node.js ====================
echo -e "${BLUE}━━━ 第二步：检测运行环境（Node.js）━━━${NC}"
echo ""

NODE_OK=false
if command -v node &>/dev/null; then
    NODE_VER=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -ge 22 ] 2>/dev/null; then
        echo -e "  ✅ Node.js 已就绪（版本 $(node -v)）"
        NODE_OK=true
    else
        echo -e "  ⚠️  Node.js 版本较旧（$(node -v)），需要 v22+"
    fi
else
    echo -e "  📦 Node.js 未安装"
fi

if [ "$NODE_OK" = false ]; then
    echo -e "  📦 正在自动安装 Node.js..."
    case "$OS_TYPE" in
        mac)
            if ! command -v brew &>/dev/null; then
                echo -e "      正在安装 Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
                if [ -f /opt/homebrew/bin/brew ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [ -f /usr/local/bin/brew ]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            if command -v brew &>/dev/null; then
                brew install node@22 2>/dev/null && NODE_OK=true
                brew link --overwrite --force node@22 2>/dev/null || true
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
        echo -e "  ${YELLOW}⚠️  Node.js 自动安装失败，请手动安装：${NC}"
        echo -e "  ${YELLOW}  访问 https://nodejs.org 下载安装包${NC}"
        exit 1
    fi
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

echo ""

# ==================== 安装 Codex ====================
echo -e "${BLUE}━━━ 第三步：安装 OpenAI Codex CLI ━━━${NC}"
echo ""

if command -v codex &>/dev/null; then
    echo -e "  ✅ Codex 已安装（$(codex --version 2>/dev/null | head -1 || echo '')）"
    echo ""
    echo -e "  启动方法: 终端输入 ${GREEN}codex${NC}"
    echo -e "  更新方法: 重新运行此脚本"
    echo ""
    exit 0
fi

if ! command -v npm &>/dev/null; then
    echo -e "  ${RED}❌ npm 未就绪，无法安装 Codex${NC}"
    echo -e "  请确保 Node.js 已正确安装后重试"
    exit 1
fi

echo -e "  📦 通过 npm 安装 @openai/codex ..."

# 国内网络自动切镜像
if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
    npm config set registry https://registry.npmmirror.com 2>/dev/null || true
    echo -e "  💡 已切换至国内镜像加速"
fi

if npm install -g @openai/codex@latest 2>/dev/null; then
    if command -v codex &>/dev/null; then
        echo -e "  ${GREEN}✅ Codex 安装成功！${NC}"
    else
        # 重试安装（处理可选平台依赖缺失的情况）
        echo -e "  💡 首次安装后未检测到命令，重试安装平台依赖..."
        npm install -g @openai/codex@latest 2>/dev/null || true
        if command -v codex &>/dev/null; then
            echo -e "  ${GREEN}✅ Codex 安装成功！${NC}"
        else
            echo -e "  ${RED}❌ 安装后未找到命令，请检查 npm 全局安装路径${NC}"
            exit 1
        fi
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║           🎉  OpenAI Codex CLI 安装完成！               ║${NC}"
    echo -e "${CYAN}║                                                          ║${NC}"
    echo -e "${CYAN}║  启动方法：                                              ║${NC}"
    echo -e "${CYAN}║  终端输入 codex → 回车                                  ║${NC}"
    echo -e "${CYAN}║  第一次使用会弹出浏览器登录 ChatGPT 账号                 ║${NC}"
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
    echo -e "  手动安装: npm install -g @openai/codex@latest"
    echo -e "  如有问题请截图联系卖家。"
    echo ""
    exit 1
fi
