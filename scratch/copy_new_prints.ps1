$uploads = @(
    @{ src = 'media_1795233593858_f21dc243.jpg'; name = 'print-exercicio-prancha.jpg'; cat = 'Exercício' },
    @{ src = 'media_1795233595544_c0b2b044.jpg'; name = 'print-exercicio-elevacao.jpg'; cat = 'Exercício' },
    @{ src = 'media_1795233715898_66588983.jpg'; name = 'print-almoco-abobora.jpg'; cat = 'Almoço' },
    @{ src = 'media_1795233717051_a786d15e.jpg'; name = 'print-almoco-pimentao.jpg'; cat = 'Almoço' },
    @{ src = 'media_1795233789188_0f04fcaa.jpg'; name = 'print-cafe-bolo.jpg'; cat = 'Café' },
    @{ src = 'media_1795233790558_11e8a893.jpg'; name = 'print-cafe-panqueca.jpg'; cat = 'Café' },
    @{ src = 'media_1795233845350_34cb0578.jpg'; name = 'print-jantar-sopa.jpg'; cat = 'Jantar' },
    @{ src = 'media_1795233908238_8bfd4177.jpg'; name = 'print-bebida-kefir.jpg'; cat = 'Bebidas' }
)

$baseDir = "C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4\.user_uploaded"
$destDir = "d:\SITE TRAFEGO DR\images"

Add-Type -AssemblyName System.Drawing

foreach ($item in $uploads) {
    $srcPath = Join-Path $baseDir $item.src
    $destPath = Join-Path $destDir $item.name
    Copy-Item $srcPath $destPath -Force
    $bmp = [System.Drawing.Bitmap]::FromFile($destPath)
    Write-Output "Copied $($item.name): $($bmp.Width) x $($bmp.Height) ($($item.cat))"
    $bmp.Dispose()
}

# Remove old unused recipe print files
$oldPrints = @(
    'receita-cafe-omelete.jpg',
    'receita-cafe-crepioca.jpg',
    'receita-almoco-salada.jpg',
    'receita-almoco-frango.jpg',
    'receita-janta-quinoa.jpg',
    'receita-janta-abobrinha.jpg',
    'receita-janta-peixe.jpg',
    'receita-bebida-cenoura.jpg',
    'receita-bebida-cha.jpg'
)

foreach ($old in $oldPrints) {
    $oldPath = Join-Path $destDir $old
    if (Test-Path $oldPath) {
        Remove-Item $oldPath -Force
        Write-Output "Removed old print: $old"
    }
}
