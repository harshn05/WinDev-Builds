@echo off

if /i "%~1"=="TerminalInit" goto TerminalInit
setlocal

REM ============================================================
REM WinDev - Main launcher and shared helper functions
REM
REM Normal usage:
REM   WinDev.cmd [starting-directory]
REM
REM Helper usage (used by component launchers):
REM   WinDev.cmd LocateEnvironment <live-dir> <iso-path> <volume-label>
REM   WinDev.cmd GetDriveByLabel <volume-label>
REM   WinDev.cmd IsDriveByLabel <volume-label>
REM   WinDev.cmd MountISO <iso-path>
REM   WinDev.cmd MountISOByLabel <iso-path> <volume-label>
REM ============================================================

REM ============================================================
REM Dispatch helper commands. If no helper command was requested,
REM continue to the normal WinDev launcher.
REM ============================================================

if /i "%~1"=="GetDriveByLabel"   goto GetDriveByLabel
if /i "%~1"=="IsDriveByLabel"    goto IsDriveByLabel
if /i "%~1"=="MountISO"          goto MountISO
if /i "%~1"=="MountISOByLabel"   goto MountISOByLabel
if /i "%~1"=="LocateEnvironment" goto LocateEnvironment
if /i "%~1"=="TerminalInit" goto TerminalInit

goto Main

:GetDriveByLabel

set "WINDEV_HELPER_LABEL=%~2"

for /f "delims=" %%I in ('
    powershell -NoProfile -Command ^
    "$v = Get-Volume | Where-Object { $_.FileSystemLabel -eq $env:WINDEV_HELPER_LABEL -and $_.DriveLetter } | Select-Object -First 1; if ($v) { $v.DriveLetter + ':' }"
') do (
    echo %%I
)

set "WINDEV_HELPER_LABEL="

exit /b 0


REM ============================================================
REM IsDriveByLabel
REM ============================================================

:IsDriveByLabel

set "WINDEV_HELPER_LABEL=%~2"

powershell -NoProfile -Command ^
    "$v = Get-Volume | Where-Object { $_.FileSystemLabel -eq $env:WINDEV_HELPER_LABEL -and $_.DriveLetter } | Select-Object -First 1; if ($v) { '1' } else { '0' }"

set "WINDEV_HELPER_LABEL="

exit /b 0


REM ============================================================
REM MountISO
REM ============================================================

:MountISO

echo [WinDev] Mounting ISO:
echo          %~2

powershell -NoProfile -Command ^
    "Mount-DiskImage -ImagePath '%~2' | Out-Null"

if errorlevel 1 (
    echo ERROR: Failed to mount ISO.
    exit /b 1
)

exit /b 0


REM ============================================================
REM MountISOByLabel
REM ============================================================

:MountISOByLabel

set "WINDEV_HELPER_LABEL=%~3"
set "WINDEV_HELPER_DRIVE="

echo [WinDev] Checking whether %~3 is already mounted...

for /f "delims=" %%I in ('
    powershell -NoProfile -Command ^
    "$label=$env:WINDEV_HELPER_LABEL; $v=Get-Volume | Where-Object { $_.FileSystemLabel -eq $label -and $_.DriveLetter } | Select-Object -First 1; if ($v) { $v.DriveLetter + ':' } else { $c=Get-CimInstance Win32_CDROMDrive | Where-Object { $_.VolumeName -eq $label -and $_.MediaLoaded } | Select-Object -First 1; if ($c) { $c.Drive } }"
') do (
    set "WINDEV_HELPER_DRIVE=%%I"
)

if defined WINDEV_HELPER_DRIVE (
    echo [WinDev] %~3 is already mounted.
    echo [WinDev] Mounted drive:
    echo          %WINDEV_HELPER_DRIVE%
    set "WINDEV_HELPER_LABEL="
    set "WINDEV_HELPER_DRIVE="
    exit /b 0
)

echo [WinDev] %~3 is not mounted.
echo [WinDev] Mounting ISO:
echo          %~2

