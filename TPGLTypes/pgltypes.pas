unit pgltypes;

{$ifdef FPC}
  {$mode OBJFPC}{$H+}
  {$modeswitch ADVANCEDRECORDS}
  {$modeswitch OUT}
  {$macro ON}
  {$DEFINE RELEASE_INLINE :=
	  {$IFOPT D+}  {$ELSE} inline; {$ENDIF}
	}
{$else}
  {$POINTERMATH ON}
{$endif}

{$DEFINE PGL_RGB}



interface

uses
  Classes, SysUtils, Math;

type

  TPGLAnchors = (ANCHOR_CENTER = 0, ANCHOR_LEFT = 1, ANCHOR_TOP = 2, ANCHOR_RIGHT = 3, ANCHOR_BOTTOM = 4);

	{ TPGLColorI }

	PPGLColorI = ^TPGLColorI;
	TPGLColorI = record
	  private
	    fR,fG,fB,fA: Byte;

	  	procedure SetR(value: Byte);
	    procedure SetG(value: Byte);
	    procedure SetB(value: Byte);
	    procedure SetA(value: Byte);

	  public
	  	property R: Byte read fR write SetR;
	    property G: Byte read fG write SetG;
	    property B: Byte read fB write SetB;
	    property A: Byte read fA write SetA;

      // different operator definitions for FPC and Delpi
      {$ifdef FPC}
		    class operator Initialize(var Color: TPGLColorI);
	      class operator := (Color: UINT32): TPGLColorI;
	      class operator := (Values: Array of Integer): TPGLColorI;
				class operator +  (ColorA,ColorB: TPGLColorI): TPGLColorI;
				class operator +  (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
				class operator -  (ColorA,ColorB: TPGLColorI): TPGLColorI;
				class operator -  (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
				class operator *  (ColorI: TPGLColorI; Value: Single): TPGLColorI;
				class operator /  (ColorI: TPGLColorI; Value: Single): TPGLColorI;
				class operator =  (ColorA, ColorB: TPGLColorI): Boolean;
      {$else}
        class operator Initialize(out Color: TPGLColorI);
	      class operator Implicit(Color: UINT32): TPGLColorI;
	      class operator Implicit(Values: Array of Integer): TPGLColorI;
				class operator Add(ColorA,ColorB: TPGLColorI): TPGLColorI;
				class operator Add(ColorI: TPGLColorI; Value: Integer): TPGLColorI;
				class operator Subtract(ColorA,ColorB: TPGLColorI): TPGLColorI;
				class operator Subtract(ColorI: TPGLColorI; Value: Integer): TPGLColorI;
				class operator Multiply(ColorI: TPGLColorI; Value: Single): TPGLColorI;
				class operator Divide(ColorI: TPGLColorI; Value: Single): TPGLColorI;
				class operator Equal(ColorA, ColorB: TPGLColorI): Boolean;
      {$endif}

  end;

	{ TPGLColorF }

  PPGLColorF = ^TPGLColorF;
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

      {$ifdef FPC}
		    class operator Initialize(var Color: TPGLColorF);
	      class operator := (Color: UINT32): TPGLColorF;
				class operator := (Values: Array of Single): TPGLColorF;
				class operator +  (ColorA,ColorB: TPGLColorF): TPGLColorF;
				class operator +  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator -  (ColorA,ColorB: TPGLColorF): TPGLColorF;
				class operator -  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator *  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator /  (ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator =  (ColorA, ColorB: TPGLColorF): Boolean;
      {$else}
	      class operator Initialize(out Color: TPGLColorF);
	      class operator Implicit(Color: UINT32): TPGLColorF;
				class operator Implicit(Values: Array of Single): TPGLColorF;
				class operator Add(ColorA,ColorB: TPGLColorF): TPGLColorF;
				class operator Add(ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator Subtract(ColorA,ColorB: TPGLColorF): TPGLColorF;
				class operator Subtract(ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator Multiply(ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator Divide(ColorF: TPGLColorF; Value: Single): TPGLColorF;
				class operator Equal(ColorA, ColorB: TPGLColorF): Boolean;
      {$endif}
  end;

	{ TPGLVec2 }

	TPGLVec2 = record
	  public
	  	X,Y: Single;

      {$ifdef FPC}
	  	  class operator Initialize(var Vec: TPGLVec2);
        class operator := (const aValues: Array of Single): TPGLVec2;
        class operator := (const aValues: Array of Integer): TPGLVec2;
      {$else}
        class operator Initialize(out Vec: TPGLVec2);
        class operator Implicit(const aValues: Array of Single): TPGLVec2;
        class operator Implicit(const aValues: Array of Integer): TPGLVec2;
      {$endif}

  end;

	{ TPGLVec3 }

  PPGLVec3 = ^TPGLVec3;
	TPGLVec3 = record
	  public
	  	X,Y,Z: Single;

      {$ifdef FPC}
				class operator Initialize(var Vec: TPGLVec3);
				class operator := (Values: Array of Single): TPGLVec3;
				class operator := (Values: Array of Integer): TPGLVec3;
      {$else}
        class operator Initialize(out Vec: TPGLVec3);
				class operator Implicit(Values: Array of Single): TPGLVec3;
				class operator Implicit(Values: Array of Integer): TPGLVec3;
      {$endif}
	end;

	{ TPGLVec4 }

	TPGLVec4 = record
		public
	  	X,Y,Z,W: Single;

      {$ifdef FPC}
				class operator Initialize(var Vec: TPGLVec4);
				class operator := (Values: Array of Single): TPGLVec4;
				class operator := (Values: Array of Integer): TPGLVec4;
        class operator := (Color: TPGLColorF): TPGLVec4;
        class operator + (aVec1, aVec2: TPGLVec4): TPGLVec4;
        class operator - (aVec1, aVec2: TPGLVec4): TPGLVec4;
        class operator * (aVec: TPGLVec4; aValue: Single): TPGLVec4;
        class operator / (aVec: TPGLVec4; aValue: Single): TPGLVec4;
      {$else}
				class operator Initialize(out Vec: TPGLVec4);
				class operator Implicit(Values: Array of Single): TPGLVec4;
				class operator Implicit(Values: Array of Integer): TPGLVec4;
      {$endif}
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
      procedure Crop(aBounds: TPGLRectI);
      procedure FitTo(aBounds: TPGLRectI);

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

      procedure Crop(aBounds: TPGLRectF);
      procedure FitTo(aBounds: TPGLRectF);
	end;


  TPGLColorIHelper = record helper for TPGLColorI
  {$ifndef FPC}
  	class operator Implicit(ColorF: TPGLColorF): TPGLColorI;
    class operator Equal(ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
  {$endif}
  end;


  TPGLColorFHelper = record helper for TPGLColorF
  {$ifndef FPC}
    class operator Implicit(ColorI: TPGLColorI): TPGLColorF;
    class operator Equal(ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;
  {$endif}
  end;


  TPGLVec2Helper = record helper for TPGLVec2
  {$ifndef FPC}
    class operator Implicit(aVec3: TPGLVec3): TPGLVec2;
    class operator Implicit(aVec4: TPGLVec4): TPGLVec2;
  {$endif}
  end;


  TPGLVec3Helper = record helper for TPGLVec3
  {$ifndef FPC}
    class operator Implicit(aVec2: TPGLVec2): TPGLVec3;
    class operator Implicit(aVec4: TPGLVec4): TPGLVec3;
  {$endif}
  end;


  TPGLVec4Helper = record helper for TPGLVec4
  {$ifndef FPC}
    class operator Implicit(aVec2: TPGLVec2): TPGLVec4;
    class operator Implicit(aVec3: TPGLVec3): TPGLVec4;
  {$endif}
  end;


  TPGLRectIHelper = record helper for TPGLRectI
  {$ifndef FPC}
    class operator Implicit(aRect: TPGLRectF): TPGLRectI;
  {$endif}
  end;


  TPGLRectFHelper = record helper for TPGLRectF
  {$ifndef FPC}
    class operator Implicit(aRect: TPGLRectI): TPGLRectF;
  {$endif}
  end;

(*//////////////////////////////////////////////////////////////////////////////////)
                                     Operators
(//////////////////////////////////////////////////////////////////////////////////*)

{$REGION Operators}

	(* Operators Dependant on Other Types. Only for FFPC *)

  {$ifdef FPC}

   { Colors }
	operator := (ColorF: TPGLColorF): TPGLColorI;
  operator := (Color: TPGLVec4): TPGLColorI;
  operator =  (ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
  operator + (Color1, Color2: TPGLColorI): TPGLVec4;
  operator - (Color1, Color2: TPGLColorI): TPGLVec4;

  operator := (ColorI: TPGLColorI): TPGLColorF;
  operator := (Color: TPGLVec4): TPGLColorF;
  operator =  (ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;
  operator + (Color1, Color2: TPGLColorF): TPGLVec4;
  operator - (Color1, Color2: TPGLColorF): TPGLVec4;

   { Vectors }
  operator := (aVec3: TPGLVec3): TPGLVec2;
  operator := (aVec4: TPGLVec4): TPGLVec2;

  operator := (aVec2: TPGLVec2): TPGLVec3;
  operator := (aVec4: TPGLVec4): TPGLVec3;

  operator := (aVec2: TPGLVec2): TPGLVec4;
  operator := (aVec3: TPGLVec3): TPGLVec4;

  { Rects }
  operator := (aRect: TPGLRectF): TPGLRectI;

  operator := (aRect: TPGLRectI): TPGLRectF;

  {$endif}

{$ENDREGION}

	// clamping
	function ClampI(const value: Integer): Byte; overload;
	function ClampF(const value: Single): Single; overload;

	procedure ClampVarI(var value: Integer);
	procedure ClampVarF(var value: Single);

	// colors
	function ColorI(const aRed, aGreen, aBlue: Byte; aAlpha: Byte = 255): TPGLColorI;
	function ColorF(const aRed, aGreen, aBlue: Single; aAlpha: Single = 1.0): TPGLColorF;
	function MixF(const aDestColor, aSrcColor: TPGLColorF; aSrcFactor: Single): TPGLColorF; overload;
	function MixI(const aDestColor, aSrcColor: TPGLColorI; aSrcFactor: Byte): TPGLColorI; overload;
	function MixP(const aDestColor, aSrcColor: PPGLColorI; aSrcFactor: Byte): TPGLColorI; overload;
	procedure AlphaBlend(const srccolor, dstcolor: Pointer); RELEASE_INLINE

	// rects
	function RectI(const aLeft, aTop, aRight, aBottom: Integer): TPGLRectI;
	function RectIC(const aCenter: TPGLVec2; aWidth, aHeight: Integer): TPGLRectI;
	function RectIWH(const aLeft, aTop, aWidth, aHeight: Integer): TPGLRectI;
	function RectF(const aLeft, aTop, aRight, aBottom: Single): TPGLRectF;
	function RectFC(const aCenter: TPGLVec2; aWidth, aHeight: Single): TPGLRectF;
	function RectFWH(const aLeft, aTop, aWidth, aHeight: Single): TPGLRectF;

  // vectors
  function Vec2(const aX, aY: Single): TPGLVec2;
  function Vec3(const aX, aY, aZ: Single): TPGLVec3;
  function Vec4(const aX, aY, aZ, aW: Single): TPGLVec4;

  // math
  function Distance(const Vec1, Vec2: TPGLVec3): Single; RELEASE_INLINE
  function Angle(const Vec1, Vec2: TPGLVec2): Single; RELEASE_INLINE
  function AnglePoint(const aStartVec: TPGLVec2; const aAngle: Single; const aDist: Single): TPGLVec2; RELEASE_INLINE
  function EdgeTest(const P1, P2, TestPoint: TPGLVec2): Single; RELEASE_INLINE
  function Mins(const aVec1, aVec2: TPGLVec3): TPGLVec3; overload; RELEASE_INLINE
  function Mins(const aVec1, aVec2, aVec3: TPGLVec3): TPGLVec3; overload; RELEASE_INLINE
  function Mins(const Arr: Array of TPGLVec3): TPGLVec3; overload; RELEASE_INLINE
  function Maxes(const aVec1, aVec2: TPGLVec3): TPGLVec3; overload; RELEASE_INLINE
  function Maxes(const aVec1, aVec2, aVec3: TPGLVec3): TPGLVec3; overload; RELEASE_INLINE
  function Maxes(const Arr: Array of TPGLVec3): TPGLVec3; overload; RELEASE_INLINE

var
	RedBlueComps: UINT32;
  GreenComp: UINT32;
  BlendDstPtr, BlendSrcPtr: PUINT32;


 const
   // colors Integer
  pgl_empty: TPGLColorI =         (fR: 0; fG: 0; fB: 0; fA: 0);
  pgl_white: TPGLColorI =         (fR: 255; fG: 255; fB: 255; fA: 255);
  pgl_black: TPGLColorI =         (fR: 0; fG: 0; fB: 0; fA: 255);

  pgl_grey: TPGLColorI =          (fR: 128; fG: 128; fB: 128; fA: 255);
  pgl_light_grey: TPGLColorI =    (fR: 75; fG: 75; fB: 75; fA: 255);
  pgl_dark_grey: TPGLColorI =     (fR: 225; fG: 225; fB: 225; fA: 255);

  pgl_red: TPGLColorI =           (fR: 255; fG: 0; fB: 0; fA: 255);
  pgl_ligh_red: TPGLColorI =      (fR: 255; fG: 125; fB: 128; fA: 255);
  pgl_dark_red: TPGLColorI =      (fR: 128; fG: 0; fB: 0; fA: 255);

  pgl_yellow: TPGLColorI =        (fR: 255; fG: 255; fB: 0; fA: 255);
  pgl_light_yellow: TPGLColorI =  (fR: 255; fG: 255; fB: 128; fA: 255);
  pgl_dark_yellow: TPGLColorI =   (fR: 128; fG: 128; fB: 0; fA: 255);

  pgl_blue: TPGLColorI =          (fR: 0; fG: 0; fB: 255; fA: 255);
  pgl_light_blue: TPGLColorI =    (fR: 128; fG: 128; fB: 255; fA: 255);
  pgl_dark_blue: TPGLColorI =     (fR: 0; fG: 0; fB: 128; fA: 255);

  pgl_green: TPGLColorI =         (fR: 0; fG: 255; fB: 0; fA: 255);
  pgl_light_green: TPGLColorI =   (fR: 128; fG: 255; fB: 128; fA: 255);
  pgl_dark_green: TPGLColorI =    (fR: 0; fG: 128; fB: 0; fA: 255);

  pgl_orange: TPGLColorI =        (fR: 255; fG: 128; fB: 0; fA: 255);
  pgl_light_orange: TPGLColorI =  (fR: 255; fG: 190; fB: 128; fA: 255);
  pgl_dark_orange: TPGLColorI =   (fR: 128; fG: 64; fB: 0; fA: 255);

  pgl_brown: TPGLColorI =         (fR: 128; fG: 64; fB: 0; fA: 255);
  pgl_light_brown: TPGLColorI =   (fR: 180; fG: 90; fB: 0; fA: 255);
  pgl_dark_brown: TPGLColorI =    (fR: 96; fG: 48; fB: 0; fA: 255);

  pgl_purple: TPGLColorI =        (fR: 128; fG: 0; fB: 128; fA: 255);
  pgl_cyan: TPGLColorI =          (fR: 0; fG: 255; fB: 255; fA: 255);
  pgl_magenta: TPGLColorI =       (fR: 255; fG: 0; fB: 255; fA: 255);
  pgl_pink: TPGLColorI =          (fR: 255; fG: 196; fB: 196; fA: 255);

  // colors float
  pgl_empty_f: TPGLColorF =         (fR: 0 / 255; fG: 0 / 255; fB: 0 / 255; fA: 0 / 255);
  pgl_white_f: TPGLColorF =         (fR: 255 / 255; fG: 255 / 255; fB: 255 / 255; fA: 255 / 255);
  pgl_black_f: TPGLColorF =         (fR: 0 / 255; fG: 0 / 255; fB: 0 / 255; fA: 255 / 255);

  pgl_grey_f: TPGLColorF =          (fR: 128 / 255;  fG: 128 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_light_grey_f: TPGLColorF =    (fR: 75 / 255;  fG: 75 / 255;  fB: 75 / 255;  fA: 255 / 255);
  pgl_dark_grey_f: TPGLColorF =     (fR: 225 / 255;  fG: 225 / 255;  fB: 225 / 255;  fA: 255 / 255);

  pgl_red_f: TPGLColorF =           (fR: 255 / 255;  fG: 0 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_ligh_red_f: TPGLColorF =      (fR: 255 / 255;  fG: 125 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_dark_red_f: TPGLColorF =      (fR: 128 / 255;  fG: 0 / 255;  fB: 0 / 255;  fA: 255 / 255);

  pgl_yellow_f: TPGLColorF =        (fR: 255 / 255;  fG: 255 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_light_yellow_f: TPGLColorF =  (fR: 255 / 255;  fG: 255 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_dark_yellow_f: TPGLColorF =   (fR: 128 / 255;  fG: 128 / 255;  fB: 0 / 255;  fA: 255 / 255);

  pgl_blue_f: TPGLColorF =          (fR: 0 / 255;  fG: 0 / 255;  fB: 255 / 255;  fA: 255 / 255);
  pgl_light_blue_f: TPGLColorF =    (fR: 128 / 255;  fG: 128 / 255;  fB: 255 / 255;  fA: 255 / 255);
  pgl_dark_blue_f: TPGLColorF =     (fR: 0 / 255;  fG: 0 / 255;  fB: 128 / 255;  fA: 255 / 255);

  pgl_green_f: TPGLColorF =         (fR: 0 / 255;  fG: 255 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_light_green_f: TPGLColorF =   (fR: 128 / 255;  fG: 255 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_dark_green_f: TPGLColorF =    (fR: 0 / 255;  fG: 128 / 255;  fB: 0 / 255;  fA: 255 / 255);

  pgl_orange_f: TPGLColorF =        (fR: 255 / 255;  fG: 128 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_light_orange_f: TPGLColorF =  (fR: 255 / 255;  fG: 190 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_dark_orange_f: TPGLColorF =   (fR: 128 / 255;  fG: 64 / 255;  fB: 0 / 255;  fA: 255 / 255);

  pgl_brown_f: TPGLColorF =         (fR: 128 / 255;  fG: 64 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_light_brown_f: TPGLColorF =   (fR: 180 / 255;  fG: 90 / 255;  fB: 0 / 255;  fA: 255 / 255);
  pgl_dark_brown_f: TPGLColorF =    (fR: 96 / 255;  fG: 48 / 255;  fB: 0 / 255;  fA: 255 / 255);

  pgl_purple_f: TPGLColorF =        (fR: 128 / 255;  fG: 0 / 255;  fB: 128 / 255;  fA: 255 / 255);
  pgl_cyan_f: TPGLColorF =          (fR: 0 / 255;  fG: 255 / 255;  fB: 255 / 255;  fA: 255 / 255);
  pgl_magenta_f: TPGLColorF =       (fR: 255 / 255;  fG: 0 / 255;  fB: 255 / 255;  fA: 255 / 255);
  pgl_pink_f: TPGLColorF =          (fR: 255 / 255;  fG: 196 / 255;  fB: 196 / 255;  fA: 255 / 255);

implementation

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLColorI
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

{$ifdef FPC}
class operator TPGLColorI.Initialize(var Color: TPGLColorI);
{$else}
class operator TPGLColorI.Initialize(out Color: TPGLColorI);
{$endif}
	begin
  	Color.R := 0;
    Color.G := 0;
    Color.B := 0;
    Color.A := 255;
  end;


{$ifdef FPC}
class operator TPGLColorI.:= (Color: UINT32): TPGLColorI;
{$else}
class operator TPGLColorI.Implicit(Color: UINT32): TPGLColorI;
{$endif}
var
Ptr: PByte;
	begin
  	Ptr := @Color;
    Result.R := ClampI(Ptr[2]);
    Result.G := ClampI(Ptr[1]);
    Result.B := ClampI(Ptr[0]);
    Result.A := ClampI(Ptr[3]);
  end;


{$ifdef FPC}
class operator TPGLColorI.:= (Values: Array of Integer): TPGLColorI;
{$else}
class operator TPGLColorI.Implicit(Values: Array of Integer): TPGLColorI;
{$endif}
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


{$ifdef FPC}
class operator TPGLColorI.+ (ColorA,ColorB: TPGLColorI): TPGLColorI;
{$else}
class operator TPGLColorI.Add(ColorA,ColorB: TPGLColorI): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(ColorA.R + ColorB.R);
    Result.G := ClampI(ColorA.G + ColorB.G);
    Result.B := ClampI(ColorA.B + ColorB.B);
    Result.A := ClampI(ColorA.A + ColorB.A);
  end;


{$ifdef FPC}
class operator TPGLColorI.+ (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
{$else}
class operator TPGLColorI.Add(ColorI: TPGLColorI; Value: Integer): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(ColorI.R + Value);
    Result.G := ClampI(ColorI.G + Value);
    Result.B := ClampI(ColorI.B + Value);
    Result.A := ClampI(ColorI.A + Value);
  end;


{$ifdef FPC}
class operator TPGLColorI.- (ColorA,ColorB: TPGLColorI): TPGLColorI;
{$else}
class operator TPGLColorI.Subtract(ColorA,ColorB: TPGLColorI): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(ColorA.R - ColorB.R);
    Result.G := ClampI(ColorA.G - ColorB.G);
    Result.B := ClampI(ColorA.B - ColorB.B);
    Result.A := ClampI(ColorA.A - ColorB.A);
  end;


{$ifdef FPC}
class operator TPGLColorI.- (ColorI: TPGLColorI; Value: Integer): TPGLColorI;
{$else}
class operator TPGLColorI.Subtract(ColorI: TPGLColorI; Value: Integer): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(ColorI.R - Value);
    Result.G := ClampI(ColorI.G - Value);
    Result.B := ClampI(ColorI.B - Value);
    Result.A := ClampI(ColorI.A - Value);
  end;


{$ifdef FPC}
class operator TPGLColorI.* (ColorI: TPGLColorI; Value: Single): TPGLColorI;
{$else}
class operator TPGLColorI.Multiply(ColorI: TPGLColorI; Value: Single): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(Trunc(ColorI.R * Value));
    Result.G := ClampI(Trunc(ColorI.G * Value));
    Result.B := ClampI(Trunc(ColorI.B * Value));
    Result.A := ClampI(Trunc(ColorI.A * Value));
  end;


{$ifdef FPC}
class operator TPGLColorI./ (ColorI: TPGLColorI; Value: Single): TPGLColorI;
{$else}
class operator TPGLColorI.Divide(ColorI: TPGLColorI; Value: Single): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(Trunc(ColorI.R / Value));
    Result.G := ClampI(Trunc(ColorI.G / Value));
    Result.B := ClampI(Trunc(ColorI.B / Value));
    Result.A := ClampI(Trunc(ColorI.A / Value));
  end;


{$ifdef FPC}
class operator TPGLColorI.=  (ColorA, ColorB: TPGLColorI): Boolean;
{$else}
class operator TPGLColorI.Equal(ColorA, ColorB: TPGLColorI): Boolean;
{$endif}
	begin
  	Result := (ColorA.R = ColorB.R) and (ColorA.G = ColorB.G) and (ColorA.B = ColorB.B) and (ColorA.A = ColorB.A);
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
{$ifdef FPC}
class operator TPGLColorF.Initialize(var Color: TPGLColorF);
{$else}
class operator TPGLColorF.Initialize(out Color: TPGLColorF);
{$endif}
	begin
  	Color.R := 0;
    Color.G := 0;
    Color.B := 0;
    Color.A := 1;
  end;

{$ifdef FPC}
class operator TPGLColorF.:= (Color: UINT32): TPGLColorF;
{$else}
class operator TPGLColorF.Implicit(Color: UINT32): TPGLColorF;
{$endif}
var
Ptr: PByte;
	begin
  	Ptr := @Color;
    Result.R := ClampF(Ptr[2] / 255);
    Result.G := ClampF(Ptr[1] / 255);
    Result.B := ClampF(Ptr[0] / 255);
    Result.A := ClampF(Ptr[3] / 255);
  end;

{$ifdef FPC}
class operator TPGLColorF.:= (Values: Array of Single): TPGLColorF;
{$else}
class operator TPGLColorF.Implicit(Values: Array of Single): TPGLColorF;
{$endif}
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

{$ifdef FPC}
class operator TPGLColorF.+ (ColorA,ColorB: TPGLColorF): TPGLColorF;
{$else}
class operator TPGLColorF.Add(ColorA,ColorB: TPGLColorF): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorA.R + ColorB.R);
    Result.G := ClampF(ColorA.G + ColorB.G);
    Result.B := ClampF(ColorA.B + ColorB.B);
    Result.A := ClampF(ColorA.A + ColorB.A);
  end;

{$ifdef FPC}
class operator TPGLColorF.+ (ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$else}
class operator TPGLColorF.Add(ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorF.R + Value);
    Result.G := ClampF(ColorF.G + Value);
    Result.B := ClampF(ColorF.B + Value);
    Result.A := ClampF(ColorF.A + Value);
  end;

{$ifdef FPC}
class operator TPGLColorF.- (ColorA,ColorB: TPGLColorF): TPGLColorF;
{$else}
class operator TPGLColorF.Subtract(ColorA,ColorB: TPGLColorF): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorA.R - ColorB.R);
    Result.G := ClampF(ColorA.G - ColorB.G);
    Result.B := ClampF(ColorA.B - ColorB.B);
    Result.A := ClampF(ColorA.A - ColorB.A);
  end;

{$ifdef FPC}
class operator TPGLColorF.- (ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$else}
class operator TPGLColorF.Subtract(ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorF.R - Value);
    Result.G := ClampF(ColorF.G - Value);
    Result.B := ClampF(ColorF.B - Value);
    Result.A := ClampF(ColorF.A - Value);
  end;

{$ifdef FPC}
class operator TPGLColorF.* (ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$else}
class operator TPGLColorF.Multiply(ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorF.R * Value);
    Result.G := ClampF(ColorF.G * Value);
    Result.B := ClampF(ColorF.B * Value);
    Result.A := ClampF(ColorF.A * Value);
  end;

{$ifdef FPC}
class operator TPGLColorF./ (ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$else}
class operator TPGLColorF.Divide(ColorF: TPGLColorF; Value: Single): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorF.R / Value);
    Result.G := ClampF(ColorF.G / Value);
    Result.B := ClampF(ColorF.B / Value);
    Result.A := ClampF(ColorF.A / Value);
  end;

{$ifdef FPC}
class operator TPGLColorF.=  (ColorA, ColorB: TPGLColorF): Boolean;
{$else}
class operator TPGLColorF.Equal(ColorA, ColorB: TPGLColorF): Boolean;
{$endif}
	begin
  	Result := (ColorA.R = ColorB.R) and (ColorA.G = ColorB.G) and (ColorA.B = ColorB.B) and (ColorA.A = ColorB.A);
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

{$ifdef FPC}
class operator TPGLVec2.Initialize(var Vec: TPGLVec2);
{$else}
class operator TPGLVec2.Initialize(out Vec: TPGLVec2);
{$endif}
	begin
  	Vec.X := 0;
    Vec.Y := 0;
  end;

{$ifdef FPC}
class operator TPGLVec2.:=(const aValues: Array of Single): TPGLVec2;
{$else}
class operator TPGLVec2.Implicit(const aValues: Array of Single): TPGLVec2;
{$endif}
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(aValues);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Exit;
    end;

    if len > 2 then len := 2;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := aValues[I];
    end;
  end;

{$ifdef FPC}
class operator TPGLVec2.:=(const aValues: Array of Integer): TPGLVec2;
{$else}
class operator TPGLVec2.Implicit(const aValues: Array of Integer): TPGLVec2;
{$endif}
var
len: Integer;
I: Integer;
Ptr: PSingle;
	begin
  	len := Length(aValues);
    if len = 0 then begin
    	Result.X := 0;
      Result.Y := 0;
      Exit;
    end;

    if len > 2 then len := 2;

    Ptr := @Result;

    for I := 0 to len - 1 do begin
    	Ptr[I] := Single(aValues[I]);
    end;
  end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLVec3
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

{$ifdef FPC}
class operator TPGLVec3.Initialize(var Vec: TPGLVec3);
{$else}
class operator TPGLVec3.Initialize(out Vec: TPGLVec3);
{$endif}
	begin
  	Vec.X := 0;
    Vec.Y := 0;
    Vec.Z := 0;
  end;

{$ifdef FPC}
class operator TPGLVec3.:= (Values: Array of Single): TPGLVec3;
{$else}
class operator TPGLVec3.Implicit(Values: Array of Single): TPGLVec3;
{$endif}
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

{$ifdef FPC}
class operator TPGLVec3.:= (Values: Array of Integer): TPGLVec3;
{$else}
class operator TPGLVec3.Implicit(Values: Array of Integer): TPGLVec3;
{$endif}
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

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TPGLVec4
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

{$ifdef FPC}
class operator TPGLVec4.Initialize(var Vec: TPGLVec4);
{$else}
class operator TPGLVec4.Initialize(out Vec: TPGLVec4);
{$endif}
	begin
  	Vec.X := 0;
    Vec.Y := 0;
    Vec.Z := 0;
    Vec.W := 0;
  end;

{$ifdef FPC}
class operator TPGLVec4.:= (Values: Array of Single): TPGLVec4;
{$else}
class operator TPGLVec4.Implicit(Values: Array of Single): TPGLVec4;
{$endif}
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

{$ifdef FPC}
class operator TPGLVec4.:= (Values: Array of Integer): TPGLVec4;
{$else}
class operator TPGLVec4.Implicit(Values: Array of Integer): TPGLVec4;
{$endif}
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


class operator TPGLVec4.:= (Color: TPGLColorF): TPGLVec4;
  begin
    Result.X := Color.R;
    Result.Y := Color.G;
    Result.Z := Color.B;
    Result.W := Color.A;
  end;


class operator TPGLVec4.+ (aVec1, aVec2: TPGLVec4): TPGLVec4;
  begin
    Result.X := aVec1.X + aVec2.X;
    Result.Y := aVec1.Y + aVec2.Y;
    Result.Z := aVec1.Z + aVec2.Z;
    Result.W := aVec1.W + aVec2.W;
  end;

class operator TPGLVec4.- (aVec1, aVec2: TPGLVec4): TPGLVec4;
  begin
    Result.X := aVec1.X - aVec2.X;
    Result.Y := aVec1.Y - aVec2.Y;
    Result.Z := aVec1.Z - aVec2.Z;
    Result.W := aVec1.W - aVec2.W;
  end;

class operator TPGLVec4.* (aVec: TPGLVec4; aValue: Single): TPGLVec4;
  begin
    Result.X := aVec.X * aValue;
    Result.Y := aVec.Y * aValue;
    Result.Z := aVec.Z * aValue;
    Result.W := aVec.W * aValue;
  end;

class operator TPGLVec4./ (aVec: TPGLVec4; aValue: Single): TPGLVec4;
  begin
    Result.X := aVec.X / aValue;
    Result.Y := aVec.Y / aValue;
    Result.Z := aVec.Z / aValue;
    Result.W := aVec.W / aValue;
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
    fLeft := fLeft + Diff;
    fRight := fRight + Diff;
  end;

procedure TPGLRectI.SetY(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fY - value;
    fY := Value;
    fTop := fTop + Diff;
    fBottom := fTop + Diff;
  end;

procedure TPGLRectI.SetCenter(value: TPGLVec2);
var
DiffX, DiffY: Integer;
	begin
  	DiffX := fX - trunc(value.X);
    DiffY := fY - trunc(value.Y);
    fX := trunc(value.X);
    fY := trunc(value.Y);
    fLeft := fLeft + DiffX;
    fRight := fRight + DiffX;
    fTop := fTop + DiffY;
    fBottom := fBottom + DiffY;
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
    fX := fX + Diff;
    fRight := fRight + Diff;
  end;

procedure TPGLRectI.SetRight(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fRight - value;
    fRight := value;
    fX := fX + Diff;
    fLeft := fLeft + Diff;
  end;

procedure TPGLRectI.SetTop(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fTop - value;
    fTop := value;
    fY := fY + Diff;
    fBottom := fBottom + Diff;
  end;

procedure TPGLRectI.SetBottom(value: Integer);
var
Diff: Integer;
	begin
  	Diff := fBottom - value;
    fBottom := value;
    fY := fY + Diff;
    fTop := fTop + Diff;
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


procedure TPGLRectI.Crop(aBounds: TPGLRectI);
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


procedure TPGLRectI.FitTo(aBounds: TPGLRectI);
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

    Self.SetSize(Vec2(NewWidth,NewHeight));

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
    fLeft := fLeft + Diff;
    fRight := fRight + Diff;
  end;

procedure TPGLRectF.SetY(value: Single);
var
Diff: Single;
	begin
  	Diff := fY - value;
    fY := Value;
    fTop := fTop + Diff;
    fBottom := fBottom + Diff;
  end;

procedure TPGLRectF.SetCenter(values: TPGLVec2);
var
DiffX, DiffY: Single;
	begin
  	DiffX := fX - (values.X);
    DiffY := fY - (values.Y);
    fX := (values.X);
    fY := (values.Y);
    fLeft := fLeft + DiffX;
    fRight := fRight + DiffX;
    fTop := fTop + DiffY;
    fBottom := fBottom + DiffY;
  end;

procedure TPGLRectF.SetLeft(value: Single);
var
Diff: Single;
	begin
  	Diff := fLeft - value;
    fLeft := value;
    fX := fX + Diff;
    fRight := fRight + Diff;
  end;

procedure TPGLRectF.SetRight(value: Single);
var
Diff: Single;
	begin
  	Diff := fRight - value;
    fRight := value;
    fX := fX + Diff;
    fLeft := fLeft + Diff;
  end;

procedure TPGLRectF.SetTop(value: Single);
var
Diff: Single;
	begin
  	Diff := fTop - value;
    fTop := value;
    fY := fY + Diff;
    fBottom := fBottom + Diff;
  end;

procedure TPGLRectF.SetBottom(value: Single);
var
Diff: Single;
	begin
  	Diff := fBottom - value;
    fBottom := value;
    fY := fY + Diff;
    fTop := fTop + Diff;
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

procedure TPGLRectF.Crop(aBounds: TPGLRectF);
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

procedure TPGLRectF.FitTo(aBounds: TPGLRectF);
var
WR, HR: Single;
NewWidth, NewHeight: Single;
	begin

    while True do begin

    	WR := Self.Width / aBounds.Width;
    	NewWidth := (Self.Width * (1/WR));
      NewHeight := (Self.Height * (1/WR));
      Self.SetSize(Vec2(NewWidth, NewHeight));

      HR := Self.Height / aBounds.Height;
      NewHeight := (Self.Height * (1/HR));
      NewWidth := (Self.Width * (1/WR));
      Self.SetSize(Vec2(NewWidth, NewHeight));

      if (NewWidth <= aBounds.Width) and (NewHeight <= aBounds.Height) then Break;

    end;

  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                       Operators
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

{$ifdef FPC}
operator := (ColorF: TPGLColorF): TPGLColorI;
{$else}
class operator TPGLColorIHelper.Implicit(ColorF: TPGLColorF): TPGLColorI;
{$endif}
	begin
  	Result.R := ClampI(trunc(ColorF.R * 255));
    Result.G := ClampI(trunc(ColorF.G * 255));
    Result.B := ClampI(trunc(ColorF.B * 255));
    Result.A := ClampI(trunc(ColorF.A * 255));
  end;

{$ifdef FPC}
operator := (ColorI: TPGLColorI): TPGLColorF;
{$else}
class operator TPGLColorFHelper.Implicit(ColorI: TPGLColorI): TPGLColorF;
{$endif}
	begin
  	Result.R := ClampF(ColorI.R / 255);
    Result.G := ClampF(ColorI.G / 255);
    Result.B := ClampF(ColorI.B / 255);
    Result.A := ClampF(ColorI.A / 255);
  end;

{$ifdef FPC}
operator = (ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
{$else}
class operator TPGLColorIHelper.Equal(ColorI: TPGLColorI; ColorF: TPGLColorF): Boolean;
{$endif}
	begin
  	Result := (ColorI.R = trunc(ColorF.R * 255)) and (ColorI.G = trunc(ColorF.G * 255))
    and (ColorI.B = trunc(ColorF.B * 255)) and (ColorI.A = trunc(ColorF.A * 255));
  end;

operator := (Color: TPGLVec4): TPGLColorI;
  begin
    Result.R := trunc(Color.X * 255);
    Result.G := trunc(Color.Y * 255);
    Result.B := trunc(Color.Z * 255);
    Result.A := trunc(Color.W * 255);
  end;

operator := (Color: TPGLVec4): TPGLColorF;
  begin
    Result.R := (Color.X);
    Result.G := (Color.Y);
    Result.B := (Color.Z);
    Result.A := (Color.W);
  end;

operator + (Color1, Color2: TPGLColorI): TPGLVec4;
  begin
    Result.X := (Color1.R + Color2.R) / 255;
    Result.Y := (Color1.G + Color2.G) / 255;
    Result.Z := (Color1.B + Color2.B) / 255;
    Result.W := (Color1.A + Color2.A) / 255;
  end;

operator - (Color1, Color2: TPGLColorI): TPGLVec4;
  begin
    Result.X := (Color1.R - Color2.R) / 255;
    Result.Y := (Color1.G - Color2.G) / 255;
    Result.Z := (Color1.B - Color2.B) / 255;
    Result.W := (Color1.A - Color2.A) / 255;
  end;

operator + (Color1, Color2: TPGLColorF): TPGLVec4;
  begin
    Result.X := (Color1.R + Color2.R);
    Result.Y := (Color1.G + Color2.G);
    Result.Z := (Color1.B + Color2.B);
    Result.W := (Color1.A + Color2.A);
  end;

operator - (Color1, Color2: TPGLColorF): TPGLVec4;
  begin
    Result.X := (Color1.R - Color2.R);
    Result.Y := (Color1.G - Color2.G);
    Result.Z := (Color1.B - Color2.B);
    Result.W := (Color1.A - Color2.A);
  end;

{$ifdef FPC}
operator = (ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;
{$else}
class operator TPGLColorFHelper.Equal(ColorF: TPGLColorF; ColorI: TPGLColorI): Boolean;
{$endif}
	begin
  	Result := (trunc(ColorF.R * 255) = ColorI.R) and (trunc(ColorF.G * 255) = ColorI.G)
    and (trunc(ColorF.B * 255) = ColorI.B) and (trunc(ColorF.A * 255) = ColorI.A);
  end;

{$ifdef FPC}
operator := (aVec3: TPGLVec3): TPGLVec2;
{$else}
class operator TPGLVec2Helper.Implicit(aVec3: TPGLVec3): TPGLVec2;
{$endif}
	begin
  	Result.X := aVec3.X;
    Result.Y := aVec3.Y;
  end;

{$ifdef FPC}
operator := (aVec4: TPGLVec4): TPGLVec2;
{$else}
class operator TPGLVec2Helper.Implicit(aVec4: TPGLVec4): TPGLVec2;
{$endif}
	begin
  	Result.X := aVec4.X;
    Result.Y := aVec4.Y;
  end;

{$ifdef FPC}
operator := (aVec2: TPGLVec2): TPGLVec3;
{$else}
class operator TPGLVec3Helper.Implicit(aVec2: TPGLVec2): TPGLVec3;
{$endif}
	begin
  	Result.X := aVec2.X;
    Result.Y := aVec2.Y;
  end;

{$ifdef FPC}
operator := (aVec4: TPGLVec4): TPGLVec3;
{$else}
class operator TPGLVec3Helper.Implicit(aVec4: TPGLVec4): TPGLVec3;
{$endif}
	begin
  	Result.X := aVec4.X;
    Result.Y := aVec4.Y;
    Result.Z := aVec4.Z;
  end;

{$ifdef FPC}
operator := (aVec2: TPGLVec2): TPGLVec4;
{$else}
class operator TPGLVec4Helper.Implicit(aVec2: TPGLVec2): TPGLVec4;
{$endif}
	begin
  	Result.X := aVec2.X;
    Result.Y := aVec2.Y;
  end;

{$ifdef FPC}
operator := (aVec3: TPGLVec3): TPGLVec4;
{$else}
class operator TPGLVec4Helper.Implicit(aVec3: TPGLVec3): TPGLVec4;
{$endif}
	begin
  	Result.X := aVec3.X;
    Result.Y := aVec3.Y;
    Result.Z := aVec3.Z;
  end;

{$ifdef FPC}
operator := (aRect: TPGLRectF): TPGLRectI;
{$else}
class operator TPGLRectIHelper.Implicit(aRect: TPGLRectF): TPGLRectI;
{$endif}
	begin
  	Result := TPGLRectI.Create(trunc(aRect.Left), trunc(aRect.Top), trunc(aRect.Right), trunc(aRect.Bottom));
  end;

{$ifdef FPC}
operator := (aRect: TPGLRectI): TPGLRectF;
{$else}
class operator TPGLRectFHelper.Implicit(aRect: TPGLRectI): TPGLRectF;
{$endif}
	begin
  	Result := TPGLRectF.Create(aRect.Left, aRect.Top, aRect.Right, aRect.Bottom);
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                       Functions
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

function ClampI(const value: Integer): Byte;
	begin
  	Result := value;
    if value > 255 then Exit(255);
    if value < 0 then Exit(0);
  end;

function ClampF(const value: Single): Single;
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

function ColorI(const aRed, aGreen, aBlue: Byte; aAlpha: Byte = 255): TPGLColorI;
	begin
  	Result.fR := aRed;
    Result.fG := aGreen;
    Result.fB := aBlue;
    Result.fA := aAlpha;
  end;

function ColorF(const aRed, aGreen, aBlue: Single; aAlpha: Single = 1.0): TPGLColorF;
	begin
  	Result.fR := ClampF(aRed);
    Result.fG := ClampF(aGreen);
    Result.fB := ClampF(aBlue);
    Result.fA := ClampF(aAlpha)
  end;

function MixF(const aDestColor, aSrcColor: TPGLColorF; aSrcFactor: Single): TPGLColorF;
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

function MixI(const aDestColor, aSrcColor: TPGLColorI; aSrcFactor: Byte): TPGLColorI;
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

function MixP(const aDestColor, aSrcColor: PPGLColorI; aSrcFactor: Byte): TPGLColorI;
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

procedure AlphaBlend(const srccolor, dstcolor: Pointer);
var
Alpha: Byte;
	begin
    BlendDstPtr := PUINT32(dstcolor);
    BlendSrcPtr := PUINT32(srccolor);
	  Alpha := 255 - (BlendSrcPtr^ shr 24);

		RedBlueComps := BlendSrcPtr^ and $ff00ff;
		GreenComp := BlendSrcPtr^ and $00ff00;
		RedBlueComps := RedBLueComps + ((BlendDstPtr^ and $ff00ff) - RedBlueComps) * Alpha shr 8;
		GreenComp := GreenComp + ((BlendDstPtr^ and $00ff00) - GreenComp) * Alpha shr 8;
		BlendDstPtr^ := $ff000000 or (RedBlueComps and $ff00ff) or (GreenComp and $ff00);
	end;

function RectI(const aLeft, aTop, aRight, aBottom: Integer): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(aLeft, aTop, aRight, aBottom);
  end;

function RectIC(const aCenter: TPGLVec2; aWidth, aHeight: Integer): TPGLRectI;
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

function RectIWH(const aLeft, aTop, aWidth, aHeight: Integer): TPGLRectI;
	begin
  	Result := TPGLRectI.Create(aLeft, aTop, aLeft + (aWidth - 1), aTop + (aHeight - 1));
  end;

function RectF(const aLeft, aTop, aRight, aBottom: Single): TPGLRectF;
	begin
  	Result := TPGLRectF.Create(aLeft, aTop, aRight, aBottom);
  end;

function RectFC(const aCenter: TPGLVec2; aWidth, aHeight: Single): TPGLRectF;
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

function RectFWH(const aLeft, aTop, aWidth, aHeight: Single): TPGLRectF;
	begin
  	Result := TPGLRectF.Create(aLeft, aTop, aLeft + (aWidth - 1), aTop + (aHeight - 1))
  end;

function Vec2(const aX, aY: Single): TPGLVec2;
  begin
    Result.X := aX;
    Result.Y := aY;
  end;

function Vec3(const aX, aY, aZ: Single): TPGLVec3;
  begin
    Result.X := aX;
    Result.Y := aY;
    Result.Z := aZ;
  end;

function Vec4(const aX, aY, aZ, aW: Single): TPGLVec4;
  begin
    Result.X := aX;
    Result.Y := aY;
    Result.Z := aZ;
    Result.W := aW;
  end;

function Distance(const Vec1, Vec2: TPGLVec3): Single; RELEASE_INLINE
  begin
    Exit( Sqrt( IntPower(Vec2.X - Vec1.X, 2) + IntPower(Vec2.Y - Vec1.Y, 2) + IntPower(Vec2.Z - Vec1.Z, 2) ) );
  end;

function Angle(const Vec1, Vec2: TPGLVec2): Single; RELEASE_INLINE
  begin
    Exit( ArcTan2(Vec2.Y - Vec1.Y, Vec2.X - Vec1.X) );
  end;

function AnglePoint(const aStartVec: TPGLVec2; const aAngle: Single; const aDist: Single): TPGLVec2; RELEASE_INLINE
  begin
    Result.X := aStartVec.X + (aDist * Cos(aAngle));
    Result.Y := aStartVec.Y + (aDist * Sin(aAngle));
  end;

function EdgeTest(const P1, P2, TestPoint: TPGLVec2): Single; RELEASE_INLINE
  begin
     Exit( (P1.X - P2.X) * (TestPoint.Y - P1.Y) - (P1.Y - P2.Y) * (TestPoint.X - P1.X) );
  end;

function Mins(const aVec1, aVec2: TPGLVec3): TPGLVec3;
  begin
    // Min X
    if aVec1.x < aVec2.x then Result.x := aVec1.x else Result.x := aVec2.x;
    // Min Y
    if aVec1.y < aVec2.y then Result.y := aVec1.y else Result.y := aVec2.y;
    // Min Z
    if aVec1.x < aVec2.z then Result.z := aVec1.z else Result.z := aVec2.z;
  end;

function Mins(const aVec1, aVec2, aVec3: TPGLVec3): TPGLVec3; 
  begin
    // Min X
    Result.X := aVec1.X;
    if aVec2.X < aVec1.X then begin
      if aVec2.X < aVec3.X then begin
        Result.X := aVec2.X;
      end else begin
        Result.X := aVec3.X;
      end;
    end;

    // Min Y
    Result.Y := aVec1.Y;
    if aVec2.Y < aVec1.Y then begin
      if aVec2.Y < aVec3.Y then begin
        Result.Y := aVec2.Y;
      end else begin
        Result.Y := aVec3.Y;
      end;
    end;

    // Min Z
    Result.Z := aVec1.Z;
    if aVec2.Z < aVec1.Z then begin
      if aVec2.Z < aVec3.Z then begin
        Result.Z := aVec2.Z;
      end else begin
        Result.Z := aVec3.Z;
      end;
    end;
  end;

function Mins(const Arr: Array of TPGLVec3): TPGLVec3;
var
I: INT32;
  begin

    if Length(Arr) = 0 then Exit(Vec3(0,0,0));
    if Length(Arr) = 1 then Exit(Arr[0]);

    // Min X
    Result := Arr[0];
    for I := 1 to High(Arr) do begin
      if Arr[I].X < Result.X then Result.X := Arr[I].X;
      if Arr[I].Y < Result.Y then Result.Y := Arr[I].Y;
      if Arr[I].Z < Result.Z then Result.Z := Arr[I].Z;
    end;

  end;

function Maxes(const aVec1, aVec2: TPGLVec3): TPGLVec3;
  begin
    // Min X
    if aVec1.x > aVec2.x then Result.x := aVec1.x else Result.x := aVec2.x;
    // Min Y
    if aVec1.y > aVec2.y then Result.y := aVec1.y else Result.y := aVec2.y;
    // Min Z
    if aVec1.x > aVec2.z then Result.z := aVec1.z else Result.z := aVec2.z;
  end;

function Maxes(const aVec1, aVec2, aVec3: TPGLVec3): TPGLVec3;
  begin
    // Min X
    Result.X := aVec1.X;
    if (aVec2.X > aVec1.X) or (aVec3.X > aVec1.X) then begin
      if aVec2.X > aVec3.X then begin
        Result.X := aVec2.X;
      end else begin
        Result.X := aVec3.X;
      end;
    end;

    // Min Y
    Result.Y := aVec1.Y;
    if (aVec2.Y > aVec1.Y) or (aVec3.Y > aVec1.Y) then begin
      if aVec2.Y > aVec3.Y then begin
        Result.Y := aVec2.Y;
      end else begin
        Result.Y := aVec3.Y;
      end;
    end;

    // Min Z
    Result.Z := aVec1.Z;
    if (aVec2.Z > aVec1.Z) or (aVec3.Z > aVec1.Z) then begin
      if aVec2.Z > aVec3.Z then begin
        Result.Z := aVec2.Z;
      end else begin
        Result.Z := aVec3.Z;
      end;
    end;
  end;

function Maxes(const Arr: Array of TPGLVec3): TPGLVec3;
var
I: INT32;
  begin

    if Length(Arr) = 0 then Exit(Vec3(0,0,0));
    if Length(Arr) = 1 then Exit(Arr[0]);

    // Min X
    Result := Arr[0];
    for I := 1 to High(Arr) do begin
      if Arr[I].X > Result.X then Result.X := Arr[I].X;
      if Arr[I].Y > Result.Y then Result.Y := Arr[I].Y;
      if Arr[I].Z > Result.Z then Result.Z := Arr[I].Z;
    end;

  end;

end.

