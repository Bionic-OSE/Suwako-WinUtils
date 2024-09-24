# SuwakoDebloater - AveYo's Edge Removal script
# All right belongs to AveYo. I did not modify this script much, aside from making it a bit more readable

Param(
	[Parameter(Mandatory=$true,Position=0)]
	[int32]$edwvaveyo,
	[Parameter(Mandatory=$false,Position=1)]
	[int32]$NoNeed2StopExplorer
)

if ($edwvaveyo -eq 1) {
	$also_remove_webview = 1
	$also_remove_widgets = 1
	$also_remove_xsocial = 1
} else {
	$also_remove_webview = 0
	$also_remove_widgets = 0
	$also_remove_xsocial = 0
}

$ErrorActionPreference = 'SilentlyContinue'
Write-Host -ForegroundColor Cyan -BackgroundColor DarkGray "Removing Microsoft Edge components..."
Write-Host "`r`nEdge Removal - AveYo, 2023.09.14 (modified by Bionic Butter)`r`n"

$global:IS64 = [Environment]::Is64BitOperatingSystem
$global:IFEO = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
$global:EDGE_UID = '{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
$global:WEBV_UID = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
$global:UPDT_UID = '{F3C4FE00-EFD5-403B-9569-398A20F1BA4A}'
$global:PROGRAMS = ($env:ProgramFiles, ${env:ProgramFiles(x86)})[$IS64]
$global:SOFTWARE = ('SOFTWARE', 'SOFTWARE\WOW6432Node')[$IS64]
$global:ALLHIVES = 'HKCU:\SOFTWARE','HKLM:\SOFTWARE','HKCU:\SOFTWARE\Policies','HKLM:\SOFTWARE\Policies'
if ($IS64) { $global:ALLHIVES += "HKCU:\$SOFTWARE","HKLM:\$SOFTWARE","HKCU:\$SOFTWARE\Policies","HKLM:\$SOFTWARE\Policies"}

## -------------------------------------------------------------------------------------------------------------------------------

## 1 collect info. thanks AveYo, your code was a great eye stress test

Write-Host -ForegroundColor Cyan "Getting installation information"
$remove_appx = @("MicrosoftEdge"); $remove_win32 = @("Microsoft Edge","Microsoft Edge Update"); $skip = @() # @("DevTools")
if ($also_remove_webview -eq 1) {$remove_appx += "Win32WebViewHost"; $remove_win32 += "Microsoft EdgeWebView"}
if ($also_remove_widgets -eq 1) {$remove_appx += "WebExperience"}
if ($also_remove_xsocial -eq 1) {$remove_appx += "GamingServices"}
$global:WEBV = $also_remove_webview -eq 1
Import-Module -DisableNameChecking $PSScriptRoot\Debloaveyo.psm1

## -------------------------------------------------------------------------------------------------------------------------------

## 2 enable admin privileges 
## (we don't really need this since the debloater would require admin before hand, but still gonna leave it here in case)
$D1=[uri].module.gettype('System.Diagnostics.Process')."GetM`ethods"(42) |where {$_.Name -eq 'SetPrivilege'} #`:no-ev-warn
'SeSecurityPrivilege','SeTakeOwnershipPrivilege','SeBackupPrivilege','SeRestorePrivilege'|foreach {$D1.Invoke($null, @("$_",2))}

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Stopping related processes"
## 3 shut down edge & webview clone stuff
cd $env:systemdrive
if ($NoNeed2StopExplorer -eq 0) {taskkill /im explorer.exe /f 2>&1 >''}
$shut = 'Widgets','widgetservice','msedgewebview2',"MicrosoftEdge*",'chredge','msedge','edge','msteams','msfamily','WebViewHost','Clipchamp','SearchApp'
$shut | foreach {kill -name $_ -force -ea 0}

Write-Host -ForegroundColor Cyan "Removing uninstall block"
## clear win32 uninstall block
foreach ($name in $remove_win32) { foreach ($sw in $ALLHIVES) {
	$key = "$sw\Microsoft\Windows\CurrentVersion\Uninstall\$name"; if (-not (test-path $key)) {continue}
	foreach ($val in 'NoRemove','NoModify','NoRepair') {rp $key $val -force -ea 0}
	foreach ($val in 'ForceRemove','Delete') {sp $key $val 1 -type Dword -force}
}}
PREPARE_EDGE

