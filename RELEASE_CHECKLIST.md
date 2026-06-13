# Release Checklist

发布前逐项确认，全部通过后方可打 tag。

---

## 一、脚本层

- [ ] 6 个安装脚本语法检查通过 (`bash -n` / PowerShell parser)
- [ ] `bash scripts/check-scripts.sh` 全部 PASS
- [ ] 所有 bash 脚本 `--help` 正常输出（含 `--china` 用法）
- [ ] 所有 bash 脚本 `--dry-run` 正常预览
- [ ] 所有 bash 脚本 `--china` + `--dry-run` 正常预览
- [ ] 所有 PowerShell 脚本 `-Help` 正常输出（含 `-China` 用法）
- [ ] 所有 PowerShell 脚本 `-DryRun` 正常预览
- [ ] 所有 PowerShell 脚本 `-China` + `-DryRun` 正常预览
- [ ] 官方 installer 为第一优先级（非 China 模式下）
- [ ] 普通模式：3-tier auto-fallback（官方 → npm 官方源 → npmmirror）
- [ ] China 模式：强制 npmmirror（跳过官方安装器 + npm 官方源探测）
- [ ] 所有 npm 安装使用 `--registry` 单次参数（非全局设置）
- [ ] 无 `npm config set registry`
- [ ] 无 `sudo npm install -g`
- [ ] 无 `@main` 未版本化 URL
- [ ] 网络探测 5 个端点（官方域名, npmjs.org, npmmirror.com, api.deepseek.com, github.com）
- [ ] Windows: 3 个 .cmd 文件（仅普通入口，China 为 PS1 内部参数）均为 ASCII-only + CRLF
- [ ] Git 依赖仅警告，不 `exit 1`
- [ ] Node.js 安装引导优先推荐手动下载 MSI/pkg（含 SHA256 校验提示）
- [ ] Node.js 已满足版本要求时跳过安装
- [ ] 安装日志写入 `%TEMP%/~/agent-install-{agent}.log`
- [ ] 无 `2>$null` / `2>/dev/null` 吞错（改为日志重定向）
- [ ] 所有故障排查链接指向 `troubleshooting.html`（非 `docs/support.html`）

## 二、文档层

- [ ] README.md 版本号为 v3.2.6
- [ ] README.md 包含国内用户 `--china` / `-China` 提示
- [ ] troubleshooting.html 命令为一行一条（非多行合并）
- [ ] troubleshooting.html 包含 `--china` 网络模式说明
- [ ] troubleshooting.html 链接已统一为 `troubleshooting.html`
- [ ] `docs/i/` 入口文件正常

## 三、CI 层

- [ ] `.github/workflows/test-install.yml` 覆盖 Linux + Windows
- [ ] `.github/workflows/release-smoke-test.yml` 存在且正确
- [ ] `.github/workflows/release.yml` 安装命令指向当前版本 tag

## 四、版本文件

- [ ] `VERSION` 文件内容为 `v3.2.6`
- [ ] `CHANGELOG.md` 已更新 v3.2.6 条目
- [ ] `scripts/lib/utils.sh` RAW_BASE 为 `@v3.2.6`
- [ ] 版本号遵循 semver（vX.Y.Z）

## 五、交付物检查

- [ ] `dist/delivery/AI-Agent-Windows-v3.2.6/` 目录存在且完整
- [ ] `dist/delivery/AI-Agent-macOS-Linux-v3.2.6/` 目录存在且完整
- [ ] Windows zip：无 .sh 文件
- [ ] macOS zip：无 .cmd / .ps1 文件
- [ ] Windows .cmd 文件为 ASCII-only + CRLF 换行
- [ ] 中文文件名已替换（README.txt, CHECK-UPDATE.txt）
- [ ] 3 份 PDF 手册均为 v3.2.6 版本

## 六、Git 操作

- [ ] `git status` 无意外未提交文件
- [ ] 所有修改已 commit
- [ ] `git push origin main` 推送成功
- [ ] tag 不存在于远程

## 七、Tag 创建

```bash
VERSION=$(cat VERSION)
git tag -a "${VERSION}" -m "v3.2.6: Emergency Fix — unified entrypoints, PS1 fixes"
git push origin "${VERSION}"
```

- [ ] tag 创建在最新 commit 上
- [ ] tag push 成功

## 八、CDN 验证（tag 后）

- [ ] jsDelivr 刷新: `https://purge.jsdelivr.net/gh/vinnim92/agent-install-guide@v3.2.6/scripts/install-claude-code.sh`
- [ ] 6 个安装脚本 CDN 可达（HTTP 200）
- [ ] CDN 冒烟测试 workflow 通过

## 九、功能测试（macOS）

- [ ] `bash install-claude-code.sh --china --dry-run` 正常输出
- [ ] `bash install-codex.sh --china --dry-run` 正常输出
- [ ] `bash install-openclaw.sh --china --dry-run` 正常输出
- [ ] `bash install-claude-code.sh --dry-run` 显示 3-tier auto-fallback 预览
- [ ] `bash install-codex.sh --dry-run` 显示 3-tier auto-fallback 预览
- [ ] `bash install-openclaw.sh --dry-run` 显示 3-tier auto-fallback 预览
- [ ] `bash install-codex.sh --china` 正常安装 Codex（强制镜像）
- [ ] `AGENT_INSTALL_YES=1 bash install-codex.sh --china` 自动确认安装
- [ ] 普通模式下网络不通时自动 fallback 到下一路径
- [ ] 安装日志记录：mode, 5 endpoints, install path, Node/npm versions, install cmd, errors, result
- [ ] `--help` 输出包含普通模式和 `--china` 模式说明
- [ ] Node.js >= 22 时跳过安装

## 十、商品上架

- [ ] 闲鱼标题选定
- [ ] 闲鱼描述更新
- [ ] 闲鱼封面图版本号已更新

---

## 当前版本: v3.2.6
