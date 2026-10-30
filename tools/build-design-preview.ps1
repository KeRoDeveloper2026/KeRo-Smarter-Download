param([string]$Target = 'x86_64-pc-windows-msvc', [string]$ToolsFrom)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
# Preview build only: no install, registry edits, signing, tag or publication.
# No release signing key is passed to Cargo, build scripts or child tools.
Remove-Item Env:UPDATE_SIGNING_KEY -ErrorAction SilentlyContinue
$env:RUSTFLAGS = '-C target-feature=+crt-static'
cargo build --locked --release --features design-preview --target $Target
if ($LASTEXITCODE -ne 0) { throw 'Preview application build failed' }
$stage = Join-Path $PWD 'dist-design-preview/KeRo-Design-Preview'
New-Item -ItemType Directory -Force $stage | Out-Null
Copy-Item "target/$Target/release/KeRoDownload.exe" $stage -Force
Copy-Item LICENSE, COPYRIGHT, THIRD-PARTY-NOTICES.txt $stage -Force
foreach ($name in @('extension', 'extension-firefox')) {
    $dest = Join-Path $stage $name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item $name $dest -Recurse
    Remove-Item "$dest/test" -Recurse -Force -ErrorAction SilentlyContinue
}
if ($ToolsFrom) {
    if (-not (Test-Path "$ToolsFrom/ffmpeg.exe")) { throw 'ToolsFrom must be an existing KeRo tools folder' }
    Copy-Item $ToolsFrom "$stage/tools" -Recurse -Force
}
# Separate test extensions: their copies use port 9615 and a separate Firefox ID.
foreach ($name in @('extension', 'extension-firefox')) {
    foreach ($js in @('background.js', 'options.js')) {
        $file = Join-Path $stage "$name/$js"
        $content = [IO.File]::ReadAllText($file).Replace('port: 9614', 'port: 9615')
        [IO.File]::WriteAllText($file, $content, [Text.UTF8Encoding]::new($false))
    }
    $file = Join-Path $stage "$name/manifest.json"
    $manifest = Get-Content $file -Raw | ConvertFrom-Json
    $manifest.name = 'KeRo Design Preview (test only)'
    if ($manifest.browser_specific_settings.gecko) { $manifest.browser_specific_settings.gecko.id = 'kero-design-preview@kerodeveloper2026' }
    $manifest | ConvertTo-Json -Depth 30 | Set-Content $file -Encoding utf8
}
@'
KeRo DOWNLOAD WINDOW DESIGN PREVIEW - Windows 10/11 x64

نسخة تجريبية مستقلة، وليست تحديثا أو مثبتا للبرنامج الأساسي.
فك الضغط في مجلد جديد، وشغّل KeRoDownload.exe.
الإعدادات والتحميلات التجريبية تحفظ في KeRoDesignPreview داخل بيانات المستخدم.
لا يتم استيراد أو تعديل بيانات البرنامج الأساسي. منفذ التجربة 9615.
التحديث التلقائي والتشغيل مع Windows معطلان في نسخة التجربة.

لتجربة الإضافة معها دون تغيير إعدادات إضافتك الأساسية:
استخدم ملف مستخدم منفصلا في المتصفح، وحمّل مجلد extension كإضافة غير معبأة.
لفايرفوكس استخدم extension-firefox/manifest.json عبر about:debugging.
اللوجو العائم كما هو؛ اسم نسخة الإضافة التجريبية يميزها فقط.

لتحميل الفيديو أو التورنت انسخ مجلد tools من البرنامج المثبت إلى مجلد التجربة.
تحميل ملفات HTTP العادية واختبار نافذة التقدم لا يحتاج أدوات الوسائط.

This portable preview uses its own KeRoDesignPreview profile and port 9615.
Automatic app/helper updates and Windows autostart are disabled. No installer,
production updater manifests, registry association or production data migration.
Use a separate browser profile for its test extension (extension folder).
Unsigned Firefox preview: load extension-firefox/manifest.json temporarily.
The ZIP contains no third-party helper EXEs; copy the existing tools folder
for media/torrent tests. Normal HTTP downloads need no extra tools.
'@ | Set-Content "$stage/READ-ME-FIRST.txt" -Encoding utf8
$zip = Join-Path $PWD 'dist-design-preview/KeRo-Download-Window-Preview-Win10_11-x64.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path "$stage/*" -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
[IO.File]::WriteAllText("$zip.sha256", "$hash  $([IO.Path]::GetFileName($zip))`n")
