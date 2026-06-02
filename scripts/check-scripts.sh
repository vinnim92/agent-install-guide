#!/usr/bin/env bash
# ============================================================
# scripts 目录静态检查
# 确保符合"单系统 + 单 Agent"安装规范
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
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

# ---- Bash 源码不得 source lib ----
echo ""
echo "--- 检查: Bash 源码必须自包含 ---"
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

# ---- Bash 源码自包含输出函数 ----
echo ""
echo "--- 检查: Bash 源码自包含常用函数 ---"
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

# ---- 单 Agent 源码不得交叉安装 ----
echo ""
echo "--- 检查: 单 Agent 源码不得交叉安装其他 Agent ---"
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

# ---- .sh 源码 shebang ----
echo ""
echo "--- 检查: .sh 源码 shebang ---"
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

# ---- .sh 源码 set -euo pipefail ----
echo ""
echo "--- 检查: .sh 源码 set -euo pipefail ---"
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

# ---- .ps1 源码 ErrorActionPreference ----
echo ""
echo "--- 检查: .ps1 源码 ErrorActionPreference ---"
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
echo "--- 检查: 源码包含对应验证命令 ---"
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
check_verify_cmd "${SCRIPT_DIR}/install-claude-code.sh"    "claude"   "command -v claude\|command_exists claude\|command_exists.*AGENT_BIN"
check_verify_cmd "${SCRIPT_DIR}/install-codex.sh"          "codex"    "command -v codex\|command_exists codex\|command_exists.*AGENT_BIN"
check_verify_cmd "${SCRIPT_DIR}/install-openclaw.sh"       "openclaw" "command -v openclaw\|command_exists openclaw\|command_exists.*AGENT_BIN"
check_verify_cmd "${SCRIPT_DIR}/install-claude-code.ps1"   "claude"   "Get-Command claude\|Get-Command \$AgentBin"
check_verify_cmd "${SCRIPT_DIR}/install-codex.ps1"         "codex"    "Get-Command codex\|Get-Command \$AgentBin"
check_verify_cmd "${SCRIPT_DIR}/install-openclaw.ps1"      "openclaw" "Get-Command openclaw\|Get-Command \$AgentBin"

# ---- --help 支持 ----
echo ""
echo "--- 检查: 源码支持 --help ---"
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
echo "--- 检查: 源码支持 --dry-run ---"
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

# ---- Bash confirm() 使用 /dev/tty ----
echo ""
echo "--- 检查: Bash confirm() 使用 /dev/tty ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '/dev/tty' "$f" 2>/dev/null; then
            check_pass "${fname} confirm() 使用 /dev/tty"
        else
            check_fail "${fname} confirm() 缺少 /dev/tty"
        fi
    fi
done

# ---- Bash help 包含 AGENT_INSTALL_YES=1 bash 推荐 ----
echo ""
echo "--- 检查: Bash help 包含 AGENT_INSTALL_YES=1 bash 推荐 ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q 'AGENT_INSTALL_YES=1 bash' "$f" 2>/dev/null; then
            check_pass "${fname} help 包含 AGENT_INSTALL_YES=1 bash 推荐"
        else
            check_fail "${fname} help 缺少 AGENT_INSTALL_YES=1 bash 推荐"
        fi
    fi
done

# ---- 禁止 npm config set registry ----
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
echo "--- 检查: 禁止 @main 未版本化 URL（应使用 @v3.1.1 等版本标签） ---"
AT_MAIN_HITS=$(grep -rn '@main' "${SCRIPT_DIR}" --include="*.sh" --include="*.ps1" 2>/dev/null | grep -v "check-scripts.sh" || true)
if [ -n "$AT_MAIN_HITS" ]; then
    check_fail "发现 @main 未版本化 URL（应固定为 @v3.1.1 等版本标签）"
    echo "$AT_MAIN_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现 @main URL（已版本化）"
fi

