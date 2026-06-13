@echo off
setlocal
set "SCRIPT_DIR=%~dp0"

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install-claude-code.ps1"

echo.
echo Installer finished. If you see red error messages above, please take a screenshot.
pause
exit /b %ERRORLEVEL%
