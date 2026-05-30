# Changelog

## v3.0.4 (2026-05-30)

### 小白体验优化
- 安装脚本新增普通安装前自动环境预检（系统、架构、网络、依赖、已安装状态）
- `--dry-run` / `-DryRun` 调整为排查/预览模式（只看不装），不再作为小白主流程
- `--help` 中将 dry-run 描述为"排查/预览（只看不装）"

### 文档交付
- 交付 PDF 从聚合版拆分为 Claude Code / Codex / OpenClaw 三份独立手册
- 每份 PDF 仅含一个 Agent 的安装引导，无聚合选择流程
- PDF 增加 Terminal / PowerShell 详细打开步骤
- 新增 `docs/support.html` 故障排查页面，按错误类型分类
- 报错反馈从"发给我"调整为"故障排查页面 + 协助版发给卖家"
- 所有交付命令固定到 `@v3.0.4`

### 检查增强
- `check-scripts.sh` 新增 8 项扩展检查（交付文档 @main、旧路径、"发给我"、三合一语义、预检提示、dry-run 定位、验证命令变量形式）

---

## v3.0.3 (2026-05-30)

### 安装策略升级
- **官方 installer 优先**: 全部 6 个脚本优先使用官方安装器
  - Claude Code: `claude.ai/install.sh` / `claude.ai/install.ps1`
  - Codex: `chatgpt.com/codex/install.sh` / `chatgpt.com/codex/install.ps1`
  - OpenClaw: `openclaw.ai/install.sh` / `openclaw.ai/install.ps1`
- npm 仅作为 fallback，使用 `--registry` 单次参数切换国内镜像
- **不再使用** `npm config set registry` 永久修改 npm 配置

### Node.js 版本要求
- OpenClaw: 最低 Node ≥ 22.19，推荐 v24+
- Codex: Node ≥ 22

### URL 版本固定
- 所有安装命令从 `@main` 固定为 `@v3.0.3`，确保用户拿到的是已测试的稳定版

### CI / 检查增强
- 新增 Windows CI (`validate-windows` job)，验证所有 PowerShell 脚本语法、`-Help`、`-DryRun`
- 新增 CDN 冒烟测试 workflow (`release-smoke-test.yml`)，tag 后自动验证 6 个脚本的 CDN 可达性
- `check-scripts.sh` 新增 4 项检查：
  - 禁止 `npm config set registry`（应用 `--registry` 单次参数）
  - 禁止 `sudo npm install -g`
  - 禁止 `@main` 未版本化 URL
  - 官方 installer 引用检查

### 修复
- 修复 v3.0.2 tag 指向旧 commit（含已删除的 `scripts/mac-linux/` / `scripts/windows/` 目录）
- `scripts/lib/` 旧文件同步修复 `npm config set registry` 问题

---

## v3.0.2 (2026-05-30)

### 结构清理
- 删除遗留目录 `scripts/mac-linux/` 和 `scripts/windows/`
- 6 个自包含安装脚本均位于 `scripts/` 根目录

### 分发
- 所有脚本通过 jsDelivr CDN 分发

---

## v3.0.1 (2026-05-29)

### 脚本拆分
- 6 个独立安装脚本：每个 Agent × 每个平台各一个
- Bash 脚本（macOS/Linux）: `install-claude-code.sh`, `install-codex.sh`, `install-openclaw.sh`
- PowerShell 脚本（Windows）: `install-claude-code.ps1`, `install-codex.ps1`, `install-openclaw.ps1`
- 所有脚本自包含，无 `source scripts/lib` 依赖
- `--help`, `--dry-run`, `AGENT_INSTALL_YES=1` 全支持

### 商品化
- 重写 README 为闲鱼商品落地页
- 新增 `docs/guide.md` 零基础总教程
- 新增 `docs/agents/` 单 Agent 独立教程
- 新增 `xianyu-materials/` 闲鱼上架物料

---

## v2.0 (2026-05-28)

- 重写为零基础版，自动环境检测和安装
- 中文提示，新手友好

## v1.0 (2026-05-27)

- 初始版本，基础安装脚本
