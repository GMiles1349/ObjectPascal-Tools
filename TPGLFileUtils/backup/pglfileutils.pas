unit pglfileutils;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils, Linux, BaseUnix;

type

  PPGLDirectory = ^TPGLDirectory;
  TPGLDirectory = record
    private
      fPath: String;
      fDirectories: Array of String;
      fFiles: Array of String;

      procedure SetPath(aPath: String);

      function GetFileCount(): UINT32;
      function GetDirectoryCount(): UINT32;
      function GetFile(Index: UINT32): String;
      function GetDirectory(Index: UINT32): String;

    public
      property Path: String read fPath write SetPath;
      property FileCount: UINT32 read GetFileCount;
      property DirectoryCount: UINT32 read GetDirectoryCount;
      property Files[Index: UINT32]: String read GetFile;
      property Directories[Index: UINT32]: String read GetDirectory;

  end;


  function FindFile(aFileName: String; aRootPath: String): String;
  function ReadFile(aFileName: String; out aBuffer: UnicodeString): INT32; overload;
  function ReadFile(aFileName: String; out aBuffer: AnsiString): INT32; overload;
  function ReadFile(aFileName: String; var aBuffer: specialize TArray<Byte>): INT32; overload;
  function ReadFile(aFileName: String; var aBuffer: specialize TArray<Char>): INT32; overload;
  function ReadFile(aFileName: String; var aBuffer: Pointer): INT32; overload;
  function WriteFile(const aFileName: String; const aData: Pointer; const aSize: UINT32; const aOverWriteExisting: Boolean = False): INT32; overload;
  function WriteFile(const aFileName: String; const aData: PChar; const aOverWriteExisting: Boolean = False): INT32; overload;
  function WriteFile(const aFileName: String; const aData: String; const aOverWriteExisting: Boolean = False): INT32; overload;

implementation

procedure TPGLDirectory.SetPath(aPath: String);
var
Dirs: PDir;
DP: PDirent;
I,R: INT32;
OutString: PString;
  begin
    Self.fPath := aPath;
    SetLength(Self.fDirectories, 0);
    SetLength(Self.fFiles, 0);
    Dirs := fpOpenDir(aPath);

    if Dirs = nil then Exit;

    repeat
      DP := fpReadDir(Dirs^);
      if DP = nil then break;

      if DP^.d_type = 4 then begin
        SetLength(Self.fDirectories, Length(Self.fDirectories) + 1);
        I := High(Self.fDirectories);
        Self.fDirectories[I] := aPath;
        OutString := @Self.fDirectories[I];
      end else if DP^.d_type = 8 then begin
        SetLength(Self.fFiles, Length(Self.fFiles) + 1);
        I := High(Self.fFiles);
        Self.fFiles[I] := '';
        OutString := @Self.fFiles[I];
      end;

      R := 0;
      while DP^.d_name[R] <> #$00 do begin
        OutString^ := OutString^ + DP^.d_name[R];
        Inc(R);
      end;

      if DP^.d_type = 4 then begin
        OutString^ := OutString^ + '/';
      end;

    until DP = nil;

    I := 0;
    while I <= High(Self.fDirectories) do begin
      if (Self.fDirectories[I] = aPath + '.') or (Self.fDirectories[I] = aPath + '..') then begin
        Delete(Self.fDirectories, I, 1);
      end else begin
        Inc(I);
      end;
    end;

  end;

function TPGLDirectory.GetFileCount(): UINT32;
  begin
    Exit(Length(Self.fFiles));
  end;

function TPGLDirectory.GetDirectoryCount(): UINT32;
  begin
    Exit(Length(Self.fDirectories));
  end;

function TPGLDirectory.GetFile(Index: UINT32): String;
  begin
    if Index > High(Self.fFiles) then Exit('');
    Exit(Self.fFiles[Index]);
  end;

function TPGLDirectory.GetDirectory(Index: UINT32): String;
  begin
    if Index > High(Self.fDirectories) then Exit('');
    Exit(Self.fDirectories[Index]);
  end;


function FindFile(aFileName: String; aRootPath: String): String;
var
RootDir: TPGLDirectory;
RetName: String;
CheckName: String;
I: UINT32;
  begin

    RetName := '';

    RootDir.Path := aRootPath;
    if (RootDir.FileCount = 0) and (RootDir.DirectoryCount = 0) then Exit('');

    Initialize(Result);
    SetLength(Result, 0);

    // check files in directory
    if (RootDir.FileCount <> 0) then begin
      for I := 0 to RootDir.FileCount - 1 do begin
        if RootDir.Files[I] = aFileName then begin
          Exit(aRootPath + aFileName);
        end;
      end;
    end;

    // check sub directories
    if (RootDir.DirectoryCount <> 0) then begin
      for I := 0 to RootDir.DirectoryCount - 1 do begin
        if ExtractFileName(RootDir.Directories[i])[1] = '.' then Continue;
        CheckName := FindFile(aFileName, RootDir.Directories[I] + '/');
        if CheckName <> '' then begin
          if Length(RetName) <> 0 then RetName := RetName + ', ';
          RetName := RetName + CheckName;
        end;
      end;
    end;

    // for debugging purposes
    if RetName = '' then begin
      Exit('');
    end else begin
      Exit(RetName);
    end;

  end;