powershell -NoProfile -Command ^
    "Mount-DiskImage -ImagePath '%~2' | Out-Null"

if errorlevel 1 (
    echo ERROR: Failed to mount ISO.
    set "WINDEV_HELPER_LABEL="
    exit /b 1
)

echo [WinDev] Waiting for Windows to expose the volume...

powershell -NoProfile -Command "Start-Sleep -Seconds 1"

echo [WinDev] Looking for mounted volume...

set "WINDEV_HELPER_DRIVE="

for /f "delims=" %%I in ('
    powershell -NoProfile -Command ^
    "$label=$env:WINDEV_HELPER_LABEL; $v=Get-Volume | Where-Object { $_.FileSystemLabel -eq $label -and $_.DriveLetter } | Select-Object -First 1; if ($v) { $v.DriveLetter + ':' } else { $c=Get-CimInstance Win32_CDROMDrive | Where-Object { $_.VolumeName -eq $label -and $_.MediaLoaded } | Select-Object -First 1; if ($c) { $c.Drive } }"
') do (
    set "WINDEV_HELPER_DRIVE=%%I"
)

if not defined WINDEV_HELPER_DRIVE (
    echo ERROR: %~3 drive not found after mounting.
    set "WINDEV_HELPER_LABEL="
    exit /b 1
)

echo [WinDev] %~3 mounted successfully.
echo [WinDev] Mounted drive:
echo          %WINDEV_HELPER_DRIVE%

set "WINDEV_HELPER_LABEL="
set "WINDEV_HELPER_DRIVE="

exit /b 0


REM ============================================================
REM LocateEnvironment
REM
REM Generic environment discovery helper.
REM
REM Arguments:
REM   %2 = live directory
REM   %3 = ISO path
REM   %4 = volume label
REM
REM Priority:
REM   1. Live directory
REM   2. Already mounted ISO
REM   3. Mount ISO
REM
REM IMPORTANT:
REM   Diagnostic messages go to stderr.
REM   Only the final resolved path is written to stdout.
REM   This allows callers to safely use FOR /F.
REM ============================================================

:LocateEnvironment

set "WINDEV_HELPER_LIVE=%~2"
set "WINDEV_HELPER_ISO=%~3"
set "WINDEV_HELPER_LABEL=%~4"
set "WINDEV_HELPER_DRIVE="

>&2 echo [WinDev] Looking for environment: %WINDEV_HELPER_LABEL%
>&2 echo [WinDev] Checking directory:
>&2 echo          %WINDEV_HELPER_LIVE%

REM ------------------------------------------------------------
REM 1. Prefer live directory
REM ------------------------------------------------------------

if exist "%WINDEV_HELPER_LIVE%\" (

    >&2 echo [WinDev] Directory found.
    >&2 echo [WinDev] Using live directory.

    echo %WINDEV_HELPER_LIVE%

    set "WINDEV_HELPER_LIVE="
    set "WINDEV_HELPER_ISO="
    set "WINDEV_HELPER_LABEL="
    exit /b 0
)

>&2 echo [WinDev] Directory not found.
>&2 echo.
>&2 echo [WinDev] Checking ISO:
>&2 echo          %WINDEV_HELPER_ISO%

REM ------------------------------------------------------------
REM 2. Check ISO
REM ------------------------------------------------------------

if not exist "%WINDEV_HELPER_ISO%" (

    >&2 echo [WinDev] ISO not found.
    >&2 echo.
    >&2 echo ERROR: WinDev %WINDEV_HELPER_LABEL% environment not found.
    >&2 echo.
    >&2 echo Expected either:
    >&2 echo   %WINDEV_HELPER_LIVE%
    >&2 echo or:
    >&2 echo   %WINDEV_HELPER_ISO%

    set "WINDEV_HELPER_LIVE="
    set "WINDEV_HELPER_ISO="
    set "WINDEV_HELPER_LABEL="
    exit /b 1
)

>&2 echo [WinDev] ISO found.

