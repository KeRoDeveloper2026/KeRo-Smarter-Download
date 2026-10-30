$ErrorActionPreference = 'Stop'
$exe = Join-Path $PWD 'dist-design-preview/KeRo-Design-Preview/KeRoDownload.exe'
$diagnostics = Join-Path $PWD 'dist-design-preview/diagnostics'
New-Item -ItemType Directory -Force $diagnostics | Out-Null
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class DesignWindowCapture {
 [StructLayout(LayoutKind.Sequential)] public struct RECT { public int L,T,R,B; }
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd, out RECT rect);
}
'@
# Native Slint render using clearly marked sample data; no production profile.
$p = Start-Process $exe -ArgumentList '--design-preview-showcase' -PassThru
try {
    $deadline = (Get-Date).AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 300
        $p.Refresh()
        if ($p.HasExited) { throw "Native sample window exited: $($p.ExitCode)" }
    } while ($p.MainWindowHandle -eq 0 -and (Get-Date) -lt $deadline)
    if ($p.MainWindowHandle -eq 0) { throw 'Native progress dialog did not open' }
    Start-Sleep -Seconds 2
    $rect = New-Object DesignWindowCapture+RECT
    if (-not [DesignWindowCapture]::GetWindowRect($p.MainWindowHandle, [ref]$rect)) { throw 'Cannot read window bounds' }
    $bmp = New-Object Drawing.Bitmap(($rect.R-$rect.L), ($rect.B-$rect.T))
    $graphics = [Drawing.Graphics]::FromImage($bmp)
    try {
        $graphics.CopyFromScreen($rect.L, $rect.T, 0, 0, $bmp.Size)
        $bmp.Save((Join-Path $diagnostics 'native-progress-sample.png'), [Drawing.Imaging.ImageFormat]::Png)
    } finally { $graphics.Dispose(); $bmp.Dispose() }
} finally { if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force } }

# Normal app startup must expose only the isolated test profile and port.
$production = Join-Path $env:APPDATA 'KeRo/KeRoDownload'
function Profile-Fingerprint {
    if (-not (Test-Path $production)) { return '' }
    return ((Get-ChildItem $production -Recurse -File | Sort-Object FullName | ForEach-Object { "$($_.FullName):$((Get-FileHash $_.FullName).Hash)" }) -join "`n")
}
$before = Profile-Fingerprint
$p = Start-Process $exe -PassThru
try {
    $ping = $null
    $deadline = (Get-Date).AddSeconds(30)
    do {
        Start-Sleep -Milliseconds 300
        try { $ping = Invoke-RestMethod 'http://127.0.0.1:9615/ping' -Headers @{'X-SwiftGet'='1'} -TimeoutSec 2 } catch { }
        if ($p.HasExited) { throw "Preview startup failed: $($p.ExitCode)" }
    } while (-not $ping -and (Get-Date) -lt $deadline)
    if ($ping.app -ne 'KeRoDownload') { throw 'Preview local API failed' }
    if ((Profile-Fingerprint) -ne $before) { throw 'Production data changed during preview smoke test' }
    "Native render: PASS`nPreview API on 9615: PASS`nProduction profile unchanged: PASS`nHost: Windows Server 2022 (not live Windows 10/11)`nSample screenshot uses deterministic QA data, not a live download." | Set-Content "$diagnostics/SMOKE-TEST.txt"
} finally { if (-not $p.HasExited) { Stop-Process -Id $p.Id -Force } }
