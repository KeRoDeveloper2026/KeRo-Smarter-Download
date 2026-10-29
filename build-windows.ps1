# KeRo Smarter Download - one-click Windows build
# Installs what is missing (Visual Studio C++ Build Tools, Rust), builds
# KeRoDownload.exe, gets ffmpeg + yt-dlp and makes dist\KeRoDownload-Setup.exe.

$ErrorActionPreference = "Stop"
# Windows PowerShell 5.1 starts with old TLS versions that GitHub refuses, and its
# progress bar makes downloads very slow: switch both before any download.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.ServicePointManager]::SecurityProtocol } catch { }
$ProgressPreference = "SilentlyContinue"
Set-Location -Path $PSScriptRoot

function Step($text) { Write-Host ""; Write-Host "==> $text" -ForegroundColor Cyan }
function Fail($text) {
    Write-Host ""
    Write-Host "ERROR: $text" -ForegroundColor Red
    Write-Host "Send a screenshot of this window to Claude." -ForegroundColor Yellow
    Read-Host "Press Enter to close"
    exit 1
}
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
                "$env:USERPROFILE\.cargo\bin"
}

Write-Host "KeRo Smarter Download build" -ForegroundColor Green
Write-Host "The first run downloads a few GB and can take 20-40 minutes. Later runs are fast."

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Fail "winget was not found. Install 'App Installer' from the Microsoft Store, then run this again."
}

