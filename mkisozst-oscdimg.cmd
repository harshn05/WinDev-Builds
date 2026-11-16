@echo off
setlocal
title WinDev Incremental ISO + ZST Packager (oscdimg)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0mkisozst-oscdimg.ps1"
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" (
    echo [ERROR] One or more modules failed.
) else (
    echo Packager completed.
)
echo.
pause
exit /b %RC%
