Add-Type -AssemblyName System.Drawing
$f = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795204300073_feca9f81.png'
$img = [System.Drawing.Bitmap]::FromFile($f)
Write-Output "Dimensions: $($img.Width) x $($img.Height)"
$c00 = $img.GetPixel(0, 0)
Write-Output "Pixel (0,0): A=$($c00.A) R=$($c00.R) G=$($c00.G) B=$($c00.B)"
$cMid = $img.GetPixel(250, 10)
Write-Output "Pixel (250,10): A=$($cMid.A) R=$($cMid.R) G=$($cMid.G) B=$($cMid.B)"
$img.Dispose()
