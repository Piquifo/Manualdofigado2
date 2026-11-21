$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
$artifactDir = 'C:\Users\Glemer\.gemini\antigravity\brain\1de7420f-6c24-4569-93e4-bef468ae14b4'

function CaptureElement([string]$targetId, [int]$w, [int]$h, [string]$outName) {
    $rawHtml = [System.IO.File]::ReadAllText('d:\SITE TRAFEGO DR\index.html', [System.Text.Encoding]::UTF8)
    
    # Inject a script right before </body> that scrolls to the element and pauses slightly
    $inject = @"
<script>
window.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('$targetId');
  if (el) {
    el.scrollIntoView({ behavior: 'instant', block: 'start' });
  }
});
</script>
"@
    $customHtml = $rawHtml.Replace('</body>', "$inject`n</body>")
    $tempFile = "d:\SITE TRAFEGO DR\scratch_view.html"
    [System.IO.File]::WriteAllText($tempFile, $customHtml, [System.Text.Encoding]::UTF8)
    
    $outPath = "$artifactDir\$outName"
    $fileUrl = 'file:///d:/SITE%20TRAFEGO%20DR/scratch_view.html'
    
    $args = @(
        '--headless=new',
        '--disable-gpu',
        "--window-size=$w,$h",
        '--hide-scrollbars',
        '--virtual-time-budget=2000',
        '--run-all-compositor-stages-before-draw',
        "--screenshot=$outPath",
        $fileUrl
    )
    
    $p = Start-Process $chrome -ArgumentList $args -Wait -PassThru -NoNewWindow
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
    
    if (Test-Path $outPath) {
        $len = (Get-Item $outPath).Length
        Write-Output "OK: $outName ($len bytes)"
    } else {
        Write-Output "FAILED: $outName"
    }
}

CaptureElement "amostra-receitas" 1200 900 "amostra_receitas_desktop.png"
CaptureElement "amostra-receitas" 375 800 "amostra_receitas_mobile.png"
CaptureElement "bonus" 1200 850 "modulo5_bonus_desktop.png"
