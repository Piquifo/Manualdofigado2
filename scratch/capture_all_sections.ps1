# 1. Rebuild Standalone
$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
$css = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\style.css', [System.Text.Encoding]::UTF8)
$js = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\script.js', [System.Text.Encoding]::UTF8)

$standalone = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$css`n</style>")
$standalone = $standalone.Replace('<script src="script.js"></script>', "<script>`n$js`n</script>")

[System.IO.File]::WriteAllText('d:\SITE TRAFEGO DR\site-completo-figado.html', $standalone, [System.Text.Encoding]::UTF8)
Write-Output "Rebuilt site-completo-figado.html successfully ($($standalone.Length) bytes)"

# 2. Chrome capture helper
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$artifactDir = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4'

function CaptureViaHttp([string]$targetId, [int]$vpW, [int]$vpH, [int]$scrollOffset, [string]$outName) {
    $wrapHtml = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { margin: 0; padding: 0; background: #0C1812; display: flex; justify-content: center; overflow: hidden; }
iframe { width: ${vpW}px; height: ${vpH}px; border: none; }
</style>
</head>
<body>
<iframe id="f" src="http://localhost:8080/index.html"></iframe>
<script>
window.onload = () => {
  setTimeout(() => {
    const doc = document.getElementById('f').contentWindow.document;
    const el = doc.getElementById('${targetId}');
    if (el) {
      el.scrollIntoView({ behavior: 'instant', block: 'start' });
      if (${scrollOffset} !== 0) {
        document.getElementById('f').contentWindow.scrollBy(0, ${scrollOffset});
      }
    }
  }, 450);
};
</script>
</body>
</html>
"@
    $tempFile = "d:\SITE TRAFEGO DR\scratch_shot.html"
    [System.IO.File]::WriteAllText($tempFile, $wrapHtml, [System.Text.Encoding]::UTF8)
    
    $outPath = "$artifactDir\$outName"
    $winW = $vpW + 20
    $winH = $vpH + 20
    
    $args = @(
        '--headless=new',
        '--disable-gpu',
        "--window-size=$winW,$winH",
        '--hide-scrollbars',
        '--run-all-compositor-stages-before-draw',
        "--screenshot=$outPath",
        'http://localhost:8080/scratch_shot.html'
    )
    
    $p = Start-Process $chrome -ArgumentList $args -Wait -PassThru -NoNewWindow
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
    
    if (Test-Path $outPath) {
        $len = (Get-Item $outPath).Length
        Write-Output "OK: $outName ($len bytes)"
    } else {
        Write-Output "FAILED: $outName"
    }
}

# Capture Módulo 3 (Desktop & Mobile)
CaptureViaHttp "volumes" 1200 950 -30 "modulo3_5guias_updated_desktop.png"
CaptureViaHttp "volumes" 375 920 -10 "modulo3_5guias_updated_mobile.png"

# Capture Módulo 11 (Desktop & Mobile)
CaptureViaHttp "rotina-resultados" 1200 900 -20 "modulo11_rotina_desktop.png"
CaptureViaHttp "rotina-resultados" 375 900 -10 "modulo11_rotina_mobile.png"

# Capture Módulo 10 (Oferta Desktop)
CaptureViaHttp "oferta" 1200 900 -20 "modulo10_oferta_desktop.png"

# Capture Hero (Desktop & Mobile)
CaptureViaHttp "inicio" 1200 750 0 "hero_topo_updated_desktop.png"
CaptureViaHttp "inicio" 375 750 0 "hero_topo_updated_mobile.png"
