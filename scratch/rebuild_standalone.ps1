$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
$css = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\style.css', [System.Text.Encoding]::UTF8)
$js = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\script.js', [System.Text.Encoding]::UTF8)

$standalone = $html.Replace('<link rel="stylesheet" href="style.css">', "<style>`n$css`n</style>")
$standalone = $standalone.Replace('<script src="script.js"></script>', "<script>`n$js`n</script>")
[System.IO.File]::WriteAllText('d:\SITE TRAFEGO DR\site-completo-figado.html', $standalone, [System.Text.Encoding]::UTF8)
Write-Output "Rebuilt site-completo-figado.html successfully with $([System.IO.FileInfo]::new('d:\SITE TRAFEGO DR\site-completo-figado.html').Length) bytes"
