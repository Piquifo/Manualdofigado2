$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8080/")
$listener.Start()
Write-Output "Listening on http://localhost:8080/"

$dir = "d:\SITE TRAFEGO DR"

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    
    $localPath = $request.Url.LocalPath
    if ($localPath -eq "/" -or $localPath -eq "") {
        $localPath = "/index.html"
    }
    
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
