unit pglimage;

{$mode ObjFPC}{$H+}
{$MODESWITCH ADVANCEDRECORDS}
{$INLINE ON}

interface

uses
	Classes, SysUtils, Math, pgltypes;

(*//////////////////////////////////////////////////////////////////////////////////)
                                     Types
(//////////////////////////////////////////////////////////////////////////////////*)

{$REGION Types}

type


  TPGLImage = class;
  TPGLDrawInstance = class;
  TPGLImageResizeActions = (RESIZE_CLEAR = 0, RESIZE_CROP = 1, RESIZE_STRETCH = 2);

  TPGLBitmapInfo = packed record
  	InfoSize: DWORD;
    Width: DWORD;
    Height: DWORD;
    Planes: WORD;
    BitsPerPixel: WORD;
    CompressionType: DWORD;
    ImageSize: DWORD;
    HorzPixelPerMeter: DWORD;
    VertPixelPerMeter: DWORD;
    NumColors: DWORD;
    NumImportantColors: DWORD;

    class operator Initialize (var Dest: TPGLBitmapInfo);
  end;

  TPGLBitmapHeader = packed record
  	FileType: Array [0..1] of Char;
    FileSize: DWORD;
    Reserved1: WORD;
    Reserved2: WORD;
    DataOffset: DWORD;
    HeaderInfo: TPGLBitmapInfo;

    class operator Initialize (var Dest: TPGLBitmapHeader);
  end;

  { TPGLDestDescription }

  TPGLDestDescription = record
  	public
    	DataLocation: Pointer;
    	DataPixelWidth: Cardinal;
    	DataPixelHeight: Cardinal;
  end;


  { TPGLImage }

  TPGLImage = class(TPersistent)
    private
      fData: PByte;
      fRowPtr: Array of PByte;
      fDataSize: Cardinal;
      fRowSize: Cardinal;
      fWidth,fHeight: Integer;

      procedure InitData();
      function GetChunk(aX, aY, aWidth, aHeight: Cardinal): PByte;
      function GetRowPtr(Index: Cardinal): PByte;
      function GetPixel(X: Cardinal; Y: Cardinal): TPGLColorI;
      function GetBounds(): TPGLRectI;
      procedure SetPixel(X: Cardinal; Y: Cardinal; Color: TPGLColorI);


    public
      property Data: PByte read fData;
      property RowPtr[Index: Cardinal]: PByte read GetRowPtr;
      property DataSize: Cardinal read fDataSize;
      property RowSize: Cardinal read fRowSize;
      property Width: Integer read fWidth;
      property Height: Integer read fHeight;
      property Bounds: TPGLRectI read GetBounds;
      property Pixle[X: Cardinal; Y: Cardinal]: TPGLColorI read GetPixel write SetPixel;

      constructor Create(aWidth: Cardinal = 1; aHeight: Cardinal = 1);
      constructor Create(aFileName: String);
      destructor Destroy(); override;

      procedure SaveToFile(aFileName: String);

      procedure Clear(); overload;
      procedure Clear(aClearColor: TPGLColorI); overload;
      procedure ReplaceColor(aOldColor, aNewColor: TPGLColorI; aCheckAlpha: Boolean = False);
      procedure SetWidth(aWidth: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);
      procedure SetHeight(aHeight: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);
      procedure SetSize(aWidth: Cardinal; aHeight: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);

      procedure DrawCircle(aCenter: TPGLVec2; aRadius: Single; aColor: TPGLColorI); register;
      procedure DrawRectangle(aRect: TPGLRectF; aColor: TPGLColorF); register;

      procedure Blit(aDest: TPGLDestDescription; aDestBounds, aSrcBounds: TPGLRectI); overload;
      procedure Blit(aDest: TPGLImage; aDestBounds, aSrcBounds: TPGLRectI); overload;

  end;


  { TPGLDrawInstance }

  TPGLDrawInstance = class(TPersistent)
    private
      // global properties
      fAlphaBlendEnabled: Boolean;

      // cached user created objects
      fImages: specialize TArray<TPGLImage>;

      constructor Create(); // constructor hidden, singleton

      // getters, setters
      procedure SetAlphaBlendEnabled(aEnabled: Boolean);

      // object handling
      procedure AddImage(aImage: TPGLImage); register;

      procedure RemoveImage(aImage: TPGLImage); register;

    public
      property AlphaBlendEnabled: Boolean read fAlphaBlendEnabled write SetAlphaBlendEnabled;

  end;


{$ENDREGION}


(*//////////////////////////////////////////////////////////////////////////////////)
                                     Functions
(//////////////////////////////////////////////////////////////////////////////////*)

{$REGION Functions}

  // factories
	function DestDesc(aData: Pointer; aDestWidth, aDestHeight: Cardinal): TPGLDestDescription; register;

  // image data functions
  function WriteBMP(aFileName: String; aData: Pointer; aWidth, aHeight: Cardinal): Boolean; register;
  function LoadBMP(aFileName: String; out aWidth: Cardinal; out aHeight: Cardinal; out aChannels: Cardinal): Pointer; register;
  procedure TrimBMPAlignment(var aData: Pointer; aWidth, aHeight: Cardinal; aNewSize: PCardinal); register;
  function AddAlphaChannel(var aData: Pointer; aWidth, aHeight: Cardinal; out aNewSize: Cardinal): Boolean; register;
  function RemoveAlphaChannel(var aData: Pointer; aWidth, aHeight: Cardinal; out aNewSize: Cardinal): Boolean; register;
  function FlipDataVerticle(var aData: Pointer; aWidth, aHeight, aChannels: Cardinal): Boolean; register;
  function SwapDataRedBlue(aData: Pointer; aWidth, aHeight, aChannels: Cardinal): Boolean; register;


{$ENDREGION}

var
	PGL: TPGLDrawInstance;

implementation

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLBitmapInfo
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLBitmapInfo.Initialize(var Dest: TPGLBitmapInfo);
	begin
  	FillByte(Dest, SizeOf(Dest), 0);
    Dest.InfoSize := 40;
    Dest.Planes := 1;
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLBitmapHeader
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLBitmapHeader.Initialize(var Dest: TPGLBitmapHeader);
	begin
  	FillByte(Dest, SizeOf(Dest), 0);
	end;



(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLImage
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TPGLImage.Create(aWidth: Cardinal = 1; aHeight: Cardinal = 1);
	begin
  	Self.fWidth := aWidth;
    Self.fHeight := aHeight;

    Self.InitData();

    PGL.AddImage(Self);

  end;

constructor TPGLImage.Create(aFileName: String);
var
w,h,c,newsize: Cardinal;
iData: PByte;
	begin
  	iData := LoadBMP(aFileName, w, h, c);

    if iData = nil then begin
    	Self.fWidth := 1;
      Self.fHeight := 1;
      Self.InitData();
      Exit;
    end;

    Self.fWidth := w;
    Self.fHeight := h;

    Self.InitData();

    if c = 3 then begin
    	AddAlphaChannel(iData, w, h, newsize);
    end;

    //FlipDataVerticle(iData, w, h, 4);

    Move(iData[0], Self.fData[0], Self.fDataSize);
    FreeMemory(iData);

    PGL.AddImage(Self);
  end;

destructor TPGLImage.Destroy();
var
I: Integer;
  begin

    for I := 0 to High(Self.fRowPtr) do begin
    	Self.fRowPtr[I] := nil;
    end;

    FreeMemory(Self.fData);
    Self.fData := nil;

  end;

procedure TPGLImage.InitData();
var
I: Integer;
	begin

    // free memory if it's allocated
    if Assigned(Self.fData) then begin
    	FreeMemory(Self.fData);
    end;

    // calculate new data size and allocate
  	Self.fDataSize := (Self.fWidth * Self.fHeight) * 4;
    Self.fRowSize := Self.fWidth * 4;
    Self.fData := GetMemory(Self.fDataSize);
    FillByte(Self.fData[0], Self.fDataSize, 255);

    // set up the row pointers
    SetLength(Self.fRowPtr, Self.fHeight);

    for I := 0 to Self.fHeight - 1 do begin
    	Self.fRowPtr[I] := Self.fData + (Self.fRowSize * I);
    end;

  end;

procedure TPGLImage.SaveToFile(aFileName: String);
	begin
  	WriteBMP(aFileName, Self.fData, Self.fWidth, SElf.fHeight);
  end;

function TPGLImage.GetChunk(aX, aY, aWidth, aHeight: Cardinal): PByte;
var
ChunkSize: Cardinal;
WidthSize: Cardinal;
I: Integer;
SPtr, DPtr: PByte;
	begin
    if aX > Self.fWidth - 1 then Exit(nil);
    if aY > Self.fHeight - 1 then Exit(nil);
    if aX + (aWidth - 1) > Self.fWidth - 1 then Exit(nil);
    if aY + (aHeight - 1) > Self.fHeight - 1 then Exit(nil);

    WidthSize := aWidth * 4;
    ChunkSize := (aWidth * aHeight) * 4;
    Result := GetMemory(ChunkSize);
    DPtr := Result;

    for I := aY to (aY + aHeight) - 2 do begin
    	SPtr := Self.fRowPtr[I] + (aX * 4);
      Move(SPtr^, DPtr^, WidthSize);
      DPtr := DPtr + WidthSize;
    end;

  end;

function TPGLImage.GetRowPtr(Index: Cardinal): PByte;
	begin
    if Index > Self.fHeight - 1 then Exit(nil);
    Exit(Self.fRowPtr[Index]);
  end;

function TPGLImage.GetPixel(X: Cardinal; Y: Cardinal): TPGLColorI;
var
Ptr: PByte;
	begin
    Result := [0,0,0,0];
  	if (X > Self.fWidth - 1) or (Y > Self.fHeight - 1) then Exit;
    Ptr := Self.fRowPtr[Y] + (X * 4);
    Move(Ptr^, Result, 4);
  end;

procedure TPGLImage.SetPixel(X: Cardinal; Y: Cardinal; Color: TPGLColorI);
var
Ptr: PByte;
	begin
  	//if (X > Self.fWidth - 1) or (Y > Self.fHeight - 1) then Exit;
    //Ptr := Self.fRowPtr[Y] + (X * 4);
    Ptr := Self.fData + (((Self.fWidth * Y) + X) * 4);
    Move(Color, Ptr[0], 4);
  end;

function TPGLImage.GetBounds(): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(0,0,Self.Width - 1,Self.Height - 1);
  end;

procedure TPGLImage.Clear();
	begin
  	FillByte(Self.fData^, Self.fDataSize, 0);
  end;

procedure TPGLImage.Clear(aClearColor: TPGLColorI);
var
Ptr: ^TPGLColorI;
I: Integer;
	begin

    Ptr := @Self.fData[0];

    for I := 0 to trunc(Self.fDataSize / 4) - 1 do begin
    	Ptr[I] := aClearColor;
    end;

  end;

procedure TPGLImage.ReplaceColor(aOldColor, aNewColor: TPGLColorI; aCheckAlpha: Boolean = False);
var
I: Integer;
PixelCount: Integer;
Ptr: ^TPGLColorI;
	begin

    Ptr := @Self.fData[0];
    PixelCount := Self.fWidth * Self.fHeight;

    if aCheckAlpha then begin

	    for I := 0 to PixelCount - 1 do begin
	    	if Ptr[i] = aOldColor then begin
	      	Ptr[i] := aNewColor;
	      end;
	    end;

    end else begin

    	for I := 0 to PixelCount - 1 do begin
	    	if (Ptr[i].R = aOldColor.R) and (Ptr[i].G = aOldColor.G) and (Ptr[i].B = aOldColor.B) then begin
	      	Ptr[i] := aNewColor;
	      end;
	    end;

    end;

  end;

procedure TPGLImage.SetWidth(aWidth: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);
	begin
  	Self.SetSize(aWidth, Self.fHeight, aResizeAction);
  end;

procedure TPGLImage.SetHeight(aHeight: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);
	begin
  	Self.SetSize(Self.fWidth, aHeight, aResizeAction);
  end;

procedure TPGLImage.SetSize(aWidth: Cardinal; aHeight: Cardinal; aResizeAction: TPGLImageResizeActions = RESIZE_CLEAR);
var
NewSize: Integer;
WidthRatio, HeightRatio: Single;
ChunkData: PByte;
MaxWidth, MaxHeight, ChunkWidth, MoveWidth: Integer;
I,Z: Integer;
SPos,DPos: Integer;
	begin

    // just reallocate data if RESIZE_CLEAR
    if aResizeAction = RESIZE_CLEAR then begin
    	Self.fWidth := aWidth;
      Self.fHeight := aHeight;
      Self.InitData();
      Exit;
    end;

    NewSize := (aWidth * aHeight) * 4;

    // if RESIZE_CROP, grap the chunk, reallocate, and paste data back in
    if aResizeAction = RESIZE_CROP then begin
    	ChunkData := Self.GetChunk(0, 0, Self.fWidth, Self.fHeight);
      ChunkWidth := Self.fRowSize;
      MaxWidth := Min(Self.fWidth, aWidth);
      MaxHeight := Min(Self.fHeight, aHeight);
      MoveWidth := MaxWidth * 4;
      SPos := 0;
      DPos := 0;

      Self.fWidth := aWidth;
      Self.fHeight := aHeight;
      Self.InitData();

      for Z := 0 to MaxHeight - 1 do begin
        Move(ChunkData[SPos], Self.fData[DPos], MoveWidth);
        SPos += ChunkWidth;
        DPos += Self.fRowSize;
     	end;

      FreeMemory(ChunkData);

    end;
  end;

procedure TPGLImage.DrawCircle(aCenter: TPGLVec2; aRadius: Single; aColor: TPGLColorI);
var
Rect: TPGLRectI;
Dist: Single;
I,Z: Integer;
Pos: Integer;
OutColor: ^TPGLColorI;
	begin
  	Rect := RectIC(aCenter, trunc(aRadius * 2), trunc(aRadius * 2));
    Rect.Crop(RectIWH(0,0,Self.Width,Self.Height));
    OutColor := @Self.fData[0];

    // draw with blending

    if aColor.A < 255 then begin
	    for Z := Rect.Top to Rect.Bottom do begin

        Pos := (Z * Self.Width) + Rect.Left;

	      for I := Rect.Left to Rect.Right do begin

	        Dist := Sqrt( IntPower((aCenter.X) - I, 2) + IntPower((aCenter.Y) - Z, 2));

	        if Dist <= aRadius then begin
            AlphaBlend(PUINT32(@aColor), PUINT32(@OutColor[Pos]));
	        end;

          Pos := Pos + 1;

	      end;
	    end;

    	Exit;
    end;

    // draw without blending
    for Z := Rect.Top to Rect.Bottom do begin

      Pos := (Z * Self.Width) + Rect.Left;

      for I := Rect.Left to Rect.Right do begin

        Dist := Sqrt( IntPower((aCenter.X) - I, 2) + IntPower((aCenter.Y) - Z, 2));

        if Dist <= aRadius then begin
        	OutColor[Pos] := aColor;
        end;

        Pos := Pos + 1;

      end;
    end;

  end;

procedure TPGLImage.DrawRectangle(aRect: TPGLRectF; aColor: TPGLColorF);
var
Rect: TPGLRectI;
I,Z: Integer;
OutColor: ^TPGLColorI;
Pos: Integer;
	begin

    Rect := aRect;
    //Rect.Crop(RectIWH(0,0,Self.Width,Self.Height));
    OutColor := @Self.fData[0];

    for Z := Rect.Top to Rect.Bottom do begin

      Pos := (Z * Self.Width) + Bounds.Left;

      for I := Rect.Left to Rect.Right do begin
      	OutColor[Pos] := aColor;
        Inc(Pos);
      end;
    end;

  end;

procedure TPGLImage.Blit(aDest: TPGLDestDescription; aDestBounds, aSrcBounds: TPGLRectI);
var
WidthRatio, HeightRatio: Single;
SPos, DPos: Integer;
SPtr, DPtr: PByte;
DRowSize, MoveSize: Integer;
DX1, DX2, DY1, DY2, SX1, SX2, SY1, SY2, DWidth, DHeight, SWidth, SHeight: Integer;
I, Z: Integer;
X, Y: Single;
SColor: TPGLColorI;
MColor: TPGLColorI;
	begin

    // exit on Src origin is larger then right or bottom
    if (aSrcBounds.Left >= Self.fWidth) or (aSrcBounds.Top >= Self.fHeight) then Exit;

    // exit on Dest origin is larger than right or bottom
    if (aDestBounds.Left >= aDest.DataPixelWidth) or (aDestBounds.Top >= aDest.DataPixelHeight) then Exit;

    SX1 := aSrcBounds.Left;
    SX2 := aSrcBounds.Right;
    SY1 := aSrcBounds.Top;
    SY2 := aSrcBounds.Bottom;

    if SX1 < 0 then SX1 := 0;
    if SX2 >= Self.fWidth then SX2 := Self.fWidth - 1;
    if SY1 < 0 then SY1 := 0;
    if SY2 >= Self.fHeight then SY2 := Self.fHeight - 1;

    SWidth := SX2 - SX1;
    SHeight := SY2 - SY1;

    DX1 := aDestBounds.Left;
    DX2 := aDestBounds.Right;
    DY1 := aDestBounds.Top;
    DY2 := aDestBounds.Bottom;

    if DX1 < 0 then DX1 := 0;
    if DX2 >= aDest.DataPixelWidth then DX2 := aDest.DataPixelWidth - 1;
    if DY1 < 0 then DY1 := 0;
    if DY2 >= aDest.DataPixelHeight then DY2 := aDest.DataPixelHeight - 1;

    DWidth := DX2 - DX1;
    DHeight := DY2 - DY1;

    WidthRatio := SWidth / DWidth;
    HeightRatio := SHeight / DHeight;

    SPtr := Self.fData;
    DPtr := PByte(aDest.DataLocation);

    DRowSize := aDest.DataPixelWidth * 4;


    if PGL.AlphaBlendEnabled then begin

	    for Z := 0 to DHeight - 1 do begin
	      for I := 0 to DWidth - 1 do begin

	      	DPos := (( (Z + DY1) * aDest.DataPixelWidth) + (I + DX1)) * 4;

	        X := ((I + SX1) * WidthRatio);
	        Y := ((Z + SY1) * HeightRatio);
	        Spos := ( (trunc(Y) * Self.fWidth) + Trunc(X)) * 4;

	        AlphaBlend(PUINT32(@SPtr[SPos]), PUINT32(@DPtr[DPos]));

	      end;
	    end;

    end else begin

      for Z := 0 to DHeight - 1 do begin
	      for I := 0 to DWidth - 1 do begin

	      	DPos := (( (Z + DY1) * aDest.DataPixelWidth) + (I + DX1)) * 4;

	        X := ((I + SX1) * WidthRatio);
	        Y := ((Z + SY1) * HeightRatio);
	        Spos := ( (trunc(Y) * Self.fWidth) + Trunc(X)) * 4;

	        Move(SPtr[SPos], DPtr[DPos], 4);

	      end;
	    end;

    end;


  end;

procedure TPGLImage.Blit(aDest: TPGLImage; aDestBounds, aSrcBounds: TPGLRectI);
	begin
  	Self.Blit(DestDesc(aDest.fData, aDest.fWidth, aDest.fHeight), aDestBounds, aSrcBounds);
  end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLDrawInstance
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TPGLDrawInstance.Create();
	begin
  	Self.fAlphaBlendEnabled := True;
    Initialize(Self.fImages);
  end;


procedure TPGLDrawInstance.SetAlphaBlendEnabled(aEnabled: Boolean);
	begin
  	if aEnabled <> Self.fAlphaBlendEnabled then begin
    	// TODO: Flush batches and whatnot
    end;

    Self.fAlphaBlendEnabled := aEnabled;
  end;


procedure TPGLDrawInstance.AddImage(aImage: TPGLImage);
	begin

  end;


procedure TPGLDrawInstance.RemoveImage(aImage: TPGLImage);
	begin

  end;



function DestDesc(aData: Pointer; aDestWidth, aDestHeight: Cardinal): TPGLDestDescription;
	begin
  	Result.DataLocation := aData;
    Result.DataPixelHeight := aDestHeight;
    Result.DataPixelWidth := aDestWidth;
  end;



function WriteBMP(aFileName: String; aData: Pointer; aWidth, aHeight: Cardinal): Boolean; register;
var
Header: TPGLBitmapHeader;
DataSize: Cardinal;
WriteData: Array of Byte;
OutFile: TFileStream;
	begin
  	Result := False;

    DataSize := 4 * (aWidth * aHeight);

    Header.FileType := 'BM';
    Header.FileSize := SizeOf(Header) + DataSize;
    Header.DataOffset := SizeOf(Header);
    Header.HeaderInfo.BitsPerPixel := 32;
    Header.HeaderInfo.CompressionType := 0;
    Header.HeaderInfo.Height := aHeight;
    Header.HeaderInfo.Width := aWidth;
    Header.HeaderInfo.HorzPixelPerMeter := 0;
    Header.HeaderInfo.VertPixelPerMeter := 0;
    Header.HeaderInfo.ImageSize := DataSize;
    Header.HeaderInfo.InfoSize := 40;
    Header.HeaderInfo.NumColors := 0;
    Header.HeaderInfo.NumImportantColors := 0;
    Header.HeaderInfo.Planes := 1;

    Initialize(WriteData);
    SetLength(WriteData, SizeOf(Header) + DataSize);
    Move(Header, WriteData[0], SizeOf(Header));
    Move(PByte(aData)[0], WriteData[SizeOf(Header)], DataSize);

    OutFile := TFileStream.Create(aFileName, fmCreate or fmOpenWrite);
    OutFile.Seek(0, 0);
    OutFile.Write(WriteData[0], Length(WriteData));
    OutFile.Free();

  end;

function LoadBMP(aFileName: String; out aWidth: Cardinal; out aHeight: Cardinal; out aChannels: Cardinal): Pointer;
var
InFile: TFileStream;
Header: TPGLBitmapHeader;
n: Cardinal;
	begin

    if FileExists(aFileName) = False then Exit(nil);

    InFile := TFileStream.Create(aFileName, fmOpenRead);
    InFile.Seek(0,0);

    Initialize(Header);
    InFile.Read(Header, SizeOf(Header));

    Result := GetMemory(Header.HeaderInfo.ImageSize);
    InFile.Seek(Header.DataOffset, 0);
    InFile.Read(Result^, Header.HeaderInfo.ImageSize);

    aWidth := Header.HeaderInfo.Width;
    aHeight := Header.HeaderInfo.Height;
    aChannels := trunc(Header.HeaderInfo.BitsPerPixel / 8);

    TrimBMPAlignment(Result, aWidth, aHeight, @n);

    InFile.Free();

  end;


procedure TrimBMPAlignment(var aData: Pointer; aWidth, aHeight: Cardinal; aNewSize: PCardinal);
var
I: Integer;
OldRowSize: Integer;
NewRowSize: Integer;
PadSize: Integer;
NewData: PByte;
Rem: Integer;
SPtr, DPtr: PByte;
SPos, DPos: Integer;
	begin

    aNewSize^ := (aWidth * aHeight) * 3;
    OldRowSize := aWidth * 3;
    Rem := OldRowSize mod 4;
    PadSize := 4 - Rem;
    OldRowSize := OldRowSize + PadSize;

    NewRowSize := aWidth * 3;

    NewData := GetMemory(aNewSize^);

    SPtr := aData;
    DPtr := NewData;
    SPos := 0;
    DPos := 0;

    for I := 0 to aHeight - 1 do begin
    	Move(SPtr[SPos], DPtr[DPos], OldRowSize);
      Inc(SPos, OldRowSize);
      Inc(DPos, NewRowSize);
    end;

    aData := ReAllocMemory(aData, aNewSize^);
    Move(NewData[0], aData^, aNewSize^);

    FreeMemory(NewData);
  end;

function AddAlphaChannel(var aData: Pointer; aWidth, aHeight: Cardinal; out aNewSize: Cardinal): Boolean;
var
Buffer: PByte;
PixelCount: Integer;
OldSize, NewSize: Integer;
SPtr, DPtr: PByte;
SPos, DPos: Integer;
I: Integer;
	begin

    OldSize := (aWidth * aHeight) * 3;
    NewSize := (aWidth * aHeight) * 4;
    PixelCount := aWidth * aHeight;

    Buffer := GetMemory(OldSize);
    Move(aData^, Buffer[0], OldSize);
    FreeMemory(aData);
    aData := GetMemory(NewSize);

    SPtr := Buffer;
    DPtr := aData;
    SPos := 0;
    DPos := 0;

    for I := 0 to PixelCount - 1 do begin
    	DPtr[DPos + 0] := SPtr[SPos + 0];
      DPtr[DPos + 1] := SPtr[SPos + 1];
      DPtr[DPos + 2] := SPtr[SPos + 2];
      DPtr[DPos + 3] := 255;

      SPtr += 3;
      DPtr += 4;
    end;

    aNewSize := NewSize;
    Exit(True);

  end;

function RemoveAlphaChannel(var aData: Pointer; aWidth, aHeight: Cardinal; out aNewSize: Cardinal): Boolean;
var
Buffer: PByte;
PixelCount: Integer;
OldSize, NewSize: Integer;
SPtr, DPtr: PByte;
SPos, DPos: Integer;
I: Integer;
	begin

    OldSize := (aWidth * aHeight) * 4;
    NewSize := (aWidth * aHeight) * 3;
    PixelCount := aWidth * aHeight;

    Buffer := GetMemory(OldSize);
    Move(aData^, Buffer[0], OldSize);
    FreeMemory(aData);
    aData := GetMemory(NewSize);

    SPtr := Buffer;
    DPtr := aData;
    SPos := 0;
    DPos := 0;

    for I := 0 to PixelCount - 1 do begin
    	DPtr[DPos + 0] := SPtr[SPos + 0];
      DPtr[DPos + 1] := SPtr[SPos + 1];
      DPtr[DPos + 2] := SPtr[SPos + 2];

      SPtr += 4;
      DPtr += 3;
    end;

    aNewSize := NewSize;
    Exit(True);

  end;

function FlipDataVerticle(var aData: Pointer; aWidth, aHeight, aChannels: Cardinal): Boolean;
var
NumLines: Integer;
I: Integer;
RowWidth: Integer;
TempData: PByte;
SPtr, DPtr: PByte;
SPos, DPos: Integer;
SLine: Integer;
	begin

    RowWidth := aWidth * aChannels;
    TempData := GetMemory(RowWidth);

    NumLines := trunc(aHeight / 2);

    for I := 0 to NumLines - 1 do begin
    	SLine := (AHeight - 1) - I;
      SPos := RowWidth * SLine;
      DPos := RowWidth * I;
      SPtr := PByte(aData) + SPos;
      DPtr := PByte(aData) + DPos;
      Move(DPtr[0], TempData[0], RowWidth);
      Move(SPtr[0], DPtr[0], RowWidth);
      Move(TempData[0], SPtr[0], RowWidth);
    end;

    Exit(True);

  end;

function SwapDataRedBlue(aData: Pointer; aWidth, aHeight, aChannels: Cardinal): Boolean;
var
Step: Cardinal;
PixelCount: Integer;
I: Integer;
Temp: Byte;
Pos: Integer;
Ptr: PByte;
	begin

    Step := aChannels;
    PixelCount := aWidth * aHeight;
    Pos := 0;
    Ptr := PByte(aData);

    for I := 0 to PixelCount - 1 do begin
    	Temp := Ptr[Pos + 0];
      Ptr[Pos + 0] := Ptr[Pos + 2];
      Ptr[Pos + 2] := Temp;

      Inc(Pos, Step);
    end;

    Exit(True);

  end;


initialization
	begin
  	PGL := TPGLDrawInstance.Create();
  end;

end.