Write-Host -ForegroundColor Cyan "Redirecting Edge protocol links to (later installed) OpenWebSearch"
## find all Edge setup.exe and gather BHO paths for OpenWebSearch / MSEdgeRedirect usage
$edges = @(); $bho = @(); $edgeupdates = @(); 'LocalApplicationData','ProgramFilesX86','ProgramFiles' |foreach {
	$folder = [Environment]::GetFolderPath($_); $bho += dir "$folder\Microsoft\Edge*\ie_to_edge_stub.exe" -rec -ea 0
	if ($WEBV) {$edges += dir "$folder\Microsoft\Edge*\setup.exe" -rec -ea 0 |where {$_ -like '*EdgeWebView*'}}
	$edges += dir "$folder\Microsoft\Edge*\setup.exe" -rec -ea 0 |where {$_ -notlike '*EdgeWebView*'}
	$edgeupdates += dir "$folder\Microsoft\EdgeUpdate\*.*.*.*\MicrosoftEdgeUpdate.exe" -rec -ea 0
}

## export OpenWebSearch innovative redirector - used by MSEdgeRedirect as well
$DIR = "$env:ProgramData\AveYo"; mkdir $DIR -ea 0 >''
foreach ($b in $bho) { if (test-path $b) { try {copy $b "$DIR\ie_to_edge_stub.exe" -force -ea 0} catch{} } }

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Removing related UWP artifacts"
## 4 remove found *Edge* appx packages with unblock tricks
$provisioned = get-appxprovisionedpackage -online; $appxpackage = get-appxpackage -allusers; $eol = @()
$store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
$users = @('S-1-5-18'); if (test-path $store) {$users += $((dir $store -ea 0 |where {$_ -like '*S-1-5-21*'}).PSChildName)}
foreach ($choice in $remove_appx) { if ('' -eq $choice.Trim()) {continue}
	foreach ($appx in $($provisioned | where {$_.PackageName -like "*$choice*"})) {
		$next = !1; foreach ($no in $skip) {if ($appx.PackageName -like "*$no*") {$next = !0}} ; if ($next) {continue}
		$PackageName = $appx.PackageName; $PackageFamilyName = ($appxpackage |where {$_.Name -eq $appx.DisplayName}).PackageFamilyName 
		ni "$store\Deprovisioned\$PackageFamilyName" -force >''; $PackageFamilyName  
		foreach ($sid in $users) {ni "$store\EndOfLife\$sid\$PackageName" -force >''} ; $eol += $PackageName
		dism /online /set-nonremovableapppolicy /packagefamily:$PackageFamilyName /nonremovable:0 >''
		remove-appxprovisionedpackage -packagename $PackageName -online -allusers >''
	}
	foreach ($appx in $($appxpackage |where {$_.PackageFullName -like "*$choice*"})) {
		$next = !1; foreach ($no in $skip) {if ($appx.PackageFullName -like "*$no*") {$next = !0}} ; if ($next) {continue}
		$PackageFullName = $appx.PackageFullName; 
		ni "$store\Deprovisioned\$appx.PackageFamilyName" -force >''; $PackageFullName
		foreach ($sid in $users) {ni "$store\EndOfLife\$sid\$PackageFullName" -force >''} ; $eol += $PackageFullName
		dism /online /set-nonremovableapppolicy /packagefamily:$PackageFamilyName /nonremovable:0 >''
		remove-appxpackage -package $PackageFullName -allusers >''
	}
}

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Attempting to uninstall Edge (and WebView based on your selection)"
## 5 run found *Edge* setup.exe with uninstall args and wait in-between
foreach ($setup in $edges) { if (-not (test-path $setup)) {continue}
	if ($setup -like '*EdgeWebView*') {$target = "--msedgewebview"} else {$target = "--msedge"}
	$sulevel = ('--system-level','--user-level')[$setup -like '*\AppData\Local\*']
	$removal = "--uninstall $target $sulevel --verbose-logging --force-uninstall"
	try {write-host $setup $removal; start -wait $setup -args $removal} catch {}
	do {sleep 3} while ((get-process -name 'setup','MicrosoftEdge*' -ea 0).Path -like '*\Microsoft\Edge*')
}

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Cleaning leftovers"
## 6 cleanup
## msi installers cleanup
gp 'HKLM:\SOFTWARE\Classes\Installer\Products\*' 'ProductName' |where {$_.ProductName -like '*Microsoft Edge*'} |foreach { 
	$prod = ($_.PSChildName -split '(.{8})(.{4})(.{4})(.{4})' -join '-').trim('-')
	$sort = 7,6,5,4,3,2,1,0,8,12,11,10,9,13,17,16,15,14,18,20,19,22,21,23,25,24,27,26,29,28,31,30,33,32,35,34
	$code = '{' + -join ($sort |foreach {$prod[$_]}) + '}'; start -wait msiexec.exe -args "/X$code /qn" 2>''
	ri $_.PSPath -recurse -force
	foreach ($sw in $ALLHIVES) {ri "$sw\Microsoft\Windows\CurrentVersion\Uninstall\$code" -recurse -force}  
} 

