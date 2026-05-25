# AI Coding Agent 全平台安装指南

> 三款主流 AI 编程助手 · 一键安装脚本 + PDF 手册

[![Version](https://img.shields.io/badge/version-v1.0.0-blue)](https://github.com/vinnim92/agent-install-guide/releases)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 这是什么？

一份面向**零基础用户**的 AI 编程助手安装指南，覆盖三款最主流的 AI Coding Agent：

| Agent | 开发商 | 特点 |
|-------|--------|------|
| **Claude Code** | Anthropic | 最省心，自带运行时，一行命令搞定 |
| **Codex CLI** | OpenAI | ChatGPT 深度用户首选 |
| **OpenClaw** 🦞 | 微软（开源） | 75+ 模型可选，有免费模型 |

支持 **Windows / macOS / Linux** 全平台。

---

## 一键安装

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.ps1 | iex
```

运行后选择要安装的 Agent，脚本自动完成环境检测、安装、验证。

---

## 包含内容

```
├── 📄 PDF 安装手册 (110页+)
│   ├── 三款 Agent × 三大平台 = 9 个安装场景
│   ├── 功能对比表 + 选型指南
│   ├── 故障排查手册（30+ 常见问题）
│   └── 国内网络优化指南
│
├── 🔧 一键安装脚本
│   ├── install.sh        → macOS / Linux
│   ├── install.ps1       → Windows PowerShell
│   └── lib/              → 各 Agent 安装模块
│
└── 🔄 持续更新
    └── Agent 版本更新 → 脚本 + PDF 同步更新
```

---

## 下载

前往 [Releases](https://github.com/vinnim92/agent-install-guide/releases) 页面下载最新版：

- `agent-install-guide-vX.X.X.zip` — PDF + 脚本完整包

---

## 项目结构

```
agent-install-guide/
├── scripts/
│   ├── install.sh              # macOS/Linux 统一入口
│   ├── install.ps1             # Windows PowerShell 入口
│   └── lib/
│       ├── utils.sh            # 公共函数库
│       ├── check-prereqs.sh    # 环境检测
│       ├── install-claude-code.sh
│       ├── install-codex.sh
│       └── install-openclaw.sh
├── docs/
│   ├── guide.md                # PDF 源文件
│   └── troubleshooting.md      # 故障排查
├── xianyu-materials/
│   ├── description.md          # 闲鱼商品描述
│   └── title-candidates.txt    # 标题候选
└── .github/workflows/
    └── release.yml             # 自动构建 PDF + Release
```

---

## 本地开发

```bash
git clone https://github.com/vinnim92/agent-install-guide.git
cd agent-install-guide

# 测试脚本
bash scripts/install.sh           # 互动菜单
bash scripts/install.sh claude    # 直接安装 Claude Code
bash scripts/install.sh codex     # 直接安装 Codex
bash scripts/install.sh openclaw  # 直接安装 OpenClaw

# 生成 PDF（需安装 pandoc）
brew install pandoc
pandoc docs/guide.md -o guide.pdf --pdf-engine=xelatex
```

---

## License

MIT © 2026

---

## 闲鱼商品页

本仓库关联闲鱼商品：**[AI 编程助手全平台安装指南](https://github.com/vinnim92/agent-install-guide)**
