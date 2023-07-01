unit pglX11Window;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
	Classes, SysUtils, Linux, UnixType, ctypes, XAtom, XUtil, XLib, X, KeySym, dglOpenGL, GL, GLExt, GLX,
  UnitUtil;

type TPGLButtonArray = Array [1..9] of Integer;
type TPGLMouseButton = (BUTTON_LEFT = 1, BUTTON_MIDDLE = 2, BUTTON_RIGHT = 3, SCROLL_UP = 4, SCROLL_DOWN = 5, SCROLL_LEFT = 6, SCROLL_RIGHT = 7,
	BUTTON_BACK = 8, BUTTON_FORWARD = 9);

type TPGLProc = procedure;
type TPGLMouseButtonProc = procedure(X, Y, Button: Integer; Shift: Boolean); register;
type TPGLMouseMoveProc = procedure(X, Y: Integer; Buttons: TPGLButtonArray; Shift: Boolean); register;
type TPGLKeyProc = procedure(aKeyCode: Byte; aScanCode: Uint32; Shift: boolean); register;
type TPGLCharProc = procedure(aChar: Char); register;


type

  TPGLX11Window = class;
  TPGLKeyboard = class;
  TPGLMouse = class;

  TPGLWindowPropDesc = record
  	public
    	Atom: TAtom;
      Name: String;
    	Format: culong;
    	NumItems: culong;
      Values: Array of culong;
  end;

  TPGLX11Window = class(TPersistent)
	  private
	    fDisplay: PDisplay;
	    fHandle: TWindow;
	    fScreen: Integer;
	    fGC: TGC;
	    fImage: PXImage;
	    fAttributes: TXWindowAttributes;
	    fEvent: TXEvent;
	    fKey: TKeySym;

	    fOpen: Boolean;
	    fWidth, fHeight: Cardinal;
	    fX,fY: Integer;
	    fTitle: String;
	    fClearColor: culong;
      fSizeable: Boolean;
      fHasTitleBar: Boolean;
      fHasFocus: Boolean;
      fProperties: Array of TPGLWindowPropDesc;

      fMouse: TPGLMouse;
      fKeyBoard: TPGLKeyboard;
      fIM: PXIM;
      fIC: PXIC;

	    // message atoms and flags
      fShouldClose: Boolean;
	    wmDeleteMessage: TAtom;

	    // callback procs
      fTryCloseProc: TPGLProc;
	    fCloseProc: TPGLProc;
	    fMoveProc: TPGLProc;
	    fResizeProc: TPGLProc;
      fGotFocusProc: TPGLProc;
      fLostFocusProc: TPGLProc;

	    destructor Destroy(); override;

	    procedure HandleClose(); register;
      procedure LockSize(aWidth: Cardinal = 0; aHeight: Cardinal = 0; aLocked: Boolean = false); register;

      function GetImageData(): Pointer;

	  public
	    property Open: Boolean read fOpen;
	    property Width: Cardinal read fWidth;
	    property Height: Cardinal read fHeight;
	    property X: Integer read fX;
	    property Y: Integer read fY;
	    property Title: String read fTitle;
      property Buffer: Pointer read GetImageData;
      property Sizeable: Boolean read fSizeable;
      Property HasTitleBar: Boolean read fHasTitleBar;
      property Mouse: TPGLMouse read fMouse;
      property Keyboard: TPGLKeyboard read fKeyboard;
      property ClearColor: culong read fClearColor;
      property TryCloseProc: TPGLProc read fTryCloseProc;
	    property CloseProc: TPGLProc read fCloseProc;
	    property MoveProc: TPGLProc read fMoveProc;
	    property ResizeProc: TPGLProc read fResizeProc;

	    constructor Create(aWidth, aHeight: Cardinal; aTitle: String);
      procedure Close(); register;
      procedure StopClose(); register;
	    procedure PollEvents(); register;

	    procedure Clear(); register;
      procedure Display(); register;

	    procedure SetTitle(aTitle: String); register;
	    procedure SetClearColor(aColor: culong); register;
      procedure SetWidth(aWidth: Cardinal); register;
      procedure SetHeight(aHeight: Cardinal); register;
      procedure SetSize(aWidth, aHeight: Cardinal); register;
      procedure SetSizeable(aSizeable: Boolean = true); register;
      procedure SetHasTitleBar(aHasTitleBar: Boolean = true); register;

      procedure SetOnTryCloseProc(aProc: TPGLProc); register;
	    procedure SetOnCloseProc(aProc: TPGLProc); register;
      procedure SetOnMoveProc(aProc: TPGLProc); register;
      procedure SetOnResizeProc(aProc: TPGLProc); register;
      procedure SetGotFocusProc(aProc: TPGLProc); register;
      procedure SetLostFocusProc(aProc: TPGLProc); register;

      procedure UpdateWindowProperties(); register;
      function GetWindowPropDesc(aPropAtom: TAtom): TPGLWindowPropDesc; register;

      procedure SetText(aText: String); register;
      procedure BlitImage(aImage: Pointer; aDestX, aDesty, aSrcWidth, aSrcHeight: Cardinal); register;

	end;


  TPGLKeyboard = class(TPersistent)
    private
      fWindow: TPGLX11Window;
			fKey: Array [0..255] of Byte;
      fShift: Boolean;
      fCtrl: Boolean;
      fAlt: Boolean;

      fKeyPressProc: TPGLKeyProc;
      fKeyReleaseProc: TPGLKeyProc;
      fKeyCharProc: TPGLCharProc;

      function GetKey(Index: Byte): Byte;
      procedure ReceiveKeyPress(aKeyCode: TKeyCode; aKeySym: TKeySym);
      procedure ReceiveKeyRelease(aKeyCode: TKeyCode; aKeySym: TKeySym);

    public
      property Key[Index: Byte]: Byte read GetKey;
      property Shift: Boolean read fShift;
      property Ctrl: Boolean read fCtrl;
      property Alt: Boolean read fAlt;

      procedure SetKeyPressProc(aProc: TPGLKeyProc); register;
      procedure SetKeyReleaseProc(aProc: TPGLKeyProc); register;
      procedure SetKeyCharProc(aProc: TPGLCharProc); register;

      constructor Create(aWindow: TPGLX11Window);

  end;


  TPGLMouse = class(TPersistent)
    private
      fX,fY: Integer;
      fLastX, fLastY: Integer;
      fDiffX, fDiffY: integer;
      fButton: TPGLButtonArray;

      fButtonPressProc: TPGLMouseButtonProc;
      fButtonReleaseProc: TPGLMouseButtonProc;
      fMoveProc: TPGLMouseMoveProc;
      fWindowLeaveProc: TPGLProc;
      fWindowEnterProc: TPGLProc;

      function GetButton(Index: Cardinal): Integer; register;

      procedure SetPosition(aX, aY: Integer); register;
      procedure SetButtonDown(aButton: Cardinal); register;
      procedure SetButtonUp(aButton: Cardinal); register;

    public
      property X: Integer read fX;
      property Y: Integer read fY;
      property LastX: Integer read fLastX;
      property LastY: Integer read flastY;
      property DiffX: Integer read fDiffX;
      property DiffY: Integer read fDiffY;
      property Button[Index: Cardinal]: Integer read GetButton;

      procedure SetButtonPressProc(aProc: TPGLMouseButtonProc); register;
      procedure SetButtonReleaseProc(aProc: TPGLMouseButtonProc); register;
      procedure SetMouseMoveProc(aProc: TPGLMouseMoveProc); register;
      procedure SetWindowLeaveProc(aProc: TPGLProc); register;
      procedure SetWindowEnterProc(aProc: TPGLProc); register;

  end;


