unit form_sharedMemoryHub;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComObj, smHub2_TLB;

type
  TSharedMemoryHubForm = class(TForm)
    SMName: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    smHub : ISharedMemoryHub2;
    procedure DisplayHubCaption;
  public
    { Public declarations }
    destructor Destroy();override;

  end;

var
  SharedMemoryHubForm: TSharedMemoryHubForm;

implementation

{$R *.dfm}

procedure TSharedMemoryHubForm.FormCreate(Sender: TObject);
begin
  smHub := CreateComObject(Class_SharedMemoryHub2) as ISharedMemoryHub2;
  DisplayHubCaption();
end;

procedure TSharedMemoryHubForm.DisplayHubCaption();
  var
    value : WideString;
begin
  if( smHub.GetSharedMemoryName(value) = S_OK)then
  begin
    SMName.Caption := value;
  end;
end;


procedure TSharedMemoryHubForm.FormDestroy(Sender: TObject);
begin
  smHub := nil;
end;

destructor TSharedMemoryHubForm.Destroy;
begin
  smHub := nil;
  inherited;
end;

end.
