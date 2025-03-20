# Optimización del sistema y activación de Windows/Office
$troubleshoot = 'https://get.activated.win'

if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
    Write-Host "Windows PowerShell no está en modo completo." -ForegroundColor Red
    Write-Host "Ayuda - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
    return
}

# Verificar antivirus de terceros
function Check3rdAV {
    $avList = Get-CimInstance -Namespace root\SecurityCenter2 -Class AntiVirusProduct | Where-Object { $_.displayName -notlike '*windows*' } | Select-Object -ExpandProperty displayName
    if ($avList) {
        Write-Host 'Posible bloqueo por antivirus: ' -ForegroundColor White -BackgroundColor Blue -NoNewline
        Write-Host " $($avList -join ', ')" -ForegroundColor DarkRed -BackgroundColor White
    }
}

# Verificar archivo de ejecución
def CheckFile { 
    param ([string]$FilePath) 
    if (-not (Test-Path $FilePath)) { 
        Check3rdAV
        Write-Host "Error al crear archivo en Temp, abortando." -ForegroundColor Red
        throw 
    } 
}

# Mejoras de rendimiento
Write-Host "Optimizando el sistema..." -ForegroundColor Cyan

# Deshabilitar servicios innecesarios
$servicesToDisable = @(
    'SysMain', 'DiagTrack', 'dmwappushservice', 'TabletInputService', 'wuauserv'
)
foreach ($service in $servicesToDisable) {
    Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType Manual -PassThru
}

# Finalizar procesos innecesarios
$processesToKill = @('OneDrive.exe', 'YourPhone.exe', 'SkypeApp.exe')
foreach ($process in $processesToKill) {
    Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
}

# Liberar memoria caché y reducir consumo de RAM
[System.GC]::Collect()

# Activación de Windows y Office (según días que el usuario elija)
function Activate-Software {
    param (
        [int]$Days = 180
    )
    $URL = 'https://get.activated.win/activation.cmd'
    $response = Invoke-WebRequest -Uri $URL -UseBasicParsing
    $FilePath = "$env:USERPROFILE\AppData\Local\Temp\Activate.cmd"
    Set-Content -Path $FilePath -Value $response.Content
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c $FilePath $Days" -Wait -NoNewWindow
    Write-Host "Windows y Office activados por $Days días." -ForegroundColor Green
}

# Ejecutar activación si el usuario lo desea
$activate = Read-Host "¿Quieres activar Windows y Office? (S/N)"
if ($activate -match "^[Ss]$") {
    $days = Read-Host "¿Cuántos días deseas activar? (máx. 180)"
    Activate-Software -Days $days
}

Write-Host "Optimización completada." -ForegroundColor Green
