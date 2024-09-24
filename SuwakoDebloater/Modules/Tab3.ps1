# Suwako Debloater - Extras Tab - (c) Bionic Butter

function Get-UCPDCrap {
	$userchoicep1sserdriver = Get-Service -Name UCPD -ea SilentlyContinue
	$userchoicep1sserregkey = Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD"
	if ($userchoicep1sserregkey -eq $false -and $userchoicep1sserdriver -ne $null) {return 2}
	elseif ($userchoicep1sserregkey) {
		[string]$ucpdreal = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD" -Name "ImagePath" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "ImagePath"
		if ($ucpdreal -eq "system32\drivers\UCPD.sys") {return 1} else {return 0}
	} else {return 0}
}
function Remove-UCPDCrap {
	$ucpdstat = Get-UCPDCrap
	
	switch ($ucpdstat) {
		0 {
			Show-Branding 0
			Write-Host "No User-Choice Protection Driver (UCPD) found" -ForegroundColor Black -BackgroundColor Green
			Write-Host "Good news! UCPD is not present on your system. Enjoy the freedom of no user-choice restrictions!" -ForegroundColor White
			Write-Host "Press Enter to return to main menu."
			Read-Host; return
		}
		2 {
			Show-Branding 0
			Write-Host "User-Choice Protection Driver (UCPD) removal pending" -ForegroundColor Black -BackgroundColor Cyan
			Write-Host "Please restart your system to complete the removal and enjoy the freedom of no registry blockages." -ForegroundColor White
			Write-Host "Press Enter to return to main menu."
			Read-Host; return
		}
	}
	
	Show-Branding 0
	#          "=========================== Console default length limit before you have to make a new line ============================"
	Write-Host "The User-Choice Protection Driver (UCPD) is a system driver introduced in April 2024 updates to client Windows 10"
	Write-Host "2004 based and Windows 11. And it is truly nothing but a MENACE. Besides preventing apps from programatically"
	Write-Host "changing your default browser away from Edge, starting from the August 2024 update, it also prevents certain things"
	Write-Host "like Suwako Feeds from doing its job. All by just preventing writes to certain registry values."
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
function Show-Menu {
	Show-Branding 0
	Show-SubmenuIndicator
	
	if ($elevated) {$elevoptsclr = "White"; $nonelevatedtext = $null} else {
		$elevoptsclr = "DarkGray"
		$nonelevatedtext = "(Requires elevation to work)"
	}
	
	Write-Host " Extra bits $nonelevatedtext"
	Write-Host " 1. Remove UCPD driver" -ForegroundColor $elevoptsclr -n; if ($elevated) {Write-Host " (recommended)" -ForegroundColor Cyan -n; Write-Host ".." -ForegroundColor DarkGray} else {Write-Host $null}
	Write-Host $null
}

while ($true) {
	Show-Menu
	Write-Host "> " -n; $unem = Read-Host
	Switch-MenusCheck $unem
	
	switch ($unem) {
		"1" {if ($elevated) {Remove-UCPDCrap}}
	}
}
