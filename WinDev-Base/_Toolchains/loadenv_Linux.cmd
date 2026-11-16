
@echo off
setlocal

set "LINUX_DISTRO=openSUSE-Tumbleweed"

where wsl.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: WSL executable not found.
    exit /b 1
)

wsl.exe --list --quiet | findstr /i /x "%LINUX_DISTRO%" >nul
if errorlevel 1 (
    echo ERROR: WSL distro "%LINUX_DISTRO%" is not registered.
    echo Available distributions:
    wsl.exe --list --verbose
    exit /b 1
)

echo Launching WinDev-Linux: %LINUX_DISTRO%
endlocal
wsl.exe -d openSUSE-Tumbleweed
