@echo off
setlocal

REM ============================================================
REM WinDev Alacritty Launcher
REM ============================================================

for %%I in ("%~dp0") do set "WINDEV=%%~fI"

set "WINDEV_BASE_DIR=%WINDEV%\WinDev-Base"
set "WINDEV_BASE_ISO=%WINDEV%\WinDev-Base.iso"

for /f "delims=" %%I in ('call "%WINDEV%\WinDev.cmd" LocateEnvironment "%WINDEV_BASE_DIR%" "%WINDEV_BASE_ISO%" "WinDev-Base"') do (
    set "WINDEV_BASE=%%I"
)

if not defined WINDEV_BASE (
    echo ERROR: WinDev-Base could not be located.
    pause
    exit /b 1
)

set "ALACRITTY=%WINDEV_BASE%\alacritty"
set "STARTDIR=%USERPROFILE%\Desktop"
CALL %WINDEV_BASE%\_Toolchains\loadMesloFonts.cmd
if errorlevel 1 (
    echo ERROR: Font initialization failed.
    pause
    exit /b 1
)

CALL "%ALACRITTY%\launch.exe"

endlocal