## edgeupdate graceful cleanup
if ($WEBV) {
	foreach ($sw in $ALLHIVES) {ri "$sw\Microsoft\EdgeUpdate" -recurse -force}  
	foreach ($UPDT in $edgeupdates) { 
		if (test-path $UPDT) {write-host "$UPDT /unregsvc";  start -wait $UPDT -args '/unregsvc'}
		do {sleep 3} while ((get-process -name 'setup','MicrosoftEdge*' -ea 0).Path -like '*\Microsoft\Edge*')
		if (test-path $UPDT) {write-host "$UPDT /uninstall"; start -wait $UPDT -args '/uninstall'}
		do {sleep 3} while ((get-process -name 'setup','MicrosoftEdge*' -ea 0).Path -like '*\Microsoft\Edge*')
	}
	Unregister-ScheduledTask -TaskName MicrosoftEdgeUpdate* -Confirm:$false -ea 0; ri "$PROGRAMS\Microsoft\Temp" -recurse -force
} 
$appdata = $([Environment]::GetFolderPath('ApplicationData'))
ri "$appdata\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Tombstones\Microsoft Edge.lnk" -force
ri "$appdata\Microsoft\Internet Explorer\Quick Launch\Microsoft Edge.lnk" -force

## undo eol unblock trick to prevent latest cumulative update (LCU) failing 
foreach ($sid in $users) { foreach ($PackageName in $eol) {ri "$store\EndOfLife\$sid\$PackageName" -force >''} }

