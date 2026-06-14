# Release Test Report — v3.2.6 Emergency Fix

> **2026-06-14 更新**: Windows 真机测试通过。详见第 10 节。

## Test Environment

| Item | Value |
|------|-------|
| macOS Date | 2026-06-13 |
| Windows Date | 2026-06-14 |
| Date | 2026-06-13 |
| System | macOS 26.5 (25F71) |
| Arch | Apple Silicon (arm64) |
| Shell | /bin/zsh |
| Node.js | v24.15.0 |
| npm | 11.12.1 |
| pwsh | Not available (download timed out) |

---

## 1. Release Closure Verification

| Check | Status | Details |
|-------|--------|---------|
| VERSION file | PASS | `v3.2.6` |
| README.md version | PASS | Download package names `AI-Agent-Windows-v3.2.6.zip`, `AI-Agent-macOS-Linux-v3.2.6.zip` |
| CHANGELOG.md | PASS | v3.2.6 entry added |
| RELEASE_CHECKLIST.md | PASS | Updated to v3.2.6 |
| scripts/lib/utils.sh RAW_BASE | PASS | `@v3.2.6` |

---

## 2. Script Syntax Checks

| Script | Status |
|--------|--------|
| install-claude-code.sh | bash -n PASS |
| install-codex.sh | bash -n PASS |
| install-openclaw.sh | bash -n PASS |
| install-claude-code.ps1 | Python validator PASS |
| install-codex.ps1 | Python validator PASS |
| install-openclaw.ps1 | Python validator PASS |

### PS1 Validation Details (Python)

| Check | claude-code | codex | openclaw |
|-------|-------------|-------|----------|
| UTF-8 BOM | Yes | Yes | Yes |
| Balanced braces | 0 | 0 | 0 |
| Balanced parens | 0 | 0 | 0 |
| Unclosed strings | None | None | None |
| U+FFFD replacement chars | 0 | 0 | 0 |
| Backtick-$ in subexpr | 0 | 0 | 0 |
| try/catch balance | 7/7 | 6/6 | 9/9 |
| if/else blocks | 46/14 | 54/24 | 60/27 |
| function count | 10 | 11 | 11 |

---

## 3. --help / -Help Tests

| Script | Mode mention |
|--------|-------------|
| install-claude-code.sh | "普通模式（官方→npm→镜像 自动 fallback）" + "--china" |
| install-codex.sh | "普通模式（官方→npm→镜像 自动 fallback）" + "--china" |
| install-openclaw.sh | "普通模式（官方→npm→镜像 自动 fallback）" + "--china" |

---

## 4. Entry Unification Verification

| Check | Status |
|-------|--------|
| windows/ has 3 .cmd (not 6) | PASS |
| No install-xxx-china.cmd in windows/ | PASS |
| No install-xxx-china.cmd in ZIP | PASS |
| install-claude.cmd calls install-claude-code.ps1 | PASS |
| install-codex.cmd calls install-codex.ps1 | PASS |
| install-openclaw.cmd calls install-openclaw.ps1 | PASS |
| mac-linux/ has 3 .sh (not more) | PASS |

---

## 5. .cmd Verification

| Check | Status |
|-------|--------|
| install-claude.cmd CRLF | PASS |
| install-codex.cmd CRLF | PASS |
| install-openclaw.cmd CRLF | PASS |
| All ASCII-only | PASS |
| All multi-line (not single-line) | PASS |

---

## 6. ZIP Integrity

### Windows ZIP (`unzip -l`)
```
16 files
├── windows/
│   ├── install-claude-code.ps1
│   ├── install-codex.ps1
│   ├── install-openclaw.ps1
│   ├── install-claude.cmd
│   ├── install-codex.cmd
│   └── install-openclaw.cmd
├── 01-Windows-Claude-Code-...-v3.2.6.pdf
├── 02-Windows-Codex-...-v3.2.6.pdf
├── 03-Windows-OpenClaw-...-v3.2.6.pdf
├── 06-Windows-一键启动说明.txt
├── CHECK-UPDATE.txt
└── README.txt
```

