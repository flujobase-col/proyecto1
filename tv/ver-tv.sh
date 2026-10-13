#!/usr/bin/env bash
# ============================================================================
#  ver-tv.sh — LINUX / macOS / WSL: abre la TV con VLC
#  (user-agent de navegador: imprescindible para varios CDN)
#  Requisitos:  sudo apt install -y vlc
# ============================================================================
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UA="Mozilla/5.0 (X11; Linux x86_64) Firefox/132.0"

if [ ! -f "$DIR/tv-en-ingles.m3u" ]; then
  echo "No existe tv-en-ingles.m3u. Ejecuta primero:  ./probar-tv.sh"
  exit 1
fi
command -v vlc >/dev/null || { echo "Instala VLC:  sudo apt install -y vlc"; exit 1; }

exec vlc --no-one-instance --http-user-agent="$UA" "$DIR/tv-en-ingles.m3u"