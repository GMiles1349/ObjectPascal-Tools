unit pglOGLWindow;

{$mode ObjFPC}{$H+}
{$modeswitch ADVANCEDRECORDS}

interface

uses
	Classes, SysUtils, glfw, glad_gl, GL;

type TPGLButtonArray = Array [1..9] of Integer;
type TPGLMouseButton = (BUTTON_LEFT = 1, BUTTON_MIDDLE = 2, BUTTON_RIGHT = 3, SCROLL_UP = 4, SCROLL_DOWN = 5, SCROLL_LEFT = 6, SCROLL_RIGHT = 7,
	BUTTON_BACK = 8, BUTTON_FORWARD = 9);

type TPGLProc = procedure;
type TPGLMouseButtonProc = procedure(X, Y, Button: Integer; Shift: Boolean); register;
type TPGLMouseMoveProc = procedure(X, Y: Integer; Buttons: TPGLButtonArray; Shift: Boolean); register;
type TPGLKeyProc = procedure(aKeyCode: Byte; aScanCode: Uint32; Shift: boolean); register;
type TPGLCharProc = procedure(aChar: Char); register;


type

  TPGLOGLWindow = class;
  TPGLKeyboard = class;
  TPGLMouse = class;

  TPGLOGLWindow = class(TPersistent)
	  private
      fHandle: PGLFWWindow;
	    fOpen: Boolean;
	    fWidth, fHeight: Cardinal;
	    fX,fY: Integer;
	    fTitle: String;
	    fClearColor: UINT32;
      fSizeable: Boolean;
      fHasTitleBar: Boolean;
      fHasFocus: Boolean;

      fMouse: TPGLMouse;
      fKeyBoard: TPGLKeyboard;

	    // message atoms and flags
      fShouldClose: Boolean;

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
      property ClearColor: UINT32 read fClearColor;
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
	    procedure SetClearColor(aColor: UINT32); register;
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

      procedure SetText(aText: String); register;
      procedure BlitImage(aImage: Pointer; aDestX, aDesty, aSrcWidth, aSrcHeight: Cardinal); register;

	end;


  TPGLKeyboard = class(TPersistent)
    private
      fWindow: TPGLOGLWindow;
			fKey: Array [0..255] of Byte;
      fShift: Boolean;
      fCtrl: Boolean;
      fAlt: Boolean;

      fKeyPressProc: TPGLKeyProc;
      fKeyReleaseProc: TPGLKeyProc;
      fKeyCharProc: TPGLCharProc;

      function GetKey(Index: Byte): Byte;

    public
      property Key[Index: Byte]: Byte read GetKey;
      property Shift: Boolean read fShift;
      property Ctrl: Boolean read fCtrl;
      property Alt: Boolean read fAlt;

      procedure SetKeyPressProc(aProc: TPGLKeyProc); register;
      procedure SetKeyReleaseProc(aProc: TPGLKeyProc); register;
      procedure SetKeyCharProc(aProc: TPGLCharProc); register;

      constructor Create(aWindow: TPGLOGLWindow);

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
                                      TPGLOGLWindow
(----------------------------------------------------------------------------------------)
(---------------------------------------------------------------------------------------*)

constructor TPGLOGLWindow.Create(aWidth, aHeight: Cardinal; aTitle: String);
var
Maj, Min: GLInt;
	begin
    Self.fWidth := aWidth;
    Self.fHeight := aHeight;
    Self.fTitle := aTitle;
    Self.fSizeable := True;
    Self.fHasTitleBar := True;

    Self.fOpen := True;

    Self.fMouse := TPGLMouse.Create();
    Self.fKeyBoard := TPGLKeyboard.Create(Self);

    GLFWInit();
    Self.fHandle := GLFWCreateWindow(aWidth, aHeight, PAnsiChar(aTitle), nil, nil);

    //gladLoadGL(TLoadProc(@glfwGetProcAddress));

    glfwMakeContextCurrent(Self.fHandle);

    glGetIntegerV(GL_MAJOR_VERSION, @Maj);
    glGetIntegerV(GL_MINOR_VERSION, @Min);

  end;


