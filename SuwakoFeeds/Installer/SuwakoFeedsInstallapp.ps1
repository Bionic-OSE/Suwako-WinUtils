# Suwako Feeds Installer menu - (c) Bionic Butter

function Show-Branding {
	Clear-Host
	$host.UI.RawUI.WindowTitle = 'Suwako Feeds Installer - (c) Bionic Butter'
	Write-Host 'Suwako Feeds - News and Interest on unsupported editions enabler' -ForegroundColor Black -BackgroundColor Cyan
	Write-Host "Version 3.0 - Installer package" -ForegroundColor Black -BackgroundColor White; Write-Host " "
}

function Get-UCPDCrap {
	$userchoicep1sserdriver = Get-Service -Name UCPD -ea SilentlyContinue
	if ($userchoicep1sserdriver -ne $null) {
		[string]$ucpdreal = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD" -Name "ImagePath" | Select-Object -ExpandProperty "ImagePath"
		if ($ucpdreal -eq "system32\drivers\UCPD.sys") {return $true} else {return $false}
	} else {return $false}
}
function Remove-UCPDCrap {
	Show-Branding
	#          "=========================== Console default length limit before you have to make a new line ============================"
	Write-Host "The User-Choice Protection Driver (UCPD) is a system driver introduced in April 2024 updates to client Windows 10 2004"
	Write-Host "based and Windows 11. And it is truly nothing but a MENACE. Besides preventing apps from programatically changing"
	Write-Host "your default browser away from Edge, starting from the August 2024 update, it also prevents Suwako Feeds from"
	Write-Host "enabling News and Interests by write protecting the registry value that gatekeeps the feature."
	Write-Host "This driver is hooked up as a service, and I can assure you this is one of those services you can remove without ANY"
	Write-Host "damage to your system (heck, even restores freedom to it). Future updates will not be able to bring it back, and"
	Write-Host "somehow if it does, you can always use this option to trash it again.`r`n"
	Write-Host "With all explainations out of the way, " -ForegroundColor White -n; Write-Host "are you ready to " -ForegroundColor Yellow -n; Write-Host "DESTROY" -ForegroundColor Red -n; Write-Host " UCPD down to its roots? (Yes)" -ForegroundColor Yellow
	
	Write-Host "> " -n; $ucpdie = Read-Host
	if ($ucpdie -like "yes") {
		Start-Process sc.exe -Wait -NoNewWindow -ArgumentList "delete UCPD"
		Unregister-ScheduledTask -TaskName 'UCPD velocity' -TaskPath '\Microsoft\Windows\AppxDeploymentClient\' -Confirm:$false
		Write-Host -ForegroundColor Green "`r`nSuccessfully burned UCPD to ashes. Please restart your system for changes to take effect."
		Write-Host "Press Enter to return to main menu."
		Read-Host; return
	} else {return}
}
function Remove-OldwakoFeeds {
	Show-Branding
	Write-Host -ForegroundColor Yellow "It seems you already have Suwako Feeds on here. It needs to be removed before the new one can be (re)installed.`r`nWanna have the installer do that? Yes to continue or anything else to go back."
	
	Write-Host "> " -n; $removefirm = Read-Host
	if ($removefirm -like "yes") {
		taskkill /f /im SuwakoFeeds.exe /t 
		# v1
		Remove-Item -Path "$env:SYSTEMDRIVE\Bionic\Moriya\SuwakoFeeds.ps1" -Force -ea SilentlyContinue
		Remove-Item -Path "$env:SYSTEMDRIVE\Bionic\Moriya\SuwakoFeeds.exe" -Force -ea SilentlyContinue
		Remove-Item -Path "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\SuwakoFeeds.lnk" -Force -ea SilentlyContinue
		# v2
		$v2installpath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds").SuwakoFeedsPath
		if ($v2installpath -ne $null) {Remove-Item -Path $v2installpath -Force -Recurse}
		Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "Suwako Feeds - News and Interest on Windows 10 LTSC 2021 enabler" -Force -ea SilentlyContinue
		Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "SuwakoFeedsPath" -Force -ea SilentlyContinue
		# v3
		$v3installpath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SuwakoFeeds" -ea SilentlyContinue).InstallLocation
		if ($v3installpath -ne $null) {& $v3installpath\Uninstall\SFUninstaller.ps1}
		return $true
	} else {return $false}
}
function Show-InstallMessage($insl) {
	Show-Branding
	Write-Host "This will install Suwako Feeds to `"$insl\SuwakoFeeds`""
	Write-Host -ForegroundColor White "If you wish to change the installation location, type `"path`". `r`nOtherwise, type `"install`" to begin the installation, and anything else to cancel."
}
function PromptI-SuwakoFeeds {
	# Detect old versions
	$v2installpath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds").SuwakoFeedsPath
	$v3installpath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\SuwakoFeeds" -ea SilentlyContinue).InstallLocation
	if ($v2installpath -ne $null) {$v2installed = Test-Path -Path $v2installpath -ea SilentlyContinue} else {$v2installed = $false}
	if ($v3installpath -ne $null) {$v3installed = Test-Path -Path $v3installpath -ea SilentlyContinue} else {$v3installed = $false}
	$v1installed = Test-Path -Path "$env:SYSTEMDRIVE\Bionic\Moriya\SuwakoFeeds.ps1" -ea SilentlyContinue
	if ($v3installed -or $v2installed -or $v1installed) {$oldremoved = Remove-OldwakoFeeds; if ($oldremoved -eq $false) {return}}
	
	$installpath = "$env:SYSTEMDRIVE\Bionic\Moriya"
	while ($true) {
		Show-InstallMessage($installpath)
		Write-Host "> " -n; $installfirm = Read-Host
		
		switch ($installfirm) {
			{$_ -like "install"} {& $PSScriptRoot\SuwakoFeedsInstaller.ps1 $installpath; exit}
			{$_ -like "path"} {
				Show-Branding
				Write-Host -ForegroundColor White "Type the VAILD full path you want to install Suwako Feeds to, and press Enter. `r`nTo cancel, leave the field blank and press Enter."
				Write-Host -ForegroundColor White "If you cancel the installation, the path you entered will reset to the default."
				Write-Host "> " -n; $installpathinp = Read-Host
				
				if (-not [string]::IsNullOrWhiteSpace($installpathinp)) {$installpath = $installpathinp}
			}
			default {return}
		}
	}
}
$build = [System.Environment]::OSVersion.Version | Select-Object -ExpandProperty "Build"
$ubr = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR
$supported = $build -in 19041..19045
$ubrtoolow = $supported -and $ubr -lt 962
$ucpde = Get-UCPDCrap
	