# ---- PDF/delivery macOS/Linux 命令必须使用 AGENT_INSTALL_YES=1 bash ----
echo ""
echo "--- 检查: PDF/delivery macOS/Linux 交付命令包含 AGENT_INSTALL_YES=1 bash ---"
YES_DELIVERY=$(grep -rn 'AGENT_INSTALL_YES=1 bash' "${REPO_ROOT}/pdf/" "${REPO_ROOT}/dist/" 2>/dev/null || true)
if [ -z "$YES_DELIVERY" ]; then
    check_fail "PDF/delivery 中 macOS/Linux 交付命令缺少 AGENT_INSTALL_YES=1 bash"
else
    check_pass "PDF/delivery 中 macOS/Linux 交付命令包含 AGENT_INSTALL_YES=1 bash"
fi

# ---- 禁止 PDF/delivery 中 macOS/Linux 命令使用裸 | bash ----
echo ""
echo "--- 检查: 禁止 PDF/delivery 中 macOS/Linux 命令使用裸 | bash（不含 AGENT_INSTALL_YES=1） ---"
BARE_BASH_HITS=$(grep -rn 'curl.*| bash' "${REPO_ROOT}/pdf/" "${REPO_ROOT}/dist/delivery/" 2>/dev/null | grep -v 'AGENT_INSTALL_YES=1' || true)
if [ -n "$BARE_BASH_HITS" ]; then
    check_fail "PDF/delivery 中 macOS/Linux 命令存在裸 | bash（应使用 AGENT_INSTALL_YES=1 bash）"
    echo "$BARE_BASH_HITS" | while read line; do echo "       $line"; done
else
    check_pass "PDF/delivery 中 macOS/Linux 交付命令均包含 AGENT_INSTALL_YES=1"
fi