### macOS ZIP (`unzip -l`)
```
10 files
├── mac-linux/
│   ├── install-claude-code.sh
│   ├── install-codex.sh
│   └── install-openclaw.sh
├── 01-macOS-Linux-Claude-Code-...-v3.2.6.pdf
├── 02-macOS-Linux-Codex-...-v3.2.6.pdf
├── 03-macOS-Linux-OpenClaw-...-v3.2.6.pdf
├── 06-macOS-Linux-一键复制命令.txt
├── CHECK-UPDATE.txt
└── README.txt
```

### Cross-Contamination
| Check | Status |
|-------|--------|
| Windows zip has 0 .sh files | PASS |
| macOS zip has 0 .cmd/.ps1 files | PASS |
| Windows zip has 0 *china* files | PASS |
| Windows zip has 3 .cmd (not 6) | PASS |

---

## 7. Fixes Applied

| Issue | Fix |
|-------|-----|
| Separate China .cmd launchers confuse beginners | Deleted 3 china.cmd files; China is now PS1/bash parameter only |
| Backtick-escaped `$null` in codex.ps1/openclaw.ps1 | Changed to `2>$null` (removed backtick) |
| Missing UTF-8 BOM on PS1 files | Added BOM to all 3 PS1 files for PS 5.1 compatibility |
| VERSION/references outdated | All bumped to v3.2.6 |

---

## 8. SHA256 (updated 2026-06-14 — PDF slimmed, ZIPs rebuilt)

```
c7cadde42a1814b371ef88383e70516dd883b597aea702def6ee48e4a800157d  AI-Agent-Windows-v3.2.6.zip
bd9bbcbf37bdc914d0609adf01c0968a74365c71eaab751074014ad02bceaa94  AI-Agent-macOS-Linux-v3.2.6.zip
```

---

## 8b. PDF Content Audit (2026-06-14)

All 12 forbidden keywords verified absent from 6 PDF HTML templates:
- 本版为什么更稳定, 更稳定, 更可靠, 版本演进, 相比上一版, 修复了
- v3.2.4, v3.2.3
- China 版, install-claude-china, install-codex-china, install-openclaw-china

---

## 9. Known Limitations

| Issue | Impact | Blocks Release? |
|-------|--------|-----------------|
| pwsh parser not run on macOS (download timed out) | PS1 validated by Python structural analyzer; Windows real-machine test confirmed scripts execute correctly | No |
| DeepSeek API endpoint unreachable in test env | Only affects API config step, not install | No |

---

## 10. Windows Real Machine Test (2026-06-14)

| Test | Result |
|------|--------|
| 双击 install-claude.cmd | PASS — 启动安装，自动 fallback 正常 |
| 双击 install-codex.cmd | PASS — 启动安装，自动 fallback 正常 |
| 双击 install-openclaw.cmd | PASS — 启动安装，自动 fallback 正常 |
| `.\install-claude-code.ps1 -Help` | PASS — 帮助输出正常，无乱码 |
| `.\install-claude-code.ps1 -DryRun` | PASS — 预览正常，显示 3-tier fallback |
| `.\install-codex.ps1 -Help` | PASS — 帮助输出正常 |
| `.\install-codex.ps1 -DryRun` | PASS — 预览正常 |
| `.\install-openclaw.ps1 -Help` | PASS — 帮助输出正常 |
| `.\install-openclaw.ps1 -DryRun` | PASS — 预览正常 |
| 普通入口自动 fallback 到国内镜像 | PASS — 官方→npm→npmmirror 自动探测并 fallback |
| ZIP 内无 China .cmd | PASS — 仅有 3 个普通 .cmd |
| .cmd 多行 CRLF | PASS — 所有 .cmd 多行显示正常 |

---

## 11. Release Decision

**v3.2.6 真机测试通过，已发布。**

- 小白交付包仅 3 个 .cmd，无 China 版入口
- 普通入口自动 fallback，国内用户无需手动选择
- Windows 真机测试全部通过
- `-China`/`--china` 保留为高级参数，不在小白流程中展示
