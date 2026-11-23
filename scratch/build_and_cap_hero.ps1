$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
$css = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\style.css', [System.Text.Encoding]::UTF8)
$js = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\script.js', [System.Text.Encoding]::UTF8)

$standalone = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$css`n</style>")
$standalone = $standalone.Replace('<script src="script.js"></script>', "<script>`n$js`n</script>")
[System.IO.File]::WriteAllText('d:\SITE TRAFEGO DR\site-completo-figado.html', $standalone, [System.Text.Encoding]::UTF8)
Write-Output "Rebuilt standalone successfully"

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
                ".png"  { $response.ContentType = "image/png" }
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

Start-Sleep -Milliseconds 600
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$artifactDir = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4'

$argsD = @('--headless=new', '--disable-gpu', '--window-size=1200,750', '--hide-scrollbars', '--virtual-time-budget=2000', '--run-all-compositor-stages-before-draw', "--screenshot=$artifactDir\hero_enfase_desktop.png", 'http://localhost:8080/index.html')
Start-Process $chrome -ArgumentList $argsD -Wait -NoNewWindow

$argsM = @('--headless=new', '--disable-gpu', '--window-size=375,750', '--hide-scrollbars', '--virtual-time-budget=2000', '--run-all-compositor-stages-before-draw', "--screenshot=$artifactDir\hero_enfase_mobile.png", 'http://localhost:8080/index.html')
Start-Process $chrome -ArgumentList $argsM -Wait -NoNewWindow

Stop-Job -Job $job
Remove-Job -Job $job
Write-Output "Captured successfully"
