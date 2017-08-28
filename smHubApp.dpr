program smHubApp;

uses
  Forms, ComServ, Dialogs,
  form_sharedMemoryHub in 'forms\form_sharedMemoryHub.pas' {SharedMemoryHubForm},
  smHub2_TLB in 'smHub2_TLB.pas',
  co_sharedMemoryHub2 in 'coclasses\co_sharedMemoryHub2.pas' {SharedMemoryHub2: CoClass};

{$R *.TLB}

{$R *.res}

begin
  ComServer.UIInteractive := False;

  if( ComServer.StartMode = smRegServer )then
      ShowMessage('Registered');

  if( ComServer.StartMode = smUnregServer )then
      ShowMessage('Unregistered');

  Application.Initialize;
  Application.CreateForm(TSharedMemoryHubForm, SharedMemoryHubForm);
  Application.Run;
end.