function ReadFile(aFileName: String; out aBuffer: UnicodeString): INT32;
var
FHandle: cint;
HStat: Stat;
Buf: Array of Char;
I: UINT32;
  begin
    FHandle := fpOpen(aFileName, O_RDONLY, O_RDONLY);
    if FHandle = -1 then Exit(-1);

    Initialize(HStat);
    Initialize(Buf);

    fpfStat(FHandle, HStat);
    SetLength(Buf, Hstat.st_size);
    fpRead(FHandle, @Buf[0], TSize(HStat.st_size));

    SetLength(aBuffer, 0);
    for I := 0 to High(Buf) do begin
      aBuffer := aBuffer + Buf[I];
    end;

    fpClose(FHandle);
    Exit(HStat.st_size);
  end;


function ReadFile(aFileName: String; out aBuffer: AnsiString): INT32;
var
FHandle: cint;
HStat: Stat;
Buf: Array of Char;
I: UINT32;
  begin
    FHandle := fpOpen(aFileName, O_RDONLY, O_RDONLY);
    if FHandle = -1 then Exit(-1);

    Initialize(HStat);
    Initialize(Buf);

    fpfStat(FHandle, HStat);
    SetLength(Buf, Hstat.st_size);
    fpRead(FHandle, @Buf[0], TSize(HStat.st_size));

    SetLength(aBuffer, 0);
    for I := 0 to High(Buf) do begin
      aBuffer := aBuffer + Buf[I];
    end;

    fpClose(FHandle);
    Exit(HStat.st_size);
  end;

function ReadFile(aFileName: String; var aBuffer: specialize TArray<Byte>): INT32;
var
FHandle: cint;
HStat: Stat;
  begin
    FHandle := fpOpen(aFileName, O_RDONLY, O_RDONLY);
    if FHandle = -1 then Exit(-1);

    Initialize(HStat);
    Initialize(aBuffer);
    fpfStat(FHandle, HStat);
    SetLength(aBuffer, HStat.st_size);
    fpRead(FHandle, aBuffer[0], TSize(HStat.st_size));

    fpClose(FHandle);
    Exit(HStat.st_size);
  end;


function ReadFile(aFileName: String; var aBuffer: specialize TArray<Char>): INT32;
var
FHandle: cint;
HStat: Stat;
  begin
    FHandle := fpOpen(aFileName, O_RDONLY, O_RDONLY);
    if FHandle = -1 then Exit(-1);

    Initialize(HStat);
    Initialize(aBuffer);
    fpfStat(FHandle, HStat);
    SetLength(aBuffer, HStat.st_size);
    fpRead(FHandle, aBuffer[0], TSize(HStat.st_size));

    fpClose(FHandle);
    Exit(HStat.st_size);
  end;


function ReadFile(aFileName: String; var aBuffer: Pointer): INT32;
var
FHandle: cint;
HStat: Stat;
  begin
    FHandle := fpOpen(aFileName, O_RDONLY, O_RDONLY);
    if FHandle = -1 then Exit(-1);

    Initialize(HStat);
    fpfStat(FHandle, HStat);

    aBuffer := GetMemory(HStat.st_size);

    fpRead(FHandle, aBuffer^, TSize(HStat.st_size));

    fpClose(FHandle);
    Exit(HStat.st_size);
  end;


function WriteFile(const aFileName: String; const aData: Pointer; const aSize: UINT32; const aOverWriteExisting: Boolean = False): INT32;
var
FHandle: cint;
  begin

    FHandle := fpOpen(aFileName, O_WRONLY or O_CREAT or O_TRUNC, S_IRWXU);

    if FHandle <> -1 then begin
      if aOverWriteExisting = False then Exit(-1);
    end;

    Result := fpWrite(FHandle, aData^, aSize);

    fpClose(FHandle);
  end;


function WriteFile(const aFileName: String; const aData: PChar; const aOverWriteExisting: Boolean = False): INT32;
  begin
    Result := WriteFile(aFileName, aData, StrLen(aData), aOverWriteExisting);
  end;

function WriteFile(const aFileName: String; const aData: String; const aOverWriteExisting: Boolean = False): INT32;
var
DataSize: UINT32;
  begin
    DataSize := Length(aData);
    Result := WriteFile(aFileName, PByte(@aData[1]), DataSize, aOverWriteExisting);
  end;

end.