# ---------------------------------------------------------------- 1. C++ build tools
Step "Checking Visual Studio C++ Build Tools"
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$hasVc = $false
if (Test-Path $vswhere) {
    $vc = & $vswhere -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($vc) { $hasVc = $true }
}
if (-not $hasVc) {
    Step "Installing Visual Studio C++ Build Tools (big download, please wait; accept the admin prompt)"
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e --accept-package-agreements --accept-source-agreements `
        --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
    if ($LASTEXITCODE -ne 0 -and $LASTEXITCODE -ne 3010) { Fail "Installing the C++ Build Tools failed (code $LASTEXITCODE)." }
} else {
    Write-Host "Found."
}

# ---------------------------------------------------------------- 2. Rust
Step "Checking Rust"
Refresh-Path
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Step "Installing Rust"
    winget install --id Rustlang.Rustup -e --accept-package-agreements --accept-source-agreements
    Refresh-Path
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) { Fail "Rust was installed but not found. Restart the computer and run this again." }
}
rustup default stable-msvc | Out-Null
cargo --version

# the version comes from Cargo.toml ([workspace.package] version = "...")
$version = ([regex]::Match((Get-Content (Join-Path $PSScriptRoot "Cargo.toml") -Raw), '(?m)^version\s*=\s*"([^"]+)"')).Groups[1].Value
if (-not $version) { $version = "1.0.0" }
Write-Host "Version $version"

# ---------------------------------------------------------------- 3. build
# a running copy would lock the files we replace
Get-Process KeRoDownload, SwiftGet -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Step "Building KeRoDownload.exe (first time: 5-15 minutes)"
cargo build --release
if ($LASTEXITCODE -ne 0) { Fail "The build failed. Scroll up to see the first red 'error' lines." }

# ---------------------------------------------------------------- 4. package
# The result is ONE file: dist\KeRoDownload-Setup.exe (+ dist\version.json
# for the GitHub release). Everything that goes into the setup is gathered
# first in build-cache\stage, which is not part of the result:
#   KeRoDownload.exe, tools\yt-dlp.exe + ffmpeg.exe, extension, extension-firefox
Step "Preparing the files for the setup"
$dist = Join-Path $PSScriptRoot "dist"
$cache = Join-Path $PSScriptRoot "build-cache"
$stage = Join-Path $cache "stage"
$tools = Join-Path $stage "tools"
if (Test-Path $stage) { Remove-Item -Recurse -Force $stage }
New-Item -ItemType Directory -Force $dist, $stage, $tools, $cache | Out-Null
# what older builds left in dist: only the setup stays there
foreach ($old in @("KeRoDownload.exe", "ffmpeg.exe", "yt-dlp.exe")) {
    Remove-Item (Join-Path $dist $old) -Force -ErrorAction SilentlyContinue
}
foreach ($old in @("extension", "portable", "store", "redist")) {
    if (Test-Path "$dist\$old") { Remove-Item -Recurse -Force "$dist\$old" }
}

Copy-Item "target\release\KeRoDownload.exe" $stage -Force
foreach ($name in @("extension", "extension-firefox")) {
    $to = Join-Path $stage $name
    if (Test-Path $to) { Remove-Item -Recurse -Force $to }
    Copy-Item -Recurse "extension" $to
    Remove-Item -Recurse -Force "$to\test" -ErrorAction SilentlyContinue
}
# Firefox wants its own manifest; the others ignore this file
Copy-Item -Force "$stage\extension-firefox\manifest.firefox.json" "$stage\extension-firefox\manifest.json"
Remove-Item "$stage\extension-firefox\manifest.firefox.json" -Force
Remove-Item "$stage\extension\manifest.firefox.json" -Force -ErrorAction SilentlyContinue

# yt-dlp (finds video links) and aria2 (torrents): downloaded once into
# build-cache, the app keeps yt-dlp updated by itself afterwards
# Download with 3 tries; falls back to curl.exe (built into Windows 10/11).
function Get-RemoteFile($url, $out) {
    $err = $null
    for ($i = 1; $i -le 3; $i++) {
        try { Invoke-WebRequest $url -OutFile $out -UseBasicParsing; if ((Test-Path $out) -and (Get-Item $out).Length -gt 0) { return } }
        catch { $err = $_.Exception.Message }
        $curl = Join-Path $env:SystemRoot "System32\curl.exe"
        if (Test-Path $curl) {
            & $curl -L --fail --silent --show-error --retry 2 -o $out $url 2>$null
            if ($LASTEXITCODE -eq 0 -and (Test-Path $out) -and (Get-Item $out).Length -gt 0) { return }
        }
        Start-Sleep -Seconds (2 * $i)
    }
    throw "Could not download $url ($err)"
}
# The SHA-256 of a file from a checksum list ("<sha256>  <name>" lines), checked.
function Assert-Sha256($file, $sumsUrl, $name) {
    $sumsFile = Join-Path $env:TEMP "kero-sums.txt"
    Get-RemoteFile $sumsUrl $sumsFile
    $text = [IO.File]::ReadAllText($sumsFile)
    $want = [string]($text -split "`n" | Where-Object { $_ -match "^([0-9a-fA-F]{64})\s+\*?$([regex]::Escape($name))\s*$" } |
        ForEach-Object { ($_ -split '\s+')[0] } | Select-Object -First 1)
    $got = (Get-FileHash $file -Algorithm SHA256).Hash
    if ($want -notmatch '^[0-9a-fA-F]{64}$' -or $got -ne $want) {
        Remove-Item -Force $file -ErrorAction SilentlyContinue
        throw "$name does not match its published SHA-256"
    }
}
# ffmpeg: our own small build (tools\ffmpeg\build.sh; GitHub builds it for
# every release). A ready one in tools\ffmpeg\win64 is used when it is there;
# the big public build of earlier versions is not used any more.
$ours = Join-Path $PSScriptRoot "tools\ffmpeg\win64"
if (Test-Path "$ours\ffmpeg.exe") {
    foreach ($f in @("ffmpeg.exe", "ffmpeg-LICENSE.txt", "lame-COPYING.txt", "ffmpeg-version.txt")) {
        if (Test-Path "$ours\$f") { Copy-Item "$ours\$f" $cache -Force }
    }
}
if (-not (Test-Path "$cache\ffmpeg.exe")) {
    Step "Downloading ffmpeg (joins video + audio)"
    try {
        $fz = Join-Path $cache "ffmpeg.zip"
        $fu = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        Get-RemoteFile $fu $fz
        $sumFile = Join-Path $env:TEMP "kero-ffmpeg-sum.txt"
        Get-RemoteFile "$fu.sha256" $sumFile
        # A one-result PowerShell pipeline unwraps its array; [0] would
        # then return a Char. Regex Group.Value always returns a String.
        $want = [string]([regex]::Match([IO.File]::ReadAllText($sumFile), '^\s*([0-9a-fA-F]{64})(?=\s|$)').Groups[1].Value)
        if ($want -notmatch '^[0-9a-fA-F]{64}$') { throw "The FFmpeg checksum response does not contain a valid SHA-256" }
        # -ne compares strings case-insensitively; no Char.ToUpper call.
        if ((Get-FileHash $fz -Algorithm SHA256).Hash -ne $want) { Remove-Item $fz -Force; throw "ffmpeg.zip does not match its published SHA-256" }
        $ft = Join-Path $cache "ffmpeg-tmp"
        if (Test-Path $ft) { Remove-Item $ft -Recurse -Force }
        Expand-Archive $fz -DestinationPath $ft -Force
        Copy-Item (Get-ChildItem $ft -Recurse -Filter ffmpeg.exe | Select-Object -First 1).FullName "$cache\ffmpeg.exe" -Force
        $lic = Get-ChildItem $ft -Recurse -Filter LICENSE* | Select-Object -First 1
        if ($lic) { Copy-Item $lic.FullName "$cache\ffmpeg-LICENSE.txt" -Force }
        Set-Content "$cache\ffmpeg-version.txt" "ffmpeg essentials build from gyan.dev"
        Remove-Item $ft -Recurse -Force
        Remove-Item $fz -Force
    } catch {
        Fail "FFmpeg could not be downloaded: $($_.Exception.Message). No installer will be made without it. Check the connection, or place a working ffmpeg.exe in tools\ffmpeg\win64, then run BUILD.bat again."
    }
}
if (-not (Test-Path "$cache\yt-dlp.exe")) {
    Step "Downloading yt-dlp (finds the links of videos)"
    try {
        $base = "https://github.com/yt-dlp/yt-dlp/releases/latest/download"
        Get-RemoteFile "$base/yt-dlp.exe" "$cache\yt-dlp.exe"
        Assert-Sha256 "$cache\yt-dlp.exe" "$base/SHA2-256SUMS" "yt-dlp.exe"
    } catch {
        Write-Host "Could not download yt-dlp now ($($_.Exception.Message)). KeRo Smarter Download gets it by itself later." -ForegroundColor Yellow
    }
}
if (-not (Test-Path "$cache\aria2c.exe")) {
    Step "Downloading aria2 (torrents)"
    try {
        $zip = Join-Path $cache "aria2.zip"
        Get-RemoteFile "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" $zip
        if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne "67D015301EEF0B612191212D564C5BB0A14B5B9C4796B76454276A4D28D9B288") { throw "aria2.zip does not match its SHA-256" }
        $tmp = Join-Path $cache "aria2-tmp"
        Expand-Archive $zip -DestinationPath $tmp -Force
        Copy-Item (Get-ChildItem $tmp -Recurse -Filter aria2c.exe | Select-Object -First 1).FullName "$cache\aria2c.exe" -Force
        Copy-Item (Get-ChildItem $tmp -Recurse -Filter COPYING | Select-Object -First 1).FullName "$cache\aria2-COPYING.txt" -Force
        Remove-Item $tmp -Recurse -Force
    } catch {
        Write-Host "Could not download aria2 now ($($_.Exception.Message)). KeRo Smarter Download gets it by itself later." -ForegroundColor Yellow
    }
}
# Visual C++ runtime: the program already carries it (static CRT, see
# .cargo\config.toml). Optional: put Microsoft's vc_redist.x64.exe into
# build-cache yourself and the installer also installs it where it is missing.
$redist = Join-Path $cache "redist"
New-Item -ItemType Directory -Force $redist | Out-Null
if (Test-Path "$cache\vc_redist.x64.exe") { Copy-Item "$cache\vc_redist.x64.exe" $redist -Force }
Copy-Item "LICENSE", "COPYRIGHT", "THIRD-PARTY-NOTICES.txt" $stage -Force
# the Firefox add-on signed by Mozilla for this version (stays in Firefox for good)
$extVersion = (Get-Content (Join-Path $PSScriptRoot "extension\manifest.firefox.json") -Raw | ConvertFrom-Json).version
$signedXpi = "extension-signed\kero-download-firefox-$extVersion.xpi"
if (Test-Path $signedXpi) { Copy-Item $signedXpi (Join-Path $stage "kero-download-firefox.xpi") -Force }
foreach ($f in @("ffmpeg.exe", "yt-dlp.exe", "ffmpeg-version.txt", "ffmpeg-LICENSE.txt", "lame-COPYING.txt", "aria2c.exe", "aria2-COPYING.txt")) {
    if (Test-Path "$cache\$f") { Copy-Item "$cache\$f" $tools -Force }
}

