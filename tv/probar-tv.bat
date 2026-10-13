@echo off
rem =====================================================================
rem  probar-tv.bat — WINDOWS: prueba los canales y crea tv-en-ingles.m3u
rem  (abre el script probar-tv.ps1 sin bloqueos de politicas de Windows)
rem =====================================================================
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0probar-tv.ps1"
echo.
pause