Write-Host -ForegroundColor Cyan "Forcing ban policies"
## .i. "Update policies are configured but will be ignored because this device isn't domain joined" .i.
$uids = @($EDGE_UID); $cdps = @('msedge'); if ($WEBV) {$uids += $WEBV_UID; $cdps += 'msedgewebview'} 
foreach ($sw in $ALLHIVES) {
	sp "$sw\Microsoft\EdgeUpdate" 'DoNotUpdateToEdgeWithChromium' 1 -type Dword -force
	sp "$sw\Microsoft\EdgeUpdate" 'UpdaterExperimentationAndConfigurationServiceControl' 0 -type Dword -force
	sp "$sw\Microsoft\EdgeUpdate" 'InstallDefault' 0 -type Dword -force
	foreach ($uid in $uids) {  
		sp "$sw\Microsoft\EdgeUpdate" "Install${uid}" 0 -type Dword -force
		sp "$sw\Microsoft\EdgeUpdate" "EdgePreview${uid}" 0 -type Dword -force
		sp "$sw\Microsoft\EdgeUpdate" "Update${uid}" 2 -type Dword -force
		foreach ($trigger in 'on-os-upgrade','on-logon','on-logon-autolaunch','on-logon-startup-boost') {
		sp "$sw\Microsoft\EdgeUpdate\Clients\${uid}\Commands\$trigger" 'AutoRunOnLogon' 0 -type Dword -force
		sp "$sw\Microsoft\EdgeUpdate\Clients\${uid}\Commands\$trigger" 'AutoRunOnOSUpgrade' 0 -type Dword -force
		sp "$sw\Microsoft\EdgeUpdate\Clients\${uid}\Commands\$trigger" 'Enabled' 0 -type Dword -force
		}
	}
	sp "$sw\Microsoft\MicrosoftEdge\Main" 'AllowPrelaunch' 0 -type Dword -force
	sp "$sw\Microsoft\MicrosoftEdge\TabPreloader" 'AllowTabPreloading' 0 -type Dword -force
	## microsoft has no shame, so we are gonna insist opting-out of unsolicited reinstalls with windows updates
	foreach ($cdp in $cdps) { foreach ($arch in 'x64','x86') { foreach ($zdp in '','-zdp') {
		sp "$sw\Microsoft\EdgeUpdateDev\CdpNames" "$cdp-stable-win-$arch$zdp" "$cdp-stable-win-arm64$zdp" -force
	}}}
}

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Installing OpenWebSearch - Redirect microsoft-edge:// protocol to your browser of choice"
## 7 add bundled OpenWebSearch script to redirect microsoft-edge: anti-competitive links to the default browser
$MSEP = ($env:ProgramFiles,${env:ProgramFiles(x86)})[[Environment]::Is64BitOperatingSystem] + '\Microsoft\Edge\Application'
$IFEO = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
$MIN = ('--headless','--width 1 --height 1')[([environment]::OSVersion.Version.Build) -gt 25179]
$CMD = "$env:systemroot\system32\conhost.exe $MIN" # AveYo: minimize prompt - see Terminal issue #13914
ni "HKLM:\SOFTWARE\Classes\microsoft-edge\shell\open\command" -force >''
sp "HKLM:\SOFTWARE\Classes\microsoft-edge" '(Default)' 'URL:microsoft-edge' -force
sp "HKLM:\SOFTWARE\Classes\microsoft-edge" 'URL Protocol' '' -force
sp "HKLM:\SOFTWARE\Classes\microsoft-edge" 'NoOpenWith' '' -force
sp "HKLM:\SOFTWARE\Classes\microsoft-edge\shell\open\command" '(Default)' "`"$DIR\ie_to_edge_stub.exe`" %1" -force
ni "HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" -force >''
sp "HKLM:\SOFTWARE\Classes\MSEdgeHTM" 'NoOpenWith' '' -force
sp "HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command" '(Default)' "`"$DIR\ie_to_edge_stub.exe`" %1" -force
ni "$IFEO\ie_to_edge_stub.exe\0" -force >''
sp "$IFEO\ie_to_edge_stub.exe" 'UseFilter' 1 -type Dword -force
sp "$IFEO\ie_to_edge_stub.exe\0" 'FilterFullPath' "$DIR\ie_to_edge_stub.exe" -force
sp "$IFEO\ie_to_edge_stub.exe\0" 'Debugger' "$CMD $DIR\OpenWebSearch.cmd" -force
ni "$IFEO\msedge.exe\0" -force >''
sp "$IFEO\msedge.exe" 'UseFilter' 1 -type Dword -force
sp "$IFEO\msedge.exe\0" 'FilterFullPath' "$MSEP\msedge.exe" -force
sp "$IFEO\msedge.exe\0" 'Debugger' "$CMD $DIR\OpenWebSearch.cmd" -force
## new: automatically re-create the needed hardlink if edge is reinstalled
$ta = New-ScheduledTaskAction -Execute '%Temp%\OpenWebSearchRepair.cmd'
$tt = New-ScheduledTaskTrigger -Once -At 00:00; $ts = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
Register-ScheduledTask -TaskName 'OpenWebSearchRepair' -Action $ta -Trigger $tt -Settings $ts -RunLevel Highest -Force >''

