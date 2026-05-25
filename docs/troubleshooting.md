# Agent 安装指南 · 常见问题排查

## 网络问题

### GitHub 访问慢 / 连不上

**现象**：安装脚本卡住、curl/wget 超时。

**解决方案**：

| 系统 | 操作 |
|------|------|
| **通用** | 开全局代理/VPN |
| **通用** | 换手机热点试试 |
| **国内 Windows** | 使用镜像: `iwr -useb https://clawd.org.cn/install.ps1 \| iex` |
| **国内 npm** | `npm config set registry https://registry.npmmirror.com` |

### npm 安装时报 EACCES 权限错误

```bash
# 方法一：设置全局路径
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc
source ~/.zshrc

# 方法二：修改目录权限（不推荐）
sudo chown -R $(whoami) /usr/local/lib/node_modules
```

---

## 安装后找不到命令

### `claude: command not found`

```bash
# Claude Code 安装在:
# macOS/Linux:  ~/.local/bin/claude
# Windows:       %USERPROFILE%\.local\bin\claude.exe

# 修复:
export PATH="$HOME/.local/bin:$PATH"    # 临时
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc  # 永久(macOS)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # 永久(Linux)
```

### `codex: command not found`

```bash
# 检查 npm 全局路径
npm prefix -g
# 应该显示类似 /usr/local 或 ~/.npm-global

# 将 npm 全局 bin 加入 PATH:
export PATH="$(npm prefix -g)/bin:$PATH"
```

### `openclaw: command not found`

```bash
# 同上，检查 npm 前缀
npm prefix -g
export PATH="$(npm prefix -g)/bin:$PATH"
```

---

## Claude Code 常见问题

### macOS 安装后提示"无法验证开发者"

**解决**：系统偏好设置 → 安全性与隐私 → 通用 → 点击"仍要打开"。

### WSL2 中 OAuth 浏览器打不开

```bash
# 指定 Windows 浏览器路径
export BROWSER="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
# 或按 c 键复制 URL，手动粘贴到浏览器
```

### Alpine Linux 报错

```bash
apk add libgcc libstdc++ ripgrep
# 然后重试安装
```

---

## Codex 常见问题

### `node -v` 版本低于 22

```bash
# 使用 nvm 升级（推荐）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc  # 或 ~/.zshrc
nvm install 22
nvm use 22
nvm alias default 22

# 验证
node -v  # 应显示 v22.x.x
```

### Windows 原生沙盒报权限错误

- 以管理员身份运行 PowerShell
- 或改用 WSL2（强烈推荐）

### WSL2 中 `/mnt/c/` 下项目运行慢

**原因**：跨文件系统 IO 性能差。

**解决**：把项目移到 Linux 文件系统：
```bash
mkdir -p ~/code
cd ~/code
# 把项目克隆到这里，不要放 /mnt/c/ 下
```

---

## OpenClaw 常见问题

### Node.js 版本不兼容

OpenClaw 需要 Node.js >= 22（推荐 v24 LTS）。升级方法同上 Codex 章节。

### Linux 编译失败

Ubuntu/Debian 缺少编译工具链：
```bash
sudo apt update
sudo apt install -y gcc g++ make python3-venv libssl-dev
```

### Gateway 启动失败

```bash
# 检查端口是否被占用
lsof -i :18789

# 强制重启
openclaw gateway stop
openclaw gateway start

# 查看日志
openclaw gateway logs
```

### 首次启动没有模型

OpenClaw 支持 75+ 提供商。无需 API Key 也有免费模型可用：
```bash
openclaw config set gateway.mode local
openclaw gateway start
# 访问 http://localhost:18789 在 Web 控制台选择免费模型
```

---

## 卸载方法

### Claude Code
```bash
# macOS (Homebrew)
brew uninstall --cask claude-code

# macOS/Linux (官方安装)
rm -rf ~/.local/bin/claude ~/.claude/
```

### Codex
```bash
npm uninstall -g @openai/codex
rm -rf ~/.codex/
```

### OpenClaw
```bash
npm uninstall -g opencode-ai
# 或 (macOS)
brew uninstall opencode
# 清理
openclaw gateway uninstall
rm -rf ~/.openclaw
```

---

## 通用排查步骤

如果以上方法都无法解决，按以下顺序排查：

1. **重启终端** — 很多问题重启就能解决
2. **检查 PATH** — `echo $PATH`，确认安装目录在路径中
3. **检查权限** — `ls -la ~/.local/bin/` 看文件是否存在
4. **查看系统日志** — macOS: `Console.app`，Linux: `journalctl`
5. **提 Issue** — https://github.com/vinnim92/agent-install-guide/issues
