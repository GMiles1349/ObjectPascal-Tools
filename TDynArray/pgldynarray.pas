unit PGLDynArray;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}
{$INCLUDE pgldynarray.inc}

interface

uses
	Classes, SysUtils;

type

	generic TDynArray<T> = record
  	private
    	fTypeSize: UINT32;
    	fSize: UINT32;
    	fMaxSize: UINT32;
    	fHigh: INT32;
    	fMemUsed: UINT32;
    	fMemReserved: UINT32;
    	fElements: array of T;

    	function GetElement(const Index: UINT32): T;
      function GetData(): Pointer;
      function GetEmpty(): Boolean;

      procedure SetElement(const Index: UINT32; Value: T);

      procedure UpdateLength(const aLength: UINT32); register; inline;

    public
    	property Data: Pointer read GetData;
      property Element[Index: UINT32]: T read GetElement write SetElement;
    	property TypeSize: UINT32 read fTypeSize;
      property Size: UINT32 read fSize;
    	property MaxSize: UINT32 read fMaxSize;
      property High: INT32 read fHigh;
    	property MemoryUsed: UINT32 read fMemUsed;
    	property MemoryReserved: UINT32 read fMemReserved;
      property Empty: Boolean read GetEmpty;

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
      procedure Swap(aIndex1, aIndex2: UINT32);
      procedure Reverse();
      procedure CopyToBuffer(var aBuffer: Pointer);
      procedure CopyToArray(var Arr: specialize TArray<T>);
      procedure CopyToDynArray(var aDynArr: TDynArray);
      procedure Combine(var aDynArr: TDynArray); overload;
      procedure Combine(var Arr: specialize TArray<T>); overload;

      function FindFirst(const Value: T): INT32;
      function FindLast(const Value: T): INT32;
      function FindAll(const Value: T): specialize TArray<UINT32>;

      class operator Initialize(var Dest: TDynArray);

  end;

implementation

class operator TDynArray.Initialize(var Dest: TDynArray);
	begin
  	Dest.fTypeSize := SizeOf(T);
    Dest.fSize := 0;
    Dest.fHigh := -1;
    Dest.fMaxSize := 0;
    Dest.fMemUsed := 0;
    Dest.fMemReserved := 0;
    Initialize(Dest.fElements);
  end;


constructor TDynArray.Create(const aNumElements: UINT32); overload;
	begin
  	SetLength(Self.fElements, aNumElements);
    Self.fSize := 0;
    Self.fHigh := -1;
    Self.fMaxSize := aNumElements;
    Self.fMemUsed := Self.fTypeSize * aNumElements;
    Self.fMemReserved := Self.fMemUsed;
  end;


constructor TDynArray.Create(const aNumElements: UINT32; const aDefaultValue: T); overload;
var
I: Cardinal;
	begin
  	SetLength(Self.fElements, aNumElements);
    Self.fSize := aNumElements;
    Self.fHigh := Self.fSize - 1;
    Self.fMaxSize := aNumElements;
    Self.fMemUsed := Self.fTypeSize * aNumElements;
    Self.fMemReserved := Self.fMemUsed;
    for I := 0 to Self.fHigh do begin
    	Self.fElements[I] := aDefaultValue;
    end;
  end;


function TDynArray.GetElement(const Index: UINT32): T;
	begin
    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
    if Index > fHigh then begin
      Initialize(Result);
    	FillByte(Result, fTypeSize, 0);
      Exit;
    end;
    {$ENDIF}
  	Exit(Self.fElements[Index]);
  end;


function TDynArray.GetData(): Pointer;
	begin
    if Self.fSize = 0 then Exit(nil);
  	Exit(@Self.fElements[0]);
  end;


function TDynArray.GetEmpty(): Boolean;
	begin
  	Exit(Self.fSize = 0);
  end;


procedure TDynArray.UpdateLength(const aLength: UINT32);
	begin
  	Self.fSize := aLength;
    Self.fHigh := Self.fSize - 1;

    Self.fMemUsed := Self.fHigh * Self.fTypeSize;

    if Self.fSize > Self.fMaxSize then begin
    	Self.fMaxSize := Self.fSize * 2;
      Self.fMemReserved := Self.fTypeSize * Self.fMaxSize;
      SetLength(Self.fElements, Self.fMaxSize);
    end;
  end;


procedure TDynArray.SetElement(const Index: UINT32; Value: T);
	begin
    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
    	if Index > Self.fHigh then Exit;
    {$ENDIF}
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
    if TrueCount > Self.fSize then TrueCount := Self.fSize;

  	Self.UpdateLength(Self.fSize - TrueCount);
  end;


procedure TDynArray.TrimFront(const aCount: UINT32);
// remove aCount elements from the front of the array
// move all other elements up by aCount and resize to new length
	begin

    if aCount >= Self.fSize then begin
      // just erase the whole thing if the count is >= current length
    	Self.UpdateLength(0);
      Exit;
    end;

    Move(Self.fElements[aCount + 1], Self.fElements[0], Self.fTypeSize * (Self.fSize - aCount));
    Self.UpdateLength(Self.fSize - aCount);

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

    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
   	if S > Self.fHigh then Exit;
    if E > Self.fHigh then E := Self.fHigh;
    {$ENDIF}

    TrimLen := E - S;
    MoveSize := (Self.fSize - E) * Self.fTypeSize;

    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
    if MoveSize <> 0 then begin
    	Move(Self.fElements[E + 1], Self.fElements[S], MoveSize);
    end;
    {$ELSE}
    Move(Self.fElements[E + 1], Self.fElements[S], MoveSize);
    {$ENDIF}

    Self.UpdateLength(Self.fSize - TrimLen);

  end;


