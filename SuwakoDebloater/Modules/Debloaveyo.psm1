# SuwakoDebloater - AveYo's Edge Removal support functions hive

## helper for set-itemproperty remove-itemproperty new-item remove-item with auto test-path
function global:sp_test_path { if (test-path $args[0]) {Microsoft.PowerShell.Management\Set-ItemProperty @args} else {
  Microsoft.PowerShell.Management\New-Item $args[0] -force -ea 0 >''; Microsoft.PowerShell.Management\Set-ItemProperty @args} }
function global:rp_test_path { if (test-path $args[0]) {Microsoft.PowerShell.Management\Remove-ItemProperty @args} }
function global:ni_test_path { if (-not (test-path $args[0])) {Microsoft.PowerShell.Management\New-Item @args} }
function global:ri_test_path { if (test-path $args[0]) {Microsoft.PowerShell.Management\Remove-Item @args} }
foreach ($f in 'sp','rp','ni','ri') {set-alias -Name $f -Value "${f}_test_path" -Scope Local -Option AllScope -force -ea 0}

## helper for edgeupdate reinstall
function global:PREPARE_UPDT($cdp='msedgeupdate', $uid=$UPDT_UID) {
  foreach ($sw in $ALLHIVES) { 
    rp "$sw\Microsoft\EdgeUpdate" 'DoNotUpdateToEdgeWithChromium' -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate" 'UpdaterExperimentationAndConfigurationServiceControl' -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate" "InstallDefault" -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate" "Install${uid}" -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate" "EdgePreview${uid}" -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate" "Update${uid}" -force -ea 0
    rp "$sw\Microsoft\EdgeUpdate\ClientState\*" 'experiment_control_labels' -force -ea 0 
    ri "$sw\Microsoft\EdgeUpdate\Clients\${uid}\Commands" -recurse -force -ea 0
    rp "$sw\Microsoft\EdgeUpdateDev\CdpNames" "$cdp-*" -force -ea 0
    sp "$sw\Microsoft\EdgeUpdateDev" 'CanContinueWithMissingUpdate' 1 -type Dword -force
    sp "$sw\Microsoft\EdgeUpdateDev" 'AllowUninstall' 1 -type Dword -force
  }
}
## helper for edge reinstall - remove bundled OpenWebSearch redirector and edgeupdate policies
function global:PREPARE_EDGE { ## with Bionic's modern function args implementation injected
  param (
    [switch]$RemoveOWS
  )
  PREPARE_UPDT 'msedge' $EDGE_UID; PREPARE_UPDT 'msedgeupdate' $UPDT_UID 
  $MSEDGE = "$PROGRAMS\Microsoft\Edge\Application\msedge.exe"
  ri "$IFEO\msedge.exe" -recurse -force; ri "$IFEO\ie_to_edge_stub.exe" -recurse -force
  ri 'Registry::HKEY_Users\S-1-5-21*\Software\Classes\microsoft-edge' -recurse -force
  sp 'HKLM:\SOFTWARE\Classes\microsoft-edge\shell\open\command' '(Default)' "`"$MSEDGE`" --single-argument %%1" -force
  ri 'Registry::HKEY_Users\S-1-5-21*\Software\Classes\MSEdgeHTM' -recurse -force
  sp 'HKLM:\SOFTWARE\Classes\MSEdgeHTM\shell\open\command' '(Default)' "`"$MSEDGE`" --single-argument %%1" -force
  if ($RemoveOWS) {
    Remove-Item -Path "$DIR\OpenWebSearch.cmd" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$Temp\OpenWebSearchRepair.cmd" -Force -ErrorAction SilentlyContinue
    Unregister-ScheduledTask -TaskName 'OpenWebSearchRepair' -Force -ErrorAction SilentlyContinue
  }
}
## helper for webview reinstall - restore webexperience (widgets) if available
function global:PREPARE_WEBVIEW {
  PREPARE_UPDT 'msedgewebview' $WEBV_UID; PREPARE_UPDT 'msedgeupdate' $UPDT_UID
  $cfg = @{Register=$true; ForceApplicationShutdown=$true; ForceUpdateFromAnyVersion=$true; DisableDevelopmentMode=$true} 
  dir "$env:SystemRoot\SystemApps\Microsoft.Win32WebViewHost*\AppxManifest.xml" -rec -ea 0 | Add-AppxPackage @cfg
  dir "$env:ProgramFiles\WindowsApps\MicrosoftWindows.Client.WebExperience*\AppxManifest.xml" -rec -ea 0 | Add-AppxPackage @cfg
  kill -name explorer -ea 0; if ((get-process -name 'explorer' -ea 0) -eq $null) {start explorer}
}
