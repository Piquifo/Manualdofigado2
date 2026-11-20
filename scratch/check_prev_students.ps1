$files = @(
    'media_1795111581853_dc3f4628.jpg',
    'media_1795111581855_1579c24d.jpg',
    'media_1795114026592_b872e438.jpg'
)

$base = "C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded"
Add-Type -AssemblyName System.Drawing

foreach ($f in $files) {
    $path = Join-Path $base $f
    if (Test-Path $path) {
        $bmp = [System.Drawing.Bitmap]::FromFile($path)
        Write-Output "$f : $($bmp.Width) x $($bmp.Height)"
        $bmp.Dispose()
    }
}