# FFmpeg is required for separate video/audio streams and MP3 conversion.
$ffmpegStaged = Join-Path $tools "ffmpeg.exe"
if (-not (Test-Path $ffmpegStaged -PathType Leaf)) { Fail "tools\ffmpeg.exe is missing from the staged application." }
& $ffmpegStaged -version | Out-Null
if ($LASTEXITCODE -ne 0) { Fail "The staged ffmpeg.exe does not run on this machine. Replace it and rebuild." }
Copy-Item "REPAIR-FFMPEG.bat", "repair-ffmpeg.ps1" $stage -Force

# ---------------------------------------------------------------- 4b. signing (optional)
# With a code signing certificate antivirus programs and Windows SmartScreen
# trust the program. Put it in signing\kero.pfx and its password in
# signing\password.txt - everything is then signed automatically.
$pfx = Join-Path $PSScriptRoot "signing\kero.pfx"
$signtool = $null
if (Test-Path $pfx) {
    $signtool = Get-ChildItem "${env:ProgramFiles(x86)}\Windows Kits\10\bin" -Recurse -Filter signtool.exe -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "x64" } | Select-Object -First 1 -ExpandProperty FullName
}
function Sign-File($file) {
    if (-not $signtool) { return }
    $pw = (Get-Content (Join-Path $PSScriptRoot "signing\password.txt") -Raw).Trim()
    & $signtool sign /fd SHA256 /f $pfx /p $pw /tr "http://timestamp.digicert.com" /td SHA256 /d "KeRo Smarter Download" $file | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Host "Signed $file" } else { Write-Host "Could not sign $file" -ForegroundColor Yellow }
}
if ($signtool) {
    Step "Signing KeRoDownload.exe"
    Sign-File "$stage\KeRoDownload.exe"
}


