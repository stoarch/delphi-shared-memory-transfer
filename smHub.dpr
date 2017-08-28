library smHub;

uses
  ComServ,
  smHub_TLB in 'smHub_TLB.pas',
  co_sharedMemoryHub in 'coclasses\co_sharedMemoryHub.pas' {ISharedMemoryHub: CoClass};

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;



{$R *.TLB}

{$R *.RES}

begin
end.
