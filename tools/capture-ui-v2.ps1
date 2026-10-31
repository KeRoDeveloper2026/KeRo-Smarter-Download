$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class KeroUiV2Capture {
 [StructLayout(LayoutKind.Sequential)] public struct RECT {public int L,T,R,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd,out RECT rect);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
}
'@
$exe=Join-Path $PWD 'trial-stage/KeRoDownloadPreview.exe'
$out=Join-Path $PWD 'dist-trial/UI-previews'
New-Item -ItemType Directory -Force $out | Out-Null
$results=@()
foreach($state in @('downloading','paused','completed','failed','english')){
 $arguments=@('--design-preview-showcase',('--preview-state='+$(if($state -eq 'english'){'downloading'}else{$state})))
 if($state -eq 'english'){$arguments+='--preview-english'}
 $p=Start-Process $exe -ArgumentList $arguments -PassThru
 try{
  $deadline=(Get-Date).AddSeconds(35)
  do{Start-Sleep -Milliseconds 200;$p.Refresh();if($p.HasExited){throw "UI sample exited $($p.ExitCode)"}}while($p.MainWindowHandle -eq 0 -and (Get-Date) -lt $deadline)
  if($p.MainWindowHandle -eq 0){throw 'No native UI window'}
  [KeroUiV2Capture]::SetForegroundWindow($p.MainWindowHandle)|Out-Null
  Start-Sleep -Seconds 2
  $rect=New-Object KeroUiV2Capture+RECT
  if(-not[KeroUiV2Capture]::GetWindowRect($p.MainWindowHandle,[ref]$rect)){throw 'No UI bounds'}
  $bitmap=New-Object Drawing.Bitmap(($rect.R-$rect.L),($rect.B-$rect.T))
  $g=[Drawing.Graphics]::FromImage($bitmap)
  try{$g.CopyFromScreen($rect.L,$rect.T,0,0,$bitmap.Size);$bitmap.Save((Join-Path $out "QA-SAMPLE-$state.png"),[Drawing.Imaging.ImageFormat]::Png)}finally{$g.Dispose();$bitmap.Dispose()}
  $p.Refresh()
  $results+=@{state=$state;working_set_bytes=$p.WorkingSet64;width=$rect.R-$rect.L;height=$rect.B-$rect.T;source='Actual Slint window with explicitly labeled deterministic QA sample data, not a live download'}
 }finally{if(-not$p.HasExited){Stop-Process -Id $p.Id -Force}}
}
$results|ConvertTo-Json|Set-Content dist-trial/verification/UI-SAMPLE-RENDERS.json
'Native window renders use QA SAMPLE values. For appearance inspection only. Interactive browser loading, actual Windows 10/11, 100/125/150/200% DPI, baseline RAM comparisons, live download pause/resume/cancel and completion actions still require desktop verification.' | Set-Content "$out/READ-ME.txt"
