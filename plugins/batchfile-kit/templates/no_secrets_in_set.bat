@echo off
REM Boundary: no secrets in set; read from CI-injected env already present.
setlocal
if not defined AUTH_TOKEN (
  echo AUTH_TOKEN missing
  exit /b 1
)
echo token present
exit /b 0