implementation

(*---------------------------------------------------------------------------------------)
(----------------------------------------------------------------------------------------)
                                      TPGLX11Window
(----------------------------------------------------------------------------------------)
(---------------------------------------------------------------------------------------*)

constructor TPGLX11Window.Create(aWidth, aHeight: Cardinal; aTitle: String);
var
EventMask: clong;
GLMin, GLMax: Integer;
	begin
    Self.fWidth := aWidth;
    Self.fHeight := aHeight;
    Self.fTitle := aTitle;
    Self.fSizeable := True;
    Self.fHasTitleBar := True;
  	Self.fDisplay := XOpenDisplay(nil);
    Self.fScreen := DefaultScreen(Self.fDisplay);
    Self.fHandle := XCreateSimpleWindow(Self.fDisplay, DefaultRootWindow(Self.fDisplay), 0, 0, aWidth, aHeight, 0, 0, 0);

    XSetStandardProperties(Self.fDisplay, Self.fHandle, PAnsiChar(aTitle), nil, 0, nil, 0, nil);

    EventMask := ExposureMask or FocusChangeMask or KeyPressMask or KeyreleaseMask or StructureNotifyMask or PointerMotionMask or
    	ButtonPressMask or ButtonReleaseMask or ButtonMotionMask or Button1MotionMask or Button2MotionMask or Button3MotionMask
      or Button4MotionMask or Button5MotionMask or EnterWindowMask or LeaveWindowMask;

    XSelectInput(Self.fDisplay, Self.fHandle, EventMask);
    Self.fGC := XCreateGC(Self.fDisplay, Self.fHandle, 0, nil);

    Self.wmDeleteMessage := XInternAtom(Self.fDisplay, 'WM_DELETE_WINDOW', False);
    XSetWMProtocols(Self.fDisplay, Self.fHandle, @Self.wmDeleteMessage, 1);
    XGetWindowAttributes(Self.fDisplay, Self.fHandle, @Self.fAttributes);

    Self.fX := Self.fAttributes.x;
    Self.fY := Self.fAttributes.y;

    XSetForeground(Self.fDisplay, Self.fGC, $FFFFFFFF);
    XClearWindow(Self.fDisplay, Self.fHandle);
    XMapRaised(Self.fDisplay, Self.fHandle);

    Self.fOpen := True;

    Self.PollEvents();
    Sleep(100);
    Self.fImage := XGetimage(Self.fDisplay, Self.fHandle, 0, 0, Self.fWidth, Self.fHeight, AllPlanes, ZPixmap);

    Self.fMouse := TPGLMouse.Create();
    Self.fKeyBoard := TPGLKeyboard.Create(Self);

    Self.fIM := XOpenIM(Self.fDisplay, nil, nil, nil);
    Self.fIC := XCreateIC(Self.fIM, [XNInputStyle, XIMPreeditNothing or XIMStatusNothing, nil]);

    glxQueryVersion(Self.fDisplay, GLMax, GLMin);

  end;


