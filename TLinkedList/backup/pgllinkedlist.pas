unit pgllinkedlist;

{$ifdef FPC}
  {$mode ObjFPC}{$H+}
  {$modeswitch ADVANCEDRECORDS}
  {$modeswitch TYPEHELPERS}
  {$INLINE ON}
  {$MACRO ON}
{$endif}

interface

uses
  Classes, SysUtils;

type

  generic TLinkedList<T> = class(TPersistent)

    type TListNode = class
      private
	      Last: TListNode;
	      Next: TListNode;
	      Value: T;

      public
        destructor Destroy(); override;
    end;

    private
      fCount: UINT32;
      fHead: TListNode;
      fTail: TListNode;

      function GetNodeValue(Index: UINT32): T;
      procedure SetNodeValue(Index: UINT32; aValue: T);

    public
      property Count: UINT32 read fCount;
      property Node[Index: UINT32]: T read GetNodeValue write SetNodeValue;

      constructor Create();
      destructor Destroy(); override;

      procedure Clear();
      procedure Push(const aValue: T); overload;
      procedure Push(const aValues: Array of T); overload;
      procedure Pop(); overload;
      procedure Pop(const aCount: UINT32); overload;
      procedure InsertAt(const aIndex: UINT32; const aValue: T); overload;
      procedure InsertAt(const aIndex: UINT32; const aValues: Array of T); overload;
      procedure Delete(const aIndex: UINT32); overload;
      procedure Delete(const aIndex: UINT32; const aCount: UINT32); overload;
      procedure DumpList(out Arr: specialize TArray<UINT32>);

      function FindFirst(const aValue: T): INT32;
      function FindLast(const aValue: T): INT32;
      function FindAll(const aValue: T): specialize TArray<UINT32>;


  end;

implementation

destructor TLinkedList.TListNode.Destroy();
  begin
    Self.Last := nil;
    Self.Next := nil;
    inherited;
  end;

constructor TLinkedList.Create();
  begin
    Self.fCount := 0;
    Self.fHead := nil;
    Self.fTail := nil;
  end;

destructor TLinkedList.Destroy();
  begin
    Self.Clear();
    inherited;
  end;


procedure TLinkedList.Clear();
var
Cur: TListNode;
Next: TListNode;
  begin

    if Self.fCount = 0 then Exit;

    Cur := Self.fHead;
    Next := Cur.Next;

    while Assigned(Cur) do begin
      FreeAndNil(Cur);
      if Assigned(Next) then begin
        Cur := Next;
        Next := Cur.Next;
      end;
    end;

    Self.fHead := nil;
    Self.fTail := nil;
    Self.fCount := 0;

  end;


function TLinkedList.GetNodeValue(Index: UINT32): T;
var
I: UINT32;
Cur: TListNode;
  begin

    if Index > Self.fCount - 1 then Exit;

    Cur := Self.fHead;
    if Index > 0 then begin
      for I := 0 to Index - 1 do begin
        Cur := Cur.Next;
      end;
    end;

    Exit(Cur.Value);

  end;


procedure TLinkedList.SetNodeValue(Index: UINT32; aValue: T);
var
I: UINT32;
Cur: TListNode;
  begin

    if Index > Self.fCount - 1 then Exit;

    Cur := Self.fHead;
    if Index > 0 then begin
      for I := 0 to Index - 1 do begin
        Cur := Cur.Next;
      end;
    end;

    Cur.Value := aValue;

  end;


procedure TLinkedList.Push(const aValue: T);
var
Cur: TListNode;
  begin

    Cur := TListNode.Create();
    Cur.Last := nil;
    Cur.Next := nil;
    Cur.Value := aValue;

    if Self.fHead = nil then begin
      Self.fHead := Cur;
      Self.fTail := Cur;
    end else begin
      Self.fTail.Next := Cur;
      Cur.Last := Self.fTail;
      Self.fTail := Cur;
    end;

    Self.fCount := Self.fCount + 1;

  end;


procedure TLinkedList.Push(const aValues: Array of T); overload;
var
I: UINT32;
  begin

    if Length(aValues) = 0 then Exit;

    for I := 0 to High(aValues) do begin
      Self.Push(aValues[I]);
    end;

  end;


procedure TLinkedList.Pop();
  begin
    if Self.fCount = 0 then Exit;

    Self.fTail := Self.fTail.Last;
    Self.fTail.Next.Free();
    Self.fTail.Next := nil;
    Self.fCount := Self.fCount - 1;
  end;


procedure TLinkedList.Pop(const aCount: UINT32);
var
I: UINT32;
  begin
    for I := 0 to aCount - 1 do begin
      Self.Pop();
      if Self.fCount = 0 then Exit;
    end;
  end;


