unit PGLDynArray;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
	Classes, SysUtils;

type

	generic TDynArray<T> = record
  	private
    	fType: T;
    	fTypeSize: UINT32;
    	fLength: UINT32;
    	fHigh: INT32;
    	fLengthReserved: UINT32;
    	fMemUsed: UINT32;
    	fMemReserved: UINT32;
    	fElements: array of T;

    	function GetElement(const Index: UINT32): T;
      function GetData(): Pointer;

      procedure SetElement(const Index: UINT32; Value: T);

      procedure UpdateLength(const aLength: UINT32); register; inline;

    public
    	property Data: Pointer read GetData;
      property Element[Index: UINT32]: T read GetElement write SetElement;
    	property TypeSize: UINT32 read fTypeSize;
      property Length: UINT32 read fLength;
    	property LengthReserved: UINT32 read fLengthReserved;
      property High: INT32 read fHigh;
    	property MemoryUsed: UINT32 read fMemUsed;
    	property MemoryReserved: UINT32 read fMemReserved;

      constructor Create(const aNumElements: UINT32); overload;
      constructor Create(const aNumElements: UINT32; const aDefaultValue: T); overload;

      procedure Resize(const aLength: UINT32);
      procedure TrimBack(const aCount: UINT32);
      procedure TrimFront(const aCount: UINT32);
      procedure TrimRange(const aStartIndex, aEndIndex: UINT32);
      procedure ShrinkToSize();
      procedure Reserve(const aLength: UINT32);
      procedure PushBack(const Value: T); overload;
      procedure PushBack(const Values: Array of T); overload;
      procedure PushFront(const Value: T); overload;
      procedure PushFront(const Values: Array of T); overload;
      procedure PopBack();
      procedure PopFront();
      procedure Insert(const aIndex: UINT32; const Value: array of T);
      procedure Delete(const Index: UINT32);
      procedure FindDeleteFirst(const Value: T);
      procedure FindDeleteLast(const Value: T);
      procedure FindDeleteAll(const Value: T);

      function FindFirst(const Value: T): INT32;
      function FindLast(const Value: T): INT32;
      function FindAll(const Value: T): specialize TArray<UINT32>;

      class operator Initialize(var Dest: TDynArray);

  end;

implementation

class operator TDynArray.Initialize(var Dest: TDynArray);
	begin
  	Dest.fTypeSize := SizeOf(T);
    Dest.fLength := 0;
    Dest.fHigh := -1;
    Dest.fLengthReserved := 0;
    Dest.fMemUsed := 0;
    Dest.fMemReserved := 0;
    Initialize(Dest.fElements);
  end;


constructor TDynArray.Create(const aNumElements: UINT32); overload;
	begin
  	SetLength(Self.fElements, aNumElements);
    Self.fLength := 0;
    Self.fHigh := -1;
    Self.fLengthReserved := aNumElements;
    Self.fMemUsed := Self.fTypeSize * aNumElements;
    Self.fMemReserved := Self.fMemUsed;
  end;


constructor TDynArray.Create(const aNumElements: UINT32; const aDefaultValue: T); overload;
var
I: Cardinal;
	begin
  	SetLength(Self.fElements, aNumElements);
    Self.fLength := aNumElements;
    Self.fHigh := Self.fLength - 1;
    Self.fLengthReserved := aNumElements;
    Self.fMemUsed := Self.fTypeSize * aNumElements;
    Self.fMemReserved := Self.fMemUsed;
    for I := 0 to Self.fHigh do begin
    	Self.fElements[I] := aDefaultValue;
    end;
  end;


function TDynArray.GetElement(const Index: UINT32): T;
	begin
    if Index > fHigh then begin
      Initialize(Result);
    	FillByte(Result, fTypeSize, 0);
      Exit;
    end;
  	Exit(Self.fElements[Index]);
  end;


function TDynArray.GetData(): Pointer;
	begin
    if Self.fLength = 0 then Exit(nil);
  	Exit(@Self.fElements[0]);
  end;


