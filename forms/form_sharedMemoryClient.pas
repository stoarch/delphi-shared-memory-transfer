unit form_sharedMemoryClient;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComObj, smHub2_TLB, StdCtrls, ComCtrls, tool_events;

type
  TSharedMemoryClientForm = class(TForm)
    TestLabel: TLabel;
    buttonSelectFile: TButton;
    dlgOpen: TOpenDialog;
    progressBarFileTransfer: TProgressBar;
    Label1: TLabel;
    memoLog: TMemo;
    Label2: TLabel;
    statusBar2: TStatusBar;
    buttonTransferFile: TButton;
    procedure buttonSelectFileClick(Sender: TObject);
    procedure buttonTransferFileClick(Sender: TObject);
  private
    { Private declarations }
    FFileName : string;
    procedure TransferFile;
    procedure Log(message: string);
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
  end;

var
  SharedMemoryClientForm: TSharedMemoryClientForm;
  g_fileName : string;

implementation

uses
  tool_fileTransfer;

{$R *.dfm}

var
  hSharedMemory : THandle;

  hMutex : THandle;

  smHub : ISharedMemoryHub2;

  sharedMemoryName : String;

  mutexName : String;

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


{ TSharedMemoryClientForm }

constructor TSharedMemoryClientForm.Create(AOwner: TComponent);
begin
  inherited;

  ReceiveSharedMemoryName();
  InitHandles();

  if( g_fileName <> '' )then
  begin
    FFileName := g_fileName;
    TestLabel.Caption := FFileName;
    buttonTransferFile.Enabled := true;
  end;

  caption := 'Shared memory client (' + sharedMemoryName + ')';
end;

procedure TSharedMemoryClientForm.buttonSelectFileClick(Sender: TObject);
begin
  if( dlgOpen.Execute() )then
  begin
    TestLabel.Caption := dlgOpen.FileName;
    FFileName := dlgOpen.FileName;
    buttonTransferFile.Enabled := true;
  end;
end;

procedure TSharedMemoryClientForm.buttonTransferFileClick(Sender: TObject);
begin
  TransferFile();
end;

procedure TSharedMemoryClientForm.TransferFile();
  const
    WAIT_FOR_EVENT_TIMEOUT = 5000;

  var
    data : pointer;
    fileInfo : TFileInfo;
    fileChunk : TFileChunk;
    fileStream : TFileStream;
    chunkSize : integer;
    readenSize : Integer;
    waitStatus : Cardinal;
    fileName : string;
    errorCode : integer;
    memSize : LongInt;
begin
  fileName := ExtractFileName(FFileName);
  //Transfer file name//
  WaitForSingleObject( hMutex, INFINITE );

  Log('Transfer file begins...');

  data := MapViewOfFile(hSharedMemory, FILE_MAP_WRITE, 0, 0, Length(FFileName) + 8);
  if( data = nil )then
  begin
    Log('Error: Unable to map file for file info');
    ReleaseMutex(hMutex);
    Exit;
  end;

  fileStream := TFileStream.Create( FFileName, fmOpenRead );

  Longint(data^) := fileStream.Size;
  Integer(Pointer(Integer(data) + 4)^) := Length(fileName);
  CopyMemory(Pointer(Integer(data) + 8), PChar(fileName), Length(fileName));

  UnmapViewOfFile(data);

  SetEvent(hNewFileEvent);

  waitStatus := WaitForSingleObject(hDataReceivedEvent, WAIT_FOR_EVENT_TIMEOUT);
  if( waitStatus = WAIT_TIMEOUT )then
  begin
    Log('Unable to connect to server.');
    ResetEvent(hNewFileEvent);
    fileStream.Destroy();
    ReleaseMutex(hMutex);
    exit;
  end;
  ResetEvent(hDataReceivedEvent);

  memSize := SHARED_MEMORY_SIZE - 4;

  progressBarFileTransfer.Max := Round(fileStream.Position/memSize) + 1;
  progressBarFileTransfer.Position := 0;

  Log('Transferring chunks of file');
  //Transfer file chunk by chunk//
  while fileStream.Position < fileStream.size do
  begin
    if( fileStream.Size - fileStream.Position < memSize )then
      chunkSize := fileStream.Size - fileStream.Position
    else
      chunkSize := memSize;

    data := MapViewOfFile(hSharedMemory, FILE_MAP_WRITE, 0, 0, chunkSize + 4 );

    if( data = nil )then
    begin
      Log('Error: Unable to map file for file chunk');
      ReleaseMutex( hMutex );
    end;

    SetLength(fileChunk.data, chunkSize);
    fileChunk.size := chunkSize;

    readenSize := fileStream.Read(fileChunk.data[0], chunkSize);
    if( readenSize <= 0 ) or ( readenSize > chunkSize )then
    begin
      errorCode := GetLastError();
      Log('Unable to read file data' );
      Log('Error::' + SysErrorMessage(errorCode) );
      SetEvent(hErrorEvent);
      fileStream.Destroy();
      ReleaseMutex(hMutex);
      exit;
    end;

    Integer(data^) := chunkSize;
    CopyMemory(Pointer(Integer(data)+4), PByte(fileChunk.data), chunkSize);

    UnmapViewOfFile(data);

    SetEvent( hNextChunkEvent );

    waitStatus := WaitForSingleObject(hDataReceivedEvent, WAIT_FOR_EVENT_TIMEOUT);
    if( waitStatus = WAIT_TIMEOUT )then
    begin
      Log('Unable to send chunk to server.');
      ResetEvent( hNextChunkEvent );
      SetEvent(hErrorEvent);
      fileStream.Destroy();
      ReleaseMutex(hMutex);
      exit;
    end;
    ResetEvent(hDataReceivedEvent);

    progressBarFileTransfer.StepIt();
    Application.ProcessMessages();
  end;

  //End of file transfer//
  Log('File transfer successfull');
  
  fileStream.Destroy();

  SetEvent( hEndFileEvent );
  ReleaseMutex(hMutex);
end;

procedure TSharedMemoryClientForm.Log( message : string );
begin
  memoLog.Lines.Add( message );
  Application.ProcessMessages();
end;



initialization

finalization
  CloseHandles();
end.