procedure TLinkedList.InsertAt(const aIndex: UINT32; const aValue: T);
var
Cur: TListNode;
Sel: TListNode;
I: UINT32;
  begin

    if aIndex > Self.fCount - 1 then Exit;
    if aIndex = Self.fCount - 1 then begin
      Self.Push(aValue);
      Exit;
    end;

    Cur := TListNode.Create();
    Cur.Value := aValue;
    Cur.Last := nil;
    Cur.Next := nil;

    Self.fCount := Self.fCount + 1;

    Sel := Self.fHead;

    if aIndex = 0 then begin
      Self.fHead.Last := Cur;
      Cur.Next := Self.fHead;
      Self.fHead := Cur;
      Exit;
    end;

    if aIndex > 0 then begin
      for I := 1 to aIndex - 1 do begin
        Sel := Sel.Next;
      end;
    end;

    Cur.Last := Sel.Last;
    Sel.Last := Cur;
    Cur.Next := Sel;
    Cur.Last.Next := Cur;

  end;


procedure TLinkedList.InsertAt(const aIndex: UINT32; const aValues: Array of T); overload;
var
I: UINT32;
Len: UINT32;
  begin

    if Length(aValues) = 0 then Exit;
    if aIndex > Self.fCount - 1 then Exit;

    Len := Length(aValues);

    // if we're inserting at the tail, then just push the values individually
    if aIndex = Self.fCount - 1 then begin
      for I := 0 to Len - 1 do begin
        Self.Push(aValues[I]);
      end;
      Exit;
    end;

    // otherwise, keep calling insert on I + aIndex
    for I := 0 to Len - 1 do begin
      Self.InsertAt(aIndex + I, aValues[I]);
    end;

  end;


procedure TLinkedList.Delete(const aIndex: UINT32); overload;
var
Cur: TListNode;
I: UINT32;
  begin
    // exit on index too large
    if aIndex > Self.fCount - 1 then Exit;

    // pop if last index
    if aIndex = Self.fCount - 1 then begin
      Self.Pop();
      exit;
    end;

    Self.fCount := Self.fCount - 1;

    // simple swap and delete on aIndex is head
    if aIndex = 0 then begin
      Cur := Self.fHead;
      Self.fHead := Cur.Next;
      Cur.Free();
      Self.fHead.Last := nil;
      Exit;
    end;

    Cur := Self.fHead;
    for I := 0 to aIndex - 1 do begin
      Cur := Cur.Next;
    end;

    Cur.Last.Next := Cur.Next;
    Cur.Next.Last := Cur.Last;
    Cur.Free();

  end;


procedure TLinkedlist.Delete(const aIndex: UINT32; const aCount: UINT32); overload;
var
I: UINT32;
  begin

    if aIndex > Self.fCount - 1 then Exit;

    // if we're removing up to or passed the tail, then just pop from aIndex to tail
    if aIndex + aCount >= Self.fCount then begin
      Self.Pop(aCount);
      Exit;
    end;

    for I := 0 to aCount - 1 do begin
      Self.Delete(aIndex);
      if Self.fCount = 0 then Exit;
    end;

  end;


function TLinkedList.FindFirst(const aValue: T): INT32;
var
I: UINT32;
Cur: TListNode;
  begin

    if Self.fCount = 0 then Exit(-1);

    Cur := Self.fHead;
    for I := 0 to Self.fCount - 1 do begin
      if Cur.Value = aValue then Exit(I);
      Cur := Cur.Next;
      if Assigned(Cur) = False then Exit(-1);
    end;

  end;


function TLinkedList.FindLast(const aValue: T): INT32;
var
I: UINT32;
Cur: TListNode;
  begin

    if Self.fCount = 0 then Exit(-1);

    Cur := Self.fTail;
    for I := 0 to Self.fCount - 1 do begin
      if Cur.Value = aValue then Exit(I);
      Cur := Cur.Last;
      if Assigned(Cur) = False then Exit (-1);
    end;

  end;


function TLinkedList.FindAll(const aValue: T): specialize TArray<UINT32>;
var
I: UINT32;
Len: UINT32;
Cur: TListNode;
  begin

    if Self.fCount = 0 then Exit(nil);

    Cur := Self.fHead;
    Len := 0;
    Initialize(Result);
    SetLength(Result, 0);

    for I := 0 to Self.fCount - 1 do begin
      if Cur.Value = aValue then begin
        Inc(Len);
        SetLength(Result, Len);
        Result[Len - 1] := I;
      end;
      Cur := Cur.Next;
    end;

  end;


procedure TLinkedList.DumpList(out Arr: specialize TArray<UINT32>);
var
I: UINT32;
Cur: TListNode;
  begin

    if Self.fCount = 0 then begin
      SetLength(Arr,0);
      Exit;
    end;

    SetLength(Arr, Self.fCount);
    Cur := Self.fHead;

    for I := 0 to Self.fCount - 1 do begin
      Arr[I] := Cur.Value;
      Cur := Cur.Next;
    end;


  end;

end.

