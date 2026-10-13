# 📺 TV · Culturas — TV mundial gratis, fluida y legal (con VLC)

**Ver canales de noticias del mundo en vivo (inglés, español, francés, alemán…),
gratis, con autorización oficial, y que funcionen fluido incluso con
internet lenta o una laptop modesta (ej. Chromebook con 4 GB de RAM).**

Este proyecto encuentra SOLO los canales que realmente fluyen desde tu
computadora: prueba cada canal en vivo, usa la variante de menor calidad
(bitrate) —la más fluida— y genera una lista lista para abrir con VLC.

> ⚖️ **Nota legal:** aquí solo se usan canales **gratuitos y autorizados**
> (DW, France 24, CGTN, VOA, TeleSUR, etc.). Las listas "pirata" de canales
> de pago se caen todo el tiempo (lo contrario de fluido) y son ilegales.
> Si un canal está bloqueado en tu región, lo verás como `SIN SEÑAL`.

---

## 📁 Qué contiene este proyecto

| Archivo | Para qué sirve |
|---|---|
| `canales.txt` | ⭐ **Lista editable** de canales. Ahí agregas o quitas canales. |
| `probar-tv.bat` | **Windows**: doble clic para probar y generar la lista. |
| `probar-tv.ps1` | El motor de Windows (lo abre el `.bat` automáticamente). |
| `ver-tv.bat` | **Windows**: doble clic para VER la TV con VLC. |
| `probar-tv.sh` | **Linux/macOS/WSL**: prueba canales y mide fluidez exacta. |
| `ver-tv.sh` | **Linux/macOS/WSL**: abre la TV con VLC. |
| `tv-en-ingles.m3u` | Resultado: la lista que VLC abre (se genera al probar). |

---

## ✅ Requisitos

