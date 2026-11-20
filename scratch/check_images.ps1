Add-Type -AssemblyName System.Drawing
$f1 = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795201988526_bfedb32d.jpg'
$img1 = [System.Drawing.Image]::FromFile($f1)
Write-Output "Screenshot: $($img1.Width) x $($img1.Height)"
$img1.Dispose()

$f2 = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795202020308_a07c6450.jpg'
$img2 = [System.Drawing.Image]::FromFile($f2)
Write-Output "Mockup: $($img2.Width) x $($img2.Height)"
$img2.Dispose()
