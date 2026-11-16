@echo off
setlocal

REM ============================================================
REM WinDev - MSYS2 UCRT64 Launcher
REM
REM Usage:
REM   login_MSYS2_UCRT64
REM       Normal MSYS2 UCRT64
REM
REM   login_MSYS2_UCRT64 python
REM       MSYS2 UCRT64 + WinPython
REM ============================================================

echo.
echo [WinDev] Initializing MSYS2 UCRT64 environment...
echo.

REM ============================================================
REM WinDev / MSYS2 paths
REM ============================================================

set "WINDEV_MSYS2_DIR=%WINDEV%\WinDev-MSYS2"
set "WINDEV_MSYS2_ISO=%WINDEV%\WinDev-MSYS2.iso"

REM ============================================================
REM Locate MSYS2
REM ============================================================

for /f "delims=" %%I in ('
    %WINDEV%\WinDev.cmd LocateEnvironment ^
        "%WINDEV_MSYS2_DIR%" ^
        "%WINDEV_MSYS2_ISO%" ^
        "WinDev-MSYS2"
') do (
    set "WINDEV_MSYS2=%%I"
)

if errorlevel 1 (
    echo.
    echo [WinDev] MSYS2 environment could not be located.
    exit /b 1
)

if not defined WINDEV_MSYS2 (
    echo.
    echo ERROR: Could not determine MSYS2 path.
    exit /b 1
)

echo.
echo [WinDev] MSYS2 environment ready.
echo [WinDev] Location:
echo          %WINDEV_MSYS2%

REM ============================================================
REM MSYS2 UCRT64 environment
REM ============================================================

echo.
echo [WinDev] Configuring MSYS2 UCRT64 environment...
::set "ConEmuANSI="
set "MSYSTEM=UCRT64"
set "MINGW_PREFIX=/ucrt64"
set "MSYSTEM_PREFIX=/ucrt64"
set "MINGW_PACKAGE_PREFIX=mingw-w64-ucrt-x86_64"

set "MSYS2_PATH_TYPE=inherit"

set "PKG_CONFIG_PATH=/ucrt64/lib/pkgconfig:/ucrt64/share/pkgconfig"
set "PKG_CONFIG_SYSTEM_LIBRARY_PATH=/ucrt64/lib"
set "PKG_CONFIG_SYSTEM_INCLUDE_PATH=/ucrt64/include"

set "PATH=%WINDEV_MSYS2%\ucrt64\bin;%WINDEV_MSYS2%\usr\bin;%PATH%"

REM ============================================================
REM Writable runtime state
REM ============================================================

::set "WINDEVTEMP=%USERPROFILE%\Desktop\WinDevTemp" (Not Required, ALREADY SET BY WinDev.cmd)
set "HOME=%WINDEVTEMP%\msys2home"

echo [WinDev] Writable runtime:
echo          %WINDEVTEMP%
echo [WinDev] MSYS2 HOME:
echo          %HOME%

REM ============================================================
REM Start MSYS2
REM ============================================================

echo.
echo [WinDev] Starting MSYS2 UCRT64...

if /i "%~1"=="python" (
    echo [WinDev] Python integration requested.
    echo [WinDev] Starting MSYS2 and loading WinPython...
    echo.
    "%WINDEV_MSYS2%\usr\bin\bash.exe" --login -i -c ^
        "loadenv_WinPython; exec bash --login -i"
) else (
    echo.
    "%WINDEV_MSYS2%\usr\bin\bash.exe" --login -i
)