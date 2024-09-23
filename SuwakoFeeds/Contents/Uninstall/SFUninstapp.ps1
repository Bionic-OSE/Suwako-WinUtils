# Suwako Feeds Uninstaller prompt - (c) Bionic Butter

if(!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -Command `"$PSCommandPath`""; exit
}

Clear-Host
$host.UI.RawUI.WindowTitle = 'Suwako Feeds Uninstaller - (c) Bionic Butter'
Write-Host 'Suwako Feeds - News and Interest on unsupported editions enabler' -ForegroundColor Black -BackgroundColor Cyan
Write-Host "Uninstaller script" -ForegroundColor Black -BackgroundColor White; Write-Host " "

Write-Host -ForegroundColor Yellow "Are sure you want to uninstall Suwako Feeds? Yes to proceed or anything else to cancel"
Write-Host "> " -n; $removefirm = Read-Host

if ($removefirm -like "yes") {
	& $PSScriptRoot\SFUninstaller.ps1
	Write-Host "Press Enter to exit"; Read-Host; exit
}
