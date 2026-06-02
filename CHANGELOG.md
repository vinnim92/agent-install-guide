# Changelog

## v3.0.9 (2026-06-02)

- 修复 Windows PowerShell 5.1 输出中文显示为 ??? 问题
- Windows ps1 脚本保存为 UTF-8 with BOM，新增 InputEncoding 设置
- support.html 新增 Windows PowerShell ??? 乱码 FAQ

---

## v3.0.8 (2026-06-01)

- 修复 Windows PowerShell 中 npm.ps1 执行策略拦截问题
- Windows ps1 脚本统一使用 Invoke-Npm（优先调用 npm.cmd，其次 npm.exe）
- Windows ps1 脚本新增 UTF-8 输出设置，修复中文乱码
- npm 安装失败时显示错误摘要（不再用 2>$null 吞掉全部输出）
- support.html 新增 npm.ps1 执行策略拦截 FAQ

---

## v3.0.7 (2026-05-30)

- 修复 PDF 长命令复制断行问题，新增 06-一键复制命令.txt
- macOS/Linux 交付命令默认使用 AGENT_INSTALL_YES=1 bash
- Bash confirm() 改为从 /dev/tty 读取，解决 curl | bash 读不到确认输入的问题
- 增强 OpenClaw npm install 失败诊断
- 新增 npm 缓存权限异常 EACCES / ~/.npm/_cacache 修复指引
- OpenClaw 默认 onboarding 改为 DeepSeek API Key
- OpenClaw support 增加 OpenAI Codex OAuth unsupported_region 排查
- 修正 OpenClaw "无需 API Key / 内置免费模型"误导文案

---

## v3.0.6 (2026-05-30)

### 修复: curl|bash 模式下无法读取确认输入
- Bash confirm() 改为从 /dev/tty 读取用户输入，解决管道 stdin 冲突
- 当 /dev/tty 不可用时，输出中文提示并引导使用 AGENT_INSTALL_YES=1
- --help 新增 curl|bash 推荐命令和手动确认模式说明

### 交付命令更新
- macOS/Linux 正式交付命令改为 `| AGENT_INSTALL_YES=1 bash`（自动确认模式）
- 3 份 PDF 手册同步更新交付命令和版本号
- 06-一键复制命令.txt 新增手动确认模式使用说明

### 故障排查
- support.html 新增"运行到确认步骤直接取消"FAQ

### 检查增强
- check-scripts.sh 新增 confirm() /dev/tty 检查
- 新增 help 包含 AGENT_INSTALL_YES=1 bash 推荐检查
- 新增 PDF/delivery 交付命令 AGENT_INSTALL_YES=1 检查
- 新增禁止裸 | bash 检查

---

## v3.0.5 (2026-05-30)

### Claude Code 定位调整
- Claude Code 改为 DeepSeek API 优先方案
- 安装脚本新增 DeepSeek API 配置引导（可选，不强制）
- PDF 手册不再第一步引导注册 Claude 官方账号
- PDF 标题更新为"Claude Code + DeepSeek API 小白安装手册"

### Codex 登录方式扩展
- Codex 新增 API Key 登录方式（保留官方账号登录）
- 安装脚本安装后增加登录方式选择
- PDF 手册新增 API Key 登录引导

### OpenClaw
- 版本号同步到 v3.0.5，内容无变更

### 检查增强
- check-scripts.sh 新增 12 项检查（DeepSeek API、Codex API Key、禁止第一步引导注册等）

### 故障排查
- support.html 新增 Claude Code DeepSeek API 配置 FAQ
- support.html 新增 Codex API Key 登录 FAQ

---

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
