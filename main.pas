unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, TlHelp32, ShellApi;

type
  TForm1 = class(TForm)
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Restart1: TMenuItem;
    Label1: TLabel;
    Timer1: TTimer;
    btnStart: TButton;
    btnKill: TButton;
    tmrRestorer: TTimer;
    ListBox1: TListBox;
    procedure Exit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure Restart1Click(Sender: TObject);
    procedure tmrRestorerTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
function IsExplorerRunning: Boolean;
var
  SnapProcHandle: THandle;
  ProcEntry: TProcessEntry32;
  NextProc: Boolean;
begin
  Result := False;

  SnapProcHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  if SnapProcHandle = INVALID_HANDLE_VALUE then
    Exit;

  ProcEntry.dwSize := SizeOf(TProcessEntry32);
  NextProc := Process32First(SnapProcHandle, ProcEntry);
  while NextProc do begin
    if UpperCase(StrPas(ProcEntry.szExeFile)) = 'EXPLORER.EXE' then
    begin
      Result := True;
      Break;
    end;
    NextProc := Process32Next(SnapProcHandle, ProcEntry);
  end;
  CloseHandle(SnapProcHandle);
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  ShellExecute(0, PCHAR('OPEN') ,PChar('C:\Windows\explorer.exe'), nil, nil, SW_NORMAL);
//  WinExec('explorer', SW_NORMAL);
end;

procedure TForm1.btnKillClick(Sender: TObject);
begin
  WinExec(PAnsiChar('taskkill /f /im explorer.exe'), SW_HIDE);
end;

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Hide;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE)
end;

procedure TForm1.Restart1Click(Sender: TObject);
begin
  btnKillClick(Sender);
  tmrRestorer.Enabled := True;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if IsExplorerRunning then
    Label1.Caption := 'Explorer is running'
  else
    Label1.Caption := 'Explorer is not running';
end;

procedure TForm1.tmrRestorerTimer(Sender: TObject);
begin
  if IsExplorerRunning then
    tmrRestorer.Enabled := False
  else
    btnStartClick(Sender);
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  Show;
end;

end.
