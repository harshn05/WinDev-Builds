@echo off
setlocal EnableExtensions

echo.
echo [WinDev] Locating .NET environment...
echo.

REM ============================================================
REM Locate WinDev-DotNet
REM ============================================================

if not defined WINDEV (
    echo [WinDev] ERROR: WINDEV is not defined.
    exit /b 1
)

set "WINDEV_DOTNET_DIR=%WINDEV%\WinDev-DotNet"
set "WINDEV_DOTNET_ISO=%WINDEV%\WinDev-DotNet.iso"
set "WINDEV_DOTNET="

for /f "delims=" %%I in ('
    call "%WINDEV%\WinDev.cmd" LocateEnvironment ^
        "%WINDEV_DOTNET_DIR%" ^
        "%WINDEV_DOTNET_ISO%" ^
        "WinDev-DotNet"
') do (
    set "WINDEV_DOTNET=%%I"
)

if not defined WINDEV_DOTNET (
    echo.
    echo [WinDev] ERROR: .NET environment could not be located.
    exit /b 1
)

REM ============================================================
REM Validate .NET installation
REM ============================================================

set "DOTNET_ROOT=%WINDEV_DOTNET%"

if not exist "%DOTNET_ROOT%\dotnet.exe" (
    echo.
    echo [WinDev] ERROR: dotnet.exe not found.
    echo [WinDev] Expected:
    echo          %DOTNET_ROOT%\dotnet.exe
    exit /b 1
)

if not exist "%DOTNET_ROOT%\sdk\" (
    echo.
    echo [WinDev] ERROR: .NET SDK directory not found.
    echo [WinDev] Expected:
    echo          %DOTNET_ROOT%\sdk
    exit /b 1
)

echo [WinDev] .NET installation:
echo          %DOTNET_ROOT%
echo.

REM ============================================================
REM Configure .NET environment
REM ============================================================

set "DOTNET_ROOT_X64=%DOTNET_ROOT%"
set "DOTNET_MULTILEVEL_LOOKUP=0"
set "DOTNET_CLI_TELEMETRY_OPTOUT=1"
set "DOTNET_NOLOGO=1"
set "DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1"

REM Keep the SDK portable, but allow user-level CLI state and
REM NuGet packages to remain in their normal writable locations.

set "PATH=%DOTNET_ROOT%;%PATH%"

REM ============================================================
REM Verify .NET
REM ============================================================

echo [WinDev] Checking .NET SDK...
echo.

"%DOTNET_ROOT%\dotnet.exe" --version

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: .NET SDK verification failed.
    exit /b 1
)

REM ============================================================
REM WinDev - .NET Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=DotNet"

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                         WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%                         .NET SDK  : %DOTNET_ROOT%%RESET%
echo %WHITE%                         DOTNET_ROOT: %DOTNET_ROOT%%RESET%
echo.
echo %GREEN%                       .NET environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%DOTNET_ROOT%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.

REM ============================================================
REM Export environment to caller
REM ============================================================

endlocal & (
    set "WINDEV_DOTNET=%WINDEV_DOTNET%"
    set "WINDEV_ENV=%WINDEV_ENV%"
    set "DOTNET_ROOT=%DOTNET_ROOT%"
    set "DOTNET_ROOT_X64=%DOTNET_ROOT_X64%"
    set "DOTNET_MULTILEVEL_LOOKUP=%DOTNET_MULTILEVEL_LOOKUP%"
    set "DOTNET_CLI_TELEMETRY_OPTOUT=%DOTNET_CLI_TELEMETRY_OPTOUT%"
    set "DOTNET_NOLOGO=%DOTNET_NOLOGO%"
    set "DOTNET_SKIP_FIRST_TIME_EXPERIENCE=%DOTNET_SKIP_FIRST_TIME_EXPERIENCE%"
    set "PATH=%PATH%"
)

REM ============================================================
REM .NET command aliases
REM ============================================================

doskey dotnetinfo=dotnet --info
doskey dotnetsdks=dotnet --list-sdks
doskey dotnetruntimes=dotnet --list-runtimes

echo [WinDev] .NET command aliases loaded.



:: NUGET PORTABLE
@echo off

if not defined WINDEV (
    echo ERROR: WINDEV is not defined.
    exit /b 1
)

set "NUGET_ROOT=%WINDEV_DOTNET%\NuGet"

set "NUGET_PACKAGES=%NUGET_ROOT%\Packages"
set "NUGET_HTTP_CACHE_PATH=%NUGET_ROOT%\HttpCache"
set "NUGET_PLUGINS_CACHE_PATH=%NUGET_ROOT%\PluginsCache"
set "NUGET_SCRATCH=%LOCALAPPDATA%\NuGet\Scratch"

if not exist "%NUGET_PACKAGES%" mkdir "%NUGET_PACKAGES%"
if not exist "%NUGET_HTTP_CACHE_PATH%" mkdir "%NUGET_HTTP_CACHE_PATH%"
if not exist "%NUGET_PLUGINS_CACHE_PATH%" mkdir "%NUGET_PLUGINS_CACHE_PATH%"
if not exist "%NUGET_SCRATCH%" mkdir "%NUGET_SCRATCH%"

echo.
echo [WinDev] Portable NuGet environment enabled.
echo [WinDev] Packages: %NUGET_PACKAGES%
echo.