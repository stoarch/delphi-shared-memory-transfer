{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O-,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
unit co_sharedMemoryHub;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows, ActiveX, Classes, ComObj, smHub_TLB, StdVcl;

type
  TISharedMemoryHub = class(TTypedComObject, IISharedMemoryHub)
  protected
    function GetSharedMemoryName(out value: WideString): HResult; stdcall;
    {Declare IISharedMemoryHub methods here}
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
  smHubInstance : TISharedMemoryHub;

type
  TSingleInstanceFactory = class(TTypedComObjectFactory)
  public
    function CreateComObject(const Controller: IUnknown ): TComObject;override;
  end;


destructor TISharedMemoryHub.Destroy;
begin
  smHubInstance := nil;
  inherited;
end;

function TISharedMemoryHub.GetSharedMemoryName(
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
    sharedMemoryName := 'SharedMemoryHub.' + RandomString(MEMORY_NAME_LEN) + '.1';
    smHubInstance := TISharedMemoryHub.CreateFromFactory(Self, Controller);
  end;

  result := smHubInstance;
end;

initialization
  smHubInstance := nil;

  TSingleInstanceFactory.Create(ComServer, TISharedMemoryHub, Class_ISharedMemoryHub,
    ciMultiInstance, tmApartment);
end.
