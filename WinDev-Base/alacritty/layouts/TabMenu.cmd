@echo off
rem WinDev new-tab menu: pick an environment for this tab.
rem Runs in the same pane, so the environment stays loaded after init.
chcp 65001 >nul

set "WD_NAMES=MSYS2 Python MinGW MSVC ClangMinGW ClangMSVC Python+MSYS2 Python+MinGW Python+MSVC Python+ClangMinGW Python+ClangMSVC"

echo.
echo   Open which environment in this tab?
echo.
echo     1  MSYS2                 Alt+M
echo     2  Python                Alt+P
echo     3  MinGW                 Alt+G
echo     4  MSVC                  Alt+V
echo     5  ClangMinGW            Alt+1
echo     6  ClangMSVC             Alt+2
echo     7  Python+MSYS2          Alt+Shift+M
echo     8  Python+MinGW          Alt+Shift+G
echo     9  Python+MSVC           Alt+Shift+V
echo     0  Python+ClangMinGW     Alt+Shift+1
echo     A  Python+ClangMSVC      Alt+Shift+2
echo.
echo     D  Default WinDev shell
echo.
choice /c 1234567890AD /n /m "  Press a key: "
set "WD_PICK=%errorlevel%"

set "WD_ENV="
if %WD_PICK% lss 12 for /f "tokens=%WD_PICK%" %%e in ("%WD_NAMES%") do set "WD_ENV=%%e"

set "WD_TAB=WinDev"
if defined WD_ENV set "WD_TAB=%WD_ENV%"

where zellij >nul 2>&1 || set "PATH=%PATH%;%ALACRITTY%"
zellij action rename-tab "%WD_TAB%" >nul 2>&1

if defined WD_ENV (
    call "%WINDEV%\WinDev.cmd" TerminalInit %WD_ENV%
) else (
    call "%WINDEV%\WinDev.cmd" TerminalInit
)

set "WD_NAMES=" & set "WD_PICK=" & set "WD_ENV=" & set "WD_TAB="