destructor TPGLX11Window.Destroy();
	begin
  	XFreeGC(Self.fDisplay, Self.fGC);
    XDestroyWindow(Self.fDisplay, Self.fHandle);
    XCloseDisplay(Self.fDisplay);
  end;


procedure TPGLX11Window.Close();
var
SendEvent: TXClientMessageEvent;
	begin
    FillByte(SendEvent, SizeOf(TXClientMessageEvent), 0);
    SendEvent._type := ClientMessage;
    SendEvent.send_event := 1;
    SendEvent.window := Self.fHandle;
    SendEvent.message_type := XInternAtom(Self.fDisplay, 'WM_PROTOCOLS', false);
    SendEvent.format := 32;
    SendEvent.data.l[0] := Self.wmDeleteMessage;
    SendEvent.data.l[1] := CurrentTime;
 		XSendEvent(Self.fDisplay, Self.fHandle, False, 0, @SendEvent);
  end;


procedure TPGLX11Window.StopClose();
	begin
  	Self.fShouldClose := False;
  end;

procedure TPGLX11Window.PollEvents();
var
KeyCode: Integer;
KSym, LCSym, UCsym: TKeySym;
	begin

    while XPending(Self.fDisplay) <> 0 do begin
    	XNextEvent(Self.fDisplay, @Self.fEvent);

      if Self.fEvent.xclient.data.l[0] = Self.wmDeleteMessage then begin
        Self.fShouldClose := True;
      	Self.HandleClose();
        break;
      end;

      case Self.fEvent._type of

      	ConfigureNotify:
          begin

            if (Self.fEvent.xconfigure.width <> Self.fWidth) or (Self.fEvent.xconfigure.height <> Self.fHeight) then begin
		        	Self.fWidth := Self.fEvent.xconfigure.width;
		          Self.fHeight := Self.fEvent.xconfigure.height;

              Self.fImage := XGetImage(Self.fDisplay, Self.fHandle, 0, 0, Self.fWidth, Self.fHeight, AllPlanes, ZPixMap);

              if Assigned(Self.fResizeProc) then begin
              	Self.fResizeProc();
              end;

		        end else begin
		        	Self.fX := Self.fEvent.xconfigure.x;
		        	Self.fY := Self.fEvent.xconfigure.y;

              if Assigned(Self.fMoveProc) then begin
              	Self.fMoveProc();
              end;

		        end;

          end;

        FocusIn:
          begin
          	Self.fHasFocus := True;
            if Assigned(Self.fGotFocusProc) then begin
            	Self.fGotFocusProc();
            end;
          end;

       	FocusOut:
          begin
          	Self.fHasFocus := False;
            if Assigned(Self.fLostFocusProc) then begin
              Self.fLostFocusProc();
            end;
          end;

        MotionNotify:
        	begin
          	Self.fMouse.SetPosition(Self.fEvent.xmotion.x, Self.fEvent.xmotion.y);
          end;

        EnterNotify:
          begin
          	if Assigned(Self.Mouse.fWindowEnterProc) then begin
            	Self.Mouse.fWindowEnterProc();
            end;
          end;

        LeaveNotify:
          begin

          	if Assigned(Self.Mouse.fWindowLeaveProc) then begin
              Self.Mouse.fWindowLeaveProc();
            end;
          end;

        ButtonPress:
          begin
          	Self.fMouse.SetButtonDown(Self.fEvent.xbutton.button);
          end;

        ButtonRelease:
          begin
          	Self.fMouse.SetButtonUp(Self.fEvent.xbutton.button);
          end;

        KeyPress:
          begin
          	KSym := XKeyCodetoKeysym(Self.fDisplay, Self.fEvent.xkey.keycode, 1);
            Self.Keyboard.ReceiveKeyPress(Self.fEvent.xkey.keycode, KSym);
          end;

        KeyRelease:
          begin
          	KSym := XKeyCodetoKeysym(Self.fDisplay, Self.fEvent.xkey.keycode, 1);
            Self.Keyboard.ReceiveKeyRelease(Self.fEvent.xkey.keycode, KSym);
          end;

      end;

    end;

  end;

