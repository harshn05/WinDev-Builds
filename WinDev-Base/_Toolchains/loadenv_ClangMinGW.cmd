@echo off
setlocal

echo.
echo [WinDev] Loading Clang + MinGW64 environment...
echo.

call "%~dp0loadenv_MinGW.cmd"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to load MinGW64 environment.
    exit /b 1
)

call "%~dp0loadenv_Clang.cmd"

if errorlevel 1 (
    echo.
    echo [WinDev] ERROR: Failed to load Clang environment.
    exit /b 1
)

set "CC=clang.exe"
set "CXX=clang++.exe"

echo.
echo [WinDev] Clang + MinGW64 environment loaded.
echo.
echo   CC  = %CC%
echo   CXX = %CXX%
echo.

endlocal & (
    set "WINDEV_TOOLCHAINS=%WINDEV_TOOLCHAINS%"
    set "MINGW_ROOT=%MINGW_ROOT%"
    set "CLANG_ROOT=%CLANG_ROOT%"
    set "PATH=%PATH%"
    set "CC=%CC%"
    set "CXX=%CXX%"
)

REM ============================================================
REM WinDev - Clang + MinGW Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=ClangMinGW"

set "CLANG_FULL_VERSION="

for /f "delims=" %%V in ('"%CLANG_ROOT%\bin\clang.exe" --version 2^>^&1') do (
    if not defined CLANG_FULL_VERSION set "CLANG_FULL_VERSION=%%V"
)

if not defined CLANG_FULL_VERSION (
    set "CLANG_FULL_VERSION=Clang"
)

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                      WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%%CLANG_FULL_VERSION%%RESET%
echo %GREEN%                  Clang + MinGW environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%CLANG_ROOT%%RESET%
echo.
echo %CYAN%  MinGW:%RESET% %WHITE%%MINGW_ROOT%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.

doskey build_clangmingw=cmake -GNinja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_FLAGS="--target=x86_64-w64-windows-gnu" -DCMAKE_CXX_FLAGS="--target=x86_64-w64-windows-gnu" -DOpenMP_CXX_FLAGS="-fopenmp=libomp" -DOpenMP_CXX_LIB_NAMES=omp -DOpenMP_omp_LIBRARY="%CLANG_ROOT%\lib\libomp.lib" -S . -B build_clangmingw -DCMAKE_COLOR_DIAGNOSTICS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON $*