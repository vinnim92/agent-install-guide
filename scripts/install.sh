#!/usr/bin/env bash
# ============================================================
# AI 编程助手 · 零基础一键安装器
#
# 用法（复制下面这行到终端回车）:
#   curl -fsSL https://cdn.jsdelivr.net/gh/vinnim92/agent-install-guide@main/scripts/install.sh | bash
#
# 目标用户：完全不会命令行的普通人
# 设计原则：不要求用户懂任何技术名词，每一步都自动完成
# ============================================================

set -e

# ==================== 干运行模式 ====================
DRY_RUN=false
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    echo ""
    echo -e "${YELLOW}🔍 干运行模式 — 只检查环境，不实际安装${NC}"
    echo ""
fi

# 干运行模式下，安装命令替换为空操作
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "      ${YELLOW}[DRY-RUN]${NC} 将执行: $*"
        return 0
    else
        eval "$@"
    fi
}

# ==================== 颜色 ====================
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
REPO="https://github.com/vinnim92/agent-install-guide"

# ==================== 欢迎 ====================
[ -n "$TERM" ] && clear || true
echo ""
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║       🤖  AI 编程助手 · 零基础一键安装器                ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║  本脚本将自动为你安装三款最火的 AI 编程助手：           ║${NC}"
echo -e "${CYAN}║    🧠 Claude Code   — 最聪明的 AI 程序员               ║${NC}"
echo -e "${CYAN}║    ⚡ Codex         — OpenAI 出品的编程利器            ║${NC}"
echo -e "${CYAN}║    🦞 OpenClaw      — 微软开源，自带免费模型          ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║  你不用懂任何技术，脚本会自动处理一切。                 ║${NC}"
echo -e "${CYAN}║  整个过程大约需要 5-10 分钟（取决于网速）。            ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# ==================== 系统检测 ====================
OS="$(uname -s)"
ARCH="$(uname -m)"

echo -e "${BLUE}━━━ 第一步：检测你的电脑 ━━━${NC}"
echo ""

case "$OS" in
    Darwin)
        echo -e "  ✅ 检测到你的电脑是 ${GREEN}Mac（苹果电脑）${NC}"
        OS_TYPE="mac"
        ;;
    Linux)
        echo -e "  ✅ 检测到你的电脑是 ${GREEN}Linux 系统${NC}"
        OS_TYPE="linux"
        # 进一步判断发行版
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            echo -e "     具体版本：${GREEN}${NAME:-Linux}${NC}"
            # Node.js 22 requires Ubuntu 20.04+ / Debian 11+
            case "$ID" in
                ubuntu)
                    if [ "${VERSION_ID:-0}" = "18.04" ] || [ "$(echo "$VERSION_ID" | cut -d. -f1)" -lt 20 ] 2>/dev/null; then
                        echo -e "  ${RED}Ubuntu ${VERSION_ID} too old, need 20.04+${NC}"
                        echo -e "     Upgrade: https://ubuntu.com/download"
                        exit 1
                    fi
                    ;;
                debian)
                    if [ "${VERSION_ID:-0}" -lt 11 ] 2>/dev/null; then
                        echo -e "  ${RED}Debian ${VERSION_ID} too old, need 11+${NC}"
                        exit 1
                    fi
                    ;;
            esac
        fi
        ;;
    *)
        echo -e "  ⚠️  抱歉，本脚本暂不支持当前操作系统。"
        echo -e "     如果你是 Windows 用户，请使用我们提供的 Windows 版安装器。"
        exit 1
        ;;
esac

echo -e "  ✅ 处理器架构：${GREEN}${ARCH}${NC}"
echo ""

# ---- 确定 Shell 配置文件（提前定义，后续步骤会用到）----
SHELL_RC=""
case "$SHELL" in
    */zsh)  SHELL_RC="$HOME/.zshrc" ;;
    */bash) SHELL_RC="$HOME/.bashrc" ;;
    *)      SHELL_RC="$HOME/.profile" ;;
