unit tool_events;

interface

const
  OK_STATUS = 0;
  ERROR_CREATION = -1000;

var
  hNewFileEvent : THandle;
  hNextChunkEvent : THandle;
  hEndFileEvent : THandle;
  hDataReceivedEvent : THandle;
  hErrorEvent : THandle;

  newFileEventName : String;
  nextChunkEventName : String;
  endFileEventName : String;
  dataReceivedEventName : String;
  errorEventName : string;


function CreateEvents() : integer;
procedure CloseEvents();
procedure SetEventNames( prefix : string );

implementation

uses
  Windows;
procedure CloseEvents();
begin
  CloseHandle( hNewFileEvent );
  CloseHandle( hNextChunkEvent );
  CloseHandle( hEndFileEvent );
  CloseHandle( hDataReceivedEvent );
  CloseHandle( hErrorEvent );
end;


function CreateEvents() : integer;
begin
  Result := ERROR_CREATION;

  hNewFileEvent := CreateEvent(nil, true, false, PAnsiChar(newFileEventName) );
  if hNewFileEvent = 0 then
  begin
    Exit;
  end;

  hNextChunkEvent := CreateEvent(nil, true, false, pAnsiChar(nextChunkEventName) );
  if hNextChunkEvent = 0 then
  begin
    Exit;
  end;

  hEndFileEvent := CreateEvent(nil, true, false, pAnsiChar(endFileEventName) );
  if hEndFileEvent = 0 then
  begin
    Exit;
  end;

  hDataReceivedEvent := CreateEvent(nil, true, false, pAnsiChar(dataReceivedEventName) );
  if hDataReceivedEvent = 0 then
  begin
    Exit;
  end;

  hErrorEvent := CreateEvent(nil, true, false, pAnsiChar(errorEventName) );
  if hErrorEvent = 0 then
  begin
    Exit;
  end;

  result := OK_STATUS;
end;

procedure SetEventNames(prefix: string);
begin
  newFileEventName := prefix + 'NewFile';
  nextChunkEventName := prefix + 'NextChunk';
  endFileEventName := prefix + 'EndOfFile';
  dataReceivedEventName := prefix + 'DataReceived';
  errorEventName := prefix + 'Error';
end;

end.