REM ------------------------------------------------------------
REM 3. Check whether ISO is already mounted
REM ------------------------------------------------------------

>&2 echo.
>&2 echo [WinDev] Checking whether ISO is already mounted...

for /f "delims=" %%I in ('
    powershell -NoProfile -Command ^
    "$label=$env:WINDEV_HELPER_LABEL; $v=Get-Volume | Where-Object { $_.FileSystemLabel -eq $label -and $_.DriveLetter } | Select-Object -First 1; if ($v) { $v.DriveLetter + ':' } else { $c=Get-CimInstance Win32_CDROMDrive | Where-Object { $_.VolumeName -eq $label -and $_.MediaLoaded } | Select-Object -First 1; if ($c) { $c.Drive } }"
') do (
    set "WINDEV_HELPER_DRIVE=%%I"
)

if defined WINDEV_HELPER_DRIVE (

    >&2 echo [WinDev] ISO is already mounted.
    >&2 echo [WinDev] Mounted drive:
    >&2 echo          %WINDEV_HELPER_DRIVE%

    echo %WINDEV_HELPER_DRIVE%

    set "WINDEV_HELPER_LIVE="
    set "WINDEV_HELPER_ISO="
    set "WINDEV_HELPER_LABEL="
    set "WINDEV_HELPER_DRIVE="
    exit /b 0
)

>&2 echo [WinDev] ISO is not mounted.

REM ------------------------------------------------------------
REM 4. Mount ISO
REM ------------------------------------------------------------

>&2 echo.
>&2 echo [WinDev] Mounting ISO...
>&2 echo          %WINDEV_HELPER_ISO%

powershell -NoProfile -Command ^
    "Mount-DiskImage -ImagePath '%WINDEV_HELPER_ISO%' | Out-Null"

if errorlevel 1 (

    >&2 echo ERROR: Failed to mount %WINDEV_HELPER_LABEL% ISO.

    set "WINDEV_HELPER_LIVE="
    set "WINDEV_HELPER_ISO="
    set "WINDEV_HELPER_LABEL="
    exit /b 1
)

>&2 echo [WinDev] ISO mount command completed.
>&2 echo [WinDev] Waiting for Windows to expose the volume...

powershell -NoProfile -Command "Start-Sleep -Seconds 1"

REM ------------------------------------------------------------
REM 5. Find mounted drive
REM ------------------------------------------------------------

>&2 echo [WinDev] Looking for mounted volume...

set "WINDEV_HELPER_DRIVE="

for /f "delims=" %%I in ('
    powershell -NoProfile -Command ^
    "$label=$env:WINDEV_HELPER_LABEL; $v=Get-Volume | Where-Object { $_.FileSystemLabel -eq $label -and $_.DriveLetter } | Select-Object -First 1; if ($v) { $v.DriveLetter + ':' } else { $c=Get-CimInstance Win32_CDROMDrive | Where-Object { $_.VolumeName -eq $label -and $_.MediaLoaded } | Select-Object -First 1; if ($c) { $c.Drive } }"
') do (
    set "WINDEV_HELPER_DRIVE=%%I"
)

if not defined WINDEV_HELPER_DRIVE (

    >&2 echo ERROR: %WINDEV_HELPER_LABEL% drive not found after mounting.

    set "WINDEV_HELPER_LIVE="
    set "WINDEV_HELPER_ISO="
    set "WINDEV_HELPER_LABEL="
    exit /b 1
)

>&2 echo [WinDev] Volume found.
>&2 echo [WinDev] %WINDEV_HELPER_LABEL% mounted successfully.
>&2 echo [WinDev] Mounted drive:
>&2 echo          %WINDEV_HELPER_DRIVE%

REM ------------------------------------------------------------
REM 6. Return resolved environment
REM ------------------------------------------------------------

echo %WINDEV_HELPER_DRIVE%

set "WINDEV_HELPER_LIVE="
set "WINDEV_HELPER_ISO="
set "WINDEV_HELPER_LABEL="
set "WINDEV_HELPER_DRIVE="

