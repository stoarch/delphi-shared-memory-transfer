unit form_sharedMemoryServer;
{$define DEBUG_CHUNKS}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, smHub2_TLB, ComObj, ComCtrls, StdCtrls, tool_events;

type
  TProgressProc = procedure (sender : TObject; position : integer ) of object;
  TLogProc = procedure (sender : TObject; message : string ) of object;

  TFileListener = class(TThread)
    private
      FOnLog : TLogProc;
      FOnProgress : TProgressProc;
      FMessage : string;
      FPosition : integer;

      procedure InternalLog;
      procedure InternalShowPosition;

      procedure Log(message: string);
      procedure ShowProgress(position : Integer);
    protected
      constructor Create(CreateSuspended: boolean);reintroduce;
      procedure Execute();override;

      property OnLog : TLogProc read FOnLog write FOnLog;
      property OnProgress : TProgressProc read FOnProgress write FOnProgress;
  end;

type
  TSharedMemoryServerForm = class(TForm)
    Label1: TLabel;
    progressBarFileReceive: TProgressBar;
    Label2: TLabel;
    memoLog: TMemo;
    statusBar: TStatusBar;
  private
    { Private declarations }
    FListener : TFileListener;
    procedure HandleProgress(sender: TObject; position: integer);
    procedure HandleLog(sender: TObject; message: string);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent);override;
    destructor Destroy;override;
  end;

var
  SharedMemoryServerForm: TSharedMemoryServerForm;

implementation

{$R *.dfm}
uses
  tool_fileTransfer;


var
  hSharedMemory : THandle;
  hMutex : THandle;

  listener : TFileListener;

  smHub : ISharedMemoryHub2;
  sharedMemoryName : String;

  mutexName : String;

  writeCS : TRTLCriticalSection;

procedure CloseHandles;forward;

procedure HaltWithError();
begin
  RaiseLastOSError();
  halt;
end;

procedure CleanHalt();
begin
  CloseHandles();
  HaltWithError();
end;


procedure InitHandles();
begin
  hSharedMemory := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SHARED_MEMORY_SIZE, PAnsiChar(sharedMemoryName) );
  if hSharedMemory = 0 then
  begin
    RaiseLastOSError();
    Halt;
  end;

  hMutex := CreateMutex(nil, false, PAnsiChar(mutexName) );
  if hMutex = 0 then
  begin
    CloseHandle( hSharedMemory );
    RaiseLastOSError();
    Halt;
  end;

  if CreateEvents() = ERROR_CREATION then
  begin
    CleanHalt();
  end;
end;

procedure CloseHandles();
begin
  CloseHandle( hSharedMemory );
  CloseHandle( hMutex );
  CloseEvents();
end;

procedure ReceiveSharedMemoryName();
  var
    smName : WideString;
begin
  smHub := CreateComObject(CLASS_SharedMemoryHub2) as ISharedMemoryHub2;
  smHub.GetSharedMemoryName(smName);//todo: check error state

  sharedMemoryName := smName;

  SetEventNames( sharedMemoryName );


  mutexName := sharedMemoryName + 'Mutex';
end;

{ TSharedMemoryServerForm }

constructor TSharedMemoryServerForm.Create(AOwner: TComponent);
  const
    SUSPENDED = true;
begin
  inherited;

  ReceiveSharedMemoryName();
  InitHandles();

  caption := 'Shared memory server (' + sharedMemoryName + ')';

  FListener := TFileListener.Create(SUSPENDED);
  FListener.OnProgress := HandleProgress;
  FListener.OnLog := HandleLog;
  FListener.Resume();
end;

destructor TSharedMemoryServerForm.Destroy;
begin
  FListener.Terminate();
  FListener.WaitFor();
  FListener.Free();

  inherited;
end;

procedure TSharedMemoryServerForm.HandleProgress(sender : TObject; position : integer );
begin
  progressBarFileReceive.Position := position;
  Application.ProcessMessages();
end;

procedure TSharedMemoryServerForm.HandleLog( sender : TObject; message : string );
begin
  memoLog.Lines.Append(message);
end;

{ TFileListener }

