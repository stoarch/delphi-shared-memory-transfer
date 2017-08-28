unit tool_fileTransfer;

interface

const
  KB = 1024;
  SHARED_MEMORY_SIZE = 256*KB;
  FILE_NAME_SIZE = 256;//bytes

type
  TFileInfo = packed record
    fileSize : longint;
    nameSize : integer;
    fileName : string;
  end;

  TFileChunk = packed record
    size : longint;
    data : array of Byte;
  end;

implementation

end.
 