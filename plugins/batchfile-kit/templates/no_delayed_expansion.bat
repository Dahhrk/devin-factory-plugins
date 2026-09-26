@echo off
REM Boundary: no EnableDelayedExpansion footgun; prefer quoted %VAR%.
setlocal
set "NAME=%~1"
echo Hello "%NAME%"
exit /b 0
