@echo off
REM Boundary: no curl|powershell download-exec; prefer local checksummed script.
setlocal
call "%~dp0scripts\install.bat"
exit /b 0
