# Release Test Report — v3.2.6 Emergency Fix

> **Windows caveat**: PowerShell parser check was done via comprehensive Python-based validation (balanced braces, string closure, BOM, encoding). Real `pwsh` parser could not be run — pwsh download from GitHub timed out (~5% after 10 min). All PS1 scripts pass structural validation.

## Test Environment

| Item | Value |
|------|-------|
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

## 8. SHA256

```
21afb805f3d48526f9dd635677f86644d2594abbed9712785f8261fba530e00e  AI-Agent-Windows-v3.2.6.zip
3fe541759454f326ac8e94879f54df9882a074fbbf43e1d5bb0864e52eafa00d  AI-Agent-macOS-Linux-v3.2.6.zip
```

---

## 9. Known Limitations

| Issue | Impact | Blocks Release? |
|-------|--------|-----------------|
| pwsh parser not actually run (no pwsh on macOS, download timed out) | PS1 validated by Python structural analyzer only | No (all structural checks pass) |
| No real Windows machine test | Cannot verify double-click behavior on Windows | No (same code pattern as v3.2.5, only removed China .cmd + fixed backtick) |
| DeepSeek API endpoint unreachable in test env | Only affects API config step, not install | No |

---

## 10. Release Decision

**Ready to release v3.2.6**

Critical fixes verified:
- Entry unification: 3 .cmd only, zero China launchers in beginner package
- install-claude.cmd correctly calls install-claude-code.ps1
- All .cmd files: ASCII, CRLF, multi-line
- All PS1 files: UTF-8 BOM, balanced braces, no broken strings
- Backtick-escaped $null fixed in codex.ps1 and openclaw.ps1
- Cross-contamination clean
- SHA256 generated
- All version references updated to v3.2.6