procedure TPGLX11Window.HandleClose();
	begin

    if Assigned(Self.fTryCloseProc) then begin
      Self.fTryCloseProc();
    end;

    if Self.fShouldClose then begin

	  	Self.fOpen := False;
	    if Assigned(Self.fCloseProc) then begin
	    	Self.fCloseProc();
	    end;
    end;

  end;


procedure TPGLX11Window.LockSize(aWidth: Cardinal = 0; aHeight: Cardinal = 0; aLocked: Boolean = false);
var
SizeHints: TXSizeHints;
MinWidth,MinHeight,MaxWidth,MaxHeight: Integer;
	begin

    if aLocked = False then begin
    	MinWidth := 0;
      MinHeight := 0;
      MaxWidth := 10000;
      MaxHeight := 10000;
    end else begin
      MinWidth := aWidth;
      MinHeight := aHeight;
      MaxWidth := aWidth;
      MaxHeight := aHeight;
    end;

  	SizeHints.base_height := Self.fHeight;
    SizeHints.base_width := Self.fWidth;
    SizeHints.max_height := MaxHeight;
    SizeHints.max_width := MaxWidth;
    SizeHints.min_height := MinHeight;
    SizeHints.min_width := MinWidth;
    SizeHints.flags := PMinSize or PMaxSize or PBaseSize or PSize;

    XSetWMNormalHints(Self.fDisplay, Self.fHandle, @SizeHints);
  end;

