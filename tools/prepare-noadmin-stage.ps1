param([Parameter(Mandatory)][string]$Platform, [Parameter(Mandatory)][string]$Target)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted') { throw 'Staging existing installers is allowed only on disposable hosted CI' }
$metadata = Get-Content .github/releases/v1.1.4.json -Raw | ConvertFrom-Json
$old = $metadata.installers | Where-Object platform -eq $Platform
if (-not $old) { throw 'Unknown platform' }
$previous = Join-Path $env:RUNNER_TEMP "previous-$Platform.exe"
Invoke-WebRequest "https://github.com/$env:GITHUB_REPOSITORY/releases/download/v1.1.4/$($old.file)" -OutFile $previous
if ((Get-FileHash $previous -Algorithm SHA256).Hash.ToLower() -ne $old.sha256) { throw 'Previous installer checksum mismatch' }
$stage = Join-Path $PWD 'build-cache/stage'
New-Item -ItemType Directory -Force $stage, dist | Out-Null
# The existing per-user installer extracts identical helper bytes into a
# disposable runner folder; no external tool is rebuilt or downloaded anew.
$p = Start-Process $previous -ArgumentList @('/VERYSILENT','/SUPPRESSMSGBOXES','/NORESTART','/SP-','/TASKS=',('/DIR="'+$stage+'"')) -Wait -PassThru
if ($p.ExitCode -ne 0) { throw "Existing installer extraction failed: $($p.ExitCode)" }
$before = @{}
Get-ChildItem "$stage/tools" -Recurse -File | ForEach-Object { $before[$_.FullName.Substring($stage.Length)] = (Get-FileHash $_.FullName).Hash }
Copy-Item "target/$Target/release/KeRoDownload.exe" "$stage/KeRoDownload.exe" -Force
Copy-Item LICENSE, COPYRIGHT, THIRD-PARTY-NOTICES.txt $stage -Force
foreach ($dir in @('extension','extension-firefox')) {
    Remove-Item "$stage/$dir" -Recurse -Force
    Copy-Item $dir "$stage/$dir" -Recurse
    Remove-Item "$stage/$dir/test" -Recurse -Force -ErrorAction SilentlyContinue
}
Remove-Item "$stage/extension/manifest.firefox.json" -Force
if ($Platform.StartsWith('Win7-')) {
    $fx = Get-Content "$stage/extension-firefox/manifest.json" -Raw | ConvertFrom-Json
    $fx.name = 'KeRo Smarter Download (Windows 7)'
    $fx.browser_specific_settings.gecko.strict_min_version = '115.0'
    $fx.browser_specific_settings.gecko.PSObject.Properties.Remove('data_collection_permissions')
    $fx.browser_specific_settings.PSObject.Properties.Remove('gecko_android')
    $fx | ConvertTo-Json -Depth 20 | Set-Content "$stage/extension-firefox/manifest.json" -Encoding utf8
}
foreach ($item in $before.GetEnumerator()) {
    if ((Get-FileHash ($stage+$item.Key)).Hash -ne $item.Value) { throw 'Bundled helper bytes changed' }
}
$before | ConvertTo-Json | Set-Content "dist/HELPER-HASHES-$Platform.json"
[IO.File]::WriteAllText("dist/PREVIOUS-$Platform.txt", $previous)
