unit pgltypes;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
  Classes, SysUtils;

type

  TPGLAnchors = (ANCHOR_CENTER = 0, ANCHOR_LEFT = 1, ANCHOR_TOP = 2, ANCHOR_RIGHT = 3, ANCHOR_BOTTOM = 4);

	{ TPGLColorI }

	PPGLColorI = ^TPGLColorI;
	TPGLColorI = record
	  private
	    {$IFDEF PGL_RGB}
	  		fB,fG,fR,fA: Byte;
	  	{$ELSE}
	      fR,fG,fB,fA: Byte;
	  	{$ENDIF}

	  	procedure SetR(value: Byte);
	    procedure SetG(value: Byte);
	    procedure SetB(value: Byte);
	    procedure SetA(value: Byte);

	  public
	  	property R: Byte read fR write SetR;
	    property G: Byte read fG write SetG;
	    property B: Byte read fB write SetB;
	    property A: Byte read fA write SetA;

	    class operator Initialize(var Color: TPGLColorI);
	end;

	{ TPGLColorF }

	TPGLColorF = record
	  private
	  	fR,fG,fB,fA: Single;
	  	procedure SetR(value: Single);
	    procedure SetG(value: Single);
	    procedure SetB(value: Single);
	    procedure SetA(value: Single);

	  public
	  	property R: Single read fR write SetR;
	    property G: Single read fG write SetG;
	    property B: Single read fB write SetB;
	    property A: Single read fA write SetA;

	    class operator Initialize(var Color: TPGLColorF);
	end;

	{ TPGLVec2 }

	TPGLVec2 = record
	  public
	  	X,Y: Single;

	  	class operator Initialize(var Vec: TPGLVec2);
	end;

	{ TPGLVec3 }

	TPGLVec3 = record
	  public
	  	X,Y,Z: Single;

	  	class operator Initialize(var Vec: TPGLVec3);
	end;

	{ TPGLVec4 }

	TPGLVec4 = record
		public
	  	X,Y,Z,W: Single;

	  	class operator Initialize(var Vec: TPGLVec4);
	end;

	{ TPGLRectI }

	TPGLRectI = record
	  private
	  	fX,fY,fLeft,fTop,fRight,fBottom,fWidth,fHeight: Integer;

	  	function GetCenter(): TPGLVec2;
	    function GetSize(): TPGLVec2;
	    function GetTopLeft(): TPGLVec2;
	    function GetTopRight(): TPGLVec2;
	    function GetBottomLeft(): TPGLVec2;
	    function GetBottomRight(): TPGLVec2;

	  	procedure SetX(value: Integer);
	    procedure SetY(value: Integer);
	    procedure SetCenter(value: TPGLVec2);
	  	procedure SetLeft(value: Integer);
	    procedure SetRight(value: Integer);
	    procedure SetTop(value: Integer);
	    procedure SetBottom(value: Integer);
	    procedure SetWidth(value: Integer);
	    procedure SetHeight(value: Integer);
	    procedure SetSize(value: TPGLVec2);
	    procedure SetTopLeft(value: TPGLVec2);
	    procedure SetTopRight(value: TPGLVec2);
	    procedure SetBottomLeft(value: TPGLVec2);
	    procedure SetBottomRight(value: TPGLVec2);

	  public
	  	property X: Integer read fX write SetX;
	  	property Y: Integer read fY write SetY;
	    property Center: TPGLVec2 read GetCenter write SetCenter;
	  	property Left: Integer read fLeft write SetLeft;
	  	property Right: Integer read fRight write SetRight;
	  	property Top: Integer read fTop write SetTop;
	  	property Bottom: Integer read fBottom write SetBottom;
	    property Width: Integer read fWidth write SetWidth;
	  	property Height: Integer read fHeight write SetHeight;
	    property Size: TPGLvec2 read GetSize write SetSize;
	    property TopLeft: TPGLVec2 read GetTopLeft write SetTopLeft;
	    property TopRight: TPGLVec2 read GetTopRight write SetTopRight;
	    property BottomLeft: TPGLVec2 read GetBottomLeft write SetBottomLeft;
	    property BottomRight: TPGLVec2 read GetBottomRight write SetBottomRight;

	    constructor Create(aLeft, aTop, aRight, aBottom: Integer);

	    procedure SetAnchoredWidth(aWidth: Integer; aAnchor: TPGLAnchors = ANCHOR_CENTER);
	    procedure SetAnchoredHeight(aHeight: Integer; aAnchor: TPGLAnchors = ANCHOR_CENTER);
	    procedure SetAnchoredSize(aWidth,aHeight: Integer; aWidthAnchor: TPGLAnchors = ANCHOR_CENTER; aHeightAnchor: TPGLAnchors = ANCHOR_CENTER);

	end;

	{ TPGLRectF }

	TPGLRectF = record
	  private
	  	fX,fY,fLeft,fTop,fRight,fBottom,fWidth,fHeight: Single;

	  	function GetSize(): TPGLVec2;
	    function GetCenter(): TPGLVec2;

	  	procedure SetX(value: Single);
	    procedure SetY(value: Single);
	    procedure SetCenter(values: TPGLVec2);
	    procedure SetLeft(value: Single);
	    procedure SetRight(value: Single);
	    procedure SetTop(value: Single);
	    procedure SetBottom(value: Single);
	    procedure SetWidth(value: Single);
	    procedure SetHeight(value: Single);
	    procedure SetSize(values: TPGLVec2);

	  public
	  	property X: Single read fX write SetX;
	  	property Y: Single read fY write SetY;
	    property Center: TPGLVec2 read GetCenter write SetCenter;
	  	property Left: Single read fLeft write SetLeft;
	  	property Right: Single read fRight write SetRight;
	  	property Top: Single read fTop write SetTop;
	  	property Bottom: Single read fBottom write SetBottom;
	  	property Width: Single read fWidth write SetWidth;
	  	property Height: Single read fHeight write SetHeight;
	    property Size: TPGLVec2 read GetSize write SetSize;

	    constructor Create(aLeft, aTop, aRight, aBottom: Single);

	end;


  TPGLRectIHelper = record helper for TPGLRectI
  	procedure Crop(aBounds: TPGLRectI);
    procedure FitTo(aBounds: TPGLRectI);
  end;


  TPGLRectFHelper = record helper for TPGLRectF
  	procedure Crop(aBounds: TPGLRectF);
    procedure FitTo(aBounds: TPGLRectF);
  end;