exit /b 0

:Main

for %%I in ("%~dp0") do set "WINDEV=%%~fI"

REM ============================================================
REM WinDev paths
REM ============================================================

set "PATH=%WINDEV%;%PATH%"

set "WINDEV_BASE_DIR=%WINDEV%\WinDev-Base"
set "WINDEV_BASE_ISO=%WINDEV%\WinDev-Base.iso"

REM ============================================================
REM Locate WinDev Base
REM ============================================================

for /f "delims=" %%I in ('call "%~f0" LocateEnvironment "%WINDEV_BASE_DIR%" "%WINDEV_BASE_ISO%" "WinDev-Base"') do (
    set "WINDEV_BASE=%%I"
)

if not defined WINDEV_BASE (
    echo.
    echo ERROR: WinDev Base environment could not be located.
    echo.
    pause
    exit /b 1
)


REM ============================================================
REM Initialize fonts BEFORE Windows Terminal starts.
REM TerminalInit is too late: Windows Terminal has already
REM initialized its font renderer by that point.
REM ============================================================

call %WINDEV_BASE%\_Toolchains\loadMesloFonts.cmd


REM ============================================================
REM Windows Terminal configuration
REM
REM The source may live on a read-only ISO. Run Windows Terminal
REM from a writable per-user runtime directory instead.
REM ============================================================

set "TERMINAL_SOURCE=%WINDEV_BASE%\terminal"
set "TERMINAL_RUNTIME=%USERPROFILE%\Desktop\WinDevTemp\Terminal"

if not exist "%TERMINAL_SOURCE%\WindowsTerminal.exe" (
    echo.
    echo ERROR: Windows Terminal source not found:
    echo        "%TERMINAL_SOURCE%\WindowsTerminal.exe"
    echo.
    pause
    exit /b 1
)

if not exist "%TERMINAL_SOURCE%\settings\settings.json" (
    echo.
    echo ERROR: Windows Terminal master settings not found:
    echo        "%TERMINAL_SOURCE%\settings\settings.json"
    echo.
    pause
    exit /b 1
)

if not exist "%TERMINAL_RUNTIME%\" (
    mkdir "%TERMINAL_RUNTIME%" 2>nul
)

if not exist "%TERMINAL_RUNTIME%\" (
    echo.
    echo ERROR: Cannot create writable Windows Terminal runtime:
    echo        "%TERMINAL_RUNTIME%"
    echo.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Sync application files from the ISO/folder to the writable
REM runtime. Keep runtime state and the portable marker local.
REM ------------------------------------------------------------

robocopy "%TERMINAL_SOURCE%" "%TERMINAL_RUNTIME%" /E /R:1 /W:1 /NFL /NDL /NJH /NJS ^
    /XF settings.json state.json .portable settings.json.backup-*

if errorlevel 8 (
    echo.
    echo ERROR: Failed to copy Windows Terminal files.
    echo        Source: "%TERMINAL_SOURCE%"
    echo        Target: "%TERMINAL_RUNTIME%"
    echo.
    pause
    exit /b 1
)

REM ------------------------------------------------------------
REM Keep portable mode enabled in the writable runtime only.
REM This marker is created even if it was removed from the ISO.
REM ------------------------------------------------------------

if not exist "%TERMINAL_RUNTIME%\.portable" (
    type nul > "%TERMINAL_RUNTIME%\.portable"
)

if not exist "%TERMINAL_RUNTIME%\settings\" (
    mkdir "%TERMINAL_RUNTIME%\settings" 2>nul
)

REM The ISO/folder settings file is the master configuration.
REM Copy it on every launch; state.json remains runtime-local.
copy /y "%TERMINAL_SOURCE%\settings\settings.json" "%TERMINAL_RUNTIME%\settings\settings.json" >nul

if errorlevel 1 (
    echo.
    echo ERROR: Failed to copy the master settings.json.
    echo.
    pause
    exit /b 1
)

REM ============================================================
REM Windows Terminal configuration
REM ============================================================

