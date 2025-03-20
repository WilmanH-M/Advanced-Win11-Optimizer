$troubleshoot = 'https://get.activated.win'
if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
    $ExecutionContext.SessionState.LanguageMode
    Write-Host "Windows PowerShell is not running in Full Language Mode."
    Write-Host "Help - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
    return
}

function ActivateSoftware {
    $choice = Read-Host "¿Qué deseas activar? (1: Windows, 2: Office, 3: Ambos)"
    if ($choice -notmatch '^[123]$') {
        Write-Host "Selección inválida. Saliendo..." -ForegroundColor Red
        return
    }
    
    $days = Read-Host "Ingresa el número de días para la activación (ejemplo: 180)"
    if ($days -notmatch '^[0-9]+$') {
        Write-Host "Número inválido. Saliendo..." -ForegroundColor Red
        return
    }
    
    if ($choice -eq '1' -or $choice -eq '3') {
        Write-Host "Activando Windows por $days días..." -ForegroundColor Green
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cscript //B C:\Windows\System32\slmgr.vbs /rearm" -Wait
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cscript //B C:\Windows\System32\slmgr.vbs /ato" -Wait
    }
    
    if ($choice -eq '2' -or $choice -eq '3') {
        Write-Host "Activando Office por $days días..." -ForegroundColor Green
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /rearm" -Wait
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cscript //B "C:\Program Files\Microsoft Office\Office16\ospp.vbs" /act" -Wait
    }
    
    Write-Host "Proceso de activación completado." -ForegroundColor Cyan
}

ActivateSoftware
