# Suwako Feeds Uninstaller - (c) Bionic Butter

if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -Command `"$PSCommandPath`""; exit
}

$v3installpath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SuwakoFeeds").InstallLocation
taskkill /f /im SuwakoFeeds.exe
Remove-Item -Path $v3installpath -Force -Recurse
Unregister-ScheduledTask -TaskName "SuwakoFeeds" -TaskPath '\Bionic\' -Confirm:$false
Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SuwakoFeeds" -Force -Recurse
Write-Host -ForegroundColor Green "Uninstall complete"
