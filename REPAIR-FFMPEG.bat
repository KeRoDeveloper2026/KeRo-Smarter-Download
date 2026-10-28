@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0repair-ffmpeg.ps1" %*
echo.
pause