| Sistema | Qué necesitas |
|---|---|
| **Windows 11** | Solo **VLC** (gratis: <https://www.videolan.org/vlc/>). Nada más. |
| **Linux/macOS** | `ffmpeg`, `curl` y `vlc` (comandos abajo). |

> 💡 En Windows no hace falta instalar ffmpeg: el script usa **el propio VLC**
> para probar los canales.

---

## 🚀 Inicio rápido

### 🪟 Windows 11 (tu otra PC)

1. Copia esta carpeta a tu PC (por USB, o `git clone`).
2. Doble clic en **`probar-tv.bat`** → prueba todos los canales (1–2 min).
3. Ve los resultados en pantalla.
4. Doble clic en **`ver-tv.bat`** → ¡a ver la TV!

### 🐧 Linux / macOS

```bash
# una sola vez:
sudo apt install -y ffmpeg curl vlc      # (macOS: brew install ffmpeg vlc)

# cada vez:
./probar-tv.sh     # prueba canales y genera tv-en-ingles.m3u
./ver-tv.sh        # abre la TV con VLC
```

### 🪟 Windows + WSL (opcional, todo gratis)

```powershell
wsl --install          # instala Linux dentro de Windows
# y dentro de WSL sigue los pasos de Linux de arriba
```

---

## 🧪 Cómo leer los resultados

| Resultado | Significado |
|---|---|
| 🟢 `FLUIDO 2.4x` | El canal se decodifica a 2.4× el tiempo real → **sí fluye** (entra a la lista). |
| 🟡 `LENTO 0.3x` | No da abasto en tu conexión/equipo → no entra (no disfrutarías). |
| 🔴 `SIN SEÑAL` | No responde: **caído o bloqueado por región** (geo-bloqueo). Normal. |

Ejemplos de bloqueos por región: CBS News y algunos de EE.UU. fuera de EE.UU.,
TV Perú dentro de Perú, RTVE 24h dentro de España… Geo es geografía, no un
problema de tu equipo. Los verdes son los que importan.

---

## ✏️ Agregar o quitar canales (canales.txt)

1. Abre `canales.txt` con el **Bloc de notas** (Windows) o `nano` (Linux).
2. Cada línea es un canal con este formato exacto:

   ```
   Nombre que quieras|https://ejemplo.com/canal.m3u8
   ```

3. Lo ideal es pegar la **URL "maestra"** del canal (la que termina en `.m3u8`).
   Los scripts eligen solos la **variante de menor bitrate**.
4. Líneas que empiezan con `#` son comentarios (se ignoran). ¡Úsalas para tomar notas!
5. Guarda, y vuelve a ejecutar `probar-tv.bat` / `probar-tv.sh`.

**Fuentes buenas de canales legales y gratuitos:**

- **iptv-org/iptv** (GitHub): la mayor colección pública de canales gratuitos,
  separados por país e idioma → <https://github.com/iptv-org/iptv>
- Las webs oficiales de cada canal (sección "En vivo"/"Watch Live").

---

## ⚙️ Por qué este proyecto SÍ fluye (los trucos)

1. **Bitrate bajo**: los scripts eligen la variante más ligera del canal
   (ej. 360p/270p ≈ 0.2–1 Mbps) en lugar del 1080p (~5 Mbps) que una
   conexión lenta jamás sostiene. Resultado medible: decodificación a 2+×
   tiempo real.
2. **User-agent de navegador**: varios CDN (Al Jazeera, DW, France 24…)
   rechazan reproductores que no se identifican como navegador. Los scripts
   y lanzadores de VLC mandan ese user-agent automáticamente.

---

## ❗ Solución de problemas

| Problema | Solución |
|---|---|
| "No se encontró VLC" | Instálalo desde <https://www.videolan.org/vlc/> y vuelve a intentar. |
| Windows bloquea el script | Usa `probar-tv.bat` (ya salta la política) o en PowerShell: `powershell -ExecutionPolicy Bypass -File probar-tv.ps1`. |
| Windows Firewall pregunta la primera vez | Es normal (VLC accede a internet). Marca **Permitir acceso** para redes privadas. |
| Todo sale `SIN SEÑAL` | Revisa que haya internet; prueba otra red; o verifica que las URLs de `canales.txt` no hayan caducado. |
| Un canal sale `SIN SEÑAL` pero en tu teléfono sí carga | Es un **bloqueo por región** (ej. canales de EE.UU. fuera de EE.UU.). Prueba canales internacionales (DW, France 24, CGTN). |
| Se ve pero se congela a cada rato | El canal eligió una calidad alta. Cambia el canal a su variante SD/360p en `canales.txt` (o busca su URL de baja calidad). |
| La imagen va lenta pero el audio bien | Es normal en conexiones justas con HLS; baja más la calidad del canal. |
| Quieres probar una URL suelta | En VLC: *Media → Abrir ubicación de red* y pega la URL. |

---

## 🌍 Plan de estudios con la TV (aprender idiomas y culturas)

- **Compara la misma noticia en varios idiomas**: DW (inglés/español/alemán),
  France 24 (inglés/francés/español), CGTN (inglés/español/chino).
  Notarás qué enfatiza cada cultura. 👉 Eso es comprensión cultural real.
- **20 minutos diarios** en un canal de noticias: repetición de frases
  noticiosas = vocabulario que se repite mucho.
- Usa los subtítulos si el canal los ofrece (VLC: *Subtítulos*.)

---

## 📦 Llevar la TV a otro dispositivo (Chromebook, Raspberry Pi, etc.)

Una vez generado `tv-en-ingles.m3u`, cópialo a cualquier equipo con VLC:

- **Chromebook/Linux**: guarda el archivo y ábrelo así:

  ```bash
  vlc --http-user-agent="Mozilla/5.0 (X11; Linux x86_64) Firefox/132.0" tv-en-ingles.m3u
  ```

- **GitHub como puente**: sube el archivo a tu repo y sincronízalo en todos
  tus equipos (`git pull`). ¡Tu nube como infraestructura de TV! 🌟

---

## 🔗 Enlaces útiles

- Descargar VLC: <https://www.videolan.org/vlc/>
- Canales gratuitos por idioma/país (iptv-org): <https://github.com/iptv-org/iptv>
- Guía de listas M3U: <https://docs.videolan.me/vlc-user/3.0/en/playlist/>

---

*Proyecto del laboratorio personal — hecho con VLC, ffmpeg y un poco de bash/PowerShell.*
*Solo canales gratuitos y autorizados. ¡A explorar el mundo! 🌎*