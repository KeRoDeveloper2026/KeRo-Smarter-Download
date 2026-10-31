$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$preview=Join-Path $PWD 'retained-preview/KeRo-Download-Window-Preview-Win10_11-x64.zip'
if((Get-FileHash $preview).Hash.ToLower() -ne '11c2ed4a3e68008810ac4753ed9f33657631353da16d274801195963e20d92ce'){throw 'Preview ZIP differs from retained artifact'}
Expand-Archive $preview trial-stage -Force
if((Get-FileHash 'trial-stage/KeRoDownload.exe').Hash.ToLower() -ne '08fa923ae5d0d449e4913098382397f6d3af8d19136db8330762927fe4231acd'){throw 'Preview application mismatch'}
$old=Join-Path $env:RUNNER_TEMP 'official-v1.1.4.exe'
Invoke-WebRequest 'https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v1.1.4/KeRoDownload-v1.1.4-Win10_11-x64.exe' -OutFile $old
if((Get-FileHash $old).Hash.ToLower() -ne '52395e642223856414a20aef9ccf0562d7177c51bef488962c735aea63dcf821'){throw 'Official helper source hash mismatch'}
$extract=Join-Path $env:RUNNER_TEMP 'helper-source'
$p=Start-Process $old -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-','/TASKS=',('/DIR="'+$extract+'"')) -PassThru
if(-not $p.WaitForExit(120000) -or $p.ExitCode -ne 0){throw 'Official helper extraction failed'}
Copy-Item "$extract/tools" trial-stage/tools -Recurse
$helpers=@{}
Get-ChildItem trial-stage/tools -File -Recurse | ForEach-Object {$helpers[$_.Name]=(Get-FileHash $_.FullName).Hash}
foreach($name in @('yt-dlp.exe','ffmpeg.exe','aria2c.exe')){if(-not (Test-Path "trial-stage/tools/$name")){throw "Missing helper $name"}}
foreach($dir in @('extension','extension-firefox')){
 foreach($file in Get-ChildItem "trial-stage/$dir" -Recurse -File | Where-Object {$_.Extension -in '.js','.html','.json'}){
  $text=[IO.File]::ReadAllText($file.FullName).Replace('kero-download://open','kero-design-preview://open')
  [IO.File]::WriteAllText($file.FullName,$text,[Text.UTF8Encoding]::new($false))
 }
 $background=Get-Content "trial-stage/$dir/background.js" -Raw
 if($background -notmatch 'port: 9615'){throw 'Incorrect extension API port'}
}
Remove-Item trial-stage/READ-ME-FIRST.txt
@'
KeRo Download Preview — Windows 10/11 x64 — trial only

1. Unzip this package completely, then run the Setup EXE.
2. Start "KeRo Download Preview" from Desktop or Start Menu.
3. All bundled helpers are installed with the app; no manual tools copying.
4. In a separate browser profile, load the installed extension folder through
   chrome://extensions, brave://extensions or edge://extensions (Developer mode).
   Firefox: about:debugging > This Firefox > Load Temporary Add-on >
   extension-firefox/manifest.json in the install folder.
5. The test extension connects to this preview on port 9615, NOT the production
   extension on 9614. "Open app" uses its own kero-design-preview protocol.
6. Existing portable trial settings may be reused from KeRoDesignPreview.
   If port 9615 was changed previously, set it back in app/extension settings.
7. AppId, install directory, protocol, shortcut and data profile are independent
   from the main app. App/helper automatic updates and autostart stay disabled.
8. Original floating logo and preview application bytes are unchanged.
9. This is unsigned test software. SmartScreen may still appear.
10. Windows Server CI checks do not certify a clean Windows 10/11 VM.

التجربة تُثبّت باسم KeRo Download Preview في مجلد مستقل دون استبدال البرنامج الأساسي.
فك الضغط بالكامل ثم شغّل ملف Setup. أدوات الفيديو والتورنت والإضافات مضمّنة.
حمّل إضافة التجربة من مجلد التثبيت في ملف متصفح منفصل؛ الإضافة الأساسية لا تتصل بهذه التجربة.
إضافة فايرفوكس مؤقتة وغير موقّعة. منفذ التجربة 9615 والتحديث التلقائي معطّل.
هذه نسخة Windows 10/11 بمعمارية 64-bit فقط، وليست Windows 7 أو 32-bit.
لو استمر فشل التشغيل، أرسل نص الخطأ وإصدار Windows والمعمارية.
'@ | Set-Content trial-stage/READ-ME-FIRST.txt -Encoding utf8
New-Item -ItemType Directory -Force dist-trial/verification | Out-Null
$helpers | ConvertTo-Json | Set-Content dist-trial/verification/HELPER-HASHES.json
python tools/audit-pe-runtime.py trial-stage --output dist-trial/verification/PE-RUNTIME.json
if($LASTEXITCODE -ne 0){throw 'Runtime audit failed'}
Rename-Item trial-stage/KeRoDownload.exe KeRoDownloadPreview.exe
$inno='C:/Program Files (x86)/Inno Setup 6/ISCC.exe'
if(-not (Test-Path $inno)){throw 'Inno Setup unavailable'}
& $inno /Qp tools/Trial.iss
if($LASTEXITCODE -ne 0){throw 'Installer compile failed'}
Copy-Item trial-stage/READ-ME-FIRST.txt dist-trial/README.txt
