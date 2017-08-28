unit co_sharedMemoryHub2;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, smHub2_TLB, StdVcl;

type
  TSharedMemoryHub2 = class(TTypedComObject, ISharedMemoryHub2)
  protected
    function GetSharedMemoryName(out value: WideString): HResult; stdcall;
    {Declare ISharedMemoryHub2 methods here}
  public
    destructor Destroy();override;
  end;

implementation

uses ComServ;

function RandomString(len : integer): WideString;
  const
    LETTERS : WideString = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    function RandomLetter() : WideChar;
    begin
      result := LETTERS[Random(Length(LETTERS))]
    end;

  var
    i : integer;
begin
  result := '';
  for i := 1 to len do
  begin
    result := result + RandomLetter();
  end;
end;

const MEMORY_NAME_LEN = 10;

var
  sharedMemoryName : WideString;
  smHubInstance : TComObject;

type
  TSingleInstanceFactory = class(TTypedComObjectFactory)
  public
    function CreateComObject(const Controller: IUnknown ): TComObject;override;
  end;


destructor TSharedMemoryHub2.Destroy;
begin
  smHubInstance := nil;
  inherited;
end;

function TSharedMemoryHub2.GetSharedMemoryName(
  out value: WideString): HResult;
begin
  value := sharedMemoryName;

  result := S_OK;
end;


{ TSingleInstanceFactory }

function TSingleInstanceFactory.CreateComObject(
  const Controller: IUnknown): TComObject;
begin
  if( not assigned(smHubInstance))then
  begin
    Randomize();
    sharedMemoryName := 'SharedMemoryHub2.' + RandomString(MEMORY_NAME_LEN) + '.1';
    smHubInstance := TSharedMemoryHub2.CreateFromFactory(Self, Controller);
  end;

  result := smHubInstance;
end;

initialization
  smHubInstance := nil;

  TSingleInstanceFactory.Create(ComServer, TSharedMemoryHub2, Class_SharedMemoryHub2,
    ciMultiInstance, tmApartment);
end.
