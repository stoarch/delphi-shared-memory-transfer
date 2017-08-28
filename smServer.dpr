program smServer;

uses
  Forms,
  smHub2_TLB,
  form_sharedMemoryServer in 'forms\form_sharedMemoryServer.pas' {SharedMemoryServerForm},
  tool_fileTransfer in 'tools\tool_fileTransfer.pas',
  tool_events in 'tools\tool_events.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSharedMemoryServerForm, SharedMemoryServerForm);
  Application.Run;
end.
