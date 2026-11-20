$imgs = @(
    'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795206995242_5a7d99a2.jpg',
    'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795206995246_1c1942b1.jpg',
    'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795206995250_88e2096b.jpg',
    'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795206995251_669759e4.jpg',
    'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded\media_1795206995252_0b622342.jpg'
)

Add-Type -AssemblyName System.Drawing
$i = 1
foreach ($f in $imgs) {
    $bmp = [System.Drawing.Bitmap]::FromFile($f)
    Write-Output "Image $i ($([System.IO.Path]::GetFileName($f))): $($bmp.Width) x $($bmp.Height)"
    $bmp.Dispose()
    $dest = "d:\SITE TRAFEGO DR\images\depoimento-foto-$i.jpg"
    Copy-Item $f $dest -Force
    $i++
}

# If there is a 6th file, let's remove it
if (Test-Path "d:\SITE TRAFEGO DR\images\depoimento-foto-6.jpg") {
    Remove-Item "d:\SITE TRAFEGO DR\images\depoimento-foto-6.jpg" -Force
    Write-Output "Removed old depoimento-foto-6.jpg"
}
