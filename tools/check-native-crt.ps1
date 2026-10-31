param([Parameter(Mandatory)][string]$Stage, [switch]$LegacyWindows7, [string]$ReportDir)
$ErrorActionPreference = 'Stop'
$Stage = (Resolve-Path $Stage).Path
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vs = & $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
$dumpbin = Get-ChildItem "$vs/VC/Tools/MSVC/*/bin/Hostx64/x64/dumpbin.exe" | Sort-Object FullName -Descending | Select-Object -First 1 -ExpandProperty FullName
if (-not $dumpbin) { throw 'dumpbin was not found; the runtime check cannot be skipped.' }
if ($ReportDir) { New-Item -ItemType Directory -Force $ReportDir | Out-Null }
$results = @()
foreach ($file in Get-ChildItem $Stage -Recurse -File | Where-Object { $_.Extension -in '.exe', '.dll', '.pyd' }) {
    $text = (& $dumpbin /NOLOGO /DEPENDENTS $file.FullName 2>&1 | Out-String)
    if ($LASTEXITCODE -ne 0) { throw "PE dependency inspection failed: $($file.Name)" }
    $dlls = @([regex]::Matches($text, '(?im)^\s+([^\s\\/:]+\.dll)\s*$') | ForEach-Object { $_.Groups[1].Value.ToLower() } | Sort-Object -Unique)
    $runtime = @($dlls | Where-Object { $_ -match '^(vcruntime\d.*|msvcp\d.*|msvcr\d.*|api-ms-win-crt-.*|ucrtbase(d)?)\.dll$' })
    $main = $file.FullName -eq (Join-Path $Stage 'KeRoDownload.exe')
    $missing = @($runtime | Where-Object {
        -not (Test-Path (Join-Path $file.DirectoryName $_)) -and
        ($main -or $LegacyWindows7 -or $_ -notmatch '^(api-ms-win-crt-.*|ucrtbase)\.dll$')
    })
    if ($main -and $runtime.Count) { throw "KeRoDownload.exe still imports a dynamic VC/UCRT runtime: $($runtime -join ', '). No installer was built." }
    if ($missing.Count) { throw "Helper $($file.Name) requires an unbundled runtime: $($missing -join ', '). Bundling was not changed." }
    if ($ReportDir) { $text | Set-Content (Join-Path $ReportDir ($file.Name + '.dependents.txt')) }
    $results += [ordered]@{file=$file.FullName; dependencies=$dlls; runtime_imports=$runtime; main=$main}
}
if (-not ($results | Where-Object main)) { throw 'KeRoDownload.exe was not inspected' }
if ($ReportDir) { $results | ConvertTo-Json -Depth 8 | Set-Content (Join-Path $ReportDir 'dumpbin-runtime-report.json') }
Write-Host 'Native dependency check passed. Embedded/self-extracted helper payloads require the separate CI audit; a clean Windows VM test remains necessary.'