destructor TPGLOGLWindow.Destroy();
	begin

  end;


procedure TPGLOGLWindow.Close();
	begin

  end;


procedure TPGLOGLWindow.StopClose();
	begin
  	Self.fShouldClose := False;
  end;

procedure TPGLOGLWindow.PollEvents();
	begin
    glfwPollEvents();
    if glfwWindowShouldClose(Self.fHandle) = 1 then begin
      Self.fOpen := False;
    end;
  end;

procedure TPGLOGLWindow.HandleClose();
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


procedure TPGLOGLWindow.LockSize(aWidth: Cardinal = 0; aHeight: Cardinal = 0; aLocked: Boolean = false);
	begin

  end;

function TPGLOGLWindow.GetImageData(): Pointer;
	begin

  end;


procedure TPGLOGLWindow.Clear();
	begin

  end;


procedure TPGLOGLWindow.Display();
	begin
    glfwSwapBuffers(Self.fHandle);
  end;

procedure TPGLOGLWindow.SetTitle(aTitle: String);
	begin

  end;


procedure TPGLOGLWindow.SetClearColor(aColor: UINT32);
	begin
    Self.fClearColor := aColor;
  end;

procedure TPGLOGLWindow.SetWidth(aWidth: Cardinal);
	begin
  	Self.SetSize(aWidth, Self.fHeight);
  end;

procedure TPGLOGLWindow.SetHeight(aHeight: Cardinal);
	begin
  	Self.SetSize(Self.fWidth, aHeight);
  end;

procedure TPGLOGLWindow.SetSize(aWidth, aHeight: Cardinal);
	begin

  end;

procedure TPGLOGLWindow.SetSizeable(aSizeable: Boolean = true);
	begin
    Self.fSizeable := aSizeable;
  	Self.LockSize(Self.fWidth, Self.fHeight, not aSizeable);
  end;

procedure TPGLOGLWindow.SetHasTitleBar(aHasTitleBar: Boolean = true);
	begin


  end;


procedure TPGLOGLWindow.SetOnTryCloseProc(aProc: TPGLProc);
	begin
  	Self.fTryCloseProc := aProc;
  end;

procedure TPGLOGLWindow.SetOnCloseProc(aProc: TPGLProc);
	begin
  	Self.fCloseProc := aProc;
  end;


procedure TPGLOGLWindow.SetOnMoveProc(aProc: TPGLProc);
	begin
  	Self.fMoveProc := aProc;
  end;

procedure TPGLOGLWindow.SetOnResizeProc(aProc: TPGLProc);
	begin
  	Self.fResizeProc := aProc;
  end;

procedure TPGLOGLWindow.SetGotFocusProc(aProc: TPGLProc);
	begin
  	Self.fGotFocusProc := aProc;
  end;

procedure TPGLOGLWindow.SetLostFocusProc(aProc: TPGLProc);
	begin
  	Self.fLostFocusProc := aProc;
  end;

procedure TPGLOGLWindow.UpdateWindowProperties();
	begin

  end;


procedure TPGLOGLWindow.SetText(aText: string);
	begin

  end;

procedure TPGLOGLWindow.BlitImage(aImage: Pointer; aDestX, aDesty, aSrcWidth, aSrcHeight: Cardinal);
  begin

  end;



(*---------------------------------------------------------------------------------------)
(----------------------------------------------------------------------------------------)
                                      TPGLKeyboard
(----------------------------------------------------------------------------------------)
(---------------------------------------------------------------------------------------*)

constructor TPGLKeyboard.Create(aWindow: TPGLOGLWindow);
	begin
  	Self.fWindow := aWindow;
  end;

function TPGLKeyboard.GetKey(Index: Byte): Byte;
	begin
  	Result := Self.fKey[Index];
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