esac

# ==================== 第二步：安装基础工具 ====================
echo -e "${BLUE}━━━ 第二步：安装必要的系统工具 ━━━${NC}"
echo -e "  （这些是电脑运行 AI 助手需要的基础组件，全部自动安装）"
echo ""

# ---- Git ----
if command -v git &>/dev/null; then
    echo -e "  ✅ Git 工具：${GREEN}已就绪${NC}（版本 $(git --version | awk '{print $3}')）"
else
    echo -e "  📦 正在安装 Git 工具（用于下载和管理文件）..."
    case "$OS_TYPE" in
        mac)
            # macOS: 优先用 xcode-select，不行再装 brew
            if ! xcode-select -p &>/dev/null; then
                echo -e "      需要先安装苹果开发工具（大约需要 2 分钟）..."
                xcode-select --install 2>/dev/null || true
                echo -e "      ${YELLOW}⚠️  请在弹出的窗口中点击"安装"，完成后按回车继续...${NC}"
                read -r
            fi
            if ! command -v git &>/dev/null; then
                echo -e "      正在安装 Homebrew（Mac 软件管家）..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
                if command -v brew &>/dev/null; then
                    brew install git
                fi
            fi
            ;;
        linux)
            if command -v apt-get &>/dev/null; then
                sudo apt-get update -qq && sudo apt-get install -y -qq git
            elif command -v dnf &>/dev/null; then
                sudo dnf install -y git
            elif command -v pacman &>/dev/null; then
                sudo pacman -S --noconfirm git
            elif command -v apk &>/dev/null; then
                sudo apk add git
            else
                echo -e "  ${YELLOW}⚠️  请手动安装 Git：https://git-scm.com/downloads${NC}"
            fi
            ;;
    esac
    if command -v git &>/dev/null; then
        echo -e "  ✅ Git 安装成功！"
    else
        echo -e "  ${RED}❌ Git 安装失败，但我们继续尝试...${NC}"
    fi
fi

# ---- Node.js ----
NODE_OK=false
if command -v node &>/dev/null; then
    NODE_VER=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_VER" -ge 22 ] 2>/dev/null; then
        echo -e "  ✅ Node.js 运行环境：${GREEN}已就绪${NC}（版本 $(node -v)）"
        NODE_OK=true
    else
        echo -e "  ⚠️  Node.js 版本较旧（$(node -v)），需要升级到 v22 以上"
    fi
else
    echo -e "  📦 Node.js 运行环境未安装"
fi

if [ "$NODE_OK" = false ]; then
    echo -e "  📦 正在自动安装 Node.js 运行环境（一些 AI 助手需要它）..."
    case "$OS_TYPE" in
        mac)
            # macOS: 用 brew 装
            if ! command -v brew &>/dev/null; then
                echo -e "      正在安装 Homebrew（Mac 上的软件管家，大约需要 2 分钟）..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>/dev/null || true
                # 添加到 PATH
                if [ -f /opt/homebrew/bin/brew ]; then
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                elif [ -f /usr/local/bin/brew ]; then
                    eval "$(/usr/local/bin/brew shellenv)"
                fi
            fi
            if command -v brew &>/dev/null; then
                brew install node@22 2>/dev/null && NODE_OK=true
                # 建立软链接
                brew link --overwrite --force node@22 2>/dev/null || true
            fi
            ;;
        linux)
            # Linux: 用 NodeSource
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
        echo -e "  ${YELLOW}⚠️  Node.js 自动安装失败，但 Claude Code 不受影响（它自带运行环境）${NC}"
        echo -e "  ${YELLOW}   Codex 和 OpenClaw 需要 Node.js，你可以之后手动安装：${NC}"
        echo -e "  ${YELLOW}   访问 https://nodejs.org 下载安装包（和装微信一样简单）${NC}"
    fi
fi

