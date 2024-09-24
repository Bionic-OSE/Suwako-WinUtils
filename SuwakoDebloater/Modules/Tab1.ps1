# Suwako Debloater - Debloat Tab - (c) Bionic Butter

function Show-Disenabled {
	param(
		[Parameter(Mandatory=$true)]
		[bool]$value
	)
	if ($value) {Write-Host -ForegroundColor Green " (ENABLED)"}
	else {Write-Host -ForegroundColor Red " (DISABLED)"}
}
function Select-Disenabled {
	param(
		[Parameter(Mandatory=$true)]
		[bool]$value
	)
	if ($value) {return $false}
	else {return $true}
}
Set-Alias -Name State -Value Show-Disenabled
Set-Alias -Name Toggle -Value Select-Disenabled
function Check-AtLeastOneEnabled {
	param(
		[Parameter(Mandatory=$true)]
		$debloats
	)
	$quorum = $debloats | Where-Object {$_ -eq $true} | Measure-Object | Select-Object -ExpandProperty Count
	return $quorum
}
function Show-Menu {
	Show-Branding 0
	Show-SubmenuIndicator
	
	if ($elevated) {$elevoptsclr = "White"; $nonelevatedtext = $null} else {
		$elevoptsclr = "DarkGray"
		$nonelevatedtext = "(Some options are unavailable in non-elevated mode)"
	}
	$startallowed = Check-AtLeastOneEnabled $debloats
	if ($startallowed) {$startclr = "White"} else {$startclr = "DarkGray"}
	if ($debloat_edge) {$edgwvclr = "White"} else {$edgwvclr = "DarkGray"}
	
	Write-Host " Debloat options $nonelevatedtext"
	Write-Host " 1. Remove ALL apps for the current user" -ForegroundColor White -n; State $debloat_currentuser
	Write-Host " 2. Remove ALL apps for ALL OTHERS (except this user)" -ForegroundColor $elevoptsclr -n; if ($elevated) {State $debloat_allusers} else {Write-Host $null}
	Write-Host " 3. Remove ALL provisioned apps (for new users)" -ForegroundColor $elevoptsclr -n; if ($elevated) {State $debloat_provisioned} else {Write-Host $null}
	Write-Host " 4. Remove and ban OneDrive" -ForegroundColor $elevoptsclr -n; if ($elevated) {State $debloat_onedrive} else {Write-Host $null}
	Write-Host " 5. Remove and ban Edge Chromium" -ForegroundColor $elevoptsclr -n; if ($elevated) {Write-Host " (NOT recommended)" -ForegroundColor Yellow -n; State $debloat_edge} else {Write-Host $null}
	Write-Host " 6. Remove and ban EdgeWebView together with Edge" -ForegroundColor $edgwvclr -n; if ($debloat_edge) {State $debloat_edgewv} else {Write-Host $null}
	Write-Host $null
	Write-Host " Exclude"
	Write-Host " 7. Exclude apps from the removal (coming soon!)" -ForegroundColor DarkGray -n; Write-Host "`r`n" -ForegroundColor DarkGray
	Write-Host " G. Start debloating" -ForegroundColor $startclr -n; if ($startallowed) {Write-Host "..`r`n" -ForegroundColor DarkGray} else {Write-Host "`r`n"}
}
function Confirm-Debloat {
	Show-Branding 0
	if ($debloat_allusers) {$syswide = ", SYSTEM WIDE"} else {$syswide = $null}
	if ($debloat_edgewv) {$sysedge = " and its relatives"} else {$sysedge = $null}
	Write-Host -ForegroundColor Black -BackgroundColor Yellow "Are SURE you want to start the removal process?"
	Write-Host -ForegroundColor White "This will remove EVERY, SINGLE, EXISTING UWP APP POSSIBLE (including the Store!)$syswidefrom your device`r`n(except those you and the debloater itself excluded)."
	if ($debloat_edge) {Write-Host -ForegroundColor White "In addition, Edge$sysedge will also be removed. This WILL stop Explorer, so please save your work in all`r`nopening Explorer windows before continuing."}
	Write-Host -ForegroundColor Yellow "`r`nIf you know what you are doing and wish to continue, type `"Yes`" to start debloating."
	Write-Host "> " -n; $removefirm = Read-Host
	
	if ($removefirm -like "yes") {
		Show-Branding 0
		Write-Host "Removal in progress..." -ForegroundColor Cyan -BackgroundColor DarkGray
		# I could not find a way to pass the array as-is to the script that's going to run in another window, meaning we're gonna have to save it to disk (and actually, this can allow users to load their own saved exclusions too, will implement that later).
		# Also, we need to convert the booleans to 0s and 1s, since the argument won't accept booleans as strings (trust me I've tried for nearly half an hour)
		. $PSScriptRoot\Exclusys.ps1
		$debloat_excludefinal = @()
		foreach ($exclusion in $debloat_exclusys) {$debloat_excludefinal += $exclusion}
		foreach ($exclusion in $debloat_excludelist) {$debloat_excludefinal += $exclusion}
		
		$ec = "$PSScriptRoot\Excludecache.txt"
		$debloat_excludefinal | Out-File -FilePath $ec -Append
		
		$darg = @()
		foreach ($debloat_value in $debloats) {
			if ($debloat_value) {$darg += "1"} else {$darg += "0"}
		}
		
		$debloat_arguments = "-File `"$PSScriptRoot\Debloater.ps1`" {0} {1} {2} {3} {4} {5} `"$ec`"" -f $darg[0], $darg[1], $darg[2], $darg[3], $darg[4], $darg[5]
		Start-Process powershell -Wait -ArgumentList $debloat_arguments
	}
}

while ($true) {
	$global:debloats = @($debloat_currentuser,$debloat_allusers,$debloat_provisioned,$debloat_onedrive,$debloat_edge,$debloatedgewv)
	Show-Menu
	Write-Host "> " -n; $unem = Read-Host
	Switch-MenusCheck $unem
	
	switch ($unem) {
		"1" {$global:debloat_currentuser = Toggle $debloat_currentuser}
		"2" {if ($elevated) {$global:debloat_allusers = Toggle $debloat_allusers}}
		"3" {if ($elevated) {$global:debloat_provisioned = Toggle $debloat_provisioned}}
		"4" {if ($elevated) {$global:debloat_onedrive = Toggle $debloat_onedrive}}
		"5" {
			if ($elevated) {$global:debloat_edge = Toggle $debloat_edge}
			if ($debloat_edgewv) {$global:debloat_edgewv = $false}
		}
		"6" {if ($debloat_edge) {$global:debloat_edgewv = Toggle $debloat_edgewv}}
		"G" {if (Check-AtLeastOneEnabled $debloats) {Confirm-Debloat}}
	}
}
