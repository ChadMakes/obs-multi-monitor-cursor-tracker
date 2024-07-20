#define MyAppName "OBS Cursor Tracker"
#define MyAppVersion "1.0"
#define MyAppPublisher "ChadMakes aka Chad Miller"
#define MyAppURL "https://github.com/ChadMakes"
#define MyAppExeName "obs-cursor-tracker.py"
#define PythonInstallerURL "https://www.python.org/ftp/python/3.9.5/python-3.9.5-amd64.exe"
#define PythonInstallerFileName "python-3.9.5-amd64.exe"

[Setup]
AppId={{8A9D66F3-4C4E-4B83-9FFC-0A8DF71184CF}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={commonpf}\obs-studio\data\obs-plugins\frontend-tools\scripts\cursor-tracker
DisableProgramGroupPage=yes
LicenseFile=LICENSE.txt
PrivilegesRequired=admin
OutputDir=.
OutputBaseFilename=OBS Multi-Monitor Cursor Tracker Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
SetupIconFile=installer_icon.ico

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
Source: "obs-cursor-tracker.py"; DestDir: "{app}"; Flags: ignoreversion
Source: "README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "installer_icon.ico"; Flags: dontcopy

[Code]
var
  DownloadPage: TDownloadWizardPage;
  OBSInstallPath: string;
  ViewInstructionsCheckbox: TNewCheckBox;
  LaunchOBSCheckbox: TNewCheckBox;

function IsPythonInstalled: Boolean;
var
  PythonPath: String;
begin
  Result := RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SOFTWARE\Python\PythonCore\3.9\InstallPath',
    '', PythonPath);
end;

function InitializeSetup(): Boolean;
begin
  Result := True;
  
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SOFTWARE\OBS Studio',
    '', OBSInstallPath) then
  begin
    if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
      'SOFTWARE\WOW6432Node\OBS Studio',
      '', OBSInstallPath) then
    begin
      OBSInstallPath := ExpandConstant('{commonpf}\obs-studio');
      if not DirExists(OBSInstallPath) then
      begin
        if MsgBox('OBS Studio installation not found in the default location. ' +
                  'Do you want to continue anyway?' + #13#10 +
                  'You may need to manually copy the script to your OBS scripts folder later.',
                  mbConfirmation, MB_YESNO) = IDNO then
        begin
          Result := False;
        end;
      end;
    end;
  end;
end;

procedure InitializeWizard;
begin
  DownloadPage := CreateDownloadPage(SetupMessage(msgWizardPreparing), SetupMessage(msgPreparingDesc), nil);
  
  if OBSInstallPath <> '' then
    WizardForm.DirEdit.Text := OBSInstallPath + '\data\obs-plugins\frontend-tools\scripts\cursor-tracker'
  else
    WizardForm.DirEdit.Text := ExpandConstant('{commonpf}\obs-studio\data\obs-plugins\frontend-tools\scripts\cursor-tracker');

  ViewInstructionsCheckbox := TNewCheckBox.Create(WizardForm);
  ViewInstructionsCheckbox.Top := WizardForm.RunList.Top + WizardForm.RunList.Height + ScaleY(8);
  ViewInstructionsCheckbox.Left := WizardForm.RunList.Left;
  ViewInstructionsCheckbox.Width := WizardForm.RunList.Width;
  ViewInstructionsCheckbox.Height := ScaleY(17);
  ViewInstructionsCheckbox.Caption := 'View setup instructions';
  ViewInstructionsCheckbox.Parent := WizardForm.FinishedPage;

  LaunchOBSCheckbox := TNewCheckBox.Create(WizardForm);
  LaunchOBSCheckbox.Top := ViewInstructionsCheckbox.Top + ViewInstructionsCheckbox.Height + ScaleY(8);
  LaunchOBSCheckbox.Left := WizardForm.RunList.Left;
  LaunchOBSCheckbox.Width := WizardForm.RunList.Width;
  LaunchOBSCheckbox.Height := ScaleY(17);
  LaunchOBSCheckbox.Caption := 'Launch OBS Studio';
  LaunchOBSCheckbox.Parent := WizardForm.FinishedPage;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpReady then begin
    if not IsPythonInstalled then begin
      DownloadPage.Clear;
      DownloadPage.Add('{#PythonInstallerURL}', '{#PythonInstallerFileName}', '');
      DownloadPage.Show;
      try
        try
          DownloadPage.Download;
          Result := True;
        except
          if DownloadPage.AbortedByUser then
            Log('Aborted by user.')
          else
            SuppressibleMsgBox(AddPeriod(GetExceptionMessage), mbCriticalError, MB_OK, IDOK);
          Result := False;
        end;
      finally
        DownloadPage.Hide;
      end;
    end else
      Result := True;
  end else
    Result := True;
