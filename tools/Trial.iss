#define AppName "KeRo Download Preview"
[Setup]
AppId={{BF2E3950-B941-4F46-AE17-7F90E4671D24}
AppName={#AppName}
AppVersion=1.1.4
AppPublisher=KeRo HaZem
DefaultDirName={localappdata}\Programs\KeRo Download Preview
DefaultGroupName={#AppName}
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=
UsePreviousAppDir=yes
DisableProgramGroupPage=yes
MinVersion=10.0
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
OutputDir=..\dist-trial
OutputBaseFilename=KeRo-Download-Preview-v1.1.4-UI-v2-Win10_11-x64-Setup
SetupIconFile=..\crates\app\icon.ico
UninstallDisplayIcon={app}\KeRoDownloadPreview.exe
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
CloseApplications=no
RestartApplications=no
[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"
[Files]
Source: "..\trial-stage\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\KeRoDownloadPreview.exe"
Name: "{group}\Chromium test extension"; Filename: "{app}\extension"
Name: "{group}\Firefox test extension"; Filename: "{app}\extension-firefox"
Name: "{group}\Uninstall {#AppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\KeRoDownloadPreview.exe"; Tasks: desktopicon
[Registry]
Root: HKCU; Subkey: "Software\Classes\kero-design-preview"; ValueType: string; ValueName: ""; ValueData: "URL:KeRo Download Preview"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\kero-design-preview"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\kero-design-preview\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\KeRoDownloadPreview.exe"" --from-browser"
[Run]
Filename: "{app}\KeRoDownloadPreview.exe"; Description: "Open KeRo Download Preview"; Flags: nowait postinstall skipifsilent
[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var Code: Integer;
begin
  Result := '';
  Exec(ExpandConstant('{cmd}'), '/C taskkill /F /IM KeRoDownloadPreview.exe >nul 2>&1', '', SW_HIDE, ewWaitUntilTerminated, Code);
end;
procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var Code: Integer;
begin
  if CurUninstallStep = usUninstall then
    Exec(ExpandConstant('{cmd}'), '/C taskkill /F /IM KeRoDownloadPreview.exe >nul 2>&1', '', SW_HIDE, ewWaitUntilTerminated, Code);
end;
