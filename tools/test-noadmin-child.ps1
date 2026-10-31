param([Parameter(Mandatory)][string]$Candidate,[Parameter(Mandatory)][string]$Previous,[Parameter(Mandatory)][string]$Output,[Parameter(Mandatory)][string]$ExpectedAppHash)
$ErrorActionPreference = 'Stop'
$result = [ordered]@{standard_user=$false; fresh_install=$false; launch=$false; upgrade=$false; silent_update_arguments=$false; uninstall=$false; data_preserved=$false; notes=@()}
function Install-Setup([string]$Setup,[string]$Label,[bool]$Auto=$false) {
    $args = @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-','/TASKS=',('/LOG="'+$Output+'.'+$Label+'.log"'))
    if ($Auto) { $args += '/AUTOUPDATE=1' }
    $p = Start-Process $Setup -ArgumentList $args -PassThru
    if (-not $p.WaitForExit(120000)) { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue; throw "Installer parent timeout: $Label" }
    $p.Refresh()
    if ($p.ExitCode -ne 0) { throw "$Label failed: exit $($p.ExitCode)" }
}
function Stop-OwnApp {
    # This script runs without admin and can affect only its own test processes.
    Get-Process KeRoDownload -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
try {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { throw 'Test user unexpectedly has administrator rights' }
    $result.standard_user=$true
    $local = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData, [Environment+SpecialFolderOption]::Create)
    $roaming = [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData, [Environment+SpecialFolderOption]::Create)
    if (-not $local -or -not $roaming) { throw 'Windows known folders are unavailable in this noninteractive test profile; manual VM validation is required.' }
    $env:TEMP=Join-Path $local 'Temp'
    $env:TMP=$env:TEMP
    New-Item -ItemType Directory -Force $env:TEMP | Out-Null
    $install = Join-Path $local 'Programs/KeRo Smarter Download'
    $data = Join-Path $roaming 'KeRo/KeRoDownload/data'
    if (Test-Path $install) { throw 'Fresh standard-user profile already has an installation' }
    Install-Setup $Candidate 'fresh'
    $exe = Join-Path $install 'KeRoDownload.exe'
    if (-not (Test-Path $exe) -or (Get-FileHash $exe).Hash -ne $ExpectedAppHash) { throw 'Fresh install path or binary mismatch' }
    $result.fresh_install=$true
    $result.helper_smoke=@{}
    foreach($tool in @('ffmpeg','yt-dlp','aria2c')){
        $argument=if($tool -eq 'ffmpeg'){'-version'}else{'--version'}
        $toolPath=Join-Path $install "tools/$tool.exe"
        $hp=Start-Process $toolPath -ArgumentList $argument -PassThru -WindowStyle Hidden -RedirectStandardOutput ($Output+".$tool.txt") -RedirectStandardError ($Output+".$tool.stderr.txt")
        if(-not $hp.WaitForExit(30000)){Stop-Process -Id $hp.Id -Force -ErrorAction SilentlyContinue; $result.helper_smoke[$tool]='TIMEOUT'}else{$hp.Refresh();$result.helper_smoke[$tool]=$hp.ExitCode}
    }
    New-Item -ItemType Directory -Force $data | Out-Null
    @{version=4;browser_port=9614;language='ar';autostart_set=$true;clipboard_monitor=$false;extension_prompted=$true;last_version='1.1.4'} | ConvertTo-Json | Set-Content "$data/settings.json" -Encoding utf8
    $app = Start-Process $exe -PassThru
    for ($i=0;$i -lt 40;$i++) {
        Start-Sleep -Milliseconds 250
        try { $pong=Invoke-RestMethod http://127.0.0.1:9614/ping -Headers @{'X-SwiftGet'='1'} -TimeoutSec 1; if ($pong.app -eq 'KeRoDownload') { $result.launch=$true;break } } catch { }
        if ($app.HasExited) { break }
    }
    if (-not $result.launch) { $result.notes += 'GUI/API launch could not be confirmed in this noninteractive standard-user session; test manually on a clean desktop VM.' }
    Stop-OwnApp
    $unins=Join-Path $install 'unins000.exe'
    $p=Start-Process $unins -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait -PassThru
    if ($p.ExitCode -ne 0 -or (Test-Path $exe)) { throw 'Fresh-install uninstall failed' }
    Install-Setup $Previous 'previous'
    if (-not (Test-Path $exe)) { throw 'Previous per-user install missing' }
    if (-not (Test-Path "$data/downloads.json")) { '[]' | Set-Content "$data/downloads.json" -Encoding utf8 }
    $partial=Join-Path $local 'kero-upgrade-test.part'
    [IO.File]::WriteAllBytes($partial,[byte[]](0..255))
    $protected=@("$data/settings.json","$data/downloads.json",$partial)
    $hashes=@{};foreach($f in $protected){$hashes[$f]=(Get-FileHash $f).Hash}
    Install-Setup $Candidate 'upgrade'
    if ((Get-FileHash $exe).Hash -ne $ExpectedAppHash) { throw 'Upgrade did not replace the executable in place' }
    foreach($f in $protected){if((Get-FileHash $f).Hash -ne $hashes[$f]){throw 'Upgrade changed settings/history/partial data'}}
    $result.upgrade=$true;$result.data_preserved=$true
    # Exercise the exact silent installer path without releasing signed metadata.
    Install-Setup $Candidate 'silent-update' $true
    Stop-OwnApp
    $result.silent_update_arguments=$true
    $p=Start-Process (Join-Path $install 'unins000.exe') -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -Wait -PassThru
    if ($p.ExitCode -ne 0 -or (Test-Path $exe)) { throw 'Upgrade uninstall failed' }
    foreach($f in $protected){if(-not(Test-Path $f)){throw 'Uninstall removed retained user data'}}
    $result.uninstall=$true
    $result.notes += 'Host has development tools/runtimes. This is a non-admin account test, not a clean Windows 7/10/11 VM certification.'
} catch { $result.error=$_.Exception.Message; $result.error_location=$_.InvocationInfo.PositionMessage }
finally { Stop-OwnApp; $result | ConvertTo-Json -Depth 8 | Set-Content $Output -Encoding utf8 }
if ($result.error) { exit 1 }