constructor TFileListener.Create(CreateSuspended: boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure TFileListener.Execute;
  const
    WAIT_FOR_EVENT_TIMEOUT = 1000;
  type
    TFileReceiveState = (frsUnknown, frsNewFileStarted, frsFileReceived, frsErrored);

  var
    data : pointer;
    size : Integer;
    outFile : TFileStream;
    position : integer;

    fileState : TFileReceiveState;
    fileHeader : TFileInfo;
    fileChunk : TFileChunk;

    procedure CleanFile();
    begin
      if( assigned(outFile))then
      begin
        FreeAndNil(outFile);
      end;
    end;

    procedure CheckError();
    begin
      if( WaitForSingleObject( hErrorEvent, WAIT_FOR_EVENT_TIMEOUT ) = WAIT_OBJECT_0 )then
      begin
        ResetEvent(hErrorEvent);
        Log('Client error occured');
        fileState := frsUnknown;
      end
    end;

    procedure CheckEndOfFile();
    begin
      if( WaitForSingleObject(hEndFileEvent, WAIT_FOR_EVENT_TIMEOUT) = WAIT_OBJECT_0)then
      begin
        ResetEvent( hEndFileEvent );
        fileState := frsFileReceived;
      end
    end;

    procedure CheckNextFileChunk();
{$IFDEF DEBUG_CHUNKS}
      var
        debugStr : string;
{$ENDIF}
      var
        bytesWritten : integer;
        f : file;
        fh : Integer;
    begin
      if( WaitForSingleObject(hNextChunkEvent, WAIT_FOR_EVENT_TIMEOUT) = WAIT_OBJECT_0 )then
      begin
        EnterCriticalSection(writeCS);
        try
          ResetEvent( hNextChunkEvent );
          ShowProgress( position );
          inc( position );

          Log(Format('Chunk %0:d is received', [position] ));

          data := MapViewOfFile(hSharedMemory, FILE_MAP_READ, 0, 0, SHARED_MEMORY_SIZE);

          if( data = nil )then
          begin
            Log('Error: Unable map view of file');
            exit;
          end;

          fileChunk.size := Integer(data^);//first four bytes of string is size

          SetLength(fileChunk.data, fileChunk.size);

          Log(Format('Chunk size is %0:d', [fileChunk.size]));

          CopyMemory(PChar(fileChunk.data), Pointer(Integer(data) + 4), fileChunk.size);

  {$ifdef DEBUG_CHUNKS}
          SetLength(debugStr, 100);
          CopyMemory(PChar(debugStr), Pointer(fileChunk.data), 100 );
          Log('Chunk data: ' + debugStr + ' ...' );
  {$endif}

          //Windows file routines for speed//
          bytesWritten := outFile.Write( fileChunk.data[0], fileChunk.size);
          if( bytesWritten <> fileChunk.size)then
          begin
            Log(SysErrorMessage(GetLastError()));
            Log(Format('Unable to write %0:d bytes (%1:d written)', [bytesWritten, fileChunk.size]));
            fileState := frsErrored;
          end;

          UnmapViewOfFile(data);

          SetEvent(hDataReceivedEvent);
        finally
          LeaveCriticalSection(writeCS);
        end;
      end;
    end;

    procedure CheckNewFileStart();
      var
        fh : integer;
    begin
      if( WaitForSingleObject(hNewFileEvent, WAIT_FOR_EVENT_TIMEOUT) = WAIT_OBJECT_0 )then
      begin
        Log('New file received');
        ResetEvent(hNewFileEvent);
        fileState := frsNewFileStarted;
        position := 0;

        data := MapViewOfFile(hSharedMemory, FILE_MAP_READ, 0, 0, FILE_NAME_SIZE);

        if( data = nil )then
        begin
          fileState := frsErrored;
          Log('Unable to map view of file to receive file name');
          exit;
        end;

        fileHeader.fileSize := Integer(data^);//first four bytes of string is size
        fileHeader.nameSize := Integer(Pointer(Integer(data)+4)^);

        SetLength(fileHeader.fileName, fileHeader.nameSize);
        CopyMemory(PChar(fileHeader.fileName), Pointer(Integer(data)+8), fileHeader.nameSize);

        UnmapViewOfFile(data);

        SetEvent(hDataReceivedEvent);

        Log('File name is: ' + fileHeader.fileName );
        Log('File size is: ' + IntToStr(fileHeader.fileSize));

        CleanFile();
        outFile := TFileStream.Create(fileHeader.fileName, fmCreate or fmShareDenyWrite );
      end;
    end;

begin
  fileState := frsUnknown;
  outFile := nil;
  try
    try
      while not terminated do
      begin
        CheckError();

        case fileState of
          frsUnknown:
            begin
              CheckNewFileStart();
            end;
          frsNewFileStarted:
            begin
              CheckNextFileChunk();
              CheckEndOfFile();
            end;
          frsFileReceived:
            begin
              Log('File received');
              CleanFile();
              fileState := frsUnknown;
            end;
        end;
      end;
    finally
      CleanFile();
    end;
  except
    on e:Exception do
    begin
      Log('Error: ' + e.Message);
    end;
  end;
end;

procedure TFileListener.InternalLog;
begin
  if Assigned(FOnLog) then
    FOnLog(self, FMessage);
end;

procedure TFileListener.InternalShowPosition;
begin
  if assigned(FOnProgress) then
    FOnProgress( self, Fposition );
end;

procedure TFileListener.Log(message : string );
begin
  FMessage := message;
  Synchronize( InternalLog );
end;

procedure TFileListener.ShowProgress(position: Integer);
begin
  FPosition := position;
  Synchronize( InternalShowPosition );
end;

initialization
  InitializeCriticalSection(writeCS);
finalization
  DeleteCriticalSection(writeCS);
  CloseHandles();
end.
