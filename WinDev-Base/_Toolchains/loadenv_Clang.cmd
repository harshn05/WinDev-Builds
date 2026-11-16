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

set "CLANG_ROOT=%WINDEV_TOOLCHAINS%\clang"

if not exist "%CLANG_ROOT%\bin\clang.exe" (
    echo.
    echo [WinDev] ERROR: Clang environment not found.
    echo [WinDev] Expected:
    echo          %CLANG_ROOT%\bin\clang.exe
    exit /b 1
)

echo [WinDev] ToolChains:
echo          %WINDEV_TOOLCHAINS%

echo [WinDev] Clang:
echo          %CLANG_ROOT%

echo.
echo [WinDev] Loading Clang environment...
echo.

set "PATH=%CLANG_ROOT%\bin;%PATH%"

set "CC=%CLANG_ROOT%\bin\clang.exe"
set "CXX=%CLANG_ROOT%\bin\clang++.exe"

echo.
echo [WinDev] Clang environment loaded.
echo.

endlocal & (
    set "WINDEV_TOOLCHAINS=%WINDEV_TOOLCHAINS%"
    set "CLANG_ROOT=%CLANG_ROOT%"
    set "PATH=%PATH%"
    set "CC=%CC%"
    set "CXX=%CXX%"
)

