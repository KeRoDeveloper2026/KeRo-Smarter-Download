param([string]$Target = 'x86_64-pc-windows-msvc', [string]$ToolsFrom)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
# Preview build only: no install, registry edits, signing, tag or publication.
# No release signing key is passed to Cargo, build scripts or child tools.
Remove-Item Env:UPDATE_SIGNING_KEY -ErrorAction SilentlyContinue
$env:RUSTFLAGS = '-C target-feature=+crt-static'
cargo build --locked --release --target $Target
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
@'
KeRo download-window DESIGN PREVIEW - Windows 10/11 x64

This is a portable application preview, not an installer or a public release.
Close the installed KeRo application first. Extract this ZIP into a new folder,
then run KeRoDownload.exe. Do not overwrite the installed application.
The application uses the existing KeRo settings/download list. Back them up
before testing. Browser integrations, download engine and floating logo are
unchanged. You can keep using the existing browser extension.

The preview contains no third-party helper EXEs. For media/torrent testing,
copy the tools folder from the installed KeRo into this preview folder.
Normal HTTP file download progress can be tested without those helpers.
This preview is not Authenticode-signed. No production updater files changed.
'@ | Set-Content "$stage/READ-ME-FIRST.txt" -Encoding utf8
$zip = Join-Path $PWD 'dist-design-preview/KeRo-Download-Window-Preview-Win10_11-x64.zip'
if (Test-Path $zip) { Remove-Item $zip -Force }
Compress-Archive -Path "$stage/*" -DestinationPath $zip
$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
[IO.File]::WriteAllText("$zip.sha256", "$hash  $([IO.Path]::GetFileName($zip))`n")
