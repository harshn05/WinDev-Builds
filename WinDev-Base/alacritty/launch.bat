@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "ZELLIJ_CONFIG_DIR=%~dp0."

:: Launch Alacritty directly
start "" /wait "alacritty.exe" --config-file "%~dp0alacritty.toml"

:: Cleanup Zellij sessions on exit
zellij.exe kill-all-sessions --yes
exit /b