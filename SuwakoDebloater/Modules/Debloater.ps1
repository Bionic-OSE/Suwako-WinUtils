# Suwako Debloater - Debloat runner module - (c) Bionic Butter

param(
	[Parameter(Mandatory=$true,Position=0)]
	[int32]$debloat_currentuser,
	[Parameter(Mandatory=$true,Position=1)]
	[int32]$debloat_allusers,
	[Parameter(Mandatory=$true,Position=2)]
	[int32]$debloat_provisioned,
	[Parameter(Mandatory=$true,Position=3)]
	[int32]$debloat_onedrive,
	[Parameter(Mandatory=$true,Position=4)]
	[int32]$debloat_edge,
	[Parameter(Mandatory=$true,Position=5)]
	[int32]$debloat_edgewv,
	[Parameter(Mandatory=$true,Position=6)]
	[string]$debloat_excludelistpath,
	[switch]$Auto
)

$debloat_excludelist = @(Get-Content -Path $debloat_excludelistpath)
function Show-NotifyBalloon {
	param(
		[Parameter(Mandatory=$true,Position=0)]
		[string]$title,
		[Parameter(Mandatory=$true,Position=1)]
		[string]$message
	)
	[system.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
	$Global:Balloon = New-Object System.Windows.Forms.NotifyIcon
	$Balloon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\..\SuwakoDebloater.exe")
	$Balloon.BalloonTipText = $message
	$Balloon.BalloonTipTitle = $title
	$Balloon.Visible = $true
	$Balloon.ShowBalloonTip(1000)
}
Import-Module -DisableNameChecking $PSScriptRoot\Branding.psm1
$elevator = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$elevated = $elevator.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($elevated -eq $false) {$debloat_allusers = $debloat_edge = $debloat_edgewv = $false}
if ($debloat_edge -eq $false) {$debloat_edgewv = $false}
Show-Branding 1

if ($Auto -eq $false) {
	Write-Host -ForegroundColor Black -BackgroundColor Yellow "Starting the removal process" -n; Write-Host " in " -ForegroundColor Yellow -n
	for ($startcount = 5; $startcount -gt 0; $startcount--) {
		Write-Host "$startcount... " -ForegroundColor Yellow -n
		Start-Sleep -Seconds 1
	}
	Write-Host "NOW!" -ForegroundColor Red -n
	Write-Host "`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n`r`n"
}

switch (1) {
	$debloat_currentuser {
		Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Removing current user's UWP apps..."
		$d_cu = @(Get-AppxPackage | Where-Object {$debloat_excludelist -notcontains [string]$_.Name})
		foreach ($app in $d_cu) {$app | Remove-AppxPackage -ErrorAction SilentlyContinue}
	}
	$debloat_allusers {
		Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Removing ALL users' UWP apps..."
		$d_au = @(Get-AppxPackage -AllUsers | Where-Object {$debloat_excludelist -notcontains [string]$_.Name})
		foreach ($app in $d_cu) {$app | Remove-AppxPackage -ErrorAction SilentlyContinue}
	}
	$debloat_provisioned {
		Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Removing provisioned UWP apps..."
		$d_pr = @(Get-AppxProvisionedPackage -Online | Where-Object {$debloat_excludelist -notcontains [string]$_.DisplayName})
		foreach ($app in $d_pr) {$app | Remove-AppxProvisionedPackage -Online}
	}
	$debloat_onedrive {& $PSScriptRoot\Deblonedrive.ps1 $debloat_edge}
	$debloat_edge {& $PSScriptRoot\Debloaveyo.ps1 $debloat_edgewv $debloat_onedrive}
}
Write-Host -ForegroundColor Black -BackgroundColor Green "REMOVAL PROCESS COMPLETED!"
if ($Auto -eq $false) {
	Show-NotifyBalloon "Suwako Debloater" "Removal process completed!"
	Start-Sleep -Seconds 7
	$Balloon.Visible = $false
	Write-Host -ForegroundColor Black -BackgroundColor White "Press Enter to close this window."
	Read-Host
} else {Start-Sleep -Seconds 3}
