param([string]$AppDir)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.ServicePointManager]::SecurityProtocol } catch { }
$work = $null
try {
    if (-not $AppDir) {
        if (Test-Path (Join-Path $PSScriptRoot 'KeRoDownload.exe') -PathType Leaf) {
            $AppDir = $PSScriptRoot
        } else {
            $running = Get-Process -Name KeRoDownload -ErrorAction SilentlyContinue | Where-Object { $_.Path } | Select-Object -First 1
            if ($running) { $AppDir = Split-Path -Parent $running.Path }
            else { $AppDir = Join-Path $env:LOCALAPPDATA 'Programs\KeRo Smarter Download' }
        }
    }
    if (-not (Test-Path (Join-Path $AppDir 'KeRoDownload.exe') -PathType Leaf)) {
        Write-Host 'The installed program was not found automatically.' -ForegroundColor Yellow
        $AppDir = (Read-Host 'Paste the folder containing KeRoDownload.exe').Trim().Trim('"')
    }
    if (-not (Test-Path (Join-Path $AppDir 'KeRoDownload.exe') -PathType Leaf)) {
        throw 'KeRoDownload.exe was not found in the selected folder. Nothing was changed.'
    }
    $tools = Join-Path $AppDir 'tools'
    $target = Join-Path $tools 'ffmpeg.exe'
    Write-Host "Repair location: $target" -ForegroundColor Cyan
    if (Test-Path $target -PathType Leaf) {
        try {
            & $target -version | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host 'FFmpeg already works here. Close and reopen KeRo, then resume the download.' -ForegroundColor Green
                exit 0
            }
        } catch { }
    }
    $work = Join-Path ([IO.Path]::GetTempPath()) ('KeRo-FFmpeg-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    $url = 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip'
    $appBytes = [IO.File]::ReadAllBytes((Join-Path $AppDir 'KeRoDownload.exe'))
    $peOffset = [BitConverter]::ToInt32($appBytes, 60)
    if ([BitConverter]::ToUInt16($appBytes, $peOffset + 4) -eq 0x14c) {
        $url = 'https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-Win10_11-x86.zip'
    }
    $platformFile = Join-Path $tools 'build-platform.txt'
    if (Test-Path $platformFile -PathType Leaf) {
        $platform = ([IO.File]::ReadAllText($platformFile)).Trim()
        if ($platform -match '^(Win7-(x86|x64)|Win10_11-x86)$') {
            $url = "https://github.com/KeRoDeveloper2026/KeRo-Smarter-Download/releases/latest/download/ffmpeg-$platform.zip"
        }
    }
    function Download-File([string]$Uri, [string]$OutFile) {
        for ($attempt = 1; $attempt -le 3; $attempt++) {
            try {
                Invoke-WebRequest -Uri $Uri -OutFile $OutFile -UseBasicParsing -TimeoutSec 600
                if ((Get-Item $OutFile).Length -gt 0) { return }
                throw 'An empty file was received.'
            } catch {
                if ($attempt -eq 3) { throw }
                Write-Host "Retrying download ($attempt/3)..." -ForegroundColor Yellow
            }
        }
    }
    Write-Host 'Downloading FFmpeg. Please keep this window open...' -ForegroundColor Cyan
    $zip = Join-Path $work 'ffmpeg.zip'
    $sum = Join-Path $work 'ffmpeg.sha256'
    Download-File "$url.sha256" $sum
    $expected = [string]([regex]::Match([IO.File]::ReadAllText($sum), '^\s*([0-9a-fA-F]{64})(?=\s|$)').Groups[1].Value)
    if ($expected -notmatch '^[a-fA-F0-9]{64}$') { throw 'Invalid published SHA-256 checksum.' }
    Download-File $url $zip
    if ((Get-FileHash $zip -Algorithm SHA256).Hash -ne $expected) { throw 'Checksum mismatch. The downloaded file will not be installed. Please retry.' }
    $unpacked = Join-Path $work 'unpacked'
    Expand-Archive -LiteralPath $zip -DestinationPath $unpacked -Force
    $ff = Get-ChildItem -LiteralPath $unpacked -Filter ffmpeg.exe -Recurse -File | Select-Object -First 1
    if (-not $ff) { throw 'ffmpeg.exe was not found inside the downloaded archive.' }
    & $ff.FullName -version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'The downloaded FFmpeg does not run on this Windows installation.' }
    New-Item -ItemType Directory -Path $tools -Force | Out-Null
    $staged = Join-Path $tools 'ffmpeg.new'
    Copy-Item -LiteralPath $ff.FullName -Destination $staged -Force
    Move-Item -LiteralPath $staged -Destination $target -Force
    $license = Get-ChildItem -LiteralPath $unpacked -Filter 'LICENSE*' -Recurse -File | Select-Object -First 1
    if ($license) { Copy-Item -LiteralPath $license.FullName -Destination (Join-Path $tools 'ffmpeg-LICENSE.txt') -Force }
    & $target -version | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'FFmpeg was copied but its final check failed.' }
    Write-Host 'Repair complete. Close and reopen KeRo, then resume the failed download.' -ForegroundColor Green
    Write-Host 'Your download list and downloaded parts were not removed.'
} catch {
    Write-Host ("Repair failed: " + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Check the internet connection and that the selected application folder is writable.'
    exit 1
} finally {
    if ($work -and (Test-Path -LiteralPath $work)) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
}
