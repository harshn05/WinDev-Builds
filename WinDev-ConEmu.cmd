@echo off
setlocal

REM ============================================================
REM WinDev ConEmu Launcher
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

set "CONEMU=%WINDEV_BASE%\conemu"
set "FONTDIR=%WINDEV_BASE%\_OhMyPosh\_fonts"
set "STARTDIR=%USERPROFILE%\Desktop"

REM Register windev:// protocol
call %WINDEV_BASE%\_Toolchains\RegisterWindevProtocol.cmd
call %WINDEV_BASE%\_Toolchains\loadMesloFonts.cmd
if not exist "%CONEMU%\ConEmu64.exe" (
    echo ERROR: ConEmu64.exe not found:
    echo "%CONEMU%\ConEmu64.exe"
    pause
    exit /b 1
)

::start "" /D "%STARTDIR%" "%CONEMU%\ConEmu64.exe" -FontDir "%FONTDIR%"
start "" /D "%STARTDIR%" "%CONEMU%\ConEmu64.exe" 

endlocal