@echo off
setlocal

echo.
echo [WinDev] Loading Clang + MSVC environment...
echo.

call "%~dp0loadenv_MSVC.cmd"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to load MSVC environment.
    exit /b 1
)

call "%~dp0loadenv_Clang.cmd"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to load Clang environment.
    exit /b 1
)

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

echo.
echo [WinDev] Clang + MSVC environment loaded.
echo.
echo   CC  = %CC%
echo   CXX = %CXX%
echo.

endlocal & (
    set "WINDEV_TOOLCHAINS=%WINDEV_TOOLCHAINS%"
    set "MSVC_ROOT=%MSVC_ROOT%"
    set "CLANG_ROOT=%CLANG_ROOT%"
    set "PATH=%PATH%"
    set "INCLUDE=%INCLUDE%"
    set "LIB=%LIB%"
    set "LIBPATH=%LIBPATH%"
    set "VCINSTALLDIR=%VCINSTALLDIR%"
    set "VCToolsInstallDir=%VCToolsInstallDir%"
    set "WindowsSdkDir=%WindowsSdkDir%"
    set "WindowsSDKVersion=%WindowsSDKVersion%"
    set "CC=%CC%"
    set "CXX=%CXX%"
)

::doskey build_clangmsvc=cmake -GNinja -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_CXX_FLAGS="-Xclang -fopenmp" -DOpenMP_CXX_FLAGS="-Xclang -fopenmp" -DOpenMP_CXX_LIB_NAMES=libomp -DOpenMP_libomp_LIBRARY="%WINDEV_TOOLCHAINS%\clang\lib\libomp.lib" -S . -B build_clangmsvc -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*

doskey build_clangmsvc=cmake -GNinja -S . -B build_clangmsvc -DCMAKE_C_COMPILER=clang-cl -DCMAKE_CXX_COMPILER=clang-cl -DCMAKE_COLOR_DIAGNOSTICS=ON "-DCMAKE_CXX_FLAGS=-Xclang -fopenmp -fansi-escape-codes -fcolor-diagnostics" "-DOpenMP_CXX_FLAGS=-Xclang -fopenmp" -DOpenMP_CXX_LIB_NAMES=libomp "-DOpenMP_libomp_LIBRARY=%WINDEV_TOOLCHAINS%\clang\lib\libomp.lib" -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*

REM ============================================================
REM WinDev - ClangMSVC Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=ClangMSVC"

set "CLANG_FULL_VERSION="

for /f "delims=" %%V in ('"%CLANG_ROOT%\bin\clang-cl.exe" --version 2^>^&1') do (
    set "CLANG_FULL_VERSION=%%V"
    goto :clangmsvc_version_found
)

:clangmsvc_version_found

if not defined CLANG_FULL_VERSION (
    set "CLANG_FULL_VERSION=Clang"
)

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                    WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%%CLANG_FULL_VERSION%%RESET%
echo %GREEN%             Clang + MSVC environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%CLANG_ROOT%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.

