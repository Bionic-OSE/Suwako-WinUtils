# Suwako Debloater - Main launcher - (c) Bionic Butter
# Tabbed navigation technology sourced from the BioniDKU Menus System project

function Get-SubmenuIndicatorColor {
	param(
		[Parameter(Mandatory=$true,Position=0)]
		[string]$currentmodulenumber,
		[Parameter(Mandatory=$true,Position=1)]
		[string]$targetmodulenumber
	)
	if ($currentmodulenumber -eq $targetmodulenumber) {$colorfg = "Black"; $colorbg = "White"} 
	else {$colorfg = "White"; $colorbg = "Black"}
	return $colorfg, $colorbg
}
function Show-SubmenuIndicator {
	$modulecurrent = Get-Content $PSScriptRoot\Modules\Tabn.ini -ErrorAction SilentlyContinue
	$modulenames = @("Q. Debloat","W. Reinstall","E. Extras")
	Write-Host " -- " -n
	if ($elevated) {Write-Host "Welcome!" -n} else {Write-Host "NON-ELEVATED!" -ForegroundColor Yellow -n}
	for ($moduleno = 1; $moduleno -le $modulenames.Length; $moduleno++) {
		$modulecolorfg, $modulecolorbg = Get-SubmenuIndicatorColor $moduleno $modulecurrent
		Write-Host " [" -n; Write-Host $modulenames[$moduleno - 1] -ForegroundColor $modulecolorfg -BackgroundColor $modulecolorbg -n; Write-Host "]" -n
	}
	Write-Host " R. Exit --`r`n"
}
function Switch-MenusModules {
	param(
		[Parameter(Mandatory=$true)]
		$moduleno
	)
	$moduleno | Out-File $PSScriptRoot\Modules\Tabn.ini
}
Set-Alias -Name Menu -Value Switch-MenusModules
function Switch-MenusCheck {
	param(
		[Parameter(Mandatory=$true)]
		$unem
	)
	switch ($unem) {
		"r" {$global:exitsignal = Confirm-Exit; exit}
		"q" {Menu 1; exit}
		"w" {Menu 2; exit}
		"e" {Menu 3; exit}
	}
}
function Confirm-Exit {
	Show-Branding 0
	Write-Host "Are sure you want to exit?" -ForegroundColor Black -BackgroundColor Yellow
	Write-Host "Type `"R`" and Enter again to exit. Your settings will be cleared if you do so." -ForegroundColor Yellow
	
	Write-Host "> " -n; $cexi = Read-Host
	if ($cexi -like "r") {return $true} else {return $false}
}

Import-Module -DisableNameChecking $PSScriptRoot\Modules\Branding.psm1
$elevator = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$global:elevated = $elevator.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$global:build = [System.Environment]::OSVersion.Version | Select-Object -ExpandProperty "Build"

$global:debloat_currentuser = $true
$global:debloat_allusers = $false
$global:debloat_provisioned = $false
$global:debloat_onedrive = $false
$global:debloat_edge = $false
$global:debloat_edgewv = $false
$global:debloat_excludelist = @()

$global:exitsignal = $false
$tabnexist = Test-Path -Path $PSScriptRoot\Modules\Tabn.ini -PathType Leaf
if ($tabnexist -eq $false) {"1" | Out-File $PSScriptRoot\Modules\Tabn.ini}
while ($exitsignal -eq $false) {
	$moduletargetraw = Get-Content $PSScriptRoot\Modules\Tabn.ini
	$moduletarget = $moduletargetraw.Trim()
	& "$PSScriptRoot\Modules\Tab${moduletarget}.ps1"
}
