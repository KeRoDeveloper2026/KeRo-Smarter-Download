$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class KeroUiV2Capture {
 [StructLayout(LayoutKind.Sequential)] public struct RECT {public int L,T,R,B;}
 [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr hwnd,out RECT rect);
 [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
 [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd,IntPtr after,int x,int y,int w,int h,uint flags);
 [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd,int cmd);
 [DllImport("user32.dll")] public static extern int GetSystemMetrics(int index);
}
'@
$exe=Join-Path $PWD 'trial-stage/KeRoDownloadPreview.exe'
$out=Join-Path $PWD 'dist-trial/UI-previews'
New-Item -ItemType Directory -Force $out | Out-Null
$results=@()
# Disposable CI desktop only: keep unrelated host windows out of cutout corners.
(New-Object -ComObject Shell.Application).MinimizeAll()
foreach($state in @('downloading','paused','completed','failed','english')){
 $arguments=@('--design-preview-showcase',('--preview-state='+$(if($state -eq 'english'){'downloading'}else{$state})))
 if($state -eq 'english'){$arguments+='--preview-english'}
 $p=Start-Process $exe -ArgumentList $arguments -PassThru
 try{
  $deadline=(Get-Date).AddSeconds(35)
  $rect=New-Object KeroUiV2Capture+RECT
  do{
   Start-Sleep -Milliseconds 300;$p.Refresh()
   if($p.HasExited){throw "UI sample exited $($p.ExitCode)"}
   if($p.MainWindowHandle -ne 0){[KeroUiV2Capture]::GetWindowRect($p.MainWindowHandle,[ref]$rect)|Out-Null}
  }while((($rect.R-$rect.L) -lt 800 -or ($rect.B-$rect.T) -lt 500 -or $p.MainWindowTitle -notlike '*DESIGN SAMPLE*') -and (Get-Date) -lt $deadline)
  if(($rect.R-$rect.L) -lt 800 -or ($rect.B-$rect.T) -lt 500){throw 'No full native progress window'}
  [KeroUiV2Capture]::ShowWindow($p.MainWindowHandle,9)|Out-Null
  [KeroUiV2Capture]::SetWindowPos($p.MainWindowHandle,[IntPtr]::Zero,0,0,0,0,0x0041)|Out-Null
  [KeroUiV2Capture]::SetForegroundWindow($p.MainWindowHandle)|Out-Null
  Start-Sleep -Seconds 2
  if(-not[KeroUiV2Capture]::GetWindowRect($p.MainWindowHandle,[ref]$rect)){throw 'No UI bounds'}
  $screenW=[KeroUiV2Capture]::GetSystemMetrics(0);$screenH=[KeroUiV2Capture]::GetSystemMetrics(1)
  if($rect.L -lt 0 -or $rect.T -lt 0 -or $rect.R -gt $screenW -or $rect.B -gt $screenH){throw "Capture would clip: $($rect.R)x$($rect.B) screen $screenW x $screenH"}
  $bitmap=New-Object Drawing.Bitmap(($rect.R-$rect.L),($rect.B-$rect.T))
  $g=[Drawing.Graphics]::FromImage($bitmap)
  try{$g.CopyFromScreen($rect.L,$rect.T,0,0,$bitmap.Size);$bitmap.Save((Join-Path $out "QA-SAMPLE-$state.png"),[Drawing.Imaging.ImageFormat]::Png)}finally{$g.Dispose();$bitmap.Dispose()}
  $p.Refresh()
  $results+=@{state=$state;working_set_bytes=$p.WorkingSet64;width=$rect.R-$rect.L;height=$rect.B-$rect.T;screen_width=$screenW;screen_height=$screenH;source='Actual Slint window with explicitly labeled deterministic QA sample data, not a live download'}
 }finally{if(-not$p.HasExited){Stop-Process -Id $p.Id -Force}}
}
$results|ConvertTo-Json|Set-Content dist-trial/verification/UI-SAMPLE-RENDERS.json
'Native window renders use QA SAMPLE values. For appearance inspection only. Interactive browser loading, actual Windows 10/11, 100/125/150/200% DPI, baseline RAM comparisons, live download pause/resume/cancel and completion actions still require desktop verification.' | Set-Content "$out/READ-ME.txt"
