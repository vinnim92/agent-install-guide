@echo off
chcp 65001 >nul
title Claude Code + DeepSeek API 小白安装器

echo ==========================================
echo   Claude Code + DeepSeek API 安装
echo   版本 v3.2.0
echo ==========================================
echo.
echo 正在启动安装脚本...
echo 如果弹出 Windows 安全提示，请选择"仍要运行"。
echo.

set SCRIPT_DIR=%~dp0
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-claude-code.ps1"

echo.
echo ==========================================
echo   安装流程已结束。
echo   如果上方出现红色错误，请截图完整窗口反馈。
echo ==========================================
echo.
pause