function TPGLX11Window.GetImageData(): Pointer;
	begin
  	Exit(Pointer(Self.fImage^.data));
  end;


procedure TPGLX11Window.Clear();
var
I: Integer;
PixelCount: Integer;
Pos: Integer;
Ptr: PByte;
	begin

    if Assigned(Self.fImage^.data) = False then Exit;

  	Pos := 0;
    PixelCount := (Self.fWidth * Self.fHeight);
    Ptr := PByte(Self.fImage^.data);

    for I := 0 to PixelCount - 1 do begin
    	//Ptr[0] := Self.fClearColor;
      Move(Self.fClearColor, Ptr[0], 3);
      Ptr := Ptr + 4;
    end;

  end;


procedure TPGLX11Window.Display();
	begin
  	XPutImage(Self.fDisplay, Self.fHandle, Self.fGC, Self.fImage, 0, 0, 0, 0, Self.fWidth, Self.fHeight);
  end;

procedure TPGLX11Window.SetTitle(aTitle: String);
	begin
  	Self.fTitle := aTitle;
    XStoreName(Self.fDisplay, Self.fHandle, PAnsiChar(Self.fTitle));
  end;


procedure TPGLX11Window.SetClearColor(aColor: culong);
	begin
    Self.fClearColor := aColor;
  	XSetWindowBackground(Self.fDisplay, Self.fHandle, aColor);
  end;

procedure TPGLX11Window.SetWidth(aWidth: Cardinal);
	begin
  	Self.SetSize(aWidth, Self.fHeight);
  end;

procedure TPGLX11Window.SetHeight(aHeight: Cardinal);
	begin
  	Self.SetSize(Self.fWidth, aHeight);
  end;

procedure TPGLX11Window.SetSize(aWidth, aHeight: Cardinal);
	begin
    XResizeWindow(Self.fDisplay, Self.fHandle, aWidth, aHeight);
  end;

procedure TPGLX11Window.SetSizeable(aSizeable: Boolean = true);
	begin
    Self.fSizeable := aSizeable;
  	Self.LockSize(Self.fWidth, Self.fHeight, not aSizeable);
  end;

procedure TPGLX11Window.SetHasTitleBar(aHasTitleBar: Boolean = true);
	begin


  end;


procedure TPGLX11Window.SetOnTryCloseProc(aProc: TPGLProc);
	begin
  	Self.fTryCloseProc := aProc;
  end;

procedure TPGLX11Window.SetOnCloseProc(aProc: TPGLProc);
	begin
  	Self.fCloseProc := aProc;
  end;


procedure TPGLX11Window.SetOnMoveProc(aProc: TPGLProc);
	begin
  	Self.fMoveProc := aProc;
  end;

procedure TPGLX11Window.SetOnResizeProc(aProc: TPGLProc);
	begin
  	Self.fResizeProc := aProc;
  end;

procedure TPGLX11Window.SetGotFocusProc(aProc: TPGLProc);
	begin
  	Self.fGotFocusProc := aProc;
  end;

procedure TPGLX11Window.SetLostFocusProc(aProc: TPGLProc);
	begin
  	Self.fLostFocusProc := aProc;
  end;

procedure TPGLX11Window.UpdateWindowProperties();
var
Atoms: PAtom;
NumProps: cint;
I: Integer;
	begin

    Atoms := XListProperties(Self.fDisplay, Self.fHandle, @NumProps);

    SetLength(Self.fProperties, NumProps);

    for I := 0 to NumProps - 1 do begin
    	Self.fProperties[i] := Self.GetWindowPropDesc(Atoms[i]);
    end;

    XFree(Atoms);

  end;