set "TERMINAL=%TERMINAL_RUNTIME%"
set "WT_EXE=%TERMINAL%\wt.exe"
set "WINDOWSTERMINAL_EXE=%TERMINAL%\WindowsTerminal.exe"

if exist "%WT_EXE%" (
    set "TERMINAL_EXE=%WT_EXE%"
) else if exist "%WINDOWSTERMINAL_EXE%" (
    set "TERMINAL_EXE=%WINDOWSTERMINAL_EXE%"
) else (
    echo.
    echo ERROR: Windows Terminal executable not found:
    echo        "%WT_EXE%"
    echo        "%WINDOWSTERMINAL_EXE%"
    echo.
    pause
    exit /b 1
)

REM ============================================================
REM Starting directory
REM ============================================================

if "%~1"=="" (
    set "STARTDIR=%USERPROFILE%\Desktop"
) else (
    set "STARTDIR=%~1"
)

REM ============================================================
REM Start Windows Terminal
REM
REM The child CMD receives WINDEV and WINDEV_BASE from this
REM launcher, then runs the WinDev terminal initialization below.
REM ============================================================

start "" "%TERMINAL_EXE%" ^
    -d "%STARTDIR%" ^
    cmd.exe /d /k call "%~f0" TerminalInit

endlocal
exit /b 0


REM ============================================================
REM TerminalInit
REM
REM WinDev equivalent of the old ConEmu CmdInit.cmd.
REM This code runs INSIDE the new Windows Terminal tab.
REM ============================================================

REM ============================================================
REM TerminalInit
REM
REM WinDev equivalent of the old ConEmu CmdInit.cmd.
REM
REM Usage:
REM
REM     WinDev.cmd TerminalInit
REM     WinDev.cmd TerminalInit Python
REM ============================================================

:TerminalInit

REM ------------------------------------------------------------
REM Always establish WinDev root from this script.
REM Do NOT depend on inherited WINDEV.
REM ------------------------------------------------------------

for %%I in ("%~dp0") do set "WINDEV=%%~fI"

if "%WINDEV:~-1%"=="\" set "WINDEV=%WINDEV:~0,-1%"

set "WINDEVTEMP=%USERPROFILE%\Desktop\WinDevTemp"


REM ------------------------------------------------------------
REM Locate WinDev-Base
REM ------------------------------------------------------------

set "WINDEV_BASE_DIR=%WINDEV%\WinDev-Base"
set "WINDEV_BASE_ISO=%WINDEV%\WinDev-Base.iso"

for /f "delims=" %%I in ('call "%~f0" LocateEnvironment "%WINDEV_BASE_DIR%" "%WINDEV_BASE_ISO%" "WinDev-Base"') do (
    set "WINDEV_BASE=%%I"
)

if not defined WINDEV_BASE (
    echo.
    echo [WinDev] ERROR: WinDev-Base could not be located.
    exit /b 1
)

REM ------------------------------------------------------------
REM UTF-8 / ANSI
REM ------------------------------------------------------------

chcp 65001 >nul

REM Build an ESC character (works on any Windows 10+ cmd)
for /f "tokens=1-2 delims=#" %%a in (
    '"prompt #$H#$E# & echo on & for %%b in (1) do rem"'
) do set "ESC=%%b"

REM ---- Banner style -------------------------------------------------
REM Modern style uses 24-bit colour + box-drawing glyphs. ConEmu (and any
REM terminal that lacks them) gets the classic 16-colour style instead.
REM Force it anywhere with:  set WINDEV_BANNER=classic
set "WD_CLASSIC="
if defined ConEmuPID set "WD_CLASSIC=1"
if /i "%WINDEV_BANNER%"=="classic" set "WD_CLASSIC=1"

