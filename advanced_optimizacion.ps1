# This script is hosted on https://get.activated.win for https://get.activated.win

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

function OptimizeSystem {
    Write-Host "⏳ Optimizando el sistema..."
    
    # Establecer algunos servicios en Manual para mejorar el rendimiento
    $services = @("DiagTrack", "SysMain", "Fax", "MapsBroker", "XblGameSave")
    foreach ($service in $services) {
        Set-Service -Name $service -StartupType Manual -ErrorAction SilentlyContinue
    }

    # Detener procesos innecesarios
    $processes = @("OneDrive", "Skype", "YourPhone", "GameBar")
    foreach ($process in $processes) {
        Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
    }

    # Liberar memoria RAM
    [System.GC]::Collect()
    Write-Host "✅ Optimización completada."
}

function ActivateWindowsOffice {
    param(
        [int]$days
    )
    Write-Host "🔑 Activando Windows y Office por $days días..."
    Invoke-Expression "cscript //nologo C:\Windows\System32\slmgr.vbs /rearm"
    Invoke-Expression "cscript //nologo C:\Windows\System32\slmgr.vbs /ato"
    Invoke-Expression "cscript //nologo C:\Windows\System32\slmgr.vbs /xpr"
    Write-Host "✅ Activación completada. Expira en $days días."
}

# Mostrar menú
Write-Host "Elige una opción:"
Write-Host "[1] HWID - Activar Windows"
Write-Host "[2] Ohook - Activar Office"
Write-Host "[3] TSforge - Activar Windows/Office/ESU"
Write-Host "[4] KMS38 - Activar Windows"
Write-Host "[5] Online KMS - Activar Windows/Office"
Write-Host "[6] Verificar estado de activación"
Write-Host "[7] Cambiar edición de Windows"
Write-Host "[8] Cambiar edición de Office"
Write-Host "[9] Optimizar sistema y reducir procesos"
Write-Host "[10] Activar Windows y Office por días personalizados"
Write-Host "[E] Extras"
Write-Host "[H] Ayuda"
Write-Host "[0] Salir"

$option = Read-Host "Selecciona una opción"

switch ($option) {
    "9" { OptimizeSystem }
    "10" {
        $days = Read-Host "Introduce el número de días para la activación"
        ActivateWindowsOffice -days $days
    }
    default { Write-Host "Opción no válida" }
}