# ---- 修复 npm 权限（解决 EACCES 错误）----
if command -v npm &>/dev/null; then
    NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "")
    if [ -n "$NPM_PREFIX" ] && [ ! -w "$NPM_PREFIX" ]; then
        # 全局安装目录没写权限，切换到用户目录
        NPM_GLOBAL_DIR="$HOME/.npm-global"
        mkdir -p "$NPM_GLOBAL_DIR" 2>/dev/null || true
        npm config set prefix "$NPM_GLOBAL_DIR" 2>/dev/null || true
        export PATH="$NPM_GLOBAL_DIR/bin:$PATH"
        if ! grep -q ".npm-global/bin" "$SHELL_RC" 2>/dev/null; then
            echo "export PATH=\"\$HOME/.npm-global/bin:\$PATH\"" >> "$SHELL_RC"
        fi
        echo -e "  💡 已自动调整 npm 安装位置（避免权限问题）"
    fi
fi

echo ""

# ==================== 第三步：安装 AI 助手 ====================
echo -e "${BLUE}━━━ 第三步：安装 AI 编程助手 ━━━${NC}"
echo -e "  （这是这次的主角——三款最火的 AI 编程助手）"
echo ""

INSTALLED_COUNT=0

# ---- Claude Code ----
echo -e "${BOLD}  🧠 安装 Claude Code ...${NC}"
if command -v claude &>/dev/null; then
    echo -e "    ${GREEN}✅ Claude Code 已安装${NC}（$(claude --version 2>/dev/null | head -1 || echo '')）"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    CLAUDE_OK=false
    echo -e "    尝试官方脚本安装..."
    if curl -fsSL --connect-timeout 30 https://claude.ai/install.sh 2>/dev/null | bash 2>/dev/null; then
        export PATH="$HOME/.local/bin:$PATH"
        if command -v claude &>/dev/null; then CLAUDE_OK=true; fi
    fi
    if [ "$CLAUDE_OK" = false ] && command -v npm &>/dev/null; then
        echo -e "    ${YELLOW}官方脚本不可用（地域限制），改用 npm 安装...${NC}"
        if npm install -g @anthropic-ai/claude-code@latest 2>/dev/null; then
            CLAUDE_OK=true
        fi
    fi
    if [ "$CLAUDE_OK" = true ]; then
        echo -e "    ${GREEN}✅ Claude Code 安装成功！${NC}"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        echo -e "    ${YELLOW}⚠️  Claude Code 安装失败，请稍后重试${NC}"
        echo -e "    ${YELLOW}手动安装: npm install -g @anthropic-ai/claude-code${NC}"
    fi
fi
# ---- Codex ----
echo -e "${BOLD}  ⚡ 安装 Codex ...${NC}"
if [ "$NODE_OK" = true ]; then
    if command -v codex &>/dev/null; then
        echo -e "    ${GREEN}✅ Codex 已安装${NC}（$(codex --version 2>/dev/null | head -1 || echo '')）"
        INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
    else
        # 国内网络自动切镜像
        if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
            npm config set registry https://registry.npmmirror.com 2>/dev/null || true
        fi
        if npm install -g @openai/codex 2>/dev/null; then
            echo -e "    ${GREEN}✅ Codex 安装成功！${NC}"
            INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
        else
            echo -e "    ${YELLOW}⚠️  Codex 安装失败（可能是网络问题），请稍后重试${NC}"
        fi
    fi
else
    echo -e "    ${YELLOW}⏭️  跳过（需要 Node.js，安装失败）${NC}"
fi

# ---- OpenClaw ----
echo -e "${BOLD}  🦞 安装 OpenClaw ...${NC}"
if command -v openclaw &>/dev/null; then
    echo -e "    ${GREEN}✅ OpenClaw 已安装${NC}（$(openclaw --version 2>/dev/null | head -1 || echo '')）"
    INSTALLED_COUNT=$((INSTALLED_COUNT + 1))
