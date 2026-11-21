# 1. Start Python HTTP server if not running
$serverProcess = Get-Process -Name python -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*http.server 8080*" }
$startedServer = $null
if (-not $serverProcess) {
    $startedServer = Start-Process python -ArgumentList "-m", "http.server", "8080", "--directory", "d:\SITE TRAFEGO DR" -PassThru -NoNewWindow
    Start-Sleep -Seconds 1
}

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

# Capture Amostra Receitas (Desktop & Mobile)
CaptureViaHttp "amostra-receitas" 1200 950 -30 "amostra_receitas_desktop.png"
CaptureViaHttp "amostra-receitas" 375 880 -10 "amostra_receitas_mobile.png"

# Capture Módulo 5 (Desktop)
CaptureViaHttp "bonus" 1200 900 -20 "modulo5_bonus_desktop.png"

if ($startedServer) {
    Stop-Process -Id $startedServer.Id -Force
}
