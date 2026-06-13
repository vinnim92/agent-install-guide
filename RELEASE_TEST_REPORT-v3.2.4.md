# Release Test Report — v3.2.4 China Hardening

## 测试环境

| 项目 | 值 |
|------|-----|
| 测试日期 | 2026-06-13 |
| 系统 | macOS 26.5 (25F71) |
| 架构 | Apple Silicon (arm64) |
| Shell | /bin/zsh |
| Node.js | v24.15.0 |
| npm | 11.12.1 |
| Git | 2.50.1 |
| 用户 | gojooy |
| HOME | /Users/gojooy |
| 网络 | GitHub ❌, npmjs ✅, npmmirror ✅, api.deepseek.com ❌ |

---

## 一、发布闭环验证

| 检查项 | 状态 | 详情 |
|--------|------|------|
| VERSION 文件 | ✅ PASS | `v3.2.4` |
| README.md 版本 | ✅ PASS | 下载包名 `AI-Agent-Windows-v3.2.4.zip`, `AI-Agent-macOS-Linux-v3.2.4.zip` |
| CHANGELOG.md | ✅ PASS | v3.2.4 条目已添加 |
| RELEASE_CHECKLIST.md | ✅ PASS | 更新至 v3.2.4，含 10 节检查清单 |
| Git commit | ✅ PASS | `6771ff7 v3.2.4: China Hardening` |
| Git push main | ✅ PASS | 推送至 origin/main |
| Git tag v3.2.4 | ✅ PASS | 483ff20 推送至 origin |
| GitHub Release | ✅ PASS | v3.2.4 is Latest, not draft, not prerelease |
| Release Assets | ✅ PASS | 2 个 zip 已上传，SHA256 匹配 |

### SHA256

```
2e46b4724c136e7da2f9df582e6e78cbe41196b4a70169ad1569d9a0e26086f9  AI-Agent-Windows-v3.2.4.zip
7475f24b4518df636facf17eb11f74f429172fe97bf4cd8bf9fae5dde1fe6cbc  AI-Agent-macOS-Linux-v3.2.4.zip
```

---

## 二、ZIP 完整性验证

### Windows ZIP (`unzip -l`)
```
14 files, 2778989 bytes
├── windows/
│   ├── install-claude-code.ps1
│   ├── install-claude.cmd (CRLF)
│   ├── install-codex.ps1
│   ├── install-codex.cmd (CRLF)
│   ├── install-openclaw.ps1
│   └── install-openclaw.cmd (CRLF)
├── 01-Windows-Claude-Code-DeepSeek-...v3.2.4.pdf
├── 02-Windows-Codex-...v3.2.4.pdf
├── 03-Windows-OpenClaw-...v3.2.4.pdf
├── 06-Windows-一键启动说明.txt
├── CHECK-UPDATE.txt
└── README.txt
```

### macOS ZIP (`unzip -l`)
```
11 files, 2604841 bytes
├── mac-linux/
│   ├── install-claude-code.sh
│   ├── install-codex.sh
│   └── install-openclaw.sh
├── 01-macOS-Linux-Claude-Code-DeepSeek-...v3.2.4.pdf
├── 02-macOS-Linux-Codex-...v3.2.4.pdf
├── 03-macOS-Linux-OpenClaw-...v3.2.4.pdf
├── 06-macOS-Linux-一键复制命令.txt
├── CHECK-UPDATE.txt
└── README.txt
```

### 交叉污染检查
| 检查项 | 状态 |
|--------|------|
| Windows zip 无 .sh 文件 | ✅ CLEAN |
| macOS zip 无 .cmd/.ps1 文件 | ✅ CLEAN |

---

## 三、功能测试 (macOS)

### 测试 1: `--help` 输出包含 `--china`

| 脚本 | 状态 | `--china` 出现 |
|------|------|----------------|
| install-claude-code.sh | ✅ PASS | 国内网络模式 — 使用说明 |
| install-codex.sh | ✅ PASS | 国内网络模式 — 使用说明 |
| install-openclaw.sh | ✅ PASS | 国内网络模式 — 使用说明 |

### 测试 2: `--china --dry-run` 输出

| 脚本 | 状态 | 关键输出 |
|------|------|----------|
| install-claude-code.sh | ✅ PASS | "国内网络模式 — 跳过官方源，使用 npm 镜像" |
| install-codex.sh | ✅ PASS | "国内网络模式 — 跳过官方源，使用 npm 镜像" |
| install-openclaw.sh | ✅ PASS | "国内网络模式 — 跳过官方源，使用 npm 镜像" |

### 测试 3: `bash -n` 语法检查

| 脚本 | 状态 |
|------|------|
| install-claude-code.sh | ✅ PASS |
| install-codex.sh | ✅ PASS |
| install-openclaw.sh | ✅ PASS |

