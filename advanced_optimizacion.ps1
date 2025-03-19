# Verificar permisos de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Ejecuta este script como Administrador." -ForegroundColor Red
    exit
}

# Función para centrar texto
function CenterText {
    param (
        [string]$text
    )
    $width = [System.Console]::WindowWidth
    $padLeft = ($width - $text.Length) / 2
    return $text.PadLeft($padLeft + $text.Length)
}

# Configuraciones persistentes
$configFilePath = "$env:USERPROFILE\advanced_optimizer_config.json"

if (-Not (Test-Path $configFilePath)) {
    $config = @{
        WhitelistProcesses = @("explorer.exe", "python.exe", "svchost.exe")
        BlacklistProcesses = @()
        PrefetchApps = @()
        AntivirusPriority = "normal"
        WifiSettings = @{}
        DisabledServices = @()
        SecuritySettings = @{}
        PerformanceLogs = @()
    }
    $config | ConvertTo-Json | Set-Content $configFilePath
} else {
    $config = Get-Content $configFilePath | ConvertFrom-Json
}

# Función para monitorear y gestionar procesos
function MonitorProcesses {
    while ($true) {
        $allProcesses = Get-Process | Where-Object { $_.ProcessName -notin $config.WhitelistProcesses }
        foreach ($process in $allProcesses) {
            if ($process.ProcessName -in $config.BlacklistProcesses) {
                Stop-Process -Name $process.ProcessName -Force
            }
        }
        Start-Sleep -Seconds 60
    }
}

# Función para optimizar la apertura de aplicaciones
function OptimizeAppOpening {
    while ($true) {
        foreach ($app in $config.PrefetchApps) {
            Start-Process $app
            Start-Sleep -Seconds 10
        }
        Start-Sleep -Minutes 15
    }
}

# Función para gestionar recursos de antivirus
function ManageAntivirusResources {
    while ($true) {
        $antivirusProcesses = Get-Process | Where-Object { $_.ProcessName -match "antivirus" }
        foreach ($process in $antivirusProcesses) {
            if ($config.AntivirusPriority -eq "high") {
                $process.PriorityClass = "High"
            } else {
                $process.PriorityClass = "Normal"
            }
        }
        Start-Sleep -Seconds 60
    }
}

# Función para diagnósticos automáticos
function AutoDiagnostics {
    while ($true) {
        # Simulación de diagnóstico
        Write-Host "Ejecutando diagnóstico del sistema..."
        Start-Sleep -Minutes 60
    }
}

# Función para deshabilitar servicios no utilizados
function DisableUnusedServices {
    foreach ($service in $config.DisabledServices) {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
    }
}

# Función para configurar la seguridad del sistema
function ConfigureSecurity {
    # Configuración de Firewall y otras medidas de seguridad
    Write-Host "Configurando seguridad del sistema..."
}

# Función para actualizar y monitorear el sistema
function UpdateAndMonitor {
    while ($true) {
        # Simulación de actualización
        Write-Host "Actualizando el sistema y monitoreando el rendimiento..."
        Start-Sleep -Hours 24
    }
}

# Mostrar menú principal
function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    Write-Host (CenterText " Advanced Windows 11 Optimization Tool ") -ForegroundColor Green
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    Write-Host ""
    Write-Host (CenterText "[1] Eliminar Bloatware")
    Write-Host (CenterText "[2] Desactivar Servicios Innecesarios")
    Write-Host (CenterText "[3] Optimizar Procesos y Subprocesos")
    Write-Host (CenterText "[4] Limpiar Archivos Temporales")
    Write-Host (CenterText "[5] Activar Windows y Office")
    Write-Host (CenterText "[6] Mostrar Estado del Sistema")
    Write-Host (CenterText "[7] Restaurar Configuración por Defecto")
    Write-Host (CenterText "[8] Actualizar Sistema")
    Write-Host (CenterText "[9] Configurar Seguridad")
    Write-Host (CenterText "[0] Salir")
    Write-Host ""
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    $option = Read-Host (CenterText "Elige una opción [1,2,3,4,5,6,7,8,9,0]")
    return $option
}

# Funciones básicas de optimización
function Remove-Bloatware {
    Write-Host (CenterText "Eliminando Bloatware...") -ForegroundColor Yellow
    .\debloat.ps1
}

function Disable-Services {
    Write-Host (CenterText "Desactivando Servicios Innecesarios...") -ForegroundColor Yellow
    $services = @("DiagTrack", "dmwappushservice", "WSearch", "Fax", "XblGameSave", "XboxNetApiSvc", "RetailDemo", "MapsBroker", "WalletService")
    foreach ($service in $services) {
        Stop-Service -Name $service -Force
        Set-Service -Name $service -StartupType Disabled
    }
}

function Optimize-Processes {
    Write-Host (CenterText "Optimizando Procesos y Subprocesos...") -ForegroundColor Yellow
    Start-Job -ScriptBlock { MonitorProcesses }
    Start-Job -ScriptBlock { OptimizeAppOpening }
    Start-Job -ScriptBlock { ManageAntivirusResources }
}

function Clean-TempFiles {
    Write-Host (CenterText "Limpiando Archivos Temporales...") -ForegroundColor Yellow
    Get-ChildItem -Path "C:\Windows\Temp","C:\Users\$env:UserName\AppData\Local\Temp" -Recurse -Force | Remove-Item -Force -Recurse
    Write-Host (CenterText "Archivos temporales limpiados.") -ForegroundColor Green
}

function Activate-WindowsOffice {
    Write-Host (CenterText "Activando Windows y Office...") -ForegroundColor Yellow
    .\activate.ps1
}

function Show-SystemStatus {
    Write-Host (CenterText "Estado del Sistema:") -ForegroundColor Cyan
    Get-ComputerInfo | Select-Object CsName, OsName, WindowsVersion, OsArchitecture, CsTotalPhysicalMemory
}

function Restore-Defaults {
    Write-Host (CenterText "Restaurando configuración original...") -ForegroundColor Yellow
    .\restore.ps1
}

function Update-System {
    Write-Host (CenterText "Actualizando el sistema y software...") -ForegroundColor Yellow
    Install-Module PSWindowsUpdate -Force -SkipPublisherCheck
    Import-Module PSWindowsUpdate
    Get-WindowsUpdate -Install -AcceptAll -AutoReboot
}

function Configure-Security {
    Write-Host (CenterText "Configurando las políticas de seguridad...") -ForegroundColor Yellow
    # Configuración de seguridad detallada aquí
    ConfigureSecurity
}

# Menú principal
do {
    $choice = Show-Menu
    switch ($choice) {
        "1" { Remove-Bloatware }
        "2" { Disable-Services }
        "3" { Optimize-Processes }
        "4" { Clean-TempFiles }
        "5" { Activate-WindowsOffice }
        "6" { Show-SystemStatus }
        "7" { Restore-Defaults }
        "8" { Update-System }
        "9" { Configure-Security }
        "0" { exit }
        default { Write-Host (CenterText "Opción no válida, intenta de nuevo.") -ForegroundColor Red }
    }
    Pause
} while ($choice -ne "0")
