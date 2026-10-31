$ErrorActionPreference='Stop'
$install=Join-Path $env:LOCALAPPDATA 'Programs/KeRo Download Preview'
$production=Join-Path $env:APPDATA 'KeRo/KeRoDownload'
function Fingerprint {
 if(-not(Test-Path $production)){return ''}
 return ((Get-ChildItem $production -Recurse -File | Sort-Object FullName | ForEach-Object {"$($_.FullName):$((Get-FileHash $_.FullName).Hash)"}) -join "`n")
}
$before=Fingerprint
$prodProtocol=(Get-ItemProperty 'HKCU:/Software/Classes/kero-download/shell/open/command' -ErrorAction SilentlyContinue).'(default)'
$setup=(Get-ChildItem dist-trial/*Setup.exe | Select-Object -First 1).FullName
$p=Start-Process $setup -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /TASKS=desktopicon' -PassThru
if(-not $p.WaitForExit(120000) -or $p.ExitCode -ne 0){throw 'Preview installation failed'}
foreach($file in Get-ChildItem trial-stage -Recurse -File){
 $relative=$file.FullName.Substring((Resolve-Path trial-stage).Path.Length+1)
 $dest=Join-Path $install $relative
 if(-not(Test-Path $dest) -or (Get-FileHash $dest).Hash -ne (Get-FileHash $file.FullName).Hash){throw "Installed component mismatch: $relative"}
}
$cmd=(Get-ItemProperty 'HKCU:/Software/Classes/kero-design-preview/shell/open/command').'(default)'
if($cmd -notlike "*$install*KeRoDownloadPreview.exe*"){throw 'Trial protocol not linked to trial executable'}
if((Get-ItemProperty 'HKCU:/Software/Classes/kero-download/shell/open/command' -ErrorAction SilentlyContinue).'(default)' -ne $prodProtocol){throw 'Production protocol changed'}
$helperResults=@{}
foreach($name in @('yt-dlp.exe','ffmpeg.exe','aria2c.exe')){
 $arg=if($name -in 'ffmpeg.exe','ffprobe.exe'){'-version'}else{'--version'}
 $out=Join-Path $env:RUNNER_TEMP "$name.stdout"
 $err=Join-Path $env:RUNNER_TEMP "$name.stderr"
 $h=Start-Process (Join-Path $install "tools/$name") -ArgumentList $arg -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
 if(-not $h.WaitForExit(60000) -or $h.ExitCode -ne 0){throw "Installed helper failed: $name"}
 $helperResults[$name]=((Get-Content $out -Raw)+(Get-Content $err -Raw)).Trim()
}
& "$install/tools/ffmpeg.exe" -hide_banner -loglevel error -f lavfi -i 'color=c=blue:s=64x64:d=0.2' -c:v mpeg4 -y "$env:RUNNER_TEMP/trial-smoke.mp4"
if($LASTEXITCODE -ne 0){throw 'Installed ffmpeg conversion failed'}
& "$install/tools/ffmpeg.exe" -hide_banner -loglevel error -i "$env:RUNNER_TEMP/trial-smoke.mp4" -f null -
if($LASTEXITCODE -ne 0){throw 'Installed ffmpeg decode failed'}
$p=Start-Process "$install/KeRoDownloadPreview.exe" -PassThru
try {
 $ping=$null;$end=(Get-Date).AddSeconds(45)
 do{
  Start-Sleep -Milliseconds 350
  try{$ping=Invoke-RestMethod 'http://127.0.0.1:9615/ping' -Headers @{'X-SwiftGet'='1'} -TimeoutSec 2}catch{}
  if($p.HasExited){throw "Installed app exited: $($p.ExitCode)"}
 }while(-not $ping -and (Get-Date) -lt $end)
 if($ping.app -ne 'KeRoDownload'){throw 'Installed preview API not available'}
 $config=Invoke-RestMethod 'http://127.0.0.1:9615/config' -Headers @{'X-SwiftGet'='1';Origin='chrome-extension://aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'} -TimeoutSec 3
 if(-not $config.ok){throw 'Extension-origin API config failed'}
 $denied=$false
 try{Invoke-RestMethod 'http://127.0.0.1:9615/ping' -Headers @{'X-SwiftGet'='1';Origin='https://example.com'} -TimeoutSec 3 | Out-Null}catch{$denied=$true}
 if(-not $denied){throw 'Untrusted webpage origin accepted'}
 if((Fingerprint) -ne $before){throw 'Production profile changed'}
}finally{if(-not $p.HasExited){Stop-Process -Id $p.Id -Force}}
$summary=[ordered]@{installed_all_files_identical=$true;installed_helpers_started=$helperResults;ffmpeg_conversion=$true;ffmpeg_decode=$true;installed_app_api_9615=$true;extension_origin_config=$true;untrusted_origin_rejected=$true;trial_protocol_registered=$true;production_protocol_unchanged=$true;production_profile_unchanged=$true;host='Windows Server 2022 hosted runner';clean_win10_11_vm_tested=$false;interactive_browser_extension_loaded=$false;source_binary_sha256='08fa923ae5d0d449e4913098382397f6d3af8d19136db8330762927fe4231acd'}
$summary | ConvertTo-Json -Depth 8 | Set-Content dist-trial/verification/INSTALL-SMOKE.json
$p=Start-Process "$install/unins000.exe" -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART' -PassThru
if(-not $p.WaitForExit(90000) -or $p.ExitCode -ne 0){throw 'Trial uninstall failed'}
if(Test-Path 'HKCU:/Software/Classes/kero-design-preview'){throw 'Trial protocol was not removed'}
if((Fingerprint) -ne $before){throw 'Uninstall changed production profile'}
'PASS: installed components, installed helper commands, FFmpeg encode/decode, application/extension-origin API, separate protocol, unchanged production data, uninstall. Windows Server host only; not a clean Windows 10/11 VM.' | Set-Content dist-trial/verification/RESULT.txt
Get-ChildItem dist-trial -Recurse -File | ForEach-Object {"$((Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLower())  $($_.FullName.Substring((Resolve-Path dist-trial).Path.Length+1))"} | Set-Content dist-trial/SHA256SUMS.txt