procedure TDynArray.ShrinkToSize();     
	begin
  	SetLength(Self.fElements, Self.fSize);
    Self.fMaxSize := Self.fSize;
    Self.fHigh := Self.fSize - 1;
    Self.fMemReserved := Self.fMaxSize * Self.fTypeSize;
  	Self.fMemUsed := Self.fSize * Self.fTypeSize;
  end;


procedure TDynArray.Reserve(const aLength: UINT32);
	begin
  	if aLength > Self.fMaxSize then begin
    	Self.fMaxSize := aLength;
      SetLength(Self.fElements, aLength);
      Self.fMemReserved := Self.fMaxSize * Self.fTypeSize;
    end;
  end;


procedure TDynArray.PushBack(const Value: T);
	begin
  	Self.UpdateLength(Self.fSize + 1);
    Self.fElements[Self.fHigh] := Value;
  end;


procedure TDynArray.PushBack(const Values: Array of T);
var
Len: UINT32;
Place: UINT32;
	begin
    Len := System.Length(Values);
    Place := Self.fSize;
    Self.UpdateLength(Self.fSize + Len);
    Move(Values[0], Self.fElements[Place], Self.fTypeSize * Len);
  end;


procedure TDynArray.PushFront(const Value: T);
var
MoveSize: UINT32;
	begin
    MoveSize := Self.fMemUsed;
  	Self.fSize := Self.fSize + 1;
    Self.UpdateLength(Self.fSize + 1);
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
  	Self.UpdateLength(Self.fSize + Len);
    Move(Self.fElements[0], Self.fElements[Len], MoveSize);
    Move(Values[0], Self.fElements[0], Self.fTypeSize * Len);
  end;


procedure TDynArray.PopBack();
	begin
    if fSize = 0 then Exit;
  	Self.UpdateLength(Self.fSize - 1);
  end;


procedure TDynArray.PopFront();
	begin
    if fSize = 0 then Exit;
  	Move(Self.fElements[1], Self.fElements[0], Self.fMemUsed - Self.fTypeSize);
    Self.UpdateLength(Self.fSize - 1);
  end;


procedure TDynArray.Insert(const aIndex: UINT32; const Value: array of T);
var
MoveSize: UINT32;
Len: UINT32;
	begin

    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
    if aIndex > Self.fSize then Exit;
    {$ENDIF}

    if aIndex = Self.fSize then begin
      Self.PushBack(Value);
      Exit;
    end;

		Len := System.Length(Value);
    MoveSize := (Self.fSize - aIndex) * Self.fTypeSize;

    Self.UpdateLength(Self.fSize + Len);

    Move(Self.fElements[aIndex], Self.fElements[aIndex + Len], MoveSize);
    Move(Value[0], Self.fElements[aIndex], Self.fTypeSize * Len);

  end;


procedure TDynArray.Delete(const Index: UINT32);
var
MoveSize: UINT32;
	begin
    {$IFDEF TPGLDYNARRAY_BOUNDS_CHECKING}
    if Self.fSize = 0 then Exit;
    {$ENDIF}

    MoveSize := (Self.fSize - Index) * Self.fTypeSize;
    Move(Self.fElements[Index + 1], Self.fElements[Index], MoveSize);
    Self.UpdateLength(Self.fSize - 1);

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


procedure TDynArray.Swap(aIndex1, aIndex2: UINT32);
var
Temp: T;
	begin

    if aIndex1 = aIndex2 then Exit;

    {$IFDEF TDYNARRAY_BOUNDS_CHECKING}
    if (aIndex1 > Self.fHigh) or (aIndex2 > Self.fHigh) then Exit;
    {$ENDIF}

  	Temp := Self.fElements[aIndex1];
    Self.fElements[aIndex1] := Self.fElements[aIndex2];
    Self.fElements[aIndex2] := Temp;
  end;


procedure TDynArray.Reverse();
var
I,R: UINT32;
Limit: UINT32;
  begin

    Limit := Self.fHigh div 2;
    R := Self.fHigh;
    for I := 0 to Limit do begin
    	Self.Swap(I,R);
      Dec(R);
    end;

  end;


procedure TDynArray.CopyToBuffer(var aBuffer: Pointer);
	begin
  	aBuffer := GetMemory(Self.MemoryUsed);
    Move(Self.fElements[0], aBuffer^, Self.fMemUsed);
  end;


procedure TDynArray.CopyToArray(var Arr: specialize TArray<T>);
	begin
  	SetLength(Arr, Self.Size);
    Move(Self.fElements[0], Arr[0], Self.fMemUsed);
  end;


procedure TDynArray.CopyToDynArray(var aDynArr: TDynArray);
	begin
  	aDynArr.Resize(Self.Size);
    aDynArr.ShrinkToSize();
    Move(Self.fElements[0], aDynArr.fElements[0], Self.fMemUsed);
  end;


procedure TDynArray.Combine(var aDynArr: TDynArray);
var
Place: UINT32;
  begin
    Place := Self.fSize;
    Self.Resize(Self.fSize + aDynArr.fSize);
    Move(aDynArr.fElements[0], Self.fElements[Place], aDynArr.fMemUsed);
  end;


procedure TDynArray.Combine(var Arr: specialize TArray<T>);
var
Place: UINT32;
Len: UINT32;
  begin
    Len := Length(Arr);
    Place := Self.fSize;
    Self.Resize(Self.fSize + Len);
    Move(Arr[0], Self.fElements[Place], Len * Self.fTypeSize);
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
    SetLength(Ret, Self.fSize);
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

