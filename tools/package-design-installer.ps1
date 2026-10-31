$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$preview=Join-Path $PWD 'dist-design-preview/KeRo-Download-Window-Preview-Win10_11-x64.zip'
Expand-Archive $preview trial-stage -Force
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
KeRo Download Preview — UI reference v3 — Windows 10/11 x64 — trial only

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
8. Window colors: open Window colors in the progress dialog. Choose a preset
   or enter three #RRGGBB values and Apply colors. Saved for future windows.
   Vector icons replace font symbols; header drag excludes caption buttons.
   Original floating logo is unchanged. UI v3 is built from the supplied reference brief; the engine remains unchanged.
9. This is unsigned test software. SmartScreen may still appear.
10. Windows Server CI checks do not certify a clean Windows 10/11 VM.
11. The ZIP also includes extension and extension-firefox folders ready for
    loading in a separate browser profile; use these trial copies on port 9615.
12. The speed and completion controls apply the existing engine options.
    Cancel pauses and closes while keeping partial files, as before.
    UI showcase images use explicitly labeled QA sample data; app mode is live.
    No new blur, shader, animation timer or WebView was added. RAM reduction
    versus the previous build has not been measured.

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
(Get-FileHash 'trial-stage/KeRoDownload.exe').Hash.ToLower() | Set-Content dist-trial/verification/APP-SHA256.txt
Rename-Item trial-stage/KeRoDownload.exe KeRoDownloadPreview.exe
$inno='C:/Program Files (x86)/Inno Setup 6/ISCC.exe'
if(-not (Test-Path $inno)){throw 'Inno Setup unavailable'}
& $inno /Qp tools/Trial.iss
if($LASTEXITCODE -ne 0){throw 'Installer compile failed'}
Copy-Item trial-stage/READ-ME-FIRST.txt dist-trial/README.txt
foreach($dir in @('extension','extension-firefox')){ Copy-Item "trial-stage/$dir" "dist-trial/$dir" -Recurse -Force }
Copy-Item tools/Trial.iss dist-trial/verification/Trial.iss
