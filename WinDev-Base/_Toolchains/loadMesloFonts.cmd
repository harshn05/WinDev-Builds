@echo off
setlocal

REM ============================================================
REM Initialize Meslo / Nerd Fonts for the current user.
REM Call this script after WINDEV_BASE has been resolved and
REM before launching Alacritty or Windows Terminal or ConEmu
REM ============================================================

if not defined WINDEV_BASE (
    echo ERROR: WINDEV_BASE is not defined.
    exit /b 1
)

set "FONT_SOURCE=%WINDEV_BASE%\_OhMyPosh\_fonts"
set "FONT_DEST=%LOCALAPPDATA%\Microsoft\Windows\Fonts"
set "REG_KEY=HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
set "FOUND_FONT="

echo ===================================================
echo           Checking ^& Loading Portable Fonts
echo ===================================================

REM 1. Validate the source directory.
if not exist "%FONT_SOURCE%\" (
    echo ERROR: Font source directory not found:
    echo        "%FONT_SOURCE%"
    exit /b 1
)

REM 2. Create the per-user font directory if required.
if not exist "%FONT_DEST%\" (
    echo [*] Creating User Fonts Directory: "%FONT_DEST%"
    mkdir "%FONT_DEST%"
    if errorlevel 1 (
        echo ERROR: Could not create the user font directory.
        exit /b 1
    )
)

REM 3. Copy missing fonts and always ensure their registry entries exist.
for %%F in ("%FONT_SOURCE%\*.ttf") do (
    if exist "%%~fF" (
        set "FOUND_FONT=1"

        if not exist "%FONT_DEST%\%%~nxF" (
            echo [+] Installing font: %%~nxF
            copy /y "%%~fF" "%FONT_DEST%\%%~nxF" >nul
            if errorlevel 1 (
                echo ERROR: Failed to copy %%~nxF
                exit /b 1
            )
        ) else (
            echo [=] Already copied: %%~nxF
        )

        reg add "%REG_KEY%" /v "%%~nF (TrueType)" /t REG_SZ /d "%FONT_DEST%\%%~nxF" /f >nul
        if errorlevel 1 (
            echo ERROR: Failed to register %%~nxF
            exit /b 1
        )
    )
)

if not defined FOUND_FONT (
    echo ERROR: No TTF fonts found in:
    echo        "%FONT_SOURCE%"
    exit /b 1
)

REM 4. Give Windows a brief moment to propagate font registration.
powershell -NoProfile -Command "Start-Sleep -Milliseconds 100"

endlocal
exit /b 0
