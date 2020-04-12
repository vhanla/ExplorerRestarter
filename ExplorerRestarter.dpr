program ExplorerRestarter;

uses
  Vcl.Forms,
  Windows,
  SysUtils,
  main in 'main.pas' {Form1};

{$R *.res}

begin
  if CreateMutex(nil, True, '{D8122517-C912-44DD-A00F-7F6705EAE76A}') = 0 then
    RaiseLastOSError;
  if GetLastError = ERROR_ALREADY_EXISTS then
    Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  Application.ShowMainForm := False;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
