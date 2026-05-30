# Release Checklist

发布前逐项确认，全部通过后方可打 tag。

---

## 一、脚本层

- [ ] 6 个入口脚本语法检查通过 (`bash -n` / PowerShell parser)
- [ ] `bash scripts/check-scripts.sh` 全部 PASS
- [ ] 所有 bash 脚本 `--help` 正常输出
- [ ] 所有 bash 脚本 `--dry-run` 正常预览
- [ ] 所有 PowerShell 脚本 `-Help` 正常输出
- [ ] 所有 PowerShell 脚本 `-DryRun` 正常预览
- [ ] 官方 installer 为第一优先级（not npm）
- [ ] 无 `npm config set registry`（使用 `--registry` 单次参数）
- [ ] 无 `sudo npm install -g`
- [ ] 无 `@main` 未版本化 URL（全部固定为 `@vX.Y.Z`）

## 二、文档层

- [ ] README.md 安装命令指向当前版本 tag
- [ ] `docs/guide.md` 安装命令指向当前版本 tag
- [ ] `docs/agents/*.md` 安装命令指向当前版本 tag
- [ ] `docs/*.html` 安装命令指向当前版本 tag
- [ ] `xianyu-materials/` 版本号已更新

## 三、CI 层

- [ ] `.github/workflows/test-install.yml` 覆盖 Linux + Windows
- [ ] `.github/workflows/release-smoke-test.yml` 存在且正确
- [ ] `.github/workflows/release.yml` 安装命令指向当前版本 tag

## 四、版本文件

- [ ] `VERSION` 文件内容为当前版本号
- [ ] `CHANGELOG.md` 已更新当前版本条目
- [ ] 版本号遵循 semver（vX.Y.Z）

## 五、Git 操作

- [ ] `git status` 无意外未提交文件
- [ ] 所有修改已 commit（`git log` 确认）
- [ ] `git push origin main` 推送成功
- [ ] tag 不存在于远程（`git ls-remote --tags origin` 确认）

## 六、Tag 创建

```bash
VERSION=$(cat VERSION)
git tag -a "${VERSION}" -m "${VERSION}: <简要描述>"
git push origin "${VERSION}"
```

- [ ] tag 创建在最新 commit 上
- [ ] tag push 成功

## 七、CDN 验证（tag 后）

- [ ] jsDelivr 刷新: `https://purge.jsdelivr.net/gh/vinnim92/agent-install-guide@${VERSION}/scripts/install-claude-code.sh`
- [ ] 6 个 bash 脚本 `curl -fsSL <CDN URL> | bash -s -- --help` 正常
- [ ] 6 个 PowerShell 脚本 CDN 可达（HTTP 200）
- [ ] CDN 冒烟测试 workflow 通过

## 八、商品上架

- [ ] 闲鱼标题从 `title-candidates.txt` 中选定
- [ ] 闲鱼描述更新为最新 `description.md`
- [ ] 闲鱼封面图版本号已更新
- [ ] 安装命令在商品描述中正确显示

---

## 当前版本: v3.0.4
