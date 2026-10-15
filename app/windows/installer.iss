; Saguki Windows installer (Inno Setup 6). Built by .github/workflows/windows.yml:
;   flutter build windows --release && iscc /DAppVersion=0.1.0.N windows\installer.iss
; Per-user install (no admin prompt), Start menu shortcut, uninstaller. Upgrades in place.

#ifndef AppVersion
  #define AppVersion "0.1.0"
#endif

[Setup]
AppId={{6C1F3A52-8E4B-4F0A-9B7D-5A2E1C9D3F47}
AppName=Saguki
AppVersion={#AppVersion}
AppPublisher=Saguny
DefaultDirName={localappdata}\Programs\Saguki
PrivilegesRequired=lowest
DisableProgramGroupPage=yes
DisableDirPage=yes
OutputDir=..\build\installer
OutputBaseFilename=saguki-setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\saguki.exe
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{userprograms}\Saguki"; Filename: "{app}\saguki.exe"
Name: "{userdesktop}\Saguki"; Filename: "{app}\saguki.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\saguki.exe"; Description: "Open Saguki"; Flags: nowait postinstall skipifsilent