$OpenWebSearch = @"
@title OpenWebSearch Redux & echo off & set ?= Open Start Menu Web Search, Widgets links or Help in your chosen browser - AveYo
for /f %%E in ('"prompt $E$S& for %%e in (1) do rem"') do echo;%%E[2t 2>nul & rem AveYo: minimize prompt
call :reg_var "HKCU\SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" ProgID ProgID
if /i "%ProgID%" equ "MSEdgeHTM" echo;Default browser is set to Edge! Change it or remove OpenWebSearch script. & pause & exit /b
call :reg_var "HKCR\%ProgID%\shell\open\command" "" Browser
set Choice=& for %%. in (%Browser%) do if not defined Choice set "Choice=%%~."
call :reg_var "HKCR\MSEdgeMHT\shell\open\command" "" FallBack
set "Edge=" & for %%. in (%FallBack%) do if not defined Edge set "Edge=%%~."
set "URI=" & set "URL=" & set "NOOP=" & set "PassTrough=%Edge:msedge=edge%"
set "CLI=%CMDCMDLINE:"=``% "
if defined CLI set "CLI=%CLI:*ie_to_edge_stub.exe`` =%"
if defined CLI set "CLI=%CLI:*ie_to_edge_stub.exe =%"
if defined CLI set "CLI=%CLI:*msedge.exe`` =%"
if defined CLI set "CLI=%CLI:*msedge.exe =%"
set "FIX=%CLI:~-1%"
if defined CLI if "%FIX%"==" " set "CLI=%CLI:~0,-1%"
if defined CLI set "RED=%CLI:microsoft-edge=%"
if defined CLI set "URL=%CLI:http=%"
if defined CLI set "ARG=%CLI:``="%"
if "%CLI%" equ "%RED%" (set NOOP=1) else if "%CLI%" equ "%URL%" (set NOOP=1)
if defined NOOP if not exist "%PassTrough%" echo;@mklink /h "%PassTrough%" "%Edge%" >"%Temp%\OpenWebSearchRepair.cmd"
if defined NOOP if not exist "%PassTrough%" schtasks /run /tn OpenWebSearchRepair 2>nul >nul
if defined NOOP if not exist "%PassTrough%" timeout /t 3 >nul
if defined NOOP if exist "%PassTrough%" start "" "%PassTrough%" %ARG%
if defined NOOP exit /b
set "URL=%CLI:*microsoft-edge=%"
set "URL=http%URL:*http=%"
set "FIX=%URL:~-2%"
if defined URL if "%FIX%"=="``" set "URL=%URL:~0,-2%"
call :dec_url
start "" "%Choice%" "%URL%"
exit

:reg_var [USAGE] call :reg_var "HKCU\Volatile Environment" value-or-"" variable [extra options]
set {var}=& set {reg}=reg query "%~1" /v %2 /z /se "," /f /e& if %2=="" set {reg}=reg query "%~1" /ve /z /se "," /f /e
for /f "skip=2 tokens=* delims=" %%V in ('%{reg}% %4 %5 %6 %7 %8 %9 2^>nul') do if not defined {var} set "{var}=%%V"
if not defined {var} (set {reg}=& set "%~3="& exit /b) else if %2=="" set "{var}=%{var}:*)    =%"& rem AveYo: v3
if not defined {var} (set {reg}=& set "%~3="& exit /b) else set {reg}=& set "%~3=%{var}:*)    =%"& set {var}=& exit /b

:dec_url Brute url percent decoding by AveYo
set ".=%URL:!=}%"&setlocal enabledelayedexpansion& rem brute url percent decoding
set ".=!.:%%={!" &set ".=!.:{3A=:!" &set ".=!.:{2F=/!" &set ".=!.:{3F=?!" &set ".=!.:{23=#!" &set ".=!.:{5B=[!" &set ".=!.:{5D=]!"
set ".=!.:{40=@!"&set ".=!.:{21=}!" &set ".=!.:{24=$!" &set ".=!.:{26=&!" &set ".=!.:{27='!" &set ".=!.:{28=(!" &set ".=!.:{29=)!"
set ".=!.:{2A=*!"&set ".=!.:{2B=+!" &set ".=!.:{2C=,!" &set ".=!.:{3B=;!" &set ".=!.:{3D==!" &set ".=!.:{25=%%!"&set ".=!.:{20= !"
set ".=!.:{=%%!" &rem set ",=!.:%%=!" & if "!,!" neq "!.!" endlocal& set "URL=%.:}=!%" & call :dec_url
endlocal& set "URL=%.:}=!%" & exit /b
rem done

"@
[io.file]::WriteAllText("$DIR\OpenWebSearch.cmd", $OpenWebSearch)

## -------------------------------------------------------------------------------------------------------------------------------

Write-Host -ForegroundColor Cyan "Finalizing operation"
## 8 final cleanup
$done = gp 'Registry::HKEY_Users\S-1-5-21*\Volatile*' Edge_Removal -ea 0; if ($done) {rp $done.PSPath Edge_Removal -force -ea 0}
if ((get-process -name 'explorer' -ea 0) -eq $null) {start explorer; Start-Sleep -Seconds 5}

## -------------------------------------------------------------------------------------------------------------------------------
