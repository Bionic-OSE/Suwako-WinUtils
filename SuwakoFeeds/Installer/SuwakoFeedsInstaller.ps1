# Suwako Feeds Installer script - (c) Bionic Butter

Param(
	[Parameter(Mandatory=$True,Position=0)]
	[string]$installpath
)

Show-Branding
Write-Host -ForegroundColor Cyan "Installing Suwako Feeds..."

if ((Test-Path -Path "$installpath\SuwakoFeeds") -eq $false) {New-Item -Path "$installpath" -Name SuwakoFeeds -itemType Directory | Out-Null}
Expand-Archive -Path $PSScriptRoot\Contents.zip -DestinationPath "$installpath\SuwakoFeeds"
reg import $PSScriptRoot\SuwakoFeeds.reg

# Set up the uninstall entry
$hkcunin = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
New-Item -Path $hkcunin -Name "SuwakoFeeds"
$suwunin = @{
	"DisplayName" = "Suwako Feeds"
	"DisplayIcon" = "$installpath\SuwakoFeeds\SuwakoFeeds.exe"
	"DisplayVersion" = "3.0"
	"InstallDate" = [string]$(Get-Date -Format "yyyyMMdd")
	"InstallLocation" = "$installpath\SuwakoFeeds"
	"Publisher" = "Bionic Butter"
	"UninstallString" = "powershell -ExecutionPolicy Bypass -Command `"$installpath\SuwakoFeeds\Uninstall\SFUninstapp.ps1`""
	"QuietUninstallString" = "powershell -ExecutionPolicy Bypass -Command `"$installpath\SuwakoFeeds\Uninstall\SFUninstall.ps1`""
}
$suwunin.GetEnumerator() | ForEach-Object {
	Set-ItemProperty -Path "$hkcunin\SuwakoFeeds" -Name $_.Key -Type String -Value $_.Value -Force
}

# Set up the startup task
[string]$usersid = (Get-LocalUser -Name $env:USERNAME).SID
$sfsxml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.6" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
	<RegistrationInfo>
		<Date>2024-09-20T17:52:22.1019041</Date>
		<Author>Bionic Butter</Author>
		<URI>\Bionic\SuwakoFeeds</URI>
	</RegistrationInfo>
	<Triggers>
		<LogonTrigger>
			<Enabled>true</Enabled>
			<UserId>$env:COMPUTERNAME\$env:USERNAME</UserId>
		</LogonTrigger>
	</Triggers>
	<Principals>
		<Principal id="Author">
			<UserId>$usersid</UserId>
			<LogonType>InteractiveToken</LogonType>
			<RunLevel>HighestAvailable</RunLevel>
		</Principal>
	</Principals>
	<Settings>
		<MultipleInstancesPolicy>Parallel</MultipleInstancesPolicy>
		<DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
		<StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
		<AllowHardTerminate>false</AllowHardTerminate>
		<StartWhenAvailable>true</StartWhenAvailable>
		<RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
		<IdleSettings>
			<StopOnIdleEnd>false</StopOnIdleEnd>
			<RestartOnIdle>false</RestartOnIdle>
		</IdleSettings>
		<AllowStartOnDemand>true</AllowStartOnDemand>
		<Enabled>true</Enabled>
		<Hidden>false</Hidden>
		<RunOnlyIfIdle>false</RunOnlyIfIdle>
		<DisallowStartOnRemoteAppSession>true</DisallowStartOnRemoteAppSession>
		<UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
		<WakeToRun>false</WakeToRun>
		<ExecutionTimeLimit>PT0S</ExecutionTimeLimit>
		<Priority>7</Priority>
	</Settings>
	<Actions Context="Author">
		<Exec>
			<Command>$installpath\SuwakoFeeds\SuwakoFeeds.exe</Command>
			<WorkingDirectory>$installpath\SuwakoFeeds</WorkingDirectory>
		</Exec>
	</Actions>
</Task>
"@

$sfsname = "SuwakoFeeds" 
$sfstrigger = @($(New-ScheduledTaskTrigger -AtLogon -User "$env:COMPUTERNAME\$env:USERNAME"))
Register-ScheduledTask -Xml $sfsxml -TaskName $sfsname -TaskPath '\Bionic\' -User "$env:COMPUTERNAME\$env:USERNAME" -Force
Set-ScheduledTask -TaskName $sfsname -TaskPath '\Bionic\' -Trigger $sfstrigger
Start-ScheduledTask -TaskName $sfsname -TaskPath '\Bionic\'

Write-Host -ForegroundColor Green "Installation finished"
Write-Host "Press Enter to exit"; Read-Host
