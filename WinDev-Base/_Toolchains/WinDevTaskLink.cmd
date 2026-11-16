@echo off
setlocal

set "URI=%~1"
set "ENV=%URI:windev://=%"

REM Windows passes custom URLs with a trailing slash
if "%ENV:~-1%"=="/" set "ENV=%ENV:~0,-1%"

REM ============================================================
REM Map windev:// URL -> WinDev ConEmu Task
REM ============================================================

if /i "%ENV%"=="MSYS2"             set "TASK=WinDev::MSYS2"
if /i "%ENV%"=="Python"            set "TASK=WinDev::Python"
if /i "%ENV%"=="MinGW"             set "TASK=WinDev::MinGW"
if /i "%ENV%"=="MSVC"              set "TASK=WinDev::MSVC"
if /i "%ENV%"=="ClangMinGW"        set "TASK=WinDev::ClangMinGW"
if /i "%ENV%"=="ClangMSVC"         set "TASK=WinDev::ClangMSVC"

if /i "%ENV%"=="Python+MSYS2"      set "TASK=WinDev::Python+MSYS2"
if /i "%ENV%"=="Python+MinGW"      set "TASK=WinDev::Python+MinGW"
if /i "%ENV%"=="Python+MSVC"       set "TASK=WinDev::Python+MSVC"
if /i "%ENV%"=="Python+ClangMSVC"  set "TASK=WinDev::Python+ClangMSVC"
if /i "%ENV%"=="Python+ClangMinGW" set "TASK=WinDev::Python+ClangMinGW"

if not defined TASK (
    echo ERROR: Unknown WinDev environment: [%ENV%]
    pause
    exit /b 1
)

set "CONEMUC=%~dp0../conemu/ConEmu/ConEmuC.exe"

if not exist "%CONEMUC%" (
    echo ERROR: ConEmuC.exe not found:
    echo %CONEMUC%
    pause
    exit /b 1
)

echo Launching: %TASK%

REM EXACT syntax already proven to work from PowerShell:
"%CONEMUC%" -GuiMacro:0 Task(^"%TASK%^")

endlocal
exit /b 0