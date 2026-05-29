# 🦞 安装 OpenClaw

> **微软开源 · 有免费模型随便用 · 1 条命令 · 5 分钟搞定**

---

## 你需要准备

| # | 东西 | 说明 |
|---|------|------|
| 1 | 电脑 | Mac 或 Windows 都行 |
| 2 | 网络 | 能上网就行 |
| 3 | 手 | 会复制粘贴 |

**就这些。不需要懂任何技术。免费模型不用花一分钱。**

---

## 安装（复制 → 粘贴 → 回车）

### Mac 用户

打开「终端」（右上角🔍搜索"终端"），粘贴下面这行，按回车：

```bash
curl -fsSL https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/mac-linux/install-openclaw.sh | bash
```

### Windows 用户

按 `⊞ + R`，输入 `powershell`，粘贴下面这行，按回车：

```powershell
iwr -useb https://raw.githubusercontent.com/vinnim92/agent-install-guide/main/scripts/windows/install-openclaw.ps1 | iex
```

> ⏳ **等 3-5 分钟**。屏幕上会滚动文字——这是脚本在自动工作。
> 你什么都不用操作。看到 `✅` 就是装好了。

---

## 开始使用

打开终端，输入：

```
openclaw gateway start
```

保持终端窗口开着。然后打开浏览器，访问：

```
http://localhost:18789
```

在网页上选择你想用的 AI 模型（自带免费模型），开始对话。

> 💬 不用花一分钱，就能体验 AI 编程助手。觉得好用再考虑升级付费模型。

---

---

## 💡 装好之后，试试这些

OpenClaw 支持 75+ 种 AI 模型，包括免费的。配上 Skill 配置包，能干更多事。

| 🦞 免费模型配置包 | 🎨 AI 一键做 PPT |
|---|---|
| 国内可用免费模型一键配置 | "帮我做一份杂志风 PPT" |
| 不用翻墙、不用付费 | HTML 网页版 + PPTX 可编辑版 |
| **即将上线** | **闲鱼搜：AI PPT Skill** |

| 📊 AI 自动 Excel 报表 | 🛠 更多 Skill 合集 |
|---|---|
| "帮我把数据做成周报" | 持续更新中 |
| 自动生成图表 + 分析 | 满足不同场景需求 |
| **闲鱼搜：Excel 自动化 Skill** | **闲鱼搜：AI Skill 工厂** |

> 📩 **闲鱼搜「AI Skill 工厂」** → 查看全部可用 Skill，大部分兼容 OpenClaw。

---

## ❓ 常见问题

**Q: 输入 `openclaw` 后提示"找不到命令"？**
→ 关掉终端窗口，重新打开，再试一次。

**Q: 安装过程中网络错误？**
→ 断开当前 WiFi，换手机热点，重试。

**Q: 免费模型够用吗？**
→ 日常写代码、写文档完全够用。复杂项目建议用付费模型（Claude、GPT 等）。

**Q: 怎么更新到最新版？**
→ 重新运行一遍上面的安装命令即可，自动覆盖升级。

**Q: 怎么卸载？**
→ Mac：`brew uninstall opencode` 或 `npm uninstall -g opencode-ai`
→ Windows：`winget uninstall SST.opencode` 或 `npm uninstall -g opencode-ai`

**Q: 其他问题？**
→ 截图发闲鱼卖家，24 小时内回复。
→ 或提 GitHub Issue：https://github.com/vinnim92/agent-install-guide/issues

---

> 📖 **版本：v3.0 ｜ 会复制粘贴就会装 ｜ 永远保持更新**
