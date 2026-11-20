# Copy new image to images/mulher-celular.jpg
$src = "C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795208241827_b2addde1.jpg"
$dest = "d:\SITE TRAFEGO DR\images\mulher-celular.jpg"
Copy-Item $src $dest -Force

Write-Output "Copied new image to $dest successfully!"
Get-Item $dest | Select-Object Name, Length, LastWriteTime