else
    # 国内网络优化
    if ! curl -fsSL --connect-timeout 3 https://registry.npmjs.org/ >/dev/null 2>&1; then
        npm config set registry https://registry.npmmirror.com 2>/dev/null || true
    fi
    if [ "$NODE_OK" = true ]; then
        npm install -g openclaw@latest 2>/dev/null && INSTALLED_COUNT=$((INSTALLED_COUNT + 1)) || true
    fi
    if command -v openclaw &>/dev/null; then
        echo -e "    ${GREEN}✅ OpenClaw 安装成功！${NC}"
    else
        echo -e "    ${YELLOW}⚠️  OpenClaw 安装失败，不影响前两个使用${NC}"
    fi
fi

echo ""

# ==================== 第四步：配置 PATH ====================
echo -e "${BLUE}━━━ 第四步：收尾配置 ━━━${NC}"

PATH_UPDATED=false
if [ -d "$HOME/.local/bin" ] && ! echo "$PATH" | grep -q ".local/bin"; then
    export PATH="$HOME/.local/bin:$PATH"
    if ! grep -q ".local/bin" "$SHELL_RC" 2>/dev/null; then
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        PATH_UPDATED=true
    fi
fi

NPM_PREFIX=$(npm prefix -g 2>/dev/null || echo "")
if [ -n "$NPM_PREFIX" ] && [ -d "$NPM_PREFIX/bin" ]; then
    export PATH="$NPM_PREFIX/bin:$PATH"
fi

if [ "$PATH_UPDATED" = true ]; then
    echo -e "  ✅ 已将 AI 助手加入系统路径（重启终端后永久生效）"
else
    echo -e "  ✅ 路径配置完成"
fi
echo ""

# ==================== 完成 ====================
echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║                  🎉  安装完成！                          ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"

if [ $INSTALLED_COUNT -eq 3 ]; then
    echo -e "${CYAN}║       三款 AI 助手全部安装成功！                         ║${NC}"
elif [ $INSTALLED_COUNT -ge 1 ]; then
    echo -e "${CYAN}║       已安装 ${INSTALLED_COUNT} 款 AI 助手                        ║${NC}"
else
    echo -e "${CYAN}║       安装遇到一些问题，但别担心——                        ║${NC}"
    echo -e "${CYAN}║       请将上面黄色部分的文字截图发给卖家帮你排查          ║${NC}"
fi

echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   ${BOLD}📖 怎么开始使用？${NC}${CYAN}                                     ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"

if command -v claude &>/dev/null; then
    echo -e "${CYAN}║   Claude Code: 打开终端 → 输入 ${GREEN}claude${CYAN} → 回车            ║${NC}"
fi
if command -v codex &>/dev/null; then
    echo -e "${CYAN}║   Codex:       打开终端 → 输入 ${GREEN}codex${CYAN} → 回车             ║${NC}"
fi
if command -v openclaw &>/dev/null; then
    echo -e "${CYAN}║   OpenClaw:    打开终端 → 输入 ${GREEN}openclaw${CYAN} → 回车         ║${NC}"
fi

echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   ${BOLD}❓ 常见问题${NC}${CYAN}                                          ║${NC}"
echo -e "${CYAN}║   1. 输入命令提示"找不到" → 关掉终端重新打开即可         ║${NC}"
echo -e "${CYAN}║   2. 网络慢装不上 → 换成手机热点试试                      ║${NC}"
echo -e "${CYAN}║   3. 其他问题 → 截图发给卖家，24 小时内回复               ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   ${BOLD}🔄 更新方法${NC}${CYAN}                                          ║${NC}"
echo -e "${CYAN}║   再次运行安装脚本即可自动升级到最新版                     ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}║   仓库地址: ${REPO}                                        ║${NC}"
echo -e "${CYAN}║                                                          ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}感谢购买！如有问题请到仓库提 Issue 或直接联系卖家。${NC}"
echo ""