# ---- 禁止"无需 API Key"文案 ----
echo ""
echo "--- 检查: 禁止"无需 API Key"文案 ---"
NO_API_KEY_HITS=$(grep -rn '无需 API Key\|无需API Key\|无需.*API.*Key' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/dist/" "${REPO_ROOT}/xianyu-materials/" 2>/dev/null | grep -v "check-scripts\|安装阶段不需要 API Key" || true)
if [ -n "$NO_API_KEY_HITS" ]; then
    check_fail "发现"无需 API Key"文案（应改为"安装阶段不需要 API Key"）"
    echo "$NO_API_KEY_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现"无需 API Key"文案"
fi

# ---- 禁止"内置免费模型"文案 ----
echo ""
echo "--- 检查: 禁止"内置免费模型"文案 ---"
FREE_MODEL_HITS=$(grep -rn '内置免费模型' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/dist/" "${REPO_ROOT}/xianyu-materials/" 2>/dev/null | grep -v "check-scripts" || true)
if [ -n "$FREE_MODEL_HITS" ]; then
    check_fail "发现"内置免费模型"文案"
    echo "$FREE_MODEL_HITS" | while read line; do echo "       $line"; done
else
    check_pass "未发现"内置免费模型"文案"
fi

# ---- OpenClaw 必须包含 deepseek-api-key onboarding ----
echo ""
echo "--- 检查: OpenClaw docs/PDF/README 包含 openclaw onboard --auth-choice deepseek-api-key ---"
DS_ONBOARD=$(grep -rn 'openclaw onboard.*deepseek-api-key\|onboard.*--auth-choice deepseek-api-key' "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/README.md" 2>/dev/null || true)
if [ -n "$DS_ONBOARD" ]; then
    check_pass "OpenClaw 文档包含 deepseek-api-key onboarding"
else
    check_fail "OpenClaw 文档缺少 deepseek-api-key onboarding"
fi

# ---- OpenClaw 必须包含 models list --provider deepseek ----
echo ""
echo "--- 检查: OpenClaw docs/PDF/README 包含 models list --provider deepseek ---"
DS_MODELS=$(grep -rn 'models list.*provider deepseek\|models list --provider deepseek' "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/README.md" 2>/dev/null || true)
if [ -n "$DS_MODELS" ]; then
    check_pass "OpenClaw 文档包含 models list --provider deepseek"
else
    check_fail "OpenClaw 文档缺少 models list --provider deepseek"
fi

# ---- OpenClaw 必须包含 openclaw dashboard ----
echo ""
echo "--- 检查: OpenClaw docs/PDF/README 包含 openclaw dashboard ---"
OC_DASHBOARD=$(grep -rn 'openclaw dashboard' "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/README.md" 2>/dev/null || true)
if [ -n "$OC_DASHBOARD" ]; then
    check_pass "OpenClaw 文档包含 openclaw dashboard"
else
    check_fail "OpenClaw 文档缺少 openclaw dashboard"
fi

# ---- OpenClaw 主流程不允许 openclaw models auth login --provider openai-codex ----
echo ""
echo "--- 检查: OpenClaw 主流程不允许 openclaw models auth login --provider openai-codex ---"
OC_OAUTH_HITS=$(grep -rn 'openclaw models auth login --provider openai-codex\|models auth login.*openai-codex' "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/README.md" 2>/dev/null || true)
if [ -n "$OC_OAUTH_HITS" ]; then
    check_fail "OpenClaw 主流程包含 openai-codex OAuth（应只在 FAQ 中说明）"
    echo "$OC_OAUTH_HITS" | while read line; do echo "       $line"; done
else
    check_pass "OpenClaw 主流程未包含 openai-codex OAuth"
fi

# ---- support.html 必须包含 unsupported_region ----
echo ""
echo "--- 检查: support.html 包含 unsupported_region FAQ ---"
if grep -q 'unsupported_region' "${REPO_ROOT}/docs/support.html" 2>/dev/null; then
    check_pass "support.html 包含 unsupported_region"
else
    check_fail "support.html 缺少 unsupported_region"
fi

# ---- support.html 必须包含 EACCES ----
echo ""
echo "--- 检查: support.html 包含 EACCES FAQ ---"
if grep -q 'EACCES' "${REPO_ROOT}/docs/support.html" 2>/dev/null; then
    check_pass "support.html 包含 EACCES"
else
    check_fail "support.html 缺少 EACCES"
fi

# ---- support.html 必须包含 .npm/_cacache ----
echo ""
echo "--- 检查: support.html 包含 .npm/_cacache ---"
if grep -q '\.npm/_cacache' "${REPO_ROOT}/docs/support.html" 2>/dev/null; then
    check_pass "support.html 包含 .npm/_cacache"
else
    check_fail "support.html 缺少 .npm/_cacache"
fi

# ---- install-openclaw.sh 必须包含 chown -R ----
echo ""
echo "--- 检查: install-openclaw.sh 包含 chown -R（npm 缓存权限修复） ---"
if grep -q 'chown -R' "${SCRIPT_DIR}/install-openclaw.sh" 2>/dev/null; then
    check_pass "install-openclaw.sh 包含 chown -R"
else
    check_fail "install-openclaw.sh 缺少 chown -R"
fi

# ---- install-openclaw.sh 必须包含 npm cache verify ----
echo ""
echo "--- 检查: install-openclaw.sh 包含 npm cache verify ---"
if grep -q 'npm cache verify' "${SCRIPT_DIR}/install-openclaw.sh" 2>/dev/null; then
    check_pass "install-openclaw.sh 包含 npm cache verify"
else
    check_fail "install-openclaw.sh 缺少 npm cache verify"
fi

# ---- 正式交付命令必须使用 @v3.1.1 ----
echo ""
echo "--- 检查: 正式交付命令必须使用 @v3.1.1 ---"
V3_OLDER_DELIVERY=$(grep -rn '@v3\.0\.[0-6]' "${REPO_ROOT}/README.md" "${REPO_ROOT}/pdf/" "${REPO_ROOT}/dist/delivery/" "${REPO_ROOT}/docs/" 2>/dev/null | grep -v "CHANGELOG\|check-scripts\|RELEASE_CHECKLIST" || true)
if [ -n "$V3_OLDER_DELIVERY" ]; then
    check_fail "发现活动旧版本交付命令（应使用 @v3.1.1）"
    echo "$V3_OLDER_DELIVERY" | while read line; do echo "       $line"; done
else
    check_pass "正式交付命令均使用 @v3.1.1"
fi

# ---- 禁止 @main ----
echo ""
echo "--- 检查: README/docs/xianyu-materials/pdf 中禁止 @main URL ---"
DOCS_AT_MAIN=$(grep -rn '@main' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/xianyu-materials/" "${REPO_ROOT}/pdf/" 2>/dev/null || true)
if [ -n "$DOCS_AT_MAIN" ]; then
    check_fail "交付文档中存在 @main 未版本化 URL"
    echo "$DOCS_AT_MAIN" | while read line; do echo "       $line"; done
else
    check_pass "交付文档中未发现 @main URL"
fi

# ---- 禁止旧路径 ----
echo ""
echo "--- 检查: 交付文档禁止旧路径 (scripts/install.sh / mac-linux / windows) ---"
OLD_PATH_HITS=$(grep -rn 'scripts/install\.sh\|scripts/install\.ps1\|scripts/mac-linux\|scripts/windows' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/xianyu-materials/" "${REPO_ROOT}/pdf/" 2>/dev/null || true)
if [ -n "$OLD_PATH_HITS" ]; then
    check_fail "交付文档中存在旧路径引用"
    echo "$OLD_PATH_HITS" | while read line; do echo "       $line"; done
else
    check_pass "交付文档中未发现旧路径引用"
fi

# ---- 禁止"发给我" ----
echo ""
echo "--- 检查: 交付文档禁止"发给我" ---"
SEND_ME=$(grep -rn '发给我' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/xianyu-materials/" "${REPO_ROOT}/pdf/" 2>/dev/null || true)
if [ -n "$SEND_ME" ]; then
    check_fail "交付文档中存在"发给我"（应使用故障排查页面链接）"
    echo "$SEND_ME" | while read line; do echo "       $line"; done
else
    check_pass "交付文档中未发现"发给我""
fi

# ---- 禁止三合一语义 ----
echo ""
echo "--- 检查: 交付文档禁止三合一/聚合选择语义 ---"
AGG_HITS=$(grep -rn '三合一\|一次安装.*三\|同时安装.*三\|全部.*安装.*[三3]' "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/xianyu-materials/" "${REPO_ROOT}/pdf/" 2>/dev/null | grep -v '不建议\|不推荐\|不要\|不建议.*一次安装' || true)
if [ -n "$AGG_HITS" ]; then
    check_fail "交付文档中存在三合一/聚合选择语义"
    echo "$AGG_HITS" | while read line; do echo "       $line"; done
else
    check_pass "交付文档中未发现三合一/聚合选择语义"
fi

# ---- 6 个脚本包含预检提示 ----
echo ""
echo "--- 检查: 安装脚本包含预检提示 ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh" \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '正在检查你的电脑环境' "$f" 2>/dev/null; then
            check_pass "${fname} 包含预检提示"
        else
            check_fail "${fname} 缺少\"正在检查你的电脑环境\""
        fi
    fi
done

# ---- dry-run 定位 ----
echo ""
echo "--- 检查: dry-run 描述为排查/预览（非主流程） ---"
for f in \
    "${SCRIPT_DIR}/install-claude-code.sh" \
    "${SCRIPT_DIR}/install-codex.sh" \
    "${SCRIPT_DIR}/install-openclaw.sh" \
    "${SCRIPT_DIR}/install-claude-code.ps1" \
    "${SCRIPT_DIR}/install-codex.ps1" \
    "${SCRIPT_DIR}/install-openclaw.ps1"; do
    fname=$(basename "$f")
    if [ -f "$f" ]; then
        if grep -q '排查.*预览\|预览.*排查\|只看不装\|排查/预览' "$f" 2>/dev/null; then
            check_pass "${fname} dry-run 定位为排查/预览"
        else
            check_fail "${fname} dry-run 缺少\"排查/预览\"描述"
        fi
    fi
done

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

# ---- 禁止翻墙相关内容 ----
echo ""
echo "--- 检查: xianyu-materials 中不包含翻墙相关内容 ---"
GFW_HITS=$(grep -rni '翻墙\|科学上网\|梯子\|shadowsocks\|v2ray\|clash.*机场' "${REPO_ROOT}/xianyu-materials/" "${REPO_ROOT}/README.md" "${REPO_ROOT}/docs/" "${REPO_ROOT}/pdf/" 2>/dev/null | grep -v '无需翻墙\|不需要翻墙\|不用翻墙\|不翻墙\|关闭.*代理.*VPN\|开了.*VPN\|切换.*全局' || true)
if [ -n "$GFW_HITS" ]; then
    check_fail "交付文档中存在翻墙相关内容"
    echo "$GFW_HITS" | while read line; do echo "       $line"; done
else
    check_pass "交付文档中未发现翻墙相关内容"
fi

# ---- Claude Code DeepSeek API 检查 ----
echo ""
echo "--- 检查: Claude Code PDF/docs 包含 DeepSeek API ---"
DS_PDF=$(grep -rn 'DeepSeek\|deepseek' "${REPO_ROOT}/pdf/claude-code-beginner-guide.html" 2>/dev/null || true)
DS_DOCS=$(grep -rn 'DeepSeek\|deepseek' "${REPO_ROOT}/docs/agents/claude-code.md" "${REPO_ROOT}/docs/agents/claude-code-guide.html" 2>/dev/null || true)
if [ -n "$DS_PDF" ] && [ -n "$DS_DOCS" ]; then
    check_pass "Claude Code PDF/docs 包含 DeepSeek API"
else
    check_fail "Claude Code PDF/docs 缺少 DeepSeek API 内容"
fi

# ---- Claude Code 安装脚本包含 DeepSeek 配置引导 ----
echo ""
echo "--- 检查: Claude Code 安装脚本包含 DeepSeek 配置引导 ---"
DS_SH=$(grep -rn 'DeepSeek\|deepseek\|configure_deepseek' "${SCRIPT_DIR}/install-claude-code.sh" 2>/dev/null || true)
DS_PS=$(grep -rn 'DeepSeek\|deepseek\|Start-DeepSeekConfig' "${SCRIPT_DIR}/install-claude-code.ps1" 2>/dev/null || true)
if [ -n "$DS_SH" ] && [ -n "$DS_PS" ]; then
    check_pass "Claude Code 安装脚本包含 DeepSeek 配置引导"
else
    check_fail "Claude Code 安装脚本缺少 DeepSeek 配置引导"
fi

# ---- Codex 文档包含 API Key 登录 ----
echo ""
echo "--- 检查: Codex PDF/docs 包含 codex login --with-api-key ---"
CX_PDF=$(grep -rn 'codex login --with-api-key' "${REPO_ROOT}/pdf/codex-beginner-guide.html" 2>/dev/null || true)
CX_DOCS=$(grep -rn 'codex login --with-api-key' "${REPO_ROOT}/docs/agents/codex.md" "${REPO_ROOT}/docs/agents/codex-guide.html" 2>/dev/null || true)
CX_SCRIPTS=$(grep -rn 'codex login --with-api-key' "${SCRIPT_DIR}/install-codex.sh" "${SCRIPT_DIR}/install-codex.ps1" 2>/dev/null || true)
if [ -n "$CX_PDF" ] && [ -n "$CX_DOCS" ] && [ -n "$CX_SCRIPTS" ]; then
    check_pass "Codex 各文档包含 codex login --with-api-key"
else
    check_fail "Codex 部分文档缺少 codex login --with-api-key"
    [ -z "$CX_PDF" ] && echo "       pdf/codex-beginner-guide.html 缺少"
    [ -z "$CX_DOCS" ] && echo "       docs/agents/codex.md 或 codex-guide.html 缺少"
    [ -z "$CX_SCRIPTS" ] && echo "       install-codex.sh 或 install-codex.ps1 缺少"
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
    red "❌ 存在 ${FAIL} 项不合规问题"
    exit 1
else
    echo ""
    green "✅ 检查已符合规范"
fi
