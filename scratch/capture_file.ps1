$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$artifactDir = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4'

function CaptureSectionFile([string]$targetId, [int]$vpW, [int]$vpH, [int]$scrollOffset, [string]$outName) {
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
<iframe id="f" src="file:///d:/SITE%20TRAFEGO%20DR/index.html"></iframe>
<script>
window.onload = () => {
  setTimeout(() => {
    try {
      const doc = document.getElementById('f').contentWindow.document;
      const el = doc.getElementById('${targetId}');
      if (el) {
        el.scrollIntoView({ behavior: 'instant', block: 'start' });
        if (${scrollOffset} !== 0) {
          document.getElementById('f').contentWindow.scrollBy(0, ${scrollOffset});
        }
      }
    } catch (e) {
      console.error(e);
    }
  }, 500);
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
        '--allow-file-access-from-files',
        '--run-all-compositor-stages-before-draw',
        "--screenshot=$outPath",
        'file:///d:/SITE%20TRAFEGO%20DR/scratch_shot.html'
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

CaptureSectionFile "amostra-receitas" 1200 950 -30 "amostra_receitas_desktop.png"
CaptureSectionFile "amostra-receitas" 375 880 -10 "amostra_receitas_mobile.png"
CaptureSectionFile "bonus" 1200 900 -20 "modulo5_bonus_desktop.png"