REM ---- Modern palette (24-bit). B = letter body, S = shadow --------
set "B1=%ESC%[38;2;86;212;221m"
set "S1=%ESC%[38;2;50;114;122m"
set "B2=%ESC%[38;2;100;204;235m"
set "S2=%ESC%[38;2;56;110;129m"
set "B3=%ESC%[38;2;114;196;248m"
set "S3=%ESC%[38;2;64;106;136m"
set "B4=%ESC%[38;2;139;187;255m"
set "S4=%ESC%[38;2;76;102;139m"
set "B5=%ESC%[38;2;174;178;255m"
set "S5=%ESC%[38;2;94;98;139m"
set "B6=%ESC%[38;2;210;168;255m"
set "S6=%ESC%[38;2;112;92;139m"
set "TITLE=%ESC%[1;38;2;240;246;252m"
set "CYAN=%ESC%[38;2;86;212;221m"
set "GOLD=%ESC%[38;2;227;179;65m"
set "DIM=%ESC%[38;2;139;148;158m"
set "LINE=%ESC%[38;2;72;79;88m"
REM ---- Classic palette (16-colour) --------------------------------
set "C16A=%ESC%[96m"
set "C16B=%ESC%[94m"
set "C16C=%ESC%[95m"
set "C16W=%ESC%[1;97m"
set "C16Y=%ESC%[93m"
set "C16D=%ESC%[90m"
set "RESET=%ESC%[0m"

REM ============================================================
REM WinDev Banner
REM ============================================================

echo.
if defined WD_CLASSIC (
    echo %C16A%  ██     ██  ██  ███    ██  ██████  ███████ ██    ██%RESET%
    echo %C16A%  ██     ██  ██  ████   ██  ██   ██ ██      ██    ██%RESET%
    echo %C16B%  ██  █  ██  ██  ██ ██  ██  ██   ██ █████   ██    ██%RESET%
    echo %C16B%  ██ ███ ██  ██  ██  ██ ██  ██   ██ ██       ██  ██ %RESET%
    echo %C16C%   ███ ███   ██  ██   ████  ██████  ███████   ████  %RESET%
    echo.
    echo %C16D%  ──────────────────────────────────────────────────%RESET%
    echo %C16W%       PORTABLE  ·  SCIENTIFIC  ·  DEVELOPMENT%RESET%
    echo %C16A%              harsh.narula@iitbombay.org%RESET%
    echo %C16D%              © 2026 Harsh Kumar Narula%RESET%
    echo %C16D%  ──────────────────────────────────────────────────%RESET%
    echo.
    echo   %C16Y%›%C16D% Ctrl+Click an environment name to open it in a new tab.%RESET%
) else (
    echo   %B1%██%S1%╗    %B1%██%S1%╗%B1%██%S1%╗%B1%███%S1%╗   %B1%██%S1%╗%B1%██████%S1%╗ %B1%███████%S1%╗%B1%██%S1%╗   %B1%██%S1%╗%RESET%
    echo   %B2%██%S2%║    %B2%██%S2%║%B2%██%S2%║%B2%████%S2%╗  %B2%██%S2%║%B2%██%S2%╔══%B2%██%S2%╗%B2%██%S2%╔════╝%B2%██%S2%║   %B2%██%S2%║%RESET%
    echo   %B3%██%S3%║ %B3%█%S3%╗ %B3%██%S3%║%B3%██%S3%║%B3%██%S3%╔%B3%██%S3%╗ %B3%██%S3%║%B3%██%S3%║  %B3%██%S3%║%B3%█████%S3%╗  %B3%██%S3%║   %B3%██%S3%║%RESET%
    echo   %B4%██%S4%║%B4%███%S4%╗%B4%██%S4%║%B4%██%S4%║%B4%██%S4%║╚%B4%██%S4%╗%B4%██%S4%║%B4%██%S4%║  %B4%██%S4%║%B4%██%S4%╔══╝  ╚%B4%██%S4%╗ %B4%██%S4%╔╝%RESET%
    echo   %S5%╚%B5%███%S5%╔%B5%███%S5%╔╝%B5%██%S5%║%B5%██%S5%║ ╚%B5%████%S5%║%B5%██████%S5%╔╝%B5%███████%S5%╗ ╚%B5%████%S5%╔╝ %RESET%
    echo    %S6%╚══╝╚══╝ ╚═╝╚═╝  ╚═══╝╚═════╝ ╚══════╝  ╚═══╝  %RESET%
    echo.
    echo %LINE%  ────────────────────────────────────────────────%RESET%
    echo %TITLE%      PORTABLE  ·  SCIENTIFIC  ·  DEVELOPMENT%RESET%
    echo %CYAN%             harsh.narula@iitbombay.org%RESET%
    echo %DIM%             © 2026 Harsh Kumar Narula%RESET%
    echo %LINE%  ────────────────────────────────────────────────%RESET%
    echo.
)
echo.

