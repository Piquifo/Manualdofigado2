Add-Type -AssemblyName System.Drawing
$f = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795202020308_a07c6450.jpg'
$img = [System.Drawing.Image]::FromFile($f)
Write-Output "Dimensions: $($img.Width) x $($img.Height)"
$img.Dispose()