procedure TDynArray.UpdateLength(const aLength: UINT32);
	begin
  	Self.fLength := aLength;
    Self.fHigh := Self.fLength - 1;

    Self.fMemUsed := Self.fHigh * Self.fTypeSize;

    if Self.fLength > Self.fLengthReserved then begin
    	Self.fLengthReserved := Self.fLength * 2;
      Self.fMemReserved := Self.fTypeSize * Self.fLengthReserved;
      SetLength(Self.fElements, Self.fLengthReserved);
    end;
  end;


procedure TDynArray.SetElement(const Index: UINT32; Value: T);
	begin
    if Index > Self.fHigh then Exit;
  	Self.fElements[Index] := Value;
  end;


procedure TDynArray.Resize(const aLength: UINT32);
	begin
  	Self.UpdateLength(aLength);
  end;


procedure TDynArray.TrimBack(const aCount: UINT32);
var
TrueCount: UINT32;
	begin
  	TrueCount := aCount;
    if TrueCount > Self.fLength then TrueCount := Self.fLength;

  	Self.UpdateLength(Self.fLength - TrueCount);
  end;


procedure TDynArray.TrimFront(const aCount: UINT32);
// remove aCount elements from the front of the array
// move all other elements up by aCount and resize to new length
	begin

    if aCount >= Self.fLength then begin
      // just erase the whole thing if the count is >= current length
    	Self.UpdateLength(0);
      Exit;
    end;

    Move(Self.fElements[aCount + 1], Self.fElements[0], Self.fTypeSize * (Self.fLength - aCount));
    Self.UpdateLength(Self.fLength - aCount);

  end;


procedure TDynArray.TrimRange(const aStartIndex, aEndIndex: UINT32);
var
S, E: UINT32;
MoveSize: UINT32;
TrimLen: UINT32;
	begin

    // if start and end are the same call Delete() instead
    if aStartIndex = aEndIndex then begin
    	Self.Delete(aStartIndex);
      Exit;
    end;

    S := aStartIndex;
    E := aEndIndex;

   	if S > Self.fHigh then Exit;
    if E > Self.fHigh then E := Self.fHigh;

    TrimLen := E - S;
    MoveSize := (Self.fLength - E) * Self.fTypeSize;

    if MoveSize <> 0 then begin
    	Move(Self.fElements[E + 1], Self.fElements[S], MoveSize);
    end;

    Self.UpdateLength(Self.fLength - TrimLen);

  end;


procedure TDynArray.ShrinkToSize();     
	begin
  	SetLength(Self.fElements, Self.fLength);
    Self.fMemReserved := Self.fLengthReserved * Self.fTypeSize;
  	Self.fMemUsed := Self.fLength * Self.fTypeSize;
  end;


procedure TDynArray.Reserve(const aLength: UINT32);
	begin
  	if aLength > Self.fLengthReserved then begin
    	Self.fLengthReserved := aLength;
      SetLength(Self.fElements, aLength);
      Self.fMemReserved := Self.fLengthReserved * Self.fTypeSize;
    end;
  end;


procedure TDynArray.PushBack(const Value: T);
	begin
  	Self.UpdateLength(Self.fLength + 1);
    Self.fElements[Self.fHigh] := Value;
  end;


procedure TDynArray.PushBack(const Values: Array of T);
var
Len: UINT32;
Place: UINT32;
	begin
    Len := System.Length(Values);
    Place := Self.fLength;
    Self.UpdateLength(Self.fLength + Len);
    Move(Values[0], Self.fElements[Place], Self.fTypeSize * Len);
  end;


procedure TDynArray.PushFront(const Value: T);
var
MoveSize: UINT32;
	begin
    MoveSize := Self.fMemUsed;
  	Self.fLength := Self.fLength + 1;
    Self.UpdateLength(Self.fLength + 1);
    Move(Self.fElements[0], Self.fElements[1], MoveSize);
    Self.fElements[0] := Value;
  end;