while ($true) {
	Show-Branding
	
	if ($supported -eq $false) {
		Write-Host "Suwako Feeds is not supported on this version of Windows. Only Windows 10 builds 19041-19045 are supported" -ForegroundColor Red
		Write-Host "Press Enter to exit"
		Read-Host; exit
	}
	if ($ubrtoolow -or $ucpde) {Write-Host "WARNING:" -ForegroundColor Black -BackgroundColor Yellow}
	switch ($true) {
		$ubrtoolow {Write-Host " - Your OS is supported, however is not up to date to have News and Interest. Make sure you're on .962 or newer." -ForegroundColor Yellow}
		$ucpde {Write-Host " - UCPD detected! This bloatware driver will prevent Suwako Feeds from working. You can use option 2 to burn it down." -ForegroundColor Yellow}
	}
	if ($ubrtoolow -or $ucpde) {Write-Host "You may continue, however don't expect the app to work until you resolved these issues.`r`n" -ForegroundColor Yellow}
	
	Write-Host "Welcome to Suwako Feeds, a small app by Bionic Butter that enables the forcefully disabled News and Interest feature`r`non editions like Windows 10 Enterprise LTSC 2021 and CMGE 2022!" -ForegroundColor White
	Write-Host "`r`n Select an action:" -ForegroundColor Cyan
	Write-Host " 1. Install Suwako Feeds" -ForegroundColor White
	if ($ucpde) {Write-Host " 2. Get rid of that UCPD crap" -ForegroundColor White}
	Write-Host " 0. Exit installer" -ForegroundColor White
	Write-Host " "
	Write-Host "> " -n; $sel = Read-Host
	switch ($sel) {
		"1" {PromptI-SuwakoFeeds}
		"2" {if ($ucpde) {Remove-UCPDCrap}}
		"0" {exit}
	}
}
