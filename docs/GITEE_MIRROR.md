# Gitee 国内镜像搭建指南

本指南帮助你在 Gitee 上创建 agent-install-guide 的国内镜像，解决中国大陆用户无法稳定访问 GitHub Pages / jsDelivr 的问题。

## 第一步：注册 Gitee 账号

1. 打开 https://gitee.com
2. 使用手机号或邮箱注册
3. 记下你的 Gitee 用户名（例如 `myname`）

## 第二步：创建镜像仓库

1. 登录 Gitee 后，点击右上角 "+" → "新建仓库"
2. 仓库名称填：`agent-install-guide`
3. 仓库类型选"公开"
4. 不要勾选"使用 Readme 文件初始化仓库"
5. 点击"创建"

## 第三步：推送代码到 Gitee

在终端中执行以下命令（替换 `<你的Gitee账号>` 和 `<你的Gitee密码或Token>`）：

```bash
# 克隆 GitHub 仓库
git clone git@github.com:vinnim92/agent-install-guide.git
cd agent-install-guide

# 添加 Gitee 远程仓库
git remote add gitee https://gitee.com/<你的Gitee账号>/agent-install-guide.git

# 推送到 Gitee
git push gitee main
```

也可以使用 Gitee 的"从 GitHub 导入"功能：
1. 创建仓库时选择"导入已有仓库"
2. 填入 GitHub 仓库地址：https://github.com/vinnim92/agent-install-guide
3. 点击"导入"

## 第四步：验证镜像可用

在 Windows PowerShell 中测试：

```powershell
$env:GITEE_ACCOUNT="<你的Gitee账号>"
irm https://gitee.com/<你的Gitee账号>/agent-install-guide/raw/main/docs/i/codex.ps1 | iex
```

如果能正常进入安装流程，说明镜像可用。

## 第五步：配置环境变量

### Windows PowerShell（当前窗口）

```powershell
$env:GITEE_ACCOUNT="<你的Gitee账号>"
```

### Windows（永久）

在"系统属性 → 环境变量"中添加用户变量 `GITEE_ACCOUNT`，值为你的 Gitee 账号。

### macOS / Linux（当前会话）

```bash
export GITEE_ACCOUNT="<你的Gitee账号>"
```

### macOS / Linux（永久）

在 `~/.zshrc` 或 `~/.bashrc` 末尾添加：

```bash
export GITEE_ACCOUNT="<你的Gitee账号>"
```

## 第六步：分发

设置好环境变量的用户，使用以下命令即可自动走 Gitee 国内镜像：

**Windows PowerShell：**

```powershell
irm https://vinnim92.github.io/agent-install-guide/i/codex.ps1 | iex
```

**macOS / Linux：**

```bash
curl -fsSL https://vinnim92.github.io/agent-install-guide/i/codex.sh | bash
```

入口 URL 不变，脚本检测到 `GITEE_ACCOUNT` 环境变量后会自动优先走 Gitee。

## 技术细节

### 三维 fallback 机制

v3.1.2 的入口脚本支持三层下载源：

1. **Gitee 国内镜像**（需要设置 `GITEE_ACCOUNT`）：从 Gitee raw 下载
2. **jsDelivr CDN**：从 jsDelivr 下载
3. **GitHub raw**：直接从 GitHub 下载

脚本按顺序尝试，任一成功即停止，全部失败才报错。

### 何时需要 Gitee 镜像

- 中国大陆用户，访问 GitHub Pages 不稳定或无法访问
- jsDelivr CDN 返回 "Failed to fetch from GitHub"
- 安装命令报 "基础连接已经关闭" 错误

### 何时不需要

- 海外用户，可以直接访问 GitHub Pages 和 jsDelivr
- 已配置代理或 VPN 的用户

## 故障排查

**Q: Gitee raw 返回 404？**
A: 检查仓库名是否为 `agent-install-guide`，分支名是否为 `main`。

**Q: Gitee 推送被拒绝？**
A: 检查是否在创建仓库时勾选了"初始化仓库"。如果有初始提交，需要先 `git pull gitee main --allow-unrelated-histories`。

**Q: 如何保持镜像同步？**
A: 每次 GitHub 有新版本后，重新推送：
```bash
git fetch origin
git push gitee main
```
