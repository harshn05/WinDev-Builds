@echo off
setlocal

echo.
echo [WinDev] Locating ToolChains environment...
echo.

set "WINDEV_TOOLCHAINS_DIR=%WINDEV%\WinDev-ToolChains"
set "WINDEV_TOOLCHAINS_ISO=%WINDEV%\WinDev-ToolChains.iso"

for /f "delims=" %%I in ('
    %WINDEV%\WinDev.cmd LocateEnvironment ^
        "%WINDEV_TOOLCHAINS_DIR%" ^
        "%WINDEV_TOOLCHAINS_ISO%" ^
        "WinDev-ToolChains"
') do (
    set "WINDEV_TOOLCHAINS=%%I"
)

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: ToolChains environment could not be located.
    exit /b 1
)

if not defined WINDEV_TOOLCHAINS (
    echo.
    echo [WinDev] ERROR: Could not determine ToolChains path.
    exit /b 1
)

set "MINGW_ROOT=%WINDEV_TOOLCHAINS%\mingw64"

if not exist "%MINGW_ROOT%\mingwvars.bat" (
    echo.
    echo [WinDev] ERROR: MinGW64 environment not found.
    echo [WinDev] Expected:
    echo          %MINGW_ROOT%\mingwvars.bat
    exit /b 1
)

echo [WinDev] ToolChains:
echo          %WINDEV_TOOLCHAINS%

echo [WinDev] MinGW64:
echo          %MINGW_ROOT%

echo.
echo [WinDev] Loading MinGW64 environment...
echo.

call "%MINGW_ROOT%\mingwvars.bat"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to initialize MinGW64.
    exit /b 1
)

echo.
echo [WinDev] MinGW64 environment loaded.
echo.

endlocal & (
    set "WINDEV_TOOLCHAINS=%WINDEV_TOOLCHAINS%"
    set "MINGW_ROOT=%MINGW_ROOT%"
    set "PATH=%PATH%"
    set "CC=%CC%"
    set "CXX=%CXX%"
    set "FC=%FC%"
    set "F77=%F77%"
    set "LD=%LD%"
    set "AR=%AR%"
    set "RANLIB=%RANLIB%"
    set "WINDRES=%WINDRES%"
    set "RC=%RC%"
    set "NM=%NM%"
    set "DLLTOOL=%DLLTOOL%"
    set "STRIP=%STRIP%"
    set "PKG_CONFIG=%PKG_CONFIG%"
)

REM ============================================================
REM WinDev - MinGW Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=MinGW"

set "MINGW_FULL_VERSION="

for /f "delims=" %%V in ('"%MINGW_ROOT%\bin\gcc.exe" --version 2^>^&1') do (
    set "MINGW_FULL_VERSION=%%V"
    goto :mingw_version_found
)

:mingw_version_found

if not defined MINGW_FULL_VERSION (
    set "MINGW_FULL_VERSION=GNU MinGW-w64"
)

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                        WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%%MINGW_FULL_VERSION%%RESET%
echo %GREEN%                    MinGW environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%MINGW_ROOT%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.

doskey build_mingw=cmake -GNinja -S . -B build_mingw -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*
