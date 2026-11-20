# 1. Build Standalone
$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
$css = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\style.css', [System.Text.Encoding]::UTF8)
$js = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\script.js', [System.Text.Encoding]::UTF8)

$standalone = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$css`n</style>")
$standalone = $standalone.Replace('<script src="script.js"></script>', "<script>`n$js`n</script>")

[System.IO.File]::WriteAllText('d:\SITE TRAFEGO DR\site-completo-figado.html', $standalone, [System.Text.Encoding]::UTF8)
Write-Output "Rebuilt site-completo-figado.html successfully ($($standalone.Length) bytes)"

# 2. Start a simple local HTTP server if needed, or render wrapper htmls for precise screenshots
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$artifactDir = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4'

# Create a capture html that scrolls to target section and waits
function CaptureSection([string]$targetId, [int]$w, [int]$h, [string]$outName) {
    $frameHtml = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
body { margin: 0; padding: 0; background: #0C1812; overflow: hidden; }
iframe { width: ${w}px; height: ${h}px; border: none; }
</style>
</head>
<body>
<iframe id="f" src="d:/SITE TRAFEGO DR/index.html"></iframe>
<script>
window.onload = () => {
  setTimeout(() => {
    const doc = document.getElementById('f').contentWindow.document;
    const el = doc.getElementById('${targetId}');
    if (el) {
      el.scrollIntoView({ behavior: 'instant', block: 'start' });
    }
  }, 400);
};
</script>
</body>
</html>
"@
    $tempFile = "d:\SITE TRAFEGO DR\scratch_cap.html"
    [System.IO.File]::WriteAllText($tempFile, $frameHtml, [System.Text.Encoding]::UTF8)
    $outPath = "$artifactDir\$outName"
    
    Start-Process $chrome -ArgumentList '--headless=new', '--disable-gpu', "--window-size=$w,$h", '--hide-scrollbars', '--run-all-compositor-stages-before-draw', "--screenshot=$outPath", "file:///$tempFile" -Wait -NoNewWindow
    
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
    Write-Output "Captured $outName ($w x $h)"
}

CaptureSection "rotina-resultados" 1200 850 "modulo11_rotina_desktop.png"
CaptureSection "rotina-resultados" 375 750 "modulo11_rotina_mobile.png"
CaptureSection "oferta" 1200 850 "modulo10_oferta_desktop.png"
CaptureSection "inicio" 1200 700 "hero_topo_desktop.png"
CaptureSection "inicio" 375 750 "hero_topo_mobile.png"