end;

function UpdateReadyMemo(Space, NewLine, MemoUserInfoInfo, MemoDirInfo, MemoTypeInfo,
  MemoComponentsInfo, MemoGroupInfo, MemoTasksInfo: String): String;
begin
  Result := MemoDirInfo + NewLine + NewLine +
    'The script will be installed in the OBS Studio frontend-tools scripts folder.' + NewLine + NewLine;
  if not IsPythonInstalled then
    Result := Result + 'Python 3.9 will be downloaded and installed.' + NewLine + NewLine;
  Result := Result + 'Required Python libraries will be installed.' + NewLine;
end;

procedure InstallPyWin32;
var
  ResultCode: Integer;
begin
  WizardForm.StatusLabel.Caption := 'Installing pywin32...';
  WizardForm.ProgressGauge.Style := npbstMarquee;
  try
    // Upgrade pip first
    if not Exec(ExpandConstant('{cmd}'), '/c python -m pip install --upgrade pip', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      Log('Failed to upgrade pip. Error code: ' + IntToStr(ResultCode));
      RaiseException('Failed to upgrade pip');
    end;
    
    // Install pywin32
    if not Exec(ExpandConstant('{cmd}'), '/c python -m pip install pywin32', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      Log('Failed to install pywin32. Error code: ' + IntToStr(ResultCode));
      RaiseException('Failed to install pywin32');
    end;
    
    // Verify installation
    if not Exec(ExpandConstant('{cmd}'), '/c python -c "import win32api"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
    begin
      Log('Failed to verify win32api installation. Error code: ' + IntToStr(ResultCode));
      RaiseException('Failed to verify win32api installation');
    end;
    
    Log('pywin32 installed and verified successfully');
  finally
    WizardForm.ProgressGauge.Style := npbstNormal;
  end;
end;

[Run]
Filename: "{tmp}\{#PythonInstallerFileName}"; Parameters: "/quiet InstallAllUsers=1 PrependPath=1"; Check: not IsPythonInstalled; Flags: waituntilterminated

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    Log('Starting pywin32 installation');
    InstallPyWin32;
    Log('Finished pywin32 installation');
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = wpFinished then
  begin
    WizardForm.RunList.Visible := False;
  end;
end;

procedure ShowInstructions;
begin
  MsgBox('To use the OBS Multi-Monitor Cursor Tracker:' + #13#10 +
         '1. Open OBS Studio' + #13#10 +
         '2. Go to Tools -> Scripts' + #13#10 +
         '3. Click the Python Settings tab' + #13#10 +
         '4. Click Browse' + #13#10 +
         '5. Navigate to C:\Program Files\Python39' + #13#10 +
         '6. Click "Select Folder"' + #13#10 +
         '7. Click on the Scripts tab' + #13#10 +
         '8. Click the "+" button to add a script' + #13#10 +
         '9. Navigate to:' + #13#10 +
         '   ' + WizardForm.DirEdit.Text + #13#10 +
         '10. Select "obs-cursor-tracker.py"' + #13#10 +
         '11. The script is now active!' + #13#10 + #13#10 +
         'For more information, please read the README.md file in the installation directory.',
         mbInformation, MB_OK);
end;

function GetOBSPath: string;
var
  RegPath: string;
begin
  // Check if OBS path is in registry
  if RegQueryStringValue(HKLM64, 'SOFTWARE\OBS Studio', '', RegPath) then
  begin
    Result := RegPath + '\bin\64bit\obs64.exe';
    if FileExists(Result) then
      Exit;
  end;

  // Check common installation paths
  Result := ExpandConstant('{pf}\obs-studio\bin\64bit\obs64.exe');
  if FileExists(Result) then
    Exit;
  
  Result := ExpandConstant('{pf32}\obs-studio\bin\64bit\obs64.exe');
  if FileExists(Result) then
    Exit;
  
  // If not found, return empty string
  Result := '';
end;

procedure LaunchOBS;
var
  ErrorCode: Integer;
  OBSPath: string;
begin
  OBSPath := GetOBSPath;
  if OBSPath <> '' then
  begin
    if not ShellExec('', OBSPath, '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode) then
    begin
      MsgBox('Error launching OBS Studio. Please start it manually.' + #13#10 +
             'Path: ' + OBSPath, mbError, MB_OK);
    end;
  end
  else
  begin
    MsgBox('OBS Studio executable not found. Please start OBS Studio manually.', mbError, MB_OK);
  end;
end;

procedure DeinitializeSetup();
begin
  if LaunchOBSCheckbox.Checked then
    LaunchOBS;
  
  if ViewInstructionsCheckbox.Checked then
    ShowInstructions;
end;