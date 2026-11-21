# 1. Build Standalone
$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
$css = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\style.css', [System.Text.Encoding]::UTF8)
$js = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\script.js', [System.Text.Encoding]::UTF8)

$standalone = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$css`n</style>")
$standalone = $standalone.Replace('<script src="script.js"></script>', "<script>`n$js`n</script>")

[System.IO.File]::WriteAllText('d:\SITE TRAFEGO DR\site-completo-figado.html', $standalone, [System.Text.Encoding]::UTF8)
Write-Output "Rebuilt site-completo-figado.html successfully ($($standalone.Length) bytes)"

# 2. Start HTTP server
$job = Start-Job -ScriptBlock {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:8080/")
    $listener.Start()
    $dir = "d:\SITE TRAFEGO DR"
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        $localPath = $request.Url.LocalPath
        if ($localPath -eq "/" -or $localPath -eq "") { $localPath = "/index.html" }
        $filePath = [System.IO.Path]::Combine($dir, $localPath.TrimStart('/').Replace('/', '\'))
        if ([System.IO.File]::Exists($filePath)) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            switch ($ext) {
                ".html" { $response.ContentType = "text/html; charset=utf-8" }
                ".css"  { $response.ContentType = "text/css; charset=utf-8" }
                ".js"   { $response.ContentType = "application/javascript; charset=utf-8" }
                ".jpg"  { $response.ContentType = "image/jpeg" }
                ".jpeg" { $response.ContentType = "image/jpeg" }
                ".png"  { $response.ContentType = "image/png" }
                ".svg"  { $response.ContentType = "image/svg+xml" }
                default { $response.ContentType = "application/octet-stream" }
            }
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $buf = [System.Text.Encoding]::UTF8.GetBytes("Not found")
            $response.OutputStream.Write($buf, 0, $buf.Length)
        }
        $response.OutputStream.Close()
    }
}

Start-Sleep -Milliseconds 800

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
const f = document.getElementById('f');
f.addEventListener('load', () => {
  setTimeout(() => {
    try {
      const doc = f.contentDocument || f.contentWindow.document;
      const el = doc.getElementById('${targetId}');
      if (el) {
        el.scrollIntoView({ behavior: 'instant', block: 'start' });
        if (${scrollOffset} !== 0) {
          f.contentWindow.scrollBy(0, ${scrollOffset});
        }
      }
    } catch(e) {
      console.error(e);
    }
  }, 250);
});
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
        '--virtual-time-budget=3000',
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

CaptureViaHttp "depoimentos" 1200 850 -20 "depoimentos_removed_beatriz_desktop.png"
CaptureViaHttp "depoimentos" 375 800 -10 "depoimentos_removed_beatriz_mobile.png"

Stop-Job -Job $job
Remove-Job -Job $job
