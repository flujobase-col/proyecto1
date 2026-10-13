#!/usr/bin/env bash
# ============================================================================
#  probar-tv.sh — LINUX / macOS / WSL
# ----------------------------------------------------------------------------
#  Lee canales.txt, prueba cada canal en vivo:
#    1. descarga la lista maestra de calidades (el .m3u8 oficial),
#    2. elige SOLA la variante de MENOR bitrate (la mas fluida),
#    3. decodifica 8 segundos y mide si va a tiempo real (speed >= 0.85x).
#  Genera tv-en-ingles.m3u SOLO con los canales FLUIDOS.
#
#  Requisitos:  sudo apt install -y ffmpeg curl vlc
#  Uso:         ./probar-tv.sh            (la lista queda en tv-en-ingles.m3u)
#               ./ver-tv.sh               (abrir la lista con VLC)
# ============================================================================
set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANALES="$DIR/canales.txt"
SALIDA="$DIR/tv-en-ingles.m3u"
UA="Mozilla/5.0 (X11; Linux x86_64) Firefox/132.0"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

for t in curl ffmpeg ffprobe; do
  command -v "$t" >/dev/null || { echo "Falta $t ->  sudo apt install -y ffmpeg curl"; exit 1; }
done
[ -f "$CANALES" ] || { echo "No existe $CANALES (junto a este script)."; exit 1; }
command -v vlc >/dev/null || echo "Aviso: VLC no esta instalado (sudo apt install -y vlc)."

# Elige la variante de MENOR ancho de banda dentro de un maestro .m3u8
variante_baja() {
  awk '
    /#EXT-X-STREAM-INF/ { line=$0; getline uri
      if (match(line, /BANDWIDTH=[0-9]+/)) { bw=substr(line, RSTART+10, RLENGTH-10) }
      if (min=="" || bw<min) { min=bw; mejor=uri } }
    END { print mejor }
  ' "$1"
}

# Convierte una ruta relativa del maestro en URL absoluta
absoluta() {
  case "$2" in
    http*) echo "$2" ;;
    /*) echo "${1%%/$(basename "$1")}/$2" ;;
    *) echo "${1%/*}/$2" ;;
  esac
}

echo "==> Probando canales de: $CANALES   (15-30 s por canal)"
echo "#EXTM3U" > "$TMP/base.m3u"
: > "$TMP/buenos.txt"

while IFS='|' read -r nombre maestro; do
  [ -n "$nombre" ] || continue

  if ! curl -fsSL --max-time 15 -A "$UA" -o "$TMP/m.m3u8" "$maestro" 2>/dev/null; then
    printf 'SIN SEÑAL     | %s\n' "$nombre"
    continue
  fi

  uri=$(variante_baja "$TMP/m.m3u8")
  [ -n "$uri" ] || uri="$maestro"
  url=$(absoluta "$maestro" "$uri")

  vel=$(timeout 45 ffmpeg -user_agent "$UA" -hide_banner -loglevel info -i "$url" \
        -t 8 -f null - 2>&1 | grep -oE 'speed=[ 0-9.]+x' | tail -1)
  num=$(echo "$vel" | tr -d 'speed= x')

  if awk "BEGIN{exit !($num>=0.85)}" 2>/dev/null; then
    printf 'FLUIDO  %-6s | %s\n' "$vel" "$nombre"
    printf '#EXTINF:-1 group-title="Culturas" ,%s\n%s\n' "$nombre" "$url" >> "$TMP/base.m3u"
    echo "$nombre|$url" >> "$TMP/buenos.txt"
  else
    printf 'LENTO   %-6s | %s   (conexion o equipo insuficientes para este canal)\n' "$vel" "$nombre"
  fi
done < <(grep -vE '^[[:space:]]*#|^[[:space:]]*$' "$CANALES")

if [ -s "$TMP/buenos.txt" ]; then
  mv "$TMP/base.m3u" "$SALIDA"
  echo
  echo "=== LISTA GRABADA: $SALIDA ==="
  echo "Canales que fluyen ($(wc -l < "$TMP/buenos.txt")):"
  cut -d'|' -f1 "$TMP/buenos.txt" | sed 's/^/  - /'
  echo
  echo "Para ver la TV:  ./ver-tv.sh"
else
  echo
  echo "=== Ningun canal fluyo desde este PC. Revisa la conexion o las URLs de canales.txt. ==="
fi