procedure TDynArray.PushFront(const Values: Array of T);
var
Len: UINT32;
MoveSize: UINT32;
	begin
    Len := System.Length(Values);
    MoveSize := Self.fMemUsed;
  	Self.UpdateLength(Self.fLength + Len);
    Move(Self.fElements[0], Self.fElements[Len], MoveSize);
    Move(Values[0], Self.fElements[0], Self.fTypeSize * Len);
  end;


procedure TDynArray.PopBack();
	begin
    if fLength = 0 then Exit;
  	Self.UpdateLength(Self.fLength - 1);
  end;


procedure TDynArray.PopFront();
	begin
    if fLength = 0 then Exit;
  	Move(Self.fElements[1], Self.fElements[0], Self.fMemUsed - Self.fTypeSize);
    Self.UpdateLength(Self.fLength - 1);
  end;


procedure TDynArray.Insert(const aIndex: UINT32; const Value: array of T);
var
MoveSize: UINT32;
Len: UINT32;
	begin
    if aIndex > Self.fLength then Exit;
    if aIndex = Self.fLength then begin
      Self.PushBack(Value);
      Exit;
    end;

		Len := System.Length(Value);
    MoveSize := (Self.fLength - aIndex) * Self.fTypeSize;

    Self.UpdateLength(Self.fLength + Len);

    Move(Self.fElements[aIndex], Self.fElements[aIndex + Len], MoveSize);
    Move(Value[0], Self.fElements[aIndex], Self.fTypeSize * Len);

  end;


procedure TDynArray.Delete(const Index: UINT32);
var
MoveSize: UINT32;
	begin
    if Self.fLength = 0 then Exit;

    MoveSize := (Self.fLength - Index) * Self.fTypeSize;
    Move(Self.fElements[Index + 1], Self.fElements[Index], MoveSize);
    Self.UpdateLength(Self.fLength - 1);

  end;


procedure TDynArray.FindDeleteFirst(const Value: T);
var
I: UINT32;
	begin
    for I := 0 to Self.fHigh do begin
    	if Self.fElements[I] = Value then begin
        Self.Delete(I);
        Exit;
      end;
    end;

  end;


procedure TDynArray.FindDeleteLast(const Value: T);
var
I: Integer;
	begin
    I := Self.fHigh;
    while I >= 0 do begin
    	if Self.fElements[I] = Value then begin
      	Self.Delete(I);
        Exit;
    	end;
      I := I - 1;
    end;
  end;


procedure TDynArray.FindDeleteAll(const Value: T);
var
I: INT32;
	begin
    I := 0;
    while I < Self.fHigh do begin
    	if Self.fElements[I] = Value then begin
        Self.Delete(i);
      end else begin
        I := I + 1;
      end;
    end;
  end;



function TDynArray.FindFirst(const Value: T): INT32;
var
I: UINT32;
	begin
    Result := -1;
    for I := 0 to Self.fHigh do begin
    	if Self.fElements[0] = Value then Exit(I);
    end;
  end;


function TDynArray.FindLast(const Value: T): INT32;
var
I: INT32;
	begin
    Result := -1;
    I := Self.fHigh;
    while I >= 0 do begin
    	if Self.fElements[I] = Value then Exit(I);
    end;
  end;


function TDynArray.FindAll(const Value: T): specialize TArray<UINT32>;
var
Ret: Array of UINT32;
FoundCount: UINT32;
I: UINT32;
	begin

    Initialize(Ret);
    SetLength(Ret, Self.fLength);
    FoundCount := 0;

    for I := 0 to Self.fHigh do begin
    	if Self.fElements[I] = Value then begin
        Ret[FoundCount] := I;
        FoundCount := FoundCount + 1;
      end;
    end;

    if FoundCount = 0 then Exit;

    Initialize(Result);
    SetLength(Result, FoundCount);
    Move(Ret[0], Result[0], FoundCount * Self.fTypeSize);

  end;



end.

