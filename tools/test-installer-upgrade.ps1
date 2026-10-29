param([Parameter(Mandatory)][string]$Platform)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
# This test installs into an ephemeral GitHub-hosted Windows user profile only.
if ($env:GITHUB_ACTIONS -ne 'true' -or $env:RUNNER_ENVIRONMENT -ne 'github-hosted') {
    throw 'Installer upgrade checks require a disposable GitHub-hosted runner'
}
$old = @{
    'Win10_11-x64' = @('KeRoDownload-Setup.exe', 'bd94afcab18b4c5754c6b14535309cc8df175b67f58b950a7699a4176be136cf')
    'Win10_11-x86' = @('KeRoDownload-v1.1.3-Win10_11-x86.exe', '242fd705cb9d28ab7c2afdb381b9182d65cc72853bc0febc25d1b87c3ebc81f3')
    'Win7-x64' = @('KeRoDownload-v1.1.3-Win7-Experimental-x64.exe', '0fc8f1b85761db255df9adc6dab9d1a17e2ad3605c89cac8a52ed0b07cd55edb')
    'Win7-x86' = @('KeRoDownload-v1.1.3-Win7-Experimental-x86.exe', '732954b23a4b17396329e44376c35b050850cacae9485cc622ee30ccecbdf12e')
}[$Platform]
if (-not $old) { throw 'Unknown platform' }
$candidate = @(Get-ChildItem dist/KeRoDownload-v1.1.4-*.exe)
if ($candidate.Count -ne 1) { throw 'Expected exactly one candidate installer' }
$oldPath = Join-Path $env:RUNNER_TEMP 'previous-setup.exe'
Invoke-WebRequest "https://github.com/$env:GITHUB_REPOSITORY/releases/download/v1.1.3/$($old[0])" -OutFile $oldPath
if ((Get-FileHash $oldPath -Algorithm SHA256).Hash.ToLower() -ne $old[1]) { throw 'Previous installer checksum mismatch' }
$installDir = Join-Path $env:RUNNER_TEMP 'KeRo-upgrade-test'
$dataDir = Join-Path $env:APPDATA 'KeRo/KeRoDownload/data'
# Engine tests may have created this disposable runner profile already.
# Preserve any existing files instead of overwriting them with canaries.
function Install-Candidate([string]$Path, [string]$LogName) {
    $logPath = Join-Path $env:RUNNER_TEMP $LogName
    $arguments = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/SP-', '/TASKS=', ('/DIR="' + $installDir + '"'), ('/LOG="' + $logPath + '"'))
    $process = Start-Process -FilePath $Path -ArgumentList $arguments -PassThru -Wait
    if ($process.ExitCode -ne 0) { throw "Installer failed: $LogName, exit $($process.ExitCode)" }
}
Install-Candidate $oldPath 'install-old.log'
$installedExe = Join-Path $installDir 'KeRoDownload.exe'
if (-not (Test-Path $installedExe)) { throw 'Previous installation missing' }
$previousVersion = (Get-Item $installedExe).VersionInfo.ProductVersion
if (-not $previousVersion.StartsWith('1.1.3')) { throw 'Unexpected previous application version' }
New-Item -ItemType Directory -Force $dataDir | Out-Null
# Synthetic canaries only: the application is not launched by this test.
# Real serialization/DPAPI behavior is covered by the engine tests separately.
if (-not (Test-Path (Join-Path $dataDir 'settings.json'))) {
    [IO.File]::WriteAllText((Join-Path $dataDir 'settings.json'), '{"language":"ar","upgrade_test":"settings-canary"}')
}
if (-not (Test-Path (Join-Path $dataDir 'downloads.json'))) {
    [IO.File]::WriteAllText((Join-Path $dataDir 'downloads.json'), '[{"upgrade_test":"download-history-canary"}]')
}
$partial = Join-Path $env:RUNNER_TEMP 'download-canary.part'
[IO.File]::WriteAllBytes($partial, [byte[]](0..255))
$preservedPaths = @((Join-Path $dataDir 'settings.json'), (Join-Path $dataDir 'downloads.json'), $partial)
$before = @{}
foreach ($path in $preservedPaths) { $before[$path] = (Get-FileHash $path -Algorithm SHA256).Hash }
Install-Candidate $candidate[0].FullName 'install-candidate.log'
foreach ($path in $preservedPaths) {
    if (-not (Test-Path $path) -or (Get-FileHash $path -Algorithm SHA256).Hash -ne $before[$path]) {
        throw 'Installer changed or removed existing data'
    }
}
if ((Get-FileHash $installedExe).Hash -ne (Get-FileHash build-cache/stage/KeRoDownload.exe).Hash) { throw 'Installed application differs from candidate' }
$version = (Get-Item $installedExe).VersionInfo.ProductVersion
if (-not $version.StartsWith('1.1.4')) { throw 'Candidate application has wrong version' }
$manifest = Get-Content (Join-Path $installDir 'extension/manifest.json') -Raw | ConvertFrom-Json
if ($manifest.version -ne '1.1.1') { throw 'Unexpected bundled browser extension version' }
foreach ($legal in @('LICENSE', 'COPYRIGHT', 'THIRD-PARTY-NOTICES.txt')) {
    if (-not (Test-Path (Join-Path $installDir $legal))) { throw 'Missing installed legal file' }
}
$protocol = (Get-ItemProperty 'HKCU:/Software/Classes/kero-download/shell/open/command').'(default)'
if (-not $protocol.Contains($installedExe) -or -not $protocol.Contains('--from-browser')) { throw 'Browser protocol registration is incorrect' }
[IO.File]::WriteAllText("$PWD/dist/UPGRADE-$Platform.txt", "PASS: verified v1.1.3 installer upgraded to candidate v1.1.4 on Windows Server 2022.`nExisting CI settings/history (or synthetic canaries when absent) and a partial download were preserved byte-for-byte. Installed EXE matches candidate; version, extension 1.1.1, legal files and protocol registration checked.`nApplication UI, actual download resume and Windows 7 runtime were not exercised by this installer check. Engine tests are reported separately in the workflow.`n")
Write-Host 'Installer upgrade preservation checks passed'
