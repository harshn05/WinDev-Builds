
@echo off
setlocal EnableExtensions

REM ============================================================
REM WinDev - VCPKG Environment
REM
REM Responsibilities:
REM   1. Locate WinDev-VCPKG directory or ISO
REM   2. Resolve the actual vcpkg root
REM   3. Load the MSVC environment
REM   4. Set vcpkg defaults for WinDev MSVC
REM
REM MSVC remains independent of vcpkg.
REM ============================================================

echo.
echo [WinDev] Locating VCPKG environment...
echo.

REM ------------------------------------------------------------
REM WinDev root
REM ------------------------------------------------------------

if not defined WINDEV (
    echo [WinDev] ERROR: WINDEV is not defined.
    exit /b 1
)

if not exist "%WINDEV%\WinDev.cmd" (
    echo [WinDev] ERROR: WinDev.cmd not found.
    echo          Expected: %WINDEV%\WinDev.cmd
    exit /b 1
)

REM ------------------------------------------------------------
REM Locate live directory or ISO
REM ------------------------------------------------------------

set "WINDEV_VCPKG_DIR=%WINDEV%\WinDev-VCPKG"
set "WINDEV_VCPKG_ISO=%WINDEV%\WinDev-VCPKG.iso"
set "WINDEV_VCPKG="

for /f "delims=" %%I in ('
    call "%WINDEV%\WinDev.cmd" LocateEnvironment ^
        "%WINDEV_VCPKG_DIR%" ^
        "%WINDEV_VCPKG_ISO%" ^
        "WinDev-VCPKG"
') do (
    set "WINDEV_VCPKG=%%I"
)

if not defined WINDEV_VCPKG (
    echo.
    echo [WinDev] ERROR: VCPKG environment could not be located.
    exit /b 1
)

REM ------------------------------------------------------------
REM Resolve actual vcpkg repository root
REM ------------------------------------------------------------

set "VCPKG_ROOT=%WINDEV_VCPKG%\vcpkg"

if not exist "%VCPKG_ROOT%\vcpkg.exe" (
    echo.
    echo [WinDev] ERROR: vcpkg.exe not found.
    echo [WinDev] Expected:
    echo          %VCPKG_ROOT%\vcpkg.exe
    exit /b 1
)

if not exist "%VCPKG_ROOT%\triplets\x64-windev-msvc.cmake" (
    echo.
    echo [WinDev] ERROR: WinDev target triplet not found.
    echo          %VCPKG_ROOT%\triplets\x64-windev-msvc.cmake
    exit /b 1
)

if not exist "%VCPKG_ROOT%\triplets\windev-msvc.cmake" (
    echo.
    echo [WinDev] ERROR: MSVC chainload toolchain not found.
    echo          %VCPKG_ROOT%\triplets\windev-msvc.cmake
    exit /b 1
)

REM ------------------------------------------------------------
REM Load the existing MSVC environment
REM ------------------------------------------------------------

echo [WinDev] VCPKG module:
echo          %WINDEV_VCPKG%
echo.
echo [WinDev] VCPKG root:
echo          %VCPKG_ROOT%
echo.

if not exist "%~dp0loadenv_MSVC.cmd" (
    echo [WinDev] ERROR: loadenv_MSVC.cmd not found.
    echo          Expected: %~dp0loadenv_MSVC.cmd
    exit /b 1
)

echo [WinDev] Loading MSVC environment...
echo.

call "%~dp0loadenv_MSVC.cmd"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: MSVC initialization failed.
    exit /b 1
)

REM ------------------------------------------------------------
REM VCPKG defaults
REM ------------------------------------------------------------

set "VCPKG_DEFAULT_TRIPLET=x64-windev-msvc"
set "VCPKG_DEFAULT_HOST_TRIPLET=x64-windev-msvc"

REM Prefer this module's vcpkg executable.

set "PATH=%VCPKG_ROOT%;%PATH%"

REM ------------------------------------------------------------
REM Status
REM ------------------------------------------------------------

echo.
echo ------------------------------------------------------------
echo   WinDev :: VCPKG
echo ------------------------------------------------------------
echo   VCPKG Root : %VCPKG_ROOT%
echo   Target     : %VCPKG_DEFAULT_TRIPLET%
echo   Host       : %VCPKG_DEFAULT_HOST_TRIPLET%
echo   Compiler   : %VCToolsVersion%
echo   SDK        : %WindowsSDKVersion%
echo ------------------------------------------------------------
echo.
echo [WinDev] VCPKG environment ready.
echo.
echo [WinDev] Example:
echo          vcpkg install muparser
echo.

REM ------------------------------------------------------------
REM Export environment beyond SETLOCAL
REM ------------------------------------------------------------

endlocal & (
    set "WINDEV_VCPKG=%WINDEV_VCPKG%"
    set "VCPKG_ROOT=%VCPKG_ROOT%"
    set "VCPKG_DEFAULT_TRIPLET=%VCPKG_DEFAULT_TRIPLET%"
    set "VCPKG_DEFAULT_HOST_TRIPLET=%VCPKG_DEFAULT_HOST_TRIPLET%"
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
    set "CC=%CC%"
    set "CXX=%CXX%"
)