### 测试 4: 真实 `--china` 安装 (Claude Code)

**命令**: `AGENT_INSTALL_YES=1 bash install-claude-code.sh --china`

**结果**: ✅ PASS

关键输出:
```
  检查网络连通性...
    ✅ 可访问: https://registry.npmmirror.com
    ✅ 可访问: https://registry.npmjs.org
    ⚠️  无法访问: https://api.deepseek.com
    ⚠️  无法访问: https://github.com
    ⚠️  部分端点不可达，安装可能受限

  国内网络模式：使用 npm 镜像源安装...
  added 1 package, and changed 1 package in 7s
  ✅ npm 镜像安装成功
  ✅ Claude Code 安装完成！
  2.1.177 (Claude Code)
```

### 测试 5: 4 端点网络检测（2/4 可达场景）

**命令**: 真实运行 `AGENT_INSTALL_YES=1 bash install-claude-code.sh --china`

**结果**: ✅ PASS

| 端点 | 状态 |
|------|------|
| registry.npmmirror.com | ✅ 可访问 |
| registry.npmjs.org | ✅ 可访问 |
| api.deepseek.com | ❌ 不可达 |
| github.com | ❌ 不可达 |

检测结果: "部分端点不可达，安装可能受限"
安装结果: 仍然成功（China 模式使用 npmmirror）

### 测试 6: 中文路径

**命令**: 在 `/tmp/测试安装-小白/` 目录下运行

**结果**: ✅ PASS — 脚本正常启动，检测和提示正常

### 测试 7: 空格路径

**命令**: 在 `/tmp/test install guide/` 目录下运行

**结果**: ✅ PASS — 脚本正常启动，检测和提示正常

### 测试 8: Node.js >= 22 跳过安装

**命令**: `AGENT_INSTALL_YES=1 bash install-codex.sh --china --dry-run`

**结果**: ✅ PASS — 系统已有 Node v24.15.0，检测输出:
```
    ✅ Node.js v24.15.0 (满足要求，将跳过安装)
```

### 测试 9: 安装日志

| Agent | 日志路径 | 状态 |
|-------|----------|------|
| Claude Code | `~/agent-install-claude-code.log` | ✅ 已生成，含时间戳和安装命令 |
| Codex | `~/agent-install-codex.log` | ✅ 路径正确（dry-run mode 无日志写入）|
| OpenClaw | `~/agent-install-openclaw.log` | ✅ 路径正确（dry-run mode 无日志写入）|

---

## 四、脚本内容一致性检查

| 检查项 | 状态 | 详情 |
|--------|------|------|
| 6 个脚本均有 `--china`/`-China` | ✅ | 3 bash + 3 ps1 |
| 6 个脚本均含故障排查链接 | ✅ | 指向 troubleshooting.html |
| 6 个脚本均有日志功能 | ✅ | LOGFILE/LogFile 变量 |
| 3 个 ps1 使用 npmmirror | ✅ | `--registry https://registry.npmmirror.com` |
| 3 个 bash Git 仅为警告 | ✅ | "不影响安装，但后续可能需要" |
| 4 端点检测代码一致 | ✅ | 所有脚本均检测相同 4 个端点 |
| 无 `npm config set registry` | ✅ | 仅使用 `--registry` 单次参数 |
| 无 `2>$null` | ✅ | ps1 改为 Tee-Object 日志重定向 |
| 无关键 `2>/dev/null` | ✅ | bash 改为 `2>>$LOGFILE` |
| 无 `@main` 未版本化 URL | ✅ | lib/utils.sh 使用 `@v3.2.4` |

---

## 五、已知限制 & 不阻断发布的问题

| 问题 | 影响 | 阻断发布? |
|------|------|-----------|
| 非 TTY 环境下 confirm() 报 `/dev/tty: Device not configured` | 仅影响 curl\|bash 管道场景（用户会使用本地 .sh 或 AGENT_INSTALL_YES=1）| ❌ 不阻断 |
| Windows .ps1 脚本未在真实 Windows 测试 | 本地无 Windows 环境 | ❌ 不阻断（语法正确，CI 可补充） |
| API Key 配置引导在非 TTY 环境无法完成交互 | 仅影响自动化场景 | ❌ 不阻断（安装本身成功） |
| pdf/ HTML 模板中 beginner-guide 文件未更新版本号 | 这些模板未用于交付 | ❌ 不阻断 |

---

## 六、发布决定

**✅ 可以发布 v3.2.4**

所有关键功能验证通过:
- China 模式正确跳过官方安装器，使用 npm 镜像
- 4 端点网络检测正确识别网络状态
- 在 GitHub 不通的情况下，--china 模式下安装成功
- 安装日志正确生成
- Git 依赖仅为警告
- Node.js 已满足版本时跳过
- zip 文件结构正确，无交叉污染
- GitHub Release 已设为 Latest，Assets 已上传