echo %GREEN%   1  windev://MSYS2             %WHITE%Alt+M%RESET%
echo %GREEN%   2  windev://Python            %WHITE%Alt+P%RESET%
echo %GREEN%   3  windev://MinGW             %WHITE%Alt+G%RESET%
echo %GREEN%   4  windev://MSVC              %WHITE%Alt+V%RESET%
echo.
echo %GREEN%   5  windev://ClangMinGW        %WHITE%Alt+1%RESET%
echo %GREEN%   6  windev://ClangMSVC         %WHITE%Alt+2%RESET%
echo.
echo %GREEN%   7  windev://Python+MSYS2      %WHITE%Alt+Shift+M%RESET%
echo %GREEN%   8  windev://Python+MinGW      %WHITE%Alt+Shift+G%RESET%
echo %GREEN%   9  windev://Python+MSVC       %WHITE%Alt+Shift+V%RESET%
echo.
echo %GREEN%   0  windev://Python+ClangMinGW %WHITE%Alt+Shift+1%RESET%
echo %GREEN%   A  windev://Python+ClangMSVC  %WHITE%Alt+Shift+2%RESET%
echo.
echo %YELLOW%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%   Use the shortcuts above to switch environments.%RESET%
echo.
echo %YELLOW%  --------------------------------------------------------------------%RESET%
echo.


REM ------------------------------------------------------------
REM WinDev PATH
REM ------------------------------------------------------------

set "PATH=%WINDEV_BASE%\_GNU_Utils\_BUSYBOX_64U;%PATH%"
set "PATH=%WINDEV_BASE%\_GNU_Utils\_MSYS2;%PATH%"
set "PATH=%WINDEV_BASE%\_Toolchains;%PATH%"
set "PATH=%WINDEV_BASE%\_Tools;%PATH%"
set "PATH=%WINDEV_BASE%\_Tools\PortableGit\cmd;%PATH%"
set "PATH=%WINDEV_BASE%\_OhMyPosh;%PATH%"




@echo off
rem ============================================================
rem WinDev CMD: Compiler Diagnostics and BusyBox Colors
rem ============================================================

rem ---------- GCC diagnostics ----------
set "GCC_COLORS=error=01;31:warning=01;33:note=01;36:caret=01;32:locus=01;35:quote=01;33:fnname=01;32:targs=01;36:range1=32:range2=34:fixit-insert=32:fixit-delete=31:diff-filename=01:diff-hunk=32:diff-delete=31:diff-insert=32:type-diff=01;32"

rem ---------- CMake diagnostics ----------
set "CMAKE_COLOR_DIAGNOSTICS=ON"

rem ---------- BusyBox ls ----------
doskey ls=ls.exe --color=auto $*
doskey ll=ls.exe --color=auto -lAh $*

rem ---------- Pager ----------
set "LESS=-R -F -X"

echo [WinDev] Compiler diagnostics and BusyBox color aliases loaded.



REM ------------------------------------------------------------
REM CMake helper aliases
REM ------------------------------------------------------------

doskey build_ninja=cmake -GNinja -S . -B build_ninja -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*
doskey build_jom=cmake -G "NMake Makefiles JOM" -S . -B build_jom -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*


REM ------------------------------------------------------------
REM Clink
REM ------------------------------------------------------------

