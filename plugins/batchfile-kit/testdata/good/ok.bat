@echo off
REM Good fixture: quoted vars, static call, no delayedExpansion, no curl|ps, no secrets in set.
setlocal
set "WORKDIR=%~dp0"
cd /d "%WORKDIR%"
if exist "%~1" type "%~1"
call :greet "%~1"
exit /b 0

:greet
echo hello "%~1"
exit /b 0