(*//////////////////////////////////////////////////////////////////////////////////)
                                     Operators
(//////////////////////////////////////////////////////////////////////////////////*)

{$REGION Operators}

	{ Colors }

	operator := (ColorF: TPGLColorF): TPGLColorI;
  operator := (ColorI: TPGLColorI): TPGLColorF;
  operator := (Color: DWORD): TPGLColorI;
  operator := (Color: DWORD): TPGLColorF;
  operator := (Values: Array of Integer): TPGLColorI;
  operator := (Values: Array of Single): TPGLColorF;
  operator +  (A,B: TPGLColorI): TPGLColorI;
  operator +  (A,B: TPGLColorF): TPGLColorF;
  operator +  (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
  operator +  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
  operator -  (A,B: TPGLColorI): TPGLColorI;
  operator -  (A,B: TPGLColorF): TPGLColorF;
  operator -  (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
  operator -  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
  operator *  (ColorI: TPGLColorI; Value: Single): TPGLColorI;
  operator *  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
  operator /  (ColorI: TPGLColorI; Value: Single): TPGLColorI;
  operator /  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
  operator =  (A, B: TPGLColorI): Boolean;
  operator =  (A, B: TPGLColorF): Boolean;
  operator =  (ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
  operator =  (ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;

  { Vectors }
  operator := (Values: Array of Single): TPGLVec2;
  operator := (Values: Array of Integer): TPGLVec2;
  operator := (aVec3: TPGLVec3): TPGLVec2;
  operator := (aVec4: TPGLVec4): TPGLVec2;

  operator := (Values: Array of Single): TPGLVec3;
  operator := (Values: Array of Integer): TPGLVec3;
  operator := (aVec2: TPGLVec2): TPGLVec3;
  operator := (aVec4: TPGLVec4): TPGLVec3;

  operator := (Values: Array of Single): TPGLVec4;
  operator := (Values: Array of Integer): TPGLVec4;
  operator := (aVec2: TPGLVec2): TPGLVec4;
  operator := (aVec3: TPGLVec3): TPGLVec4;

  { Rects }

  operator := (aRect: TPGLRectF): TPGLRectI;
  operator := (aRect: TPGLRectI): TPGLRectF;

{$ENDREGION}

	// clamping
	function ClampI(value: Integer): Byte; overload; register;
	function ClampF(value: Single): Single; overload; register;

	procedure ClampVarI(var value: Integer); register;
	procedure ClampVarF(var value: Single); register;

	// colors
	function ColorI(aRed, aGreen, aBlue: Byte; aAlpha: Byte = 255): TPGLColorI; register;
	function ColorF(aRed, aGreen, aBlue: Single; aAlpha: Single = 1.0): TPGLColorF; register;
	function Mix(aDestColor, aSrcColor: TPGLColorF; aSrcFactor: Single): TPGLColorF; overload;
	function Mix(aDestColor, aSrcColor: TPGLColorI; aSrcFactor: Byte): TPGLColorI; overload;
	function Mix(aDestColor, aSrcColor: PPGLColorI; aSrcFactor: Byte): TPGLColorI; overload;
	procedure AlphaBlend(const srccolor, dstcolor: PInteger); register; inline;

	// rects
	function RectI(aLeft, aTop, aRight, aBottom: Integer): TPGLRectI; register;
	function RectI(aCenter: TPGLVec2; aWidth, aHeight: Integer): TPGLRectI; register;
	function RectIWH(aLeft, aTop, aWidth, aHeight: Integer): TPGLRectI; register;
	function RectF(aLeft, aTop, aRight, aBottom: Single): TPGLRectF; register;
	function RectF(aCenter: TPGLVec2; aWidth, aHeight: Single): TPGLRectF; register;
	function RectFWH(aLeft, aTop, aWidth, aHeight: Single): TPGLRectF; register;


var
	RedBlueComps: Integer;
  GreenComp: Integer;

implementation

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLColorI
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLColorI.Initialize(var Color: TPGLColorI);
	begin
  	Color.R := 0;
    Color.G := 0;
    Color.B := 0;
    Color.A := 255;
  end;

procedure TPGLColorI.SetR(value:Byte);
	begin
  	fR := value;
	end;

procedure TPGLColorI.SetG(value:Byte);
	begin
  	fG := value;
	end;

procedure TPGLColorI.SetB(value:Byte);
	begin
  	fB := value;
	end;

procedure TPGLColorI.SetA(value:Byte);
	begin
  	fA := value;
	end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLColorF
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLColorF.Initialize(var Color: TPGLColorF);
	begin
  	Color.R := 0;
    Color.G := 0;
    Color.B := 0;
    Color.A := 1;
  end;

procedure TPGLColorF.SetR(value:Single);
	begin
  	fR := ClampF(value);
	end;

procedure TPGLColorF.SetG(value:Single);
	begin
  	fG := ClampF(value);
	end;

procedure TPGLColorF.SetB(value:Single);
	begin
  	fB := ClampF(value);
	end;

procedure TPGLColorF.SetA(value:Single);
	begin
  	fA := ClampF(value);
	end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLVec2
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLVec2.Initialize(var Vec: TPGLVec2);
	begin
  	Vec.X := 0;
    Vec.Y := 0;
  end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLVec3
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLVec3.Initialize(var Vec: TPGLVec3);
	begin
  	Vec.X := 0;
    Vec.Y := 0;
    Vec.Z := 0;
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLVec4
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TPGLVec4.Initialize(var Vec: TPGLVec4);
	begin
  	Vec.X := 0;
    Vec.Y := 0;
    Vec.Z := 0;
    Vec.W := 0;
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLRectI
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TPGLRectI.Create(aLeft, aTop, aRight, aBottom: Integer);
	begin
  	Self.fLeft := aLeft;
    Self.fRight := aRight;
    Self.fTop := aTop;
    Self.fBottom := aBottom;
    Self.fWidth := (aRight - aLeft) + 1;
    Self.fHeight := (aBottom - aTop) + 1;
    Self.fX := Self.fLeft + Trunc(Self.fWidth / 2);
    Self.fY := Self.fTop + Trunc(Self.fHeight / 2);
  end;

function TPGLRectI.GetCenter(): TPGLVec2;
	begin
  	Result.X := fX;
    Result.Y := fY;
  end;

function TPGLRectI.GetSize(): TPGLVec2;
	begin
  	Result.X := fWidth;
    Result.Y := fHeight;
  end;

function TPGLRectI.GetTopLeft(): TPGLVec2;
	begin
  	Result := [Self.fLeft, Self.fTop];
  end;

function TPGLRectI.GetTopRight(): TPGLVec2;
	begin
  	Result := [Self.fRight, Self.fTop];
  end;

function TPGLRectI.GetBottomLeft(): TPGLVec2;
	begin
  	Result := [Self.fLeft, Self.fBottom];
  end;

function TPGLRectI.GetBottomRight(): TPGLVec2;
	begin
  	Result := [Self.fRight, Self.fBottom];
  end;

procedure TPGLRectI.SetX(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fX - value;
    fX := Value;
    fLeft += Diff;
    fRight += Diff;
  end;

procedure TPGLRectI.SetY(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fY - value;
    fY := Value;
    fTop += Diff;
    fBottom += Diff;
  end;

procedure TPGLRectI.SetCenter(value: TPGLVec2);
var
DiffX, DiffY: Integer;
	begin
  	DiffX := fX - trunc(value.X);
    DiffY := fY - trunc(value.Y);
    fX := trunc(value.X);
    fY := trunc(value.Y);
    fLeft += DiffX;
    fRight += DiffX;
    fTop += DiffY;
    fBottom += DiffY;
  end;

procedure TPGLRectI.SetTopLeft(value: TPGLVec2);
	begin
  	SetLeft(trunc(value.x));
    SetTop(trunc(value.Y));
  end;

procedure TPGLRectI.SetTopRight(value: TPGLVec2);
	begin
  	SetRight(trunc(value.x));
    SetTop(trunc(value.Y));
  end;

procedure TPGLRectI.SetBottomLeft(value: TPGLVec2);
	begin
  	SetLeft(trunc(value.x));
    SetBottom(trunc(value.Y));
  end;

procedure TPGLRectI.SetBottomRight(value: TPGLVec2);
	begin
  	SetRight(trunc(value.x));
    SetBottom(trunc(value.Y));
  end;

procedure TPGLRectI.SetLeft(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fLeft - value;
    fLeft := value;
    fX += Diff;
    fRight += Diff;
  end;

procedure TPGLRectI.SetRight(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fRight - value;
    fRight := value;
    fX += Diff;
    fLeft += Diff;
  end;

procedure TPGLRectI.SetTop(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fTop - value;
    fTop := value;
    fY += Diff;
    fBottom += Diff;
  end;

procedure TPGLRectI.SetBottom(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fBottom - value;
    fBottom := value;
    fY += Diff;
    fTop += Diff;
  end;

procedure TPGLRectI.SetWidth(value: Integer);
	begin
  	Self.fWidth := value;
    Self.fLeft := Self.fX - trunc(Self.fWidth / 2);
    Self.fRight := Self.fLeft + Self.fWidth;
  end;

procedure TPGLRectI.SetHeight(value: Integer);
	begin
  	Self.fHeight := value;
    Self.fTop := Self.fY - trunc(Self.fHeight / 2);
    Self.fBottom := Self.fTop + Self.fHeight;
  end;

procedure TPGLRectI.SetSize(value: TPGLVec2);
	begin
  	SetWidth(trunc(value.X));
    SetHeight(trunc(value.Y));
  end;

procedure TPGLRectI.SetAnchoredWidth(aWidth: Integer; aAnchor: TPGLAnchors = ANCHOR_CENTER);
	begin

    case Ord(aAnchor) of

    	Ord(ANCHOR_LEFT):
      	begin
          Self.fWidth := aWidth;
          Self.fX := Self.fLeft + trunc(Self.fWidth / 2);
          Self.fRight := Self.fLeft + Self.fWidth;
        end;

      Ord(ANCHOR_RIGHT):
        begin
        	Self.fWidth := aWidth;
          Self.fX := Self.fRight - trunc(Self.Width / 2);
          Self.fLeft := Self.fRight - Self.fWidth;
        end;

      Else
      	begin
        	SetWidth(aWidth);
        end;

    end;

  end;

procedure TPGLRectI.SetAnchoredHeight(aHeight: Integer; aAnchor: TPGLAnchors = ANCHOR_CENTER);
	begin

    case Ord(aAnchor) of

    	Ord(ANCHOR_TOP):
      	begin
          Self.fHeight := aHeight;
          Self.fY := Self.fTop + trunc(Self.fHeight / 2);
          Self.fBottom := Self.fTop + Self.fHeight;
        end;

      Ord(ANCHOR_BOTTOM):
        begin
        	Self.fHeight := aHeight;
          Self.fY := Self.fBottom - trunc(Self.fHeight / 2);
          Self.fTop := Self.fBottom - Self.fHeight;
        end;

      Else
      	begin
        	SetHeight(aHeight);
        end;

    end;

  end;

procedure TPGLRectI.SetAnchoredSize(aWidth,aHeight: Integer; aWidthAnchor: TPGLAnchors = ANCHOR_CENTER; aHeightAnchor: TPGLAnchors = ANCHOR_CENTER);
	begin
  	SetAnchoredWidth(aWidth,aWidthAnchor);
    SetAnchoredHeight(aHeight, aHeightAnchor);
  end;


procedure TPGLRectIHelper.Crop(aBounds: TPGLRectI);
var
NewLeft, NewRight, NewTop, NewBottom: Integer;
	begin
  	NewLeft := Self.fLeft;
    NewRight := Self.fRight;
    NewTop := Self.fTop;
    NewBottom := Self.fBottom;

    if NewLeft < aBounds.Left then NewLeft := aBounds.Left;
    if NewRight > aBounds.Right then NewRight := aBounds.Right;
    if NewTop < aBounds.Top then NewTop := aBounds.Top;
    if NewBottom > aBounds.Bottom then NewBottom := aBounds.Bottom;

    Self := TPGLRectI.Create(NewLeft, NewTop, NewRight, NewBottom);
  end;


procedure TPGLRectIHelper.FitTo(aBounds: TPGLRectI);
var
Success: Boolean;
WidthPer, HeightPer: Single;
NewWidth, NewHeight: Integer;
	begin

    Success := False;
    NewWidth := Self.Width;
    NewHeight := Self.Height;

    if NewWidth < aBounds.Width then begin
      WidthPer := NewWidth * ((Self.Width / NewWidth));
      NewWidth := trunc(NewWidth * WidthPer) ;
      NewHeight := trunc(NewHeight * WidthPer);
    end;

    if NewHeight < aBounds.Height then begin
      HeightPer := NewHeight * ((Self.Height / NewHeight));
      NewHeight := trunc(NewHeight * HeightPer);
      NewWidth := trunc(NewWidth * HeightPer);
    end;

    repeat

      if NewWidth > aBounds.Width then begin
        WidthPer := aBounds.Width / NewWidth;
        NewWidth := trunc(aBounds.Width);
        NewHeight := trunc(NewHeight * WidthPer);
      end;

      if NewHeight > aBounds.Height then begin
        HeightPer := aBounds.Height / NewHeight;
        NewHeight := trunc(aBounds.Height);
        NewWidth := trunc(NewWidth * HeightPer);
      end;

      if (NewWidth <= aBounds.Width) and (NewHeight <= aBounds.Height) then begin
        Success := True;
      end;

    until Success = True;

    Self.SetSize([NewWidth,NewHeight]);

  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLRectF
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TPGLRectF.Create(aLeft, aTop, aRight, aBottom: Single);
	begin
  	Self.fLeft := aLeft;
    Self.fRight := aRight;
    Self.fTop := aTop;
    Self.fBottom := aBottom;
    Self.fWidth := aRight - aLeft;
    Self.fHeight := aBottom - aTop;
    Self.fX := Self.fLeft + (Self.fWidth / 2);
    Self.fY := Self.fTop + (Self.fHeight / 2);
  end;

function TPGLRectF.GetCenter(): TPGLVec2;
	begin
  	Result.X := fX;
    Result.Y := fY;
  end;

function TPGLRectF.GetSize(): TPGLVec2;
	begin
  	Result.X := fWidth;
    Result.Y := fHeight;
  end;

procedure TPGLRectF.SetX(value: Single);
var
Diff: Single;
	begin
  	Diff := fX - value;
    fX := Value;
    fLeft += Diff;
    fRight += Diff;
  end;

procedure TPGLRectF.SetY(value: Single);
var
Diff: Single;
	begin
  	Diff := fY - value;
    fY := Value;
    fTop += Diff;
    fBottom += Diff;
  end;

procedure TPGLRectF.SetCenter(values: TPGLVec2);
var
DiffX, DiffY: Single;
	begin
  	DiffX := fX - (values.X);
    DiffY := fY - (values.Y);
    fX := (values.X);
    fY := (values.Y);
    fLeft += DiffX;
    fRight += DiffX;
    fTop += DiffY;
    fBottom += DiffY;
  end;

procedure TPGLRectF.SetLeft(value: Single);
var
Diff: Single;
	begin
  	Diff := fLeft - value;
    fLeft := value;
    fX += Diff;
    fRight += Diff;
  end;

procedure TPGLRectF.SetRight(value: Single);
var
Diff: Single;
	begin
  	Diff := fRight - value;
    fRight := value;
    fX += Diff;
    fLeft += Diff;
  end;

procedure TPGLRectF.SetTop(value: Single);
var
Diff: Single;
	begin
  	Diff := fTop - value;
    fTop := value;
    fY += Diff;
    fBottom += Diff;
  end;

procedure TPGLRectF.SetBottom(value: Single);
var
Diff: Single;
	begin
  	Diff := fBottom - value;
    fBottom := value;
    fY += Diff;
    fTop += Diff;
  end;

procedure TPGLRectF.SetWidth(value: Single);
	begin
  	Self.fWidth := value;
    Self.fLeft := Self.fX - (self.fWidth / 2);
    Self.fRight := Self.fLeft + Self.fWidth;
  end;

procedure TPGLRectF.SetHeight(value: Single);
	begin
  	Self.fHeight := value;
    Self.fTop := Self.fY - (Self.fHeight / 2);
    Self.fBottom := Self.fTop + Self.fHeight;
  end;

procedure TPGLRectF.SetSize(values: TPGLVec2);
	begin
  	SetWidth(values.x);
    SetHeight(values.y);
  end;

procedure TPGLRectFHelper.Crop(aBounds: TPGLRectF);
var
NewLeft, NewRight, NewTop, NewBottom: Single;
	begin
  	NewLeft := Self.fLeft;
    NewRight := Self.fRight;
    NewTop := Self.fTop;
    NewBottom := Self.fBottom;

    if NewLeft < aBounds.Left then NewLeft := aBounds.Left;
    if NewRight > aBounds.Right then NewRight := aBounds.Right;
    if NewTop < aBounds.Top then NewTop := aBounds.Top;
    if NewBottom > aBounds.Bottom then NewBottom := aBounds.Bottom;

    Self := TPGLRectF.Create(NewLeft, NewTop, NewRight, NewBottom);
  end;

procedure TPGLRectFHelper.FitTo(aBounds: TPGLRectF);
var
WR, HR: Single;
NewWidth, NewHeight: Single;
	begin

    while True do begin

    	WR := Self.Width / aBounds.Width;
    	NewWidth := (Self.Width * (1/WR));
      NewHeight := (Self.Height * (1/WR));
      Self.SetSize([NewWidth, NewHeight]);

      HR := Self.Height / aBounds.Height;
      NewHeight := (Self.Height * (1/HR));
      NewWidth := (Self.Width * (1/WR));
      Self.SetSize([NewWidth, NewHeight]);

      if (NewWidth <= aBounds.Width) and (NewHeight <= aBounds.Height) then Break;

    end;

  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                       Operators
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

operator := (ColorF: TPGLColorF): TPGLColorI;
	begin
  	Result.R := ClampI(trunc(ColorF.R * 255));
    Result.G := ClampI(trunc(ColorF.G * 255));
    Result.B := ClampI(trunc(ColorF.B * 255));
    Result.A := ClampI(trunc(ColorF.A * 255));
  end;

operator := (ColorI: TPGLColorI): TPGLColorF;
	begin
  	Result.R := ClampF(ColorI.R / 255);
    Result.G := ClampF(ColorI.G / 255);
    Result.B := ClampF(ColorI.B / 255);
    Result.A := ClampF(ColorI.A / 255);
  end;

operator := (Color: DWORD): TPGLColorI;
var
Ptr: PByte;
	begin
  	Ptr := @Color;
    Result.R := ClampI(Ptr[2]);
    Result.G := ClampI(Ptr[1]);
    Result.B := ClampI(Ptr[0]);
    Result.A := ClampI(Ptr[3]);
  end;

operator := (Color: DWORD): TPGLColorF;
var
Ptr: PByte;
	begin
  	Ptr := @Color;
    Result.R := ClampF(Ptr[2] / 255);
    Result.G := ClampF(Ptr[1] / 255);
    Result.B := ClampF(Ptr[0] / 255);
    Result.A := ClampF(Ptr[3] / 255);
  end;

operator := (Values: Array of Integer): TPGLColorI;
var
len: Integer;
I: Integer;
Ptr: PByte;
	begin
    len := Length(Values);

    if len = 0 then begin
    	Result.fR := 0;
      Result.fG := 0;
      Result.fB := 0;
      Result.fA := 255;
      Exit;
    end;

    Ptr := @Result.R;
    for I := 0 to len - 1 do begin
    	Ptr[I] := ClampI(Values[I]);
    end;

  end;

operator := (Values: Array of Single): TPGLColorF;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
    len := Length(Values);

    if len = 0 then begin
    	Result.fR := 0;
      Result.fG := 0;
      Result.fB := 0;
      Result.fA := 1;
      Exit;
    end;

    Ptr := @Result.R;
    for I := 0 to len - 1 do begin
    	Ptr[I] := ClampF(Values[I]);
    end;

  end;

operator + (A,B: TPGLColorI): TPGLColorI;
	begin
  	Result.R := ClampI(A.R + B.R);
    Result.G := ClampI(A.G + B.G);
    Result.B := ClampI(A.B + B.B);
    Result.A := ClampI(A.A + B.A);
  end;

operator + (A,B: TPGLColorF): TPGLColorF;
	begin
  	Result.R := ClampF(A.R + B.R);
    Result.G := ClampF(A.G + B.G);
    Result.B := ClampF(A.B + B.B);
    Result.A := ClampF(A.A + B.A);
  end;

operator + (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
	begin
  	Result.R := ClampI(ColorI.R + Value);
    Result.G := ClampI(ColorI.G + Value);
    Result.B := ClampI(ColorI.B + Value);
    Result.A := ClampI(ColorI.A + Value);
  end;

operator + (ColorF: TPGLColorF; Value: Single): TPGLColorF;
	begin
  	Result.R := ClampF(ColorF.R + Value);
    Result.G := ClampF(ColorF.G + Value);
    Result.B := ClampF(ColorF.B + Value);
    Result.A := ClampF(ColorF.A + Value);
  end;

operator - (A,B: TPGLColorI): TPGLColorI;
	begin
  	Result.R := ClampI(A.R - B.R);
    Result.G := ClampI(A.G - B.G);
    Result.B := ClampI(A.B - B.B);
    Result.A := ClampI(A.A - B.A);
  end;

operator - (A,B: TPGLColorF): TPGLColorF;
	begin
  	Result.R := ClampF(A.R - B.R);
    Result.G := ClampF(A.G - B.G);
    Result.B := ClampF(A.B - B.B);
    Result.A := ClampF(A.A - B.A);
  end;

operator - (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
	begin
  	Result.R := ClampI(ColorI.R - Value);
    Result.G := ClampI(ColorI.G - Value);
    Result.B := ClampI(ColorI.B - Value);
    Result.A := ClampI(ColorI.A - Value);
  end;

operator - (ColorF: TPGLColorF; Value: Single): TPGLColorF;
	begin
  	Result.R := ClampF(ColorF.R - Value);
    Result.G := ClampF(ColorF.G - Value);
    Result.B := ClampF(ColorF.B - Value);
    Result.A := ClampF(ColorF.A - Value);
  end;

operator * (ColorI: TPGLColorI; Value: Single): TPGLColorI;
	begin
  	Result.R := ClampI(Trunc(ColorI.R * Value));
    Result.G := ClampI(Trunc(ColorI.G * Value));
    Result.B := ClampI(Trunc(ColorI.B * Value));
    Result.A := ClampI(Trunc(ColorI.A * Value));
  end;

operator * (ColorF: TPGLColorF; Value: Single): TPGLColorF;
	begin
  	Result.R := ClampF(ColorF.R * Value);
    Result.G := ClampF(ColorF.G * Value);
    Result.B := ClampF(ColorF.B * Value);
    Result.A := ClampF(ColorF.A * Value);
  end;

operator / (ColorI: TPGLColorI; Value: Single): TPGLColorI;
	begin
  	Result.R := ClampI(Trunc(ColorI.R / Value));
    Result.G := ClampI(Trunc(ColorI.G / Value));
    Result.B := ClampI(Trunc(ColorI.B / Value));
    Result.A := ClampI(Trunc(ColorI.A / Value));
  end;

operator / (ColorF: TPGLColorF; Value: Single): TPGLColorF;
	begin
  	Result.R := ClampF(ColorF.R / Value);
    Result.G := ClampF(ColorF.G / Value);
    Result.B := ClampF(ColorF.B / Value);
    Result.A := ClampF(ColorF.A / Value);
  end;

operator =  (A, B: TPGLColorI): Boolean;
	begin
  	Result := (A.R = B.R) and (A.G = B.G) and (A.B = B.B) and (A.A = B.A);
  end;

operator =  (A, B: TPGLColorF): Boolean;
	begin
  	Result := (A.R = B.R) and (A.G = B.G) and (A.B = B.B) and (A.A = B.A);
  end;

operator =  (ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
	begin
  	Result := (ColorI.R = trunc(ColorF.R * 255)) and (ColorI.G = trunc(ColorF.G * 255))
    and (ColorI.B = trunc(ColorF.B * 255)) and (ColorI.A = trunc(ColorF.A * 255));
  end;

operator =  (ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;
	begin
  	Result := (trunc(ColorF.R * 255) = ColorI.R) and (trunc(ColorF.G * 255) = ColorI.G)
    and (trunc(ColorF.B * 255) = ColorI.B) and (trunc(ColorF.A * 255) = ColorI.A);
  end;

{ Vectors}

operator := (Values: Array of Single): TPGLVec2;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Exit;
    end;

    if len > 2 then len := 2;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Values[I];
    end;
  end;

operator := (Values: Array of Integer): TPGLVec2;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Exit;
    end;

    if len > 2 then len := 2;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Single(Values[I]);
    end;
  end;

operator := (aVec3: TPGLVec3): TPGLVec2;
	begin
  	Result.X := aVec3.X;
    Result.Y := aVec3.Y;
  end;

operator := (aVec4: TPGLVec4): TPGLVec2;
	begin
  	Result.X := aVec4.X;
    Result.Y := aVec4.Y;
  end;

operator := (Values: Array of Single): TPGLVec3;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
      Exit;
    end;

    if len > 3 then len := 3;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Values[I];
    end;
  end;

operator := (Values: Array of Integer): TPGLVec3;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
      Exit;
    end;

    if len > 3 then len := 3;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Single(Values[I]);
    end;
  end;

operator := (aVec2: TPGLVec2): TPGLVec3;
	begin
  	Result.X := aVec2.X;
    Result.Y := aVec2.Y;
  end;

operator := (aVec4: TPGLVec4): TPGLVec3;
	begin
  	Result.X := aVec4.X;
    Result.Y := aVec4.Y;
    Result.Z := aVec4.Z;
  end;

operator := (Values: Array of Single): TPGLVec4;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
      Result.W := 0;
      Exit;
    end;

    if len > 4 then len := 4;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Values[I];
    end;
  end;

operator := (Values: Array of Integer): TPGLVec4;
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(Values);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Result.Z := 0;
      Result.W := 0;
      Exit;
    end;

    if len > 4 then len := 4;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Single(Values[I]);
    end;
  end;

operator := (aVec2: TPGLVec2): TPGLVec4;
	begin
  	Result.X := aVec2.X;
    Result.Y := aVec2.Y;
  end;

operator := (aVec3: TPGLVec3): TPGLVec4;
	begin
  	Result.X := aVec3.X;
    Result.Y := aVec3.Y;
    Result.Z := aVec3.Z;
  end;

operator := (aRect: TPGLRectF): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(trunc(aRect.Left), trunc(aRect.Top), trunc(aRect.Right), trunc(aRect.Bottom));
  end;

operator := (aRect: TPGLRectI): TPGLRectF;
	begin
  	Result := TPGLRectF.Create(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                       Functions
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

function ClampI(value: Integer): Byte;
	begin
  	Result := value;
    if value > 255 then Exit(255);
    if value < 0 then Exit(0);
  end;

function ClampF(value: Single): Single;
	begin
  	Result := value;
    if value > 1 then Exit(1);
    if value < 0 then Exit(0);
  end;

procedure ClampVarI(var value: Integer);
	begin
  	if value > 255 then begin value := 255; exit; end;
    if value < 0 then begin value := 0; exit; end;
  end;

procedure ClampVarF(var value: Single);
	begin
  	if value > 1 then begin value := 1; exit; end;
    if value < 0 then begin value := 0; exit; end;
  end;

function ColorI(aRed, aGreen, aBlue: Byte; aAlpha: Byte = 255): TPGLColorI;
	begin
  	Result.fR := aRed;
    Result.fG := aGreen;
    Result.fB := aBlue;
    Result.fA := aAlpha;
  end;

function ColorF(aRed, aGreen, aBlue: Single; aAlpha: Single = 1.0): TPGLColorF;
	begin
  	Result.fR := ClampF(aRed);
    Result.fG := ClampF(aGreen);
    Result.fB := ClampF(aBlue);
    Result.fA := ClampF(aAlpha)
  end;

function Mix(aDestColor, aSrcColor: TPGLColorF; aSrcFactor: Single): TPGLColorF;
var
SF, DF: Single;
	begin
    SF := ClampF(aSrcFactor);
    DF := 1 - SF;
  	Result.fR := (aDestColor.fR * DF) + (aSrcColor.fR * SF);
    Result.fG := (aDestColor.fG * DF) + (aSrcColor.fG * SF);
    Result.fB := (aDestColor.fB * DF) + (aSrcColor.fB * SF);
    Result.fA := 1;
  end;

function Mix(aDestColor, aSrcColor: TPGLColorI; aSrcFactor: Byte): TPGLColorI;
var
SF, DF: Single;
	begin
    SF := 1 * (aSrcFactor / 255);
    DF := 1 - SF;
  	Result.fR := trunc((aDestColor.fR * DF) + (aSrcColor.fR * SF));
    Result.fG := trunc((aDestColor.fG * DF) + (aSrcColor.fG * SF));
    Result.fB := trunc((aDestColor.fB * DF) + (aSrcColor.fB * SF));
    Result.fA := 255;
  end;

function Mix(aDestColor, aSrcColor: PPGLColorI; aSrcFactor: Byte): TPGLColorI;
var
SF, DF: Single;
	begin
    SF := 1 * (aSrcFactor / 255);
    DF := 1 - SF;
  	Result.fR := trunc((aDestColor^.fR * DF) + (aSrcColor^.fR * SF));
    Result.fG := trunc((aDestColor^.fG * DF) + (aSrcColor^.fG * SF));
    Result.fB := trunc((aDestColor^.fB * DF) + (aSrcColor^.fB * SF));
    Result.fA := 255;
  end;

procedure AlphaBlend(const srccolor, dstcolor: PInteger);
var
Alpha: Byte;
	begin
	  Alpha := 255 - (srccolor^ shr 24);

		RedBlueComps := srccolor^ and $ff00ff;
		GreenComp := srccolor^ and $00ff00;
		RedBlueComps += ((dstcolor^ and $ff00ff) - RedBlueComps) * Alpha shr 8;
		GreenComp += ((dstcolor^ and $00ff00) - GreenComp) * Alpha shr 8;
		dstcolor^ := $ff000000 or (RedBlueComps and $ff00ff) or (GreenComp and $ff00);
	end;

function RectI(aLeft, aTop, aRight, aBottom: Integer): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(aLeft, aTop, aRight, aBottom);
  end;

function RectI(aCenter: TPGLVec2; aWidth, aHeight: Integer): TPGLRectI;
	begin
  	Result.fX := trunc(aCenter.X);
    Result.fY := trunc(aCenter.Y);
    Result.fWidth := aWidth;
    Result.fHeight := aHeight;
    Result.fLeft := Result.fX - trunc(aWidth / 2);
    Result.fTop := Result.fY - trunc(aHeight / 2);
    Result.fRight := Result.fLeft + (aWidth);
    Result.fBottom := Result.fTop + (aHeight);
  end;

function RectIWH(aLeft, aTop, aWidth, aHeight: Integer): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(aLeft, aTop, aLeft + (aWidth - 1), aTop + (aHeight - 1));
  end;

function RectF(aLeft, aTop, aRight, aBottom: Single): TPGLRectF;
	begin
  	Result := TPGLRectF.Create(aLeft, aTop, aRight, aBottom);
  end;

function RectF(aCenter: TPGLVec2; aWidth, aHeight: Single): TPGLRectF;
	begin
  	Result.fX := (aCenter.X);
    Result.fY := (aCenter.Y);
    Result.fWidth := aWidth;
    Result.fHeight := aHeight;
    Result.fLeft := Result.fX - trunc(aWidth / 2);
    Result.fTop := Result.fY - trunc(aHeight / 2);
    Result.fRight := Result.fLeft + (aWidth);
    Result.fBottom := Result.fTop + (aHeight);
  end;

function RectFWH(aLeft, aTop, aWidth, aHeight: Single): TPGLRectF;
	begin
  	Result := TPGLRectF.Create(aLeft, aTop, aLeft + (aWidth - 1), aTop + (aHeight - 1))
  end;



end.