set "CLINK_HOME=%WINDEV_BASE%\clink"
set "PATH=%CLINK_HOME%;%PATH%"

if exist "%CLINK_HOME%\clink_x64.exe" (
    "%CLINK_HOME%\clink_x64.exe" inject
	"%CLINK_HOME%\clink_x64.exe" set clink.logo none
    "%CLINK_HOME%\clink_x64.exe" config prompt use oh-my-posh
	"%CLINK_HOME%\clink_x64.exe" set suggestionlist.default true
	
)

REM ------------------------------------------------------------
REM User custom WinDev initialization
REM ------------------------------------------------------------

if exist "%USERPROFILE%\.windev\CmdInit.cmd" (
    call "%USERPROFILE%\.windev\CmdInit.cmd"
)


REM ============================================================
REM Profile-specific environment
REM ============================================================

if /i "%~2"=="Python" (
    set "WINDEV_ENV=Python"
    call "%WINDEV_BASE%\_Toolchains\loadenv_WinPython.cmd"
    exit /b
)

if /i "%~2"=="MSYS2" (
    set "WINDEV_ENV=MSYS2"
    call "%WINDEV_BASE%\_Toolchains\login_MSYS2_UCRT64.bat"
    exit /b
)

if /i "%~2"=="MinGW" (
    set "WINDEV_ENV=MinGW"
    call "%WINDEV_BASE%\_Toolchains\loadenv_MinGW.cmd"
    exit /b
)

if /i "%~2"=="MSVC" (
    set "WINDEV_ENV=MSVC"
    call "%WINDEV_BASE%\_Toolchains\loadenv_MSVC.cmd"
    exit /b
)

if /i "%~2"=="ClangMinGW" (
    set "WINDEV_ENV=ClangMinGW"
    call "%WINDEV_BASE%\_Toolchains\loadenv_ClangMinGW.cmd"
    exit /b
)

if /i "%~2"=="ClangMSVC" (
    set "WINDEV_ENV=ClangMSVC"
    call "%WINDEV_BASE%\_Toolchains\loadenv_ClangMSVC.cmd"
    exit /b
)


REM ============================================================
REM Combined environments
REM ============================================================

if /i "%~2"=="Python+MSYS2" (
    set "WINDEV_ENV=Python+MSYS2"
    call "%WINDEV_BASE%\_Toolchains\login_MSYS2_UCRT64.bat" python
    exit /b
)

if /i "%~2"=="Python+MinGW" (
    set "WINDEV_ENV=Python+MinGW"

    call "%WINDEV_BASE%\_Toolchains\loadenv_WinPython.cmd"
    if errorlevel 1 exit /b

    call "%WINDEV_BASE%\_Toolchains\loadenv_MinGW.cmd"
    exit /b
)

if /i "%~2"=="Python+MSVC" (
    set "WINDEV_ENV=Python+MSVC"

    call "%WINDEV_BASE%\_Toolchains\loadenv_WinPython.cmd"
    if errorlevel 1 exit /b

    call "%WINDEV_BASE%\_Toolchains\loadenv_MSVC.cmd"
    exit /b
)

if /i "%~2"=="Python+ClangMSVC" (
    set "WINDEV_ENV=Python+ClangMSVC"

    call "%WINDEV_BASE%\_Toolchains\loadenv_WinPython.cmd"
    if errorlevel 1 exit /b

    call "%WINDEV_BASE%\_Toolchains\loadenv_ClangMSVC.cmd"
    exit /b
)

if /i "%~2"=="Python+ClangMinGW" (
    set "WINDEV_ENV=Python+ClangMinGW"

    call "%WINDEV_BASE%\_Toolchains\loadenv_WinPython.cmd"
    if errorlevel 1 exit /b

    call "%WINDEV_BASE%\_Toolchains\loadenv_ClangMinGW.cmd"
    exit /b
)


REM ============================================================
REM No profile specified
REM
REM Common WinDev initialization is already complete.
REM Stay in normal CMD.
REM ============================================================