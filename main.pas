unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus,
  Vcl.StdCtrls, TlHelp32, ShellApi, ShDocVw, ActiveX, ShlObj, Vcl.ComCtrls, IniFiles;

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
    btnListExplorers: TButton;
    lblCredits: TLabel;
    HotKey1: THotKey;
    btnSetHotkey: TButton;
    Settings1: TMenuItem;
    procedure Exit1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnKillClick(Sender: TObject);
    procedure Restart1Click(Sender: TObject);
    procedure tmrRestorerTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnListExplorersClick(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure btnSetHotkeyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HotKey1Change(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
  private
    { Private declarations }
    HotKeyID: Integer;
    HotKeyIDFunction: Integer;
    HotKeyStr: String;
    isPrompt: Boolean;
    procedure WMHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
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

procedure TForm1.btnSetHotkeyClick(Sender: TObject);
var
  key: WORD;
  modifier: Integer;
  ini: TIniFile;
begin
  key := HotKey1.HotKey and not (scShift + scCtrl + scAlt); // HotKey1.HotKey and $000000FF;
  modifier := 0;
  if HotKey1.HotKey and scShift <> 0 then
    modifier := MOD_SHIFT;
  if HotKey1.HotKey and scAlt <> 0 then
    modifier := modifier + MOD_ALT;
  if HotKey1.HotKey and scCtrl <> 0 then
    modifier := modifier + MOD_CONTROL;

  // Re-register hotkey
  if GlobalFindAtom('REXHOTKEY') <> 0 then
  begin
    UnRegisterHotkey(Handle, GlobalFindAtom('REXHOTKEY'));
    GlobalDeleteAtom(GlobalFindAtom('REXHOTKEY'));
  end;

  if not RegisterHotKey(Handle, GlobalAddAtom('REXHOTKEY'), modifier, key) then
  begin
    MessageDlg(ShortCutToText(HotKey1.HotKey) + ' failed to register, try another hotkey.', mtError, [mbOK], 0);
  end
  else
  begin
    if Sender is TButton then
      MessageDlg(ShortCutToText(HotKey1.HotKey) + ' successfully registered.', mtInformation, [mbOK], 0);
    ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
    try
      ini.WriteString('Settings', 'Hotkey', ShortCutToText(HotKey1.HotKey));
      HotKeyStr := ShortCutToText(HotKey1.HotKey);
    finally
      ini.Free;
    end;
  end;

end;

procedure TForm1.btnStartClick(Sender: TObject);
var
  I: Integer;
begin
  ShellExecute(0, PCHAR('OPEN') ,PChar('C:\Windows\explorer.exe'), nil, nil, SW_NORMAL);
//  WinExec('explorer', SW_NORMAL);
  // Let's open previously listed explorer paths
  for I := 0 to ListBox1.Count - 1 do
  begin
    if DirectoryExists(ListBox1.Items[I]) then
      ShellExecute(0, 'OPEN',PChar(ListBox1.Items[I]),nil,nil,SW_SHOWNORMAL );
  end;
end;

procedure TForm1.btnListExplorersClick(Sender: TObject);
const
  IID_IServiceProvider: TGUID = '{6D5140C1-7436-11CE-8034-00AA006009FA}';
  SID_STopLevelBrowser: TGUID = '{4C96BE40-915C-11CF-99D3-00AA004AE837}';
var
  ShellWindows: IShellWindows;
  I: Integer;
  ShellBrowser: IShellBrowser;
  WndIface: IDispatch;
  WebBrowserApp: IWebBrowserApp;
  ServiceProvider: IServiceProvider;
  ItemIDList: PItemIDList;
  bar: HWND;
  ShellView: IShellView;
  FolderView: IFolderView;
  PersistFolder2: IPersistFolder2;
  ShellFolder: IShellFolder;
  focus: Integer;
  ret: _STRRET;
  folderPath: PChar;
  AMalloc: IMalloc;
begin
  ListBox1.Items.BeginUpdate;
  ListBox1.Items.Clear;
  if Succeeded(CoCreateInstance(CLASS_ShellWindows, nil, CLSCTX_LOCAL_SERVER,
    IID_IShellWindows, ShellWindows)) then
  begin
    for I := 0 to ShellWindows.Count - 1 do
    begin
      if VarType(ShellWindows.Item(I)) = varDispatch then
      begin
      WndIface := ShellWindows.Item(VarAsType(I, VT_I4));

        try
        if Succeeded(WndIface.QueryInterface(IID_IWebBrowserApp, WebBrowserApp)) then
        begin
          begin
            if Succeeded(WebBrowserApp.QueryInterface(IID_IServiceProvider,
              ServiceProvider)) then
            begin
              if Succeeded(ServiceProvider.QueryService(SID_STopLevelBrowser,
                IID_IShellBrowser, ShellBrowser)) then
              begin
                if Succeeded(ShellBrowser.QueryActiveShellView(ShellView)) then
                begin
                  if Succeeded(ShellView.QueryInterface(IID_IFolderView, FolderView)) then
                  begin
                    FolderView.GetFocusedItem(focus);
                    FolderView.Item(focus,ItemIDList);
                    if Succeeded(FolderView.GetFolder(IID_IPersistFolder2, PersistFolder2)) then
                    begin
                      if succeeded(PersistFolder2.GetCurFolder(ItemIDList)) then
                      //if Succeeded(PersistFolder2.QueryInterface(IID_IShellFolder, ShellFolder)) then
                      begin
                        //ShellFolder.GetDisplayNameOf(ItemIDList, SHGDN_FORPARSING, ret);
                        //ListBox1.Items.Add(ret.pOleStr);
                        folderPath := StrAlloc(MAX_PATH);
                        if SHGetPathFromIDList(ItemIDList, folderPath) then
                          ListBox1.Items.Add(folderPath);
                        SHGetMalloc(AMalloc);
                        AMalloc.Free(ItemIDList);
                        StrDispose(folderPath);
                      end;
                    end;
                  end;
                end;

              end;

            end;
          end;
        end;
        except
        end;
      end;

    end;
  end;
  ListBox1.Items.EndUpdate;
end;

procedure TForm1.btnKillClick(Sender: TObject);
begin
  btnListExplorersClick(Sender);
  WinExec(PAnsiChar('taskkill /f /im explorer.exe'), SW_HIDE);
  WinExec(PAnsiChar('taskkill /f /im prevhost.exe'), SW_HIDE);
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

procedure TForm1.FormCreate(Sender: TObject);
var
  ini: TIniFile;
begin
  isPrompt := False;
  ini := TIniFile.Create(ExtractFilePath(ParamStr(0))+'config.ini');
  try
    HotKeyStr := ini.ReadString('Settings', 'Hotkey', '');
    HotKey1.HotKey := TextToShortCut(HotKeyStr);
    btnSetHotkeyClick(Sender);
  finally
    ini.Free;
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.Handle, SW_HIDE)
end;

procedure TForm1.HotKey1Change(Sender: TObject);
begin
  if HotKey1.HotKey = TextToShortCut('') then
    btnSetHotkey.Caption := 'Save'
  else
    btnSetHotkey.Caption := 'Set Hotkey';
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
begin
  if (ListBox1.Items.Count > 0) and (ListBox1.ItemIndex >=0) and (ListBox1.ItemIndex < ListBox1.Items.Count) then
  begin
    if DirectoryExists(ListBox1.Items[ListBox1.ItemIndex]) then
      ShellExecute(0, 'OPEN',PChar(ListBox1.Items[ListBox1.ItemIndex]),nil,nil,SW_SHOWNORMAL );
  end;

end;

procedure TForm1.Restart1Click(Sender: TObject);
begin
  btnListExplorersClick(Sender);
  btnKillClick(Sender);
  tmrRestorer.Enabled := True;
end;

procedure TForm1.Settings1Click(Sender: TObject);
begin
  Show;
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
  Visible := not Visible;
end;

procedure TForm1.WMHotKey(var Msg: TWMHotKey);
var
  fmsg: String;
  I: Integer;
begin
  if Msg.HotKey = GlobalFindAtom('REXHOTKEY') then
  begin
    if Visible and HotKey1.Focused then
    begin
      HotKey1.HotKey := TextToShortCut(HotKeyStr);
      Exit;
    end;

    if not isPrompt then
    begin
      isPrompt := True;
      fmsg := '';
      btnListExplorersClick(Self);
      if ListBox1.Items.Count > 0 then
      begin
        fmsg := 'There are directories currently opened by Explorer:'+#13#10#13#10;
        for I := 0 to ListBox1.Items.Count - 1 do
          fmsg := fmsg + ListBox1.Items[I]+#13#10;
        fmsg := fmsg+#13#10;
      end;

      if MessageDlg(fmsg+'Restart Explorer will restore them too.'#13#10'Restart Explorer.exe?', mtConfirmation, mbYesNo, 0) = mrYes then
      begin
        //ShowMessage('Restarting...');
        Restart1Click(Self);
      end;
      isPrompt := False;
    end;

  end;

end;

end.
