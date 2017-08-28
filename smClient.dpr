program smClient;

uses
  Forms,
  IniFiles,
  SysUtils,
  smHub2_TLB,
  form_sharedMemoryClient in 'forms\form_sharedMemoryClient.pas' {SharedMemoryClientForm},
  tool_fileTransfer in 'tools\tool_fileTransfer.pas',
  tool_events in 'tools\tool_events.pas';

{$R *.res}


  procedure ReadFileName();
    var
      ini : TMemIniFile;
  begin
    ini := TMemIniFile.Create('smClient.ini');
    try
      g_fileName := ini.ReadString('files','file1','');
    finally
      FreeAndNil( ini );
    end;
  end;
begin
  Application.Initialize;

  ReadFileName();

  Application.CreateForm(TSharedMemoryClientForm, SharedMemoryClientForm);
  Application.Run;
end.
