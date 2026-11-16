@echo off

REM ============================================================
REM WinDev - Python Launcher
REM ============================================================

echo.
echo [WinDev] Initializing WinPython environment...
echo.

REM ============================================================
REM WinDev / Python paths
REM ============================================================

set "WINDEV_PYTHON_DIR=%WINDEV%\WinDev-Python"
set "WINDEV_PYTHON_ISO=%WINDEV%\WinDev-Python.iso"

REM ============================================================
REM Locate Python
REM ============================================================

for /f "delims=" %%I in ('
    %WINDEV%\WinDev.cmd LocateEnvironment ^
        "%WINDEV_PYTHON_DIR%" ^
        "%WINDEV_PYTHON_ISO%" ^
        "WinDev-Python"
') do (
    set "WINDEV_PYTHON=%%I"
)

if errorlevel 1 (
    echo.
    echo [WinDev] Python environment could not be located.
    exit /b 1
)

if not defined WINDEV_PYTHON (
    echo.
    echo ERROR: Could not determine Python path.
    exit /b 1
)

echo.
echo [WinDev] Python environment ready.
echo [WinDev] Location:
echo          %WINDEV_PYTHON%

REM ============================================================
REM Python executable
REM ============================================================

echo.
echo [WinDev] Checking Python executable...

set "WINDEV_PYTHON_EXE=%WINDEV_PYTHON%\python\python.exe"

if not exist "%WINDEV_PYTHON_EXE%" (
    echo [WinDev] Python executable not found.
    echo.
    echo ERROR: Expected:
    echo        %WINDEV_PYTHON_EXE%
    exit /b 1
)

echo [WinDev] Python executable found.

REM ============================================================
REM Python development environment
REM ============================================================

echo.
echo [WinDev] Configuring Python development environment...

set "PYTHONHOME=%WINDEV_PYTHON%\python"
set "PYTHON_INCLUDE_DIR=%PYTHONHOME%\include"
set "PYTHON_LIBRARY=%PYTHONHOME%\libs\python314.lib"
set "PYTHON_PATH=%PYTHONHOME%"
set "PYTHON_LIB=%PYTHONHOME%\libs"
set "PYTHON_VERSION=314"

set "INCLUDE=%PYTHONHOME%\include;%INCLUDE%"
set "LIB=%PYTHONHOME%\libs;%LIB%"

call "%WINDEV_PYTHON%\scripts\env.bat"

set "PATH=%PYTHONHOME%;%PYTHONHOME%\Scripts;%PATH%"

REM ============================================================
REM Verify
REM ============================================================

echo.
echo [WinDev] Verifying Python installation...

set "PYTHON_FULL_VERSION="

for /f "delims=" %%V in ('"%WINDEV_PYTHON_EXE%" --version 2^>^&1') do (
    set "PYTHON_FULL_VERSION=%%V"
)

if not defined PYTHON_FULL_VERSION (
    echo.
    echo ERROR: Python verification failed.
    exit /b 1
)

echo %PYTHON_FULL_VERSION%

echo.
echo [WinDev] Python environment loaded successfully.

REM ============================================================
REM WinDev - Python Environment Banner
REM ============================================================

if not defined WINDEV_ENV set "WINDEV_ENV=Python"

echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
echo %CYAN%                        WINDEV - %WINDEV_ENV%%RESET%
echo.
echo %WHITE%                         %PYTHON_FULL_VERSION%%RESET%
echo %GREEN%                    Python environment ready%RESET%
echo.
echo %CYAN%  Location:%RESET% %WHITE%%WINDEV_PYTHON%%RESET%
echo.
echo %CYAN%  --------------------------------------------------------------------%RESET%
echo.
