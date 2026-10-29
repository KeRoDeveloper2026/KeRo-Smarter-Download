param([Parameter(Mandatory)][string]$Platform, [Parameter(Mandatory)][string]$Target, [bool]$Legacy)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$version = ([regex]::Match((Get-Content Cargo.toml -Raw), '(?m)^version\s*=\s*"([^"]+)"')).Groups[1].Value
$x86 = $Target.StartsWith('i686-')
$machine = if ($x86) { 0x14c } else { 0x8664 }
$stage = 'build-cache/stage'
New-Item -ItemType Directory -Force "$stage/tools", dist | Out-Null
Copy-Item "target/$Target/release/KeRoDownload.exe" $stage
Copy-Item THIRD-PARTY-NOTICES.txt $stage
Copy-Item -Recurse extension "$stage/extension"
Copy-Item -Recurse extension "$stage/extension-firefox"
Remove-Item -Recurse -Force "$stage/extension/test", "$stage/extension-firefox/test" -ErrorAction SilentlyContinue
Copy-Item extension/manifest.firefox.json "$stage/extension-firefox/manifest.json" -Force
Remove-Item "$stage/extension/manifest.firefox.json"
Copy-Item ffmpeg-out/* "$stage/tools/"
Copy-Item REPAIR-FFMPEG.bat, repair-ffmpeg.ps1 $stage
[IO.File]::WriteAllText("$stage/build-platform.txt", $Platform)
# Recovery must retain the selected platform, even when a 32-bit app runs on x64.
Copy-Item "$stage/build-platform.txt" "$stage/tools/build-platform.txt"
$ffAsset = "ffmpeg-$Platform.zip"
Compress-Archive -Path ffmpeg-out/* -DestinationPath "dist/$ffAsset"
$ffHash = (Get-FileHash "dist/$ffAsset" -Algorithm SHA256).Hash.ToLower()
[IO.File]::WriteAllText("$PWD/dist/$ffAsset.sha256", "$ffHash  $ffAsset`n")

function Check-PE([string]$Path, [int]$Expected) {
    $b = [IO.File]::ReadAllBytes((Resolve-Path $Path))
    $pe = [BitConverter]::ToInt32($b, 60)
    if ([BitConverter]::ToUInt16($b, $pe + 4) -ne $Expected) { throw "Wrong architecture: $Path" }
}
function Download-Checked([string]$Url, [string]$Path, [string]$Sha) {
    Invoke-WebRequest $Url -OutFile $Path
    if ((Get-FileHash $Path -Algorithm SHA256).Hash -ne $Sha.ToUpper()) { throw "Checksum mismatch: $Path" }
}

if ($Legacy) {
    $ytName = if ($x86) { 'yt-dlp_x86_win7.exe' } else { 'yt-dlp_win7.exe' }
    $ytHash = if ($x86) { '9c8c9c707528650f5f3c881082670a4828e4bd3eb9fa6b63d2ff957ada40cb7b' } else { 'ba637be14bb18c392a5775873f9cc910dd37f6aa7992a04e2f86f7f23b35520d' }
    Download-Checked "https://github.com/nicolaasjan/yt-dlp/releases/download/2026.10.27.141215/$ytName" "$stage/tools/yt-dlp.exe" $ytHash
} else {
    $release = Invoke-RestMethod https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest -Headers @{ Authorization = "Bearer $env:GH_TOKEN" }
    $ytName = 'yt-dlp_x86.exe'
    $sums = (Invoke-WebRequest ($release.assets | Where-Object name -eq 'SHA2-256SUMS').browser_download_url).Content
    if ($sums -is [byte[]]) { $sums = [Text.Encoding]::UTF8.GetString($sums) }
    $ytHash = [regex]::Match($sums, '(?m)^([0-9a-fA-F]{64})\s+\*?yt-dlp_x86\.exe\s*$').Groups[1].Value
    if ($ytHash.Length -ne 64) { throw 'Missing yt-dlp checksum' }
    Download-Checked ($release.assets | Where-Object name -eq $ytName).browser_download_url "$stage/tools/yt-dlp.exe" $ytHash
}
$bits = if ($x86) { '32' } else { '64' }
$ariaZipHash = if ($x86) { '35f6514cc5dd7e98a87b3c4c2d25a0754b9b063dbe59bc0f22d483464f61e5b6' } else { '67d015301eef0b612191212d564c5bb0a14b5b9c4796b76454276a4d28d9b288' }
Download-Checked "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-${bits}bit-build1.zip" aria2.zip $ariaZipHash
Expand-Archive aria2.zip aria2-tmp
Copy-Item (Get-ChildItem aria2-tmp -Recurse -Filter aria2c.exe | Select-Object -First 1).FullName "$stage/tools/"
Copy-Item (Get-ChildItem aria2-tmp -Recurse -Filter COPYING | Select-Object -First 1).FullName "$stage/tools/aria2-COPYING.txt"
foreach ($exe in @("$stage/KeRoDownload.exe", "$stage/tools/ffmpeg.exe", "$stage/tools/yt-dlp.exe", "$stage/tools/aria2c.exe")) { Check-PE $exe $machine }
foreach ($tool in @('ffmpeg', 'yt-dlp', 'aria2c')) {
    $arg = if ($tool -eq 'ffmpeg') { '-version' } else { '--version' }
    & "$stage/tools/$tool.exe" $arg
    if ($LASTEXITCODE -ne 0) { throw "$tool smoke test failed on the build host" }
}
$description = if ($Legacy) { 'EXPERIMENTAL: built for Windows 7 SP1; runtime testing on Windows 7 is still required. Engine and helper smoke tests run on Windows Server 2022 only. Community yt-dlp build is pinned; automatic replacement with upstream yt-dlp is disabled.' } else { 'x86 build for Windows 10; can also run through x86 compatibility on Windows 11. Engine and helper smoke tests run on Windows Server 2022.' }
[IO.File]::WriteAllText("$PWD/dist/BUILD-INFO-$Platform.txt", "KeRo Smarter Download $version`nSource: $env:GITHUB_SHA`nTarget: $Target`n$description`n")
$label = if ($Legacy) { $Platform.Replace('Win7-', 'Win7-Experimental-') } else { $Platform }
$name = "KeRoDownload-v$version-$label"
choco install innosetup -y --no-progress
$defines = @("/DMyAppVersion=$version", "/DOutputName=$name")
if ($x86) { $defines += '/DAppX86' }
if ($Legacy) { $defines += '/DLegacyWin7' }
& "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe" /Q @defines installer/KeRo.iss
if ($LASTEXITCODE -ne 0) { throw 'Inno Setup failed' }
if (-not $env:UPDATE_SIGNING_KEY) { throw 'UPDATE_SIGNING_KEY is required' }
$hash = (Get-FileHash "dist/$name.exe" -Algorithm SHA256).Hash.ToLower()
# The signing utility executes on the build host, independent of target architecture.
$sig = (cargo run --quiet --release -p swiftget-engine --example sign_update -- $version $hash).Trim()
if ($LASTEXITCODE -ne 0 -or $sig.Length -ne 128) { throw 'Update signing failed' }
$manifest = @{ version = $version; url = "https://github.com/$env:GITHUB_REPOSITORY/releases/download/v$version/$name.exe"; sha256 = $hash; sig = $sig }
$manifest | ConvertTo-Json | Set-Content "dist/version-$Platform.json" -Encoding utf8
