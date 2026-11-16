
@echo off
setlocal EnableExtensions

echo.
echo [WinDev] Locating ToolChains environment...
echo.

REM ============================================================
REM Locate ToolChains
REM ============================================================

if not defined WINDEV (
    echo [WinDev] ERROR: WINDEV is not defined.
    exit /b 1
)

set "WINDEV_TOOLCHAINS_DIR=%WINDEV%\WinDev-ToolChains"
set "WINDEV_TOOLCHAINS_ISO=%WINDEV%\WinDev-ToolChains.iso"
set "WINDEV_TOOLCHAINS="

for /f "delims=" %%I in ('
    call "%WINDEV%\WinDev.cmd" LocateEnvironment ^
        "%WINDEV_TOOLCHAINS_DIR%" ^
        "%WINDEV_TOOLCHAINS_ISO%" ^
        "WinDev-ToolChains"
') do (
    set "WINDEV_TOOLCHAINS=%%I"
)

if not defined WINDEV_TOOLCHAINS (
    echo.
    echo [WinDev] ERROR: ToolChains environment could not be located.
    exit /b 1
)

set "MSVC_ROOT=%WINDEV_TOOLCHAINS%\msvc"

if not exist "%MSVC_ROOT%\setup_x64.bat" (
    echo.
    echo [WinDev] ERROR: MSVC environment not found.
    echo [WinDev] Expected:
    echo          %MSVC_ROOT%\setup_x64.bat
    exit /b 1
)

echo [WinDev] ToolChains:
echo          %WINDEV_TOOLCHAINS%
echo [WinDev] MSVC:
echo          %MSVC_ROOT%
echo.

REM ============================================================
REM Initialize MSVC
REM ============================================================

echo [WinDev] Loading MSVC x64 environment...
echo.

call "%MSVC_ROOT%\setup_x64.bat"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to initialize MSVC.
    exit /b 1
)

REM ============================================================
REM Normalize MSVC environment variables
REM ============================================================

REM Derive toolset version from VCToolsInstallDir.
REM Expected path ends with ...\MSVC\14.51.36231\

if not defined VCToolsVersion (
    if defined VCToolsInstallDir (
        for %%I in ("%VCToolsInstallDir:~0,-1%") do (
            set "VCToolsVersion=%%~nxI"
        )
    )
)

REM Windows SDK root fallback.
REM Prefer the value established by setup_x64.bat.

if not defined WindowsSdkDir (
    set "WindowsSdkDir=%MSVC_ROOT%\Windows Kits\10\"
)

REM SDK version fallback.
REM Prefer the value established by setup_x64.bat.

if not defined WindowsSDKVersion (
    set "WindowsSDKVersion=10.0.28000.0\"
)

REM ============================================================
REM WinDev - MSVC Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=MSVC"

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                              WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%                         MSVC Tools : %VCToolsVersion%%RESET%
echo %WHITE%                         Windows SDK: %WindowsSDKVersion%%RESET%
echo %WHITE%                         Host       : %VSCMD_ARG_HOST_ARCH%%RESET%
echo %WHITE%                         Target     : %VSCMD_ARG_TGT_ARCH%%RESET%
echo.
echo %GREEN%                       MSVC environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%MSVC_ROOT%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.

REM ============================================================
REM Export environment to caller
REM ============================================================

endlocal & (
    set "WINDEV_TOOLCHAINS=%WINDEV_TOOLCHAINS%"
    set "MSVC_ROOT=%MSVC_ROOT%"
    set "PATH=%PATH%"
    set "INCLUDE=%INCLUDE%"
    set "LIB=%LIB%"
    set "LIBPATH=%LIBPATH%"
    set "VCINSTALLDIR=%VCINSTALLDIR%"
    set "VCToolsInstallDir=%VCToolsInstallDir%"
    set "VCToolsVersion=%VCToolsVersion%"
    set "WindowsSdkDir=%WindowsSdkDir%"
    set "WindowsSDKVersion=%WindowsSDKVersion%"
    set "VSCMD_ARG_HOST_ARCH=%VSCMD_ARG_HOST_ARCH%"
    set "VSCMD_ARG_TGT_ARCH=%VSCMD_ARG_TGT_ARCH%"
)

REM ============================================================
REM MSVC command aliases
REM ============================================================

doskey build_msvc=cmake -G Ninja -S . -B build_msvc -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="/nologo /W4 /FC /diagnostics:caret" -DCMAKE_C_COMPILER_LAUNCHER=cl_color.exe -DCMAKE_CXX_COMPILER_LAUNCHER=cl_color.exe -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*

