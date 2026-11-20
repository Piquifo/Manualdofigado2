$html = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html')
$regex = [regex]'<img\s+[^>]*src="([^"]+)"'
$matches = $regex.Matches($html)
$srcs = @()
foreach ($m in $matches) {
    $srcs += $m.Groups[1].Value
}
$srcs | Sort-Object -Unique
