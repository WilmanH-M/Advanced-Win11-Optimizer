1# This script is hosted on https://get.activated.win
2
3$troubleshoot = 'https://get.activated.win'
4if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) {
5    $ExecutionContext.SessionState.LanguageMode
6    Write-Host "Windows PowerShell is not running in Full Language Mode."
7    Write-Host "Help - https://gravesoft.dev/fix_powershell" -ForegroundColor White -BackgroundColor Blue
8    return
9}
10function CheckFile { 
11    param ([string]$FilePath) 
12    if (-not (Test-Path $FilePath)) { 
13        Check3rdAV
14        Write-Host "Failed to create MAS file in temp folder, aborting!"
15        Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
16        throw 
17    } 
18}
19
20[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
21$URLs = @(
22    'https://raw.githubusercontent.com/massgravel/Microsoft-Activation-Scripts/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd',
23    'https://dev.azure.com/massgrave/Microsoft-Activation-Scripts/_apis/git/repositories/Microsoft-Activation-Scripts/items?path=/MAS/All-In-One-Version-KL/MAS_AIO.cmd&versionType=Commit&version=313f240448953cd5fe3c5631f4e4de502f23fc9a',
24    'https://git.activated.win/massgrave/Microsoft-Activation-Scripts/raw/commit/313f240448953cd5fe3c5631f4e4de502f23fc9a/MAS/All-In-One-Version-KL/MAS_AIO.cmd'
25)
26
27foreach ($URL in $URLs | Sort-Object { Get-Random }) {
28    try { $response = Invoke-WebRequest -Uri $URL -UseBasicParsing; break } catch {}
29}
30
31if (-not $response) {
32    Check3rdAV
33    Write-Host "Failed to retrieve MAS from any of the available repositories, aborting!"
34    Write-Host "Help - $troubleshoot" -ForegroundColor White -BackgroundColor Blue
35    return
36}
37
38# Verify script integrity
39$releaseHash = '919F17B46BF62169E8811201F75EFDF1D5C1504321B78A7B0FB47C335ECBC1B0'
40$stream = New-Object IO.MemoryStream
41$writer = New-Object IO.StreamWriter $stream
42$writer.Write($response)
43$writer.Flush()
44$stream.Position = 0
45$hash = [BitConverter]::ToString([Security.Cryptography.SHA256]::Create().ComputeHash($stream)) -replace '-'
46if ($hash -ne $releaseHash) {
47    Write-Warning "Hash ($hash) mismatch, aborting!`nReport this issue at $troubleshoot"
48    $response = $null
49    return
50}
51
52# Check for AutoRun registry which may create issues with CMD
53$paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
54foreach ($path in $paths) { 
55    if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) { 
56        Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
57    } 
58}
59
60$rand = [Guid]::NewGuid().Guid
61$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
62$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:USERPROFILE\AppData\Local\Temp\MAS_$rand.cmd" }
63Set-Content -Path $FilePath -Value "@::: $rand `r`n$response"
64CheckFile $FilePath
65
66$env:ComSpec = "$env:SystemRoot\system32\cmd.exe"
67$chkcmd = & $env:ComSpec /c "echo CMD is working"
68if ($chkcmd -notcontains "CMD is working") {
69    Write-Warning "cmd.exe is not working.`nReport this issue at $troubleshoot"
70}
71# Remove this line to avoid executing the other command
72# saps -FilePath $env:ComSpec -ArgumentList "/c """"$FilePath"" $args""" -Wait
73CheckFile $FilePath
74
75$FilePaths = @("$env:SystemRoot\Temp\MAS*.cmd", "$env:USERPROFILE\AppData\Local\Temp\MAS*.cmd")
76foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
