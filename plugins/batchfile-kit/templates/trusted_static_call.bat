@echo off
REM Boundary: call static relative helper or :label; never call %VAR% / absolute / UNC.
setlocal
call :work "%~1"
exit /b 0

:work
echo arg=%~1
exit /b 0
