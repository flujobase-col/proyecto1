# ============================================================================
#  probar-tv.ps1 — WINDOWS 11 (solo con VLC, sin instalar nada mas)
# ----------------------------------------------------------------------------
#  Lee canales.txt, prueba cada canal en vivo USANDO VLC:
#    1. pide la lista maestra de calidades (.m3u8 oficial),
#    2. elige SOLA la variante de MENOR bitrate (la mas fluida),
#    3. reproduce 8 segundos con VLC en modo oculto; si no hay errores,
#       el canal pasa.
#  Genera tv-en-ingles.m3u SOLO con los canales que funcionaron.
#
#  Como ejecutar:  doble clic en probar-tv.bat  (o este script via
#                  powershell -ExecutionPolicy Bypass -File probar-tv.ps1)
# ============================================================================

# En Windows PowerShell 5.1 hay que forzar TLS 1.2 o las URLs https fallan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ErrorActionPreference = 'Continue'

# ---------- configuracion ----------
$Dir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$Lista  = Join-Path $Dir 'canales.txt'
$Salida = Join-Path $Dir 'tv-en-ingles.m3u'
$UA     = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'

# ---------- 1) localizar VLC (por si acaso no esta en el PATH) ----------
function Find-Vlc {
  $cands = @('vlc',
             "$env:ProgramFiles\VideoLAN\VLC\vlc.exe",
             "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc.exe",
             "$env:LOCALAPPDATA\VideoLAN\VLC\vlc.exe")
  foreach ($c in $cands) {
    try { $g = Get-Command $c -ErrorAction Stop; return $g.Source } catch {}
    if (Test-Path $c) { return $c }
  }
  return $null
}
$VLC = Find-Vlc
if (-not $VLC) {
  Write-Host "No se encontro VLC." -ForegroundColor Red
  Write-Host "Instala VLC desde https://www.videolan.org/vlc/ y vuelve a intentar." -ForegroundColor Yellow
  exit 1
}
Write-Host "VLC detectado: $VLC" -ForegroundColor DarkGray

# ---------- 2) leer canales.txt ----------
if (-not (Test-Path $Lista)) {
  Write-Host "Falta $Lista (copia canales.txt junto a este script)." -ForegroundColor Red
  exit 1
}
$lineas = Get-Content $Lista -Encoding UTF8 | Where-Object {
  $_.Trim().Length -gt 0 -and -not $_.TrimStart().StartsWith('#')
}
if (-not $lineas) { Write-Host "canales.txt no tiene canales." -ForegroundColor Red; exit 1 }

# ---------- helpers ----------
# Convierte una ruta relativa de un maestro .m3u8 en URL absoluta
function Resolver-Url {
  param([string]$base, [string]$ruta)
  if ($ruta -match '^https?://') { return $ruta }
  if ($ruta.StartsWith('/')) {
    $u = New-Object System.Uri $base
    return "$($u.Scheme)://$($u.Host)$ruta"
  }
  $idx = $base.LastIndexOf('/')
  return $base.Substring(0, $idx + 1) + $ruta
}

# Elige la variante de MENOR ancho de banda dentro de un maestro .m3u8
function Elegir-VarianteBaja {
  param([string[]]$master, [string]$base)
  $min = $null; $uri = $null; $x = 0
  while ($x -lt $master.Count) {
    $l = $master[$x].Trim()
    if ($l -match '#EXT-X-STREAM-INF') {
      $bw = 0
      if ($l -match 'BANDWIDTH=(\d+)') { $bw = [int]$Matches[1] }
      $y = $x + 1; $u = $null
      while ($y -lt $master.Count -and -not $u) {
        $t = $master[$y].Trim()
        if ($t -and -not $t.StartsWith('#')) { $u = $t }
        $y++
      }
      if ($u -and ($null -eq $min -or $bw -lt $min)) { $min = $bw; $uri = $u }
      $x = $y
    } else { $x++ }
  }
  if ($uri) { return $uri } else { return $base }
}

# ---------- 3) probar cada canal ----------
$buenos = @()
$i = 0
foreach ($linea in $lineas) {
  $i++
  $partes = $linea -split '\|', 2
  if ($partes.Count -lt 2) { continue }
  $nombre = $partes[0].Trim()
  $url    = $partes[1].Trim()
  Write-Host -NoNewline ("[{0:D2}/{1:D2}] {2} ... " -f $i, $lineas.Count, $nombre)

  # 3a) pedir el maestro y elegir la variante mas ligera
  $urlFinal = $url
  try {
    $resp = Invoke-WebRequest -Uri $url -Headers @{ 'User-Agent' = $UA } -UseBasicParsing -TimeoutSec 15
    if ($resp.StatusCode -ne 200) { throw "HTTP $($resp.StatusCode)" }
    if ($resp.Content -is [byte[]]) {
      $contenido = [System.Text.Encoding]::UTF8.GetString($resp.Content)
    } else {
      $contenido = [string]$resp.Content
    }
    $master = $contenido -split "`n"
    $uri = Elegir-VarianteBaja $master $url
    $urlFinal = Resolver-Url $url $uri
  } catch {
    $motivo = (($_.Exception.Message -split "`n")[0]).Trim()
    Write-Host ("SIN SEÑAL  ({0})" -f $motivo) -ForegroundColor Yellow
    continue
  }

  # 3b) reproducir 8 segundos con VLC en modo oculto y revisar errores
  $log = Join-Path $env:TEMP ("tvtest_{0}_{1}.log" -f $pid, $i)
  Remove-Item $log -ErrorAction SilentlyContinue

  $null = & $VLC '--intf=dummy' '--play-and-exit' '--run-time=8' '--no-one-instance' `
                 '--no-video-title-show' "--http-user-agent=$UA" '--verbose=2' "--logfile=$log" $urlFinal 2>&1
  $code = $LASTEXITCODE

  $errores = @()
  if (Test-Path $log) {
    $errores = Get-Content $log | Select-String -Pattern 'core error|http error|unable to open|404|403|timeout|connection refused|stream error' | Select-Object -First 3
  }

  if ($code -eq 0 -and $errores.Count -eq 0) {
    Write-Host "FLUIDO" -ForegroundColor Green
    $buenos += [PSCustomObject]@{ Nombre = $nombre; Url = $urlFinal }
  } else {
    Write-Host ("FALLO  (codigo VLC={0}, errores={1})" -f $code, $errores.Count) -ForegroundColor Red
  }
}

# ---------- 4) escribir tv-en-ingles.m3u ----------
if ($buenos.Count -gt 0) {
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.AppendLine('#EXTM3U')
  foreach ($b in $buenos) {
    [void]$sb.AppendLine(('#EXTINF:-1 group-title="Culturas" ,{0}' -f $b.Nombre))
    [void]$sb.AppendLine($b.Url)
  }
  [System.IO.File]::WriteAllText($Salida, $sb.ToString(), (New-Object System.Text.UTF8Encoding $true))

  Write-Host ""
  Write-Host "=== LISTA GRABADA: $Salida ===" -ForegroundColor Cyan
  Write-Host ("Canales que funcionaron: {0}" -f $buenos.Count)
  $buenos | ForEach-Object { Write-Host ("  - {0}" -f $_.Nombre) }
  Write-Host ""
  Write-Host "Para ver la TV: doble clic en ver-tv.bat"
} else {
  Write-Host ""
  Write-Host "Ningun canal funciono desde este PC. Revisa la conexion o las URLs de canales.txt." -ForegroundColor Yellow
}