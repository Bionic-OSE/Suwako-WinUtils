# Suwako Debloater - Component reinstall Tab - (c) Bionic Butter

function Remove-EdgeBan {
	Show-Branding 0
	Write-Host "Found yourself unable to install Edge and related stuffs after removing it with this tool? This option is for you." -ForegroundColor White 
	Write-Host "Remove Edge-blocking restrictions? Yes to continue or anything else cancel." -ForegroundColor Yellow 
	Write-Host "> " -n; $unbrickfirm = Read-Host
	
	if ($unbrickfirm -notlike "yes") {return}
	Write-Host "Unbanning..." -ForegroundColor Cyan -BackgroundColor DarkGray 
	Import-Module -DisableNameChecking $PSScriptRoot\Debloaveyo.psm1
	PREPARE_EDGE; PREPARE_WEBVIEW
	Remove-Module $PSScriptRoot\Debloaveyo.psm1
	Write-Host "UNBAN COMPLETE" -ForegroundColor Black -BackgroundColor Green -n; Write-Host ". Try installing Edge and/or WebView now and see if it works"
	Write-Host "Press Enter to return"; Read-Host
}
function Remove-OneDriveBan {
	Show-Branding 0
	$reallowed = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -ErrorAction SilentlyContinue)."DisableFileSyncNGSC"
	if ($reallowed -ne 1) {Write-Host "NOTE:" -ForegroundColor Black -BackgroundColor Yellow -n; Write-Host " It looks like the restriction is not here, but you can still try to remove it." -ForegroundColor White}
	Write-Host "Reallow installing OneDrive on this device? Yes to continue or anything else cancel." -ForegroundColor Yellow 
	Write-Host "> " -n; $unbrickfirm = Read-Host
	
	if ($unbrickfirm -notlike "yes") {return}
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Force -ErrorAction SilentlyContinue
	Write-Host -ForegroundColor Black -BackgroundColor Green "UNBANNED"
	Write-Host "Press Enter to return"; Read-Host
}
function Show-Menu {
	Show-Branding 0
	Show-SubmenuIndicator
	
	if ($elevated) {$elevoptsclr = "White"; $nonelevatedtext = $null} else {
		$elevoptsclr = "DarkGray"
		$nonelevatedtext = "(Requires elevation to work)"
	}
	
	#Write-Host " Reinstall components (current user only)"
	#Write-Host " 1. Install App Installer" -ForegroundColor White -n; Write-Host ".." -ForegroundColor DarkGray
	#Write-Host " 2. Install Microsoft Store" -ForegroundColor White -n; Write-Host ".." -ForegroundColor DarkGray
	#Write-Host " 3. Install UWP Notepad (classic UI)" -ForegroundColor White -n; Write-Host ".." -ForegroundColor DarkGray
	#Write-Host " 4. Install Windows Defender app" -ForegroundColor White -n; Write-Host "..`r`n" -ForegroundColor DarkGray
	Write-Host " Reinstall components"
	Write-Host "  < Section coming soon! >`r`n" -ForegroundColor DarkGray
	Write-Host " Unban components $nonelevatedtext"
	Write-Host " 1. Unban Microsoft Edge (& WebView)" -ForegroundColor $elevoptsclr -n; if ($elevated) {Write-Host ".." -ForegroundColor DarkGray} else {Write-Host $null}
	Write-Host " 2. Unban Microsoft OneDrive" -ForegroundColor $elevoptsclr -n; if ($elevated) {Write-Host ".." -ForegroundColor DarkGray} else {Write-Host $null}
	Write-Host $null
}

while ($true) {
	Show-Menu
	Write-Host "> " -n; $unem = Read-Host
	Switch-MenusCheck $unem
	
	switch ($unem) {
		"1" {if ($elevated) {Remove-EdgeBan}}
		"2" {if ($elevated) {Remove-OneDriveBan}}
	}
}
