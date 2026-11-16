@echo off
::set "CONTINUE_GLOBAL_DIR=%WINDEV%ConEmuPack.230724\ConEmu\_Tools\continue"

:: स्क्रिप्ट कहाँ से चल रही है उसका सही पाथ (Read-Only Drive M:\_Tools\vscode)
set "APP_DIR=%~dp0\vscode\"

:: लोकल राइटेबल टेम्पोरेरी पाथ
set "LOCAL_USER_DATA=%WINDEVTEMP%\vscode-dist-userdata"
set "LOCAL_EXT_DIR=%WINDEVTEMP%\vscode-dist-extensions"

:: पुराना वर्चुअल जंक्शन हटाकर नया क्लीन जंक्शन बनाना (बिना एडमिन राइट्स के चलता है)
if exist "%LOCAL_EXT_DIR%" rmdir "%LOCAL_EXT_DIR%"
mklink /J "%LOCAL_EXT_DIR%" "%APP_DIR%frozen-extensions"

:: VS Code को लोकल वर्चुअल पाथ के साथ रन करना
start "" "%APP_DIR%Code.exe" --extensions-dir "%LOCAL_EXT_DIR%" --user-data-dir "%LOCAL_USER_DATA%" --no-sandbox --disable-updates --crash-reporter-directory="%LOCAL_USER_DATA%\crashes" --disable-telemetry %*
