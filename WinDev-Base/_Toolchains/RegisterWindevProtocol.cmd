@echo off
setlocal

set "REGEXE=%SystemRoot%\System32\reg.exe"
set "HANDLER=%~dp0WinDevTaskLink.cmd"

echo.
echo [WinDev] Registering windev:// protocol...
echo.
echo Handler:
echo   %HANDLER%
echo.

"%REGEXE%" add "HKCU\Software\Classes\windev" ^
    /ve /t REG_SZ ^
    /d "URL:WinDev Environment Protocol" /f >nul

"%REGEXE%" add "HKCU\Software\Classes\windev" ^
    /v "URL Protocol" ^
    /t REG_SZ ^
    /d "" /f >nul

"%REGEXE%" add "HKCU\Software\Classes\windev\DefaultIcon" ^
    /ve /t REG_SZ ^
    /d "\"%SystemRoot%\System32\cmd.exe\",0" /f >nul

"%REGEXE%" add "HKCU\Software\Classes\windev\shell\open\command" ^
    /ve /t REG_SZ ^
    /d "\"%ComSpec%\" /d /c \"\"%HANDLER%\" \"%%1\"\"" /f >nul

if errorlevel 1 (
    echo.
    echo ERROR: Failed to register windev://
    exit /b 1
)

echo.
echo [WinDev] windev:// protocol registered successfully.
echo.

endlocal