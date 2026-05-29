# AI 编程助手 · 零基础安装指南

> 会复制粘贴就会装。三款最火 AI 编程助手，一行命令全部搞定。

[![Version](https://img.shields.io/badge/version-v3.0-blue)](https://github.com/vinnim92/agent-install-guide/releases)

---

## 这是什么？

一份给**完全不会电脑的人**准备的 AI 编程助手安装包。

你不需要懂命令行、不需要知道什么是 Node.js、不需要配置任何东西。你只需要：

1. 复制一行命令
2. 粘贴到黑窗口
3. 按回车
4. 等着完成

**包含三款最火的 AI 编程助手**：

| 助手 | 适合谁 | 安装指南 |
|------|--------|---------|
| 🧠 **Claude Code** | 追求最好体验的用户 | [→ 1 页安装指南](docs/agents/claude-code.md) |
| ⚡ **Codex** | ChatGPT Plus 会员 | [→ 1 页安装指南](docs/agents/codex.md) |
| 🦞 **OpenClaw** | 想用免费模型的用户 | [→ 1 页安装指南](docs/agents/openclaw.md) |

> 🆕 v3.0：每个 Agent 有独立的 1 页安装指南，选你需要的看。装好之后还推荐了能立刻用的 Skill。

---

## 一键安装（三个一起装）

### Mac 用户

打开"终端"（点右上角🔍搜索"终端"），粘贴下面这行，回车：

```bash
curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.sh | bash
```

### Windows 用户

按 `⊞ + R`，输入 `powershell`，粘贴下面这行，回车：

```powershell
iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/install.ps1 | iex
```

脚本会自动处理一切，你等着就行。5-10 分钟完成。

---

## 只装其中一个？

每个 Agent 有独立的 1 页安装指南（含 Skill 推荐）：

- [🧠 安装 Claude Code](docs/agents/claude-code.md) — 最聪明，装完推荐 PPT/Excel Skill
- [⚡ 安装 Codex](docs/agents/codex.md) — ChatGPT 用户首选
- [🦞 安装 OpenClaw](docs/agents/openclaw.md) — 有免费模型，不花钱

---

## 安装完成后

| AI 助手 | 启动命令 | 说明 |
|---------|---------|------|
| Claude Code | 终端输入 `claude` | 第一次会弹浏览器登录 |
| Codex | 终端输入 `codex` | 第一次会弹浏览器登录 |
| OpenClaw | 终端输入 `openclaw gateway start` | 浏览器访问 localhost:18789 |

---

## 装好之后能干什么？

AI 编程助手本身是"通用工具"。配上 **Skill 配置包**，它会变成某个领域的专家。闲鱼搜 **「AI Skill 工厂」**，看看已经有哪些 Skill：

- 🎨 **AI 一键做 PPT** — 说话就能出专业演示稿
- 📊 **AI 自动 Excel** — 报表周报一句话搞定
- 🛠 更多持续更新中

---

## 更新方法

再运行一次安装命令即可更新到最新版。

---

## 有问题？

- [常见问题排查](docs/troubleshooting.md) — 7 个常见问题手把手解决
- 截图发给卖家（闲鱼 24 小时内回复）
- 或提 [GitHub Issue](https://github.com/vinnim92/agent-install-guide/issues)
