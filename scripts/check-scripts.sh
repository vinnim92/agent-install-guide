#!/usr/bin/env bash
# ============================================================
# scripts 目录静态检查
# 确保符合"单系统 + 单 Agent"安装规范
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0
FAIL=0

green()  { echo -e "\033[0;32m$1\033[0m"; }
red()    { echo -e "\033[0;31m$1\033[0m"; }
yellow() { echo -e "\033[1;33m$1\033[0m"; }

check_pass() { green "  ✅ PASS: $1"; PASS=$((PASS + 1)); }
check_fail() { red   "  ❌ FAIL: $1"; FAIL=$((FAIL + 1)); }

echo ""
echo "========================================"
echo "  scripts 目录静态检查"
echo "========================================"
echo ""

# ---- 禁止旧入口文件 ----
echo "--- 检查: 禁止旧入口文件 ---"
for forbidden in install.sh install.ps1 install-all.sh install-all.ps1; do
    if [ -f "${SCRIPT_DIR}/${forbidden}" ]; then
        check_fail "${forbidden} 不应存在（旧入口）"
    else
        check_pass "${forbidden} 不存在"
    fi
done

# ---- 禁止旧语义 ----
echo ""
echo "--- 检查: 禁止旧语义（三款/全部安装/一次安装/同时安装） ---"
if grep -r "三款\|全部安装\|一次安装\|同时安装" "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" -l 2>/dev/null | grep -v "check-scripts.sh"; then
    check_fail "scripts 目录中存在旧语义关键词"
else
    check_pass "未发现旧语义关键词"
fi

# ---- 禁止 opencode 引用 ----
echo ""
echo "--- 检查: 禁止 opencode/opencode-ai/OpenCode/opencode.ai ---"
OC_HITS=$(grep -rn "opencode\|opencode-ai\|OpenCode\|opencode\.ai" "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$OC_HITS" ]; then
    check_fail "scripts 目录中存在 opencode/opencode-ai/OpenCode 引用:"
    echo "$OC_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现 opencode/opencode-ai/OpenCode 引用"
fi

# ---- Bash 入口不得 source lib ----
echo ""
echo "--- 检查: Bash 入口必须自包含 ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q 'source.*lib\|BASH_SOURCE.*lib\|\. .*lib' "$f" 2>/dev/null; then
            check_fail "${fname} 不应 source lib"
        else
            check_pass "${fname} 未依赖 lib"
        fi
    else
        check_fail "${fname} 不存在"
    fi
done

# ---- Bash 入口自包含输出函数 ----
echo ""
echo "--- 检查: Bash 入口自包含常用函数 ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        ok=true
        if ! grep -q 'print_success\|print_ok' "$f" 2>/dev/null; then ok=false; fi
        if ! grep -q 'print_error\|print_fail' "$f" 2>/dev/null; then ok=false; fi
        if [ "$ok" = true ]; then
            check_pass "${fname} 自包含输出函数"
        else
            check_fail "${fname} 缺少输出函数"
        fi
    fi
done

# ---- 单 Agent 入口不得交叉安装 ----
echo ""
echo "--- 检查: 单 Agent 入口不得交叉安装其他 Agent ---"
check_no_cross_pkg() {
    local file="$1"; local label="$2"; local forbidden="$3"
    if [ -f "$file" ]; then
        if grep -q "$forbidden" "$file" 2>/dev/null; then
            check_fail "$(basename "$file") 不应包含 $label 的安装包引用"
        else
            check_pass "$(basename "$file") 未交叉安装 $label"
        fi
    fi
}
check_no_cross_pkg "${SCRIPT_DIR}/install-claude-code.sh" "Codex/OpenClaw" "@openai/codex\|openclaw@latest\|npm install -g codex"
check_no_cross_pkg "${SCRIPT_DIR}/install-codex.sh" "Claude Code/OpenClaw" "@anthropic-ai/claude-code\|openclaw@latest"
check_no_cross_pkg "${SCRIPT_DIR}/install-openclaw.sh" "Claude Code/Codex" "@anthropic-ai/claude-code\|@openai/codex"

