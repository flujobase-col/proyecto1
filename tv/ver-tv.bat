@echo off
rem =====================================================================
rem  ver-tv.bat — WINDOWS: abre TV desde tv-en-ingles.m3u con VLC
rem  (usa un user-agent de navegador, imprescindible para varios CDN)
rem =====================================================================
cd /d "%~dp0"
if not exist "tv-en-ingles.m3u" (
  echo No existe tv-en-ingles.m3u.
  echo Ejecuta primero probar-tv.bat para generar la lista de canales.
  echo.
  pause
  exit /b 1
)

set "UA=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36"

set "VLC="
where vlc >nul 2>&1 && set "VLC=vlc.exe"
if not defined VLC if exist "%ProgramFiles%\VideoLAN\VLC\vlc.exe"  set "VLC=%ProgramFiles%\VideoLAN\VLC\vlc.exe"
if not defined VLC if exist "%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe" set "VLC=%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe"

if not defined VLC (
  echo No se encontro VLC. Instala VLC desde https://www.videolan.org/vlc/
  echo.
  pause
  exit /b 1
)

"%VLC%" --no-one-instance --http-user-agent="%UA%" "%~dp0tv-en-ingles.m3u"