function TPGLX11Window.GetWindowPropDesc(aPropAtom: TAtom): TPGLWindowPropDesc; register;
var
AtomName: PChar;
ReturnType: TAtom;
ReturnFormat: Integer;
NumItems: culong;
BytesAfterReturn: culong;
PropReturn: PChar;
I: Integer;
	begin

    AtomName := XGetAtomName(Self.fDisplay, aPropAtom);

    Result.Name := pglChartoString(AtomName);

    XGetWindowProperty(Self.fDisplay, Self.fHandle, aPropAtom, 0, 64, false, AnyPropertyType, @ReturnType,
    	@ReturnFormat, @NumItems, @BytesAfterReturn, @PropReturn);

    Result.NumItems := NumItems;
    Result.Format := ReturnFormat;
    Result.Atom := aPropAtom;

    SetLength(Result.Values, NumItems);

    for I := 0 to NumItems - 1 do begin

      case ReturnFormat of

        32:
        	begin
          	Result.Values[i] := PInteger(PropReturn)[i];
          end;

      end;

    end;

  end;


procedure TPGLX11Window.SetText(aText: string);
	begin
  	XDrawString(Self.fDisplay, Self.fHandle, Self.fGC, 0, 12, PChar(aText), Length(aText));
  end;

procedure TPGLX11Window.BlitImage(aImage: Pointer; aDestX, aDesty, aSrcWidth, aSrcHeight: Cardinal);
var
DX1, DX2, DY1, DY2, DWidth, DHeight: Cardinal;
DPos, SPos: Integer;
DPtr, SPtr: PByte;
RowSize: Integer;
I,Z: Integer;
	begin

    DX1 := aDestX;
    DY1 := ADestY;
    DX2 := DX1 + (aSrcWidth - 1);
    DY2 := DY1 + (aSrcHeight - 1);

    if DX2 > Self.fWidth - 1 then begin
      	DX2 := Self.fWidth - 1;
    end;

    DWidth := DX2 - DX1;
    if DWidth > aSrcWidth then begin
      	DWidth := aSrcWidth;
    end;

    if DY2 > Self.fHeight - 1 then begin
    	DY2 := Self.fHeight - 1;
    end;

    DHeight := DY2 - DY1;
    if DHeight > aSrcHeight then begin
      DHeight := aSrcHeight;
    end;

    RowSize := DWidth * 4;
    DPtr := PByte(Self.fImage^.data);
    SPtr := PByte(aImage);

    for Z := 0 to DHeight - 1 do begin


        DPos := (( (Z + DY1) * Self.fWidth) + (DX1)) * 4;
        SPos := (( (Z + 0) * aSrcWidth) + (0)) * 4;
        Move(SPtr[SPos], DPtr[DPos], RowSize);

    end;

  end;



(*---------------------------------------------------------------------------------------)
(----------------------------------------------------------------------------------------)
                                      TPGLKeyboard
(----------------------------------------------------------------------------------------)
(---------------------------------------------------------------------------------------*)

constructor TPGLKeyboard.Create(aWindow: TPGLX11Window);
	begin
  	Self.fWindow := aWindow;
  end;

function TPGLKeyboard.GetKey(Index: Byte): Byte;
	begin
  	Result := Self.fKey[Index];
  end;