# ---------------------------------------------------------------- 5. installer
Step "Creating the installer (KeRoDownload-Setup.exe)"
function Find-Iscc {
    @("${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
      "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
      "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe") | Where-Object { Test-Path $_ } | Select-Object -First 1
}
$iscc = Find-Iscc
if (-not $iscc) {
    Write-Host "Installing Inno Setup (makes the installer)..."
    winget install --id JRSoftware.InnoSetup -e --accept-package-agreements --accept-source-agreements | Out-Null
    $iscc = Find-Iscc
}
$setup = Join-Path $dist "KeRoDownload-Setup.exe"
if ($iscc) {
    # Antivirus / OneDrive often lock a new .exe for a moment while Inno Setup
    # writes its icon into it ("EndUpdateResource failed"). So: build in a
    # temp folder, retry a few times, and as a last resort build without the
    # installer's own icon.
    $out = Join-Path $env:TEMP "kero-setup-build"
    New-Item -ItemType Directory -Force $out | Out-Null
    $iss = Join-Path $PSScriptRoot "installer\KeRo.iss"
    $ok = $false
    foreach ($extra in @("", "", "/DNoIcon")) {
        Remove-Item (Join-Path $out "KeRoDownload-Setup.exe") -Force -ErrorAction SilentlyContinue
        $flags = @("/Q", "/O$out", "/DMyAppVersion=$version")
        if ($extra) { $flags += $extra }
        & $iscc @flags $iss
        if ($LASTEXITCODE -eq 0 -and (Test-Path (Join-Path $out "KeRoDownload-Setup.exe"))) { $ok = $true; break }
        Write-Host "Retrying (the antivirus was probably scanning the file)..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
    if ($ok) {
        Copy-Item (Join-Path $out "KeRoDownload-Setup.exe") $setup -Force
        Sign-File $setup
        # version.json: the program reads it from the latest GitHub release
        # to update itself. Never leave an unsigned or stale update manifest.
        $hash = (Get-FileHash $setup -Algorithm SHA256).Hash.ToLower()
        Remove-Item (Join-Path $dist "version.json") -Force -ErrorAction SilentlyContinue
        if ($env:UPDATE_SIGNING_KEY) {
            $sig = (cargo run --quiet --release -p swiftget-engine --example sign_update -- $version $hash)
            if ($LASTEXITCODE -ne 0 -or -not $sig -or $sig.Trim().Length -ne 128) { Fail "Could not sign the update. Check UPDATE_SIGNING_KEY against UPDATE_PUBLIC_KEY." }
            $json = [ordered]@{
                version = $version
                url = "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/download/v$version/KeRoDownload-Setup.exe"
                sha256 = $hash
                sig = $sig.Trim()
            } | ConvertTo-Json
            [IO.File]::WriteAllText((Join-Path $dist "version.json"), $json)
        } else {
            Write-Warning "Installer built for manual installation only. UPDATE_SIGNING_KEY is missing; no version.json was created. See docs/RELEASING.md."
        }
    } else {
        Fail "Could not create the setup. Tip: move this folder out of Desktop/OneDrive (e.g. to C:\KeRo) and run BUILD.bat again."
    }
} else {
    Fail "Inno Setup is not available, so the setup could not be made. Install Inno Setup 6 and run BUILD.bat again."
}

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green
if (Test-Path $setup) {
    Write-Host ""
    Write-Host "  >> Double-click  dist\KeRoDownload-Setup.exe  to install KeRo Smarter Download <<" -ForegroundColor Green
    Write-Host "     (Start Menu folder, desktop shortcut, starts with Windows, uninstall from Settings > Apps)"
}
if (Test-Path "$dist\version.json") {
    Write-Host ""
    Write-Host "Also in $dist : version.json (it goes into the GitHub release together with the setup)"
}
Start-Process explorer.exe $dist
Read-Host "Press Enter to close"