# ---- .sh 入口 shebang ----
echo ""
echo "--- 检查: .sh 入口 shebang ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    if [ -f "$f" ]; then
        if head -1 "$f" | grep -q '^#!/usr/bin/env bash'; then
            check_pass "$(basename "$f") shebang 正确"
        else
            check_fail "$(basename "$f") shebang 错误"
        fi
    fi
done

# ---- .sh 入口 set -euo pipefail ----
echo ""
echo "--- 检查: .sh 入口 set -euo pipefail ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    if [ -f "$f" ]; then
        if grep -q 'set -euo pipefail' "$f"; then
            check_pass "$(basename "$f") 包含 set -euo pipefail"
        else
            check_fail "$(basename "$f") 缺少 set -euo pipefail"
        fi
    fi
done

# ---- .ps1 入口 ErrorActionPreference ----
echo ""
echo "--- 检查: .ps1 入口 ErrorActionPreference ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    if [ -f "$f" ]; then
        if grep -q '\$ErrorActionPreference\s*=\s*"Stop"' "$f"; then
            check_pass "$(basename "$f") 包含 ErrorActionPreference = Stop"
        else
            check_fail "$(basename "$f") 缺少 ErrorActionPreference = Stop"
        fi
    else
        check_fail "$(basename "$f") 不存在"
    fi
done

# ---- 验证命令 ----
echo ""
echo "--- 检查: 入口包含对应验证命令 ---"
check_verify_cmd() {
    local file="$1"; local label="$2"; local verify_cmd="$3"
    if [ -f "$file" ]; then
        if grep -q "$verify_cmd" "$file"; then
            check_pass "$(basename "$file") 包含验证: $verify_cmd"
        else
            check_fail "$(basename "$file") 缺少验证: $verify_cmd"
        fi
    fi
}
check_verify_cmd "${SCRIPT_DIR}/install-claude-code.sh"    "claude"   "command -v claude\|command_exists claude"
check_verify_cmd "${SCRIPT_DIR}/install-codex.sh"          "codex"    "command -v codex\|command_exists codex"
check_verify_cmd "${SCRIPT_DIR}/install-openclaw.sh"       "openclaw" "command -v openclaw\|command_exists openclaw"
check_verify_cmd "${SCRIPT_DIR}/install-claude-code.ps1"   "claude"   "Get-Command claude"
check_verify_cmd "${SCRIPT_DIR}/install-codex.ps1"         "codex"    "Get-Command codex"
check_verify_cmd "${SCRIPT_DIR}/install-openclaw.ps1"      "openclaw" "Get-Command openclaw"

# ---- --help 支持 ----
echo ""
echo "--- 检查: 入口支持 --help ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '\-\-help\|show_help' "$f" 2>/dev/null; then
            check_pass "${fname} 支持 --help"
        else
            check_fail "${fname} 缺少 --help"
        fi
    fi
done
for f in \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '\$Help\|-Help\|--help' "$f" 2>/dev/null; then
            check_pass "${fname} 支持 -Help"
        else
            check_fail "${fname} 缺少 -Help"
        fi
    fi
done

# ---- --dry-run 支持 ----
echo ""
echo "--- 检查: 入口支持 --dry-run ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q 'dry.run\|DRY_RUN' "$f" 2>/dev/null; then
            check_pass "${fname} 支持 --dry-run"
        else
            check_fail "${fname} 缺少 --dry-run"
        fi
    fi
done
for f in \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '\$DryRun\|DryRun\|dry.run' "$f" 2>/dev/null; then
            check_pass "${fname} 支持 -DryRun"
        else
            check_fail "${fname} 缺少 -DryRun"
        fi
    fi
done

# ---- AGENT_INSTALL_YES 跳过确认 ----
echo ""
echo "--- 检查: AGENT_INSTALL_YES 跳过确认机制 ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q 'AGENT_INSTALL_YES' "$f" 2>/dev/null; then
            check_pass "${fname} 包含 AGENT_INSTALL_YES 机制"
        else
            check_fail "${fname} 缺少 AGENT_INSTALL_YES"
        fi
    fi
