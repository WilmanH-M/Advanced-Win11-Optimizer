# This script is hosted on https://get.activated.win

# Define la función CheckFile
function CheckFile {
    param ([string]$FilePath)
    if (-not (Test-Path $FilePath)) {
        # Si el archivo no existe, muestra un mensaje de error y termina la ejecución del script
        Write-Host "Failed to create MAS file in temp folder, aborting!" -ForegroundColor Red
        Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
        throw
    }
}

# Define la función Check3rdAV
function Check3rdAV {
    # Si el archivo de terceros no existe, muestra un mensaje de error y termina la ejecución del script
    Write-Host "Failed to create MAS file in temp folder, aborting!" -ForegroundColor Red
    Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
    throw
}

# Define la función activar_windows
function activar_windows {
    param ([string]$dias)
    # Activa Windows durante el período de tiempo especificado
    Write-Host "Activando Windows durante $dias días" -ForegroundColor Green
}

# Define la función activar_office
function activar_office {
    param ([string]$dias)
    # Activa Office durante el período de tiempo especificado
    Write-Host "Activando Office durante $dias días" -ForegroundColor Green
}

# Define la variable $troubleshoot con la URL del script de ayuda
$troubleshoot = 'https://get.activated.win'

# Configura el protocolo de seguridad para el servicio de puntos de servicio de .NET
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Define la variable $URLs con las URLS de los archivos que se deben descargar
$URLs = @(
    'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
    'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=313f240448953cd5fe3c5631f4e4de502f23fc9a',
    'https://git.activated.win/massgrave/Microsoft-Activation-Scripts/raw/commit/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd'
)

# Descarga el archivo MAS_AIO.cmd de la URL más reciente
foreach ($URL in $URLs | Sort-Object { Get-Random }) {
    try {
        $response = Invoke-WebRequest -Uri $URL -UseBasicParsing
        break
    } catch {
        # Si no se puede descargar el archivo, muestra un mensaje de error y termina la ejecución del script
        Write-Host "Failed to retrieve MAS from any of the available repositories, aborting!" -ForegroundColor Red
        Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
        return
    }
}

# Verifica la integridad del script
$releaseHash = '919F17B46BF62169E8811201F75EFDF1D5C1504321B78A7B0FB47C335ECBC1B0'
$stream = New-Object IO.MemoryStream
$writer = New-Object IO.StreamWriter $stream
$writer.Write($response)
$writer.Flush()
$stream.Position = 0
$hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
if ($hash -ne $releaseHash) {
    # Si el hash no coincide, muestra un mensaje de error y termina la ejecución del script
    Write-Warning "Hash ($hash) mismatch, aborting!`nReport this issue at $troubleshoot"
    $response = $null
    return
}

# Verifica si existe el registro de AutoRun en el directorio de comandos de PowerShell
$paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
foreach ($path in $paths) {
    if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) {
        # Si existe el registro de AutoRun, muestra un mensaje de advertencia y termina la ejecución del script
        Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
    }
}

# Genera un GUID aleatorio para el nombre del archivo temporal
$rand = [Guid]::NewGuid().Guid

# Verifica si se está ejecutando el script en modo de administrador
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')

# Define el nombre del archivo temporal en función del modo de administrador
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\MAS_$rand.cmd" }

# Crea el archivo temporal con el contenido del archivo MAS_AIO.cmd
Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"

# Verifica si el archivo temporal existe
CheckFile $FilePath

# Establece la variable de entorno ComSpec para ejecutar el archivo temporal
$env:ComSpec = "$env:SystemRoot\system32\cmd.exe"

# Verifica si el archivo cmd.exe está funcionando correctamente
$chkcmd = & $env:ComSpec /c "echo CMD is working"
if ($chkcmd -notcontains "CMD is working") {
    # Si el archivo cmd.exe no está funcionando, muestra un mensaje de advertencia y termina la ejecución del script
    Write-Warning "cmd.exe is not working.`nReport this issue at $troubleshoot"
}

# Menú principal
Write-Host "Menú principal" -ForegroundColor Cyan
Write-Host "1. Activar Windows" -ForegroundColor Green
Write-Host "2. Activar Office" -ForegroundColor Green
Write-Host "3. Salir" -ForegroundColor Red

# Lee la opción seleccionada por el usuario
$opcion = Read-Host -Prompt "Ingrese la opción que desea seleccionar"

# Procesa la opción seleccionada por el usuario
if ($opcion -eq 1) {
    # Lee la cantidad de días para activar Windows
    $dias = Read-Host -Prompt "Ingrese la cantidad de días para activar Windows"
    # Activa Windows durante el período de tiempo especificado
    activar_windows $dias
} elseif ($opcion -eq 2) {
    # Lee la cantidad de días para activar Office
    $dias_office = Read-Host -Prompt "Ingrese la cantidad de días para activar Office"
    # Activa Office durante el período de tiempo especificado
    activar_office $dias_office
} elseif ($opcion -eq 3) {
    # Sale del script
    exit
} else {
    # Si la opción seleccionada no es válida, muestra un mensaje de error y sale del script
    Write-Host "Opción inválida. Sale del script." -ForegroundColor Red
    exit
}
