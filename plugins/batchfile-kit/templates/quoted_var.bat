@echo off
REM Boundary: quote %VAR% in path/command contexts.
setlocal
set "WORKDIR=%~dp0"
cd /d "%WORKDIR%"
if exist "%~1" type "%~1"
exit /b 0
