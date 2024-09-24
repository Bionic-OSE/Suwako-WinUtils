# Suwako Debloater - Branding module - (c) Bionic Butter

function Show-Branding {
	param(
		[Parameter(Mandatory=$true)]
		[int32]$mode
	)
	switch ($mode) {
		0 {$modename = "Version 4.0 - (c) Bionic Butter"}
		1 {$modename = "Debloater module"}
		2 {$modename = "Components reinstaller module"}
	}
	if ($mode -eq 0) {$modetitle = ""} else {$modetitle = " | $modename"}
	try {$host.UI.RawUI.WindowTitle = "Suwako Debloater utility - (c) Bionic Butter $modetitle"} catch {}
	Clear-Host
	Write-Host 'Suwako Debloater utility' -ForegroundColor Black -BackgroundColor Cyan
	Write-Host "$modename" -ForegroundColor Cyan
	Write-Host " "
}
