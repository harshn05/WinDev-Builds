@echo off
setlocal EnableExtensions
cd /d "%~dp0"
title WinDev SHA-256 Checksum Generator

echo.
echo ================================================
echo       WinDev SHA-256 Checksum Generator
echo ================================================
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference = 'Stop';" ^
  "$root = (Get-Location).Path;" ^
  "$names = @('WinDev-Base','WinDev-MSYS2','WinDev-Python','WinDev-ToolChains','WinDev-DotNet');" ^
  "$files = @();" ^
  "foreach ($name in $names) { foreach ($ext in @('.iso','.iso.zst')) { $p = Join-Path $root ($name + $ext); if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { throw ('Missing file: ' + $p) }; $files += Get-Item -LiteralPath $p } };" ^
  "$lines = [System.Collections.Generic.List[string]]::new();" ^
  "foreach ($file in $files) { Write-Host ('Hashing: ' + $file.Name); $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant(); $lines.Add($file.Name); $lines.Add($hash); $lines.Add('') };" ^
  "[System.IO.File]::WriteAllLines((Join-Path $root 'checksum.txt'), $lines, [System.Text.Encoding]::ASCII);" ^
  "Write-Host ''; Write-Host 'checksum.txt generated successfully.' -ForegroundColor Green"

if errorlevel 1 (
    echo.
    echo ERROR: Checksum generation failed.
    pause
    exit /b 1
)

echo.
type checksum.txt
echo.
pause