procedure TPGLKeyBoard.ReceiveKeyPress(aKeyCode: TKeyCode; aKeySym: TKeySym);
var
SChar: Char;
RetStatus: cint;
KPEvent: TXKeyPressedEvent;
ShiftFlag: cuint32;
ControlFlag: cuint32;
StateMask: cuint32;
SkipChar: Boolean;
	begin

    SkipChar := False;

  	Self.fKey[aKeySym] := 1;

    case aKeySym of

      XK_SHIFT_L, XK_SHIFT_R:
      	begin
        	Self.fShift := True;
          SkipChar := True;
        end;

      XK_ALT_L, XK_ALT_R:
        begin
        	Self.fAlt := True;
          SkipChar := True;
        end;

      XK_CONTROL_L, XK_CONTROL_R:
        begin
        	Self.fCtrl := True;
          SkipChar := True;
        end;

      XK_RETURN:
        begin
        	SkipChar := True;
        end;

    end;

    if Assigned(Self.fKeyPressProc) then Self.fKeyPressProc(aKeyCode, aKeySym, Self.Shift);

    if Skipchar then Exit;

	  if Assigned(Self.fKeyCharProc) then begin


      if Self.fShift then ShiftFlag := ShiftMask;
      if Self.fCtrl then ControlFlag := ControlMask;

      StateMask := ShiftFlag or ControlFlag;

      KPEvent.display := Self.fWindow.fDisplay;
      KPEvent.keycode := aKeyCode;
      KPevent._type := KeyPress;
      KPEvent.state := StateMask;
    	Xutf8LookUpString(Self.fWindow.fIC, @KPEvent, @SChar, 1, nil, @RetStatus);

      if (RetStatus = 2) and (SChar <> #0) then begin
      	Self.fKeyCharProc(SChar);
      end;

    end;

  end;

procedure TPGLKeyBoard.ReceiveKeyRelease(aKeyCode: TKeyCode; aKeySym: TKeySym);
var
ls,us: TKeySym;
	begin
  	Self.fKey[aKeySym] := 0;

    case aKeySym of

      XK_SHIFT_L, XK_SHIFT_R:
      	begin
        	Self.fShift := False;
        end;

      XK_ALT_L, XK_ALT_R:
        begin
        	Self.fAlt := False;
        end;

      XK_CONTROL_L, XK_CONTROL_R:
        begin
        	Self.fCtrl := False;
        end;

    end;

    if Assigned(Self.fKeyReleaseProc) then Self.fKeyReleaseProc(aKeyCode, aKeySym, Self.Shift);
  end;

procedure TPGLKeyboard.SetKeyPressProc(aProc: TPGLKeyProc);
	begin
  	Self.fKeyPressProc := aProc;
  end;

procedure TPGLKeyboard.SetKeyReleaseProc(aProc: TPGLKeyProc);
	begin
  	Self.fKeyReleaseProc := aProc;
  end;

procedure TPGLKeyBoard.SetKeyCharProc(aProc: TPGLCharProc);
	begin
  	Self.fKeyCharProc := aProc;
  end;

(*---------------------------------------------------------------------------------------)
(----------------------------------------------------------------------------------------)
                                      TPGLMouse
(----------------------------------------------------------------------------------------)
(---------------------------------------------------------------------------------------*)

function TPGLMouse.GetButton(Index: Cardinal): Integer;
	begin
    if (Index > 9) or (Index = 0) then Exit(-1);
  	Exit(Self.Button[Index]);
  end;

procedure TPGLMouse.SetPosition(aX, aY: Integer); register;
	begin
  	Self.fLastX := Self.fX;
    Self.fLastY := Self.fY;
    Self.fX := aX;
    Self.fY := aY;
    Self.fDiffX := Self.fX - Self.fLastX;
    Self.fDiffY := Self.fY - Self.fLastY;

    if Assigned(Self.fMoveProc) then begin
    	Self.fMoveProc(Self.fX, Self.fY, Self.fButton, False);
    end;

  end;

procedure TPGLMouse.SetButtonDown(aButton: Cardinal);
	begin
  	Self.fButton[aButton] := 1;
    if Assigned(Self.fButtonPressProc) then begin
      Self.fButtonPressProc(Self.fX, Self.fY, aButton, False);
    end;
  end;

procedure TPGLMouse.SetButtonUp(aButton: Cardinal);
	begin
  	Self.fButton[aButton] := 0;
    if Assigned(Self.fButtonReleaseProc) then begin
      Self.fButtonReleaseProc(Self.fX, Self.fY, aButton, False);
    end;
  end;

procedure TPGLMouse.SetButtonPressProc(aProc: TPGLMouseButtonProc);  
	begin
   Self.fButtonPressProc := aProc;
  end;

procedure TPGLMouse.SetButtonReleaseProc(aProc: TPGLMouseButtonProc); 
	begin
  	Self.fButtonReleaseProc := aProc;
  end;

procedure TPGLMouse.SetMouseMoveProc(aProc: TPGLMouseMoveProc);
	begin
  	Self.fMoveProc := aProc;
  end;

procedure TPGLMouse.SetWindowEnterProc(aProc: TPGLProc);
	begin
  	Self.fWindowEnterProc := aProc;
  end;

procedure TPGLMouse.SetWindowLeaveProc(aProc: TPGLProc);
	begin
  	Self.fWindowLeaveProc := aProc;
  end;


end.