done
for f in \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q 'AGENT_INSTALL_YES' "$f" 2>/dev/null; then
            check_pass "${fname} 包含 AGENT_INSTALL_YES 机制"
        else
            check_fail "${fname} 缺少 AGENT_INSTALL_YES"
        fi
    fi
done

# ---- 禁止 npm config set registry（应使用 --registry 单次参数） ----
echo ""
echo "--- 检查: 禁止 npm config set registry（应使用 --registry 单次参数） ---"
NPM_REGISTRY_HITS=$(grep -rn 'npm config set registry' "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$NPM_REGISTRY_HITS" ]; then
    check_fail "发现 npm config set registry（应改用 --registry 单次参数）"
    echo "$NPM_REGISTRY_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现 npm config set registry（使用 --registry 单次参数）"
fi

# ---- 禁止 sudo npm install -g ----
echo ""
echo "--- 检查: 禁止 sudo npm install -g ---"
SUDO_NPM_HITS=$(grep -rn 'sudo npm install -g\|sudo -E npm install -g' "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$SUDO_NPM_HITS" ]; then
    check_fail "发现 sudo npm install -g（不应使用 sudo）"
    echo "$SUDO_NPM_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现 sudo npm install -g"
fi

# ---- 禁止 @main 未版本化 URL ----
echo ""
echo "--- 检查: 禁止 @main 未版本化 URL（应使用 @v3.0.3 等版本标签） ---"
AT_MAIN_HITS=$(grep -rn '@main' "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$AT_MAIN_HITS" ]; then
    check_fail "发现 @main 未版本化 URL（应固定为 @v3.0.3 等版本标签）"
    echo "$AT_MAIN_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现 @main URL（已版本化）"
fi

# ---- 官方 installer 引用检查 ----
echo ""
echo "--- 检查: 安装脚本引用官方 installer ---"
check_official_ref() {
    local file="$1"; local label="$2"; local official_url="$3"
    if [ -f "$file" ]; then
        if grep -q "$official_url" "$file" 2>/dev/null; then
            check_pass "$(basename "$file") 引用 ${label} 官方 installer"
        else
            check_fail "$(basename "$file") 缺少 ${label} 官方 installer 引用: ${official_url}"
        fi
    fi
}
check_official_ref "${SCRIPT_DIR}/install-claude-code.sh"   "Claude Code" "claude\.ai/install\.sh"
check_official_ref "${SCRIPT_DIR}/install-claude-code.ps1"  "Claude Code" "claude\.ai/install\.ps1"
check_official_ref "${SCRIPT_DIR}/install-codex.sh"         "Codex"       "chatgpt\.com/codex/install\.sh"
check_official_ref "${SCRIPT_DIR}/install-codex.ps1"        "Codex"       "chatgpt\.com/codex/install\.ps1"
check_official_ref "${SCRIPT_DIR}/install-openclaw.sh"      "OpenClaw"    "openclaw\.ai/install\.sh"
check_official_ref "${SCRIPT_DIR}/install-openclaw.ps1"     "OpenClaw"    "openclaw\.ai/install\.ps1"

# ---- 危险命令检查 ----
echo ""
echo "--- 检查: 禁止危险命令 ---"
DANGER_HITS=$(grep -rn 'rm -rf /\|chmod -R 777' "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$DANGER_HITS" ]; then
    check_fail "发现危险命令 (rm -rf / 或 chmod -R 777)"
else
    check_pass "未发现危险命令"
fi

# ---- 结果汇总 ----
echo ""
echo "========================================"
echo "  检查结果"
echo "========================================"
echo ""
TOTAL=$((PASS + FAIL))
green "  通过: ${PASS}/${TOTAL}"
if [ "$FAIL" -gt 0 ]; then
    red "  失败: ${FAIL}/${TOTAL}"
    echo ""
    red "❌ scripts 目录存在 ${FAIL} 项不合规问题"
    exit 1
else
    echo ""
    green "✅ scripts 目录已符合"单系统 + 单 Agent"安装规范"
fi
