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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$URLs = @(
    'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
    'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=313f240448953cd5fe3c5631f4e4de502f23fc9a',
    'https://git.activated.win/massgrave/Microsoft-Activation-Scripts/raw/commit/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd'
)

foreach ($URL in $URLs | Sort-Object { Get-Random }) {
    try { $response = Invoke-WebRequest -Uri $URL -UseBasicParsing; break } catch {}
}

if (-not $response) {
    Check3rdAV
    Write-Host "Failed to retrieve MAS from any of the available repositories, aborting!"
    Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
    return
}

# Verify script integrity
$releaseHash = '919F17B46BF62169E8811201F75EFDF1D5C1504321B78A7B0FB47C335ECBC1B0'
$stream = New-Object IO.MemoryStream
$writer = New-Object IO.StreamWriter $stream
$writer.Write($response)
$writer.Flush()
$stream.Position = 0
$hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
if ($hash -ne $releaseHash) {
    Write-Warning "Hash ($hash) mismatch, aborting!`nReport this issue at $troubleshoot"
    $response = $null
    return
}

# Check for AutoRun registry which may create issues with CMD
$paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
foreach ($path in $paths) { 
    if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) { 
        Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
    } 
}

$rand = [Guid]::NewGuid().Guid
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\MAS_$rand.cmd" }
Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"
CheckFile $FilePath

$env:ComSpec = "$env:SystemRoot\system32\cmd.exe"
$chkcmd = & $env:ComSpec /c "echo CMD is working"
if ($chkcmd -notcontains "CMD is working") {
    Write-Warning "cmd.exe is not working.`nReport this issue at $troubleshoot"
}
Start-Process -FilePath $env:ComSpec -ArgumentList "/c `"$FilePath`" $args" -Wait -NoNewWindow
CheckFile $FilePath

$FilePaths = @("$env:SystemRoot\Temp\MAS*.cmd", "$env:USERPROFILE\AppData\Local\Temp\MAS*.cmd")
foreach ($FilePath in $FilePaths) { Remove-Item -Path $FilePath -Force -ErrorAction SilentlyContinue }

# Optimizations
function OptimizeSystem {
    # Reduce unnecessary processes
    Write-Host "Reducing unnecessary processes..." -ForegroundColor Yellow
    $whitelist = @("explorer.exe", "svchost.exe", "lsass.exe", "services.exe", "wininit.exe")
    Get-Process | Where-Object { $_.ProcessName -notin $whitelist } | ForEach-Object { Stop-Process -Name $_.ProcessName -Force }

    # Set unnecessary services to manual
    Write-Host "Setting unnecessary services to manual..." -ForegroundColor Yellow
    $services = @("DiagTrack", "dmwappushservice", "WSearch", "Fax", "XblGameSave", "XboxNetApiSvc", "RetailDemo", "MapsBroker", "WalletService")
    foreach ($service in $services) {
        Set-Service -Name $service -StartupType Manual
    }

    # Optimize Wi-Fi settings
    Write-Host "Optimizing Wi-Fi settings..." -ForegroundColor Green
    netsh wlan set autoconfig enabled=no interface="Wi-Fi"
    netsh wlan set autoconfig enabled=yes interface="Wi-Fi"
}

# Repair system
function RepairSystem {
    Write-Host "Repairing system..." -ForegroundColor Cyan
    sfc /scannow
    DISM /Online /Cleanup-Image /RestoreHealth
}

# Activate Windows and Office
function ActivateWindowsOffice {
    param (
        [int]$days
    )
    Write-Host "Activating Windows and Office for $days days..." -ForegroundColor Yellow
    .\activate.ps1 $days
}

# Main menu
function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    Write-Host (CenterText " Advanced Windows 11 Optimization Tool ") -ForegroundColor Green
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    Write-Host ""
    Write-Host (CenterText "[1] Optimize System") -ForegroundColor White
    Write-Host (CenterText "[2] Repair System") -ForegroundColor White
    Write-Host (CenterText "[3] Activate Windows and Office") -ForegroundColor White
    Write-Host (CenterText "[4] Exit") -ForegroundColor White
    Write-Host ""
    Write-Host (CenterText "=============================================") -ForegroundColor Cyan
    $option = Read-Host (CenterText "Choose an option [1,2,3,4]")
    return $option
}

# Main loop
do {
    $choice = Show-Menu
    switch ($choice) {
        "1" { OptimizeSystem }
        "2" { RepairSystem }
        "3" {
            $days = Read-Host "Enter the number of days to activate Windows and Office"
            ActivateWindowsOffice -days $days
        }
        "4" { exit }
        default { Write-Host (CenterText "Invalid option, please try again.") -ForegroundColor Red }
    }
    Pause
} while ($choice -ne "4")
