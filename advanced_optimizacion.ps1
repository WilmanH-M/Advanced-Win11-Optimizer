$troubleshoot = 'https://get.activated.win'
if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
    $ExecutionContext.SessionState.LanguageMode
    Write-Host "Windows PowerShell is not running in Full Language Mode."
    Write-Host "Help - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
    return
}

function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host '3rd party Antivirus might be blocking the script - ' -ForegroundColor White -BackgroundColor Blue -NoNewline
        Write-Host " $($avList -join ', ')" -ForegroundColor DarkRed -BackgroundColor White
    }
}

function CheckFile { 
    param ([string]$FilePath) 
    if (-not (Test-Path $FilePath)) { 
        Check3rdAV
        Write-Host "Failed to create MAS file in temp folder, aborting!"
        Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
        throw 
    } 
}


}

# Activación de Windows y Office - Opción 10
function ActivateWindowsOffice {
    param ([int]$days)
    Write-Host "Activando Windows y Office por $days días..."
    Invoke-Expression "cscript //B C:\Windows\System32\slmgr.vbs /rearm"
    Start-Sleep -Seconds 5
    Invoke-Expression "cscript //B C:\Windows\System32\slmgr.vbs /upk"
    Start-Sleep -Seconds 5
    Invoke-Expression "cscript //B C:\Windows\System32\slmgr.vbs /ato"
    Write-Host "Activación completada por $days días."
}

# Troubleshoot - Opción 11
function Troubleshoot {
    Write-Host "Ejecutando diagnóstico y solución de problemas..."
    Get-EventLog -LogName System -Newest 20
    Write-Host "Revisión completada."
}

# Menú principal
Write-Host "Seleccione una opción:"
Write-Host "9. Optimizar el sistema"
Write-Host "10. Activar Windows y Office"
Write-Host "11. Troubleshoot"
$option = Read-Host "Ingrese el número de opción"

switch ($option) {
    "9" { OptimizeSystem }
    "10" {
        $days = Read-Host "Ingrese la cantidad de días para la activación"
        ActivateWindowsOffice -days $days
    }
    "11" { Troubleshoot }
    default { Write-Host "Opción no válida" }
}
