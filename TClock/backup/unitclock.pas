unit UnitClock;

{$ifdef FPC}
  {$mode ObjFPC}{$H+}
  {$modeswitch ADVANCEDRECORDS}
  {$modeswitch TYPEHELPERS}
  {$INLINE ON}
  {$MACRO ON}
{$endif}

interface

uses
	Classes, SysUtils, Time,
  {$ifdef linux}
    Linux, UnixType;
  {$else ifdef windows}
    winapi.windows;
  {$endif}

type

  TClockHour = UINT16;
  TClockMinute = UINT16;
  TClockSecond = UINT16;
  TClockSecond100 = UINT16;

  TClock = class;
  TClockEvent = class;

  TTimeStruct = record
    private
	    fHour: TClockHour;
	    fMinute: TClockMinute;
	    fSecond: TClockSecond;
	    fSecond100: TClockSecond100;

      procedure SetHour(const Value: TClockHour); inline;
      procedure SetMinute(const Value: TClockMinute); inline;
      procedure SetSecond(const Value: TClockSecond); inline;
      procedure SetSecond100(const Value: TClockSecond100); inline;

    public
      property Hour: TClockHour read fHour write SetHour;
      property Minute: TClockMinute read fMinute write SetMinute;
      property Second: TClockSecond read fSecond write SetSecond;
      property Second100: TClockSecond100 read fSecond100 write SetSecond100;

	    class operator Initialize(var aTimeStruct: TTimeStruct);
      class operator + (ts1, ts2: TTimeStruct): TTimeStruct;
  end;


  TClock = class(TPersistent)
  	private
    	fRunning: Boolean;
      fInterval: Double;
      fCurrentTime: Double;
      fLastTime: Double;
      fTargetTime: Double;
      fCycleTime: Double;
      fElapsedTime: Double;
      fFramesPerSecond: Double;
      fFrames: Integer;
      fFrameTime: Double;
      fResolution: Int64;
      fHMS: TTimeStruct;
      TP: timespec;

      procedure Init(); register;
      function GetResolution(): Int64; register;
      function GetTime(): Double; register;
      procedure Update(); register;

    public
      property Running: Boolean read fRunning;
      property Interval: Double read fInterval;
      property CurrentTime: Double read fCurrentTime;
      property LastTime: Double read fLastTime;
      property TargetTime: Double read fTargetTime;
      property CycleTime: Double read fCycleTime;
      property ElapsedTime: Double read fElapsedTime;
      property FramesPerSecond: Double read fFramesPerSecond;
      property Resolution: Int64 read fResolution;
      property HMS: TTimeStruct read fHMS;

      constructor Create(AInterval: Double);

      procedure Start(); register;
      procedure Stop(); register;
      procedure Wait(); register;

  end;


  TClockEvent = class(TPersistent)
    private

    public

  end;


  function TimeStruct(const aHour: TClockHour = 0; const aMinute: TClockMinute = 0; const aSecond: TClockSecond = 0; const aSecond100: TClockSecond100 = 0): TTimeStruct;

implementation

function TimeStruct(const aHour: TClockHour = 0; const aMinute: TClockMinute = 0; const aSecond: TClockSecond = 0; const aSecond100: TClockSecond100 = 0): TTimeStruct;
  begin
    Initialize(Result);
    Result.Second100 := aSecond100;
    Result.Second := aSecond;
    Result.Minute := aMinute;
    Result.Hour := aHour;
  end;


(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TTimeStruct
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

class operator TTimeStruct.Initialize(var aTimeStruct: TTimeStruct);
  begin
    aTimeStruct.fHour := 0;
    aTimeStruct.fMinute := 0;
    aTimeStruct.fSecond := 0;
    aTimeStruct.fSecond100 := 0;
  end;

procedure TTimeStruct.SetHour(const Value: TClockHour);
  begin
    Self.fHour := Value;
    while Self.fHour > 23 do begin
      Self.fHour := Self.fHour - 24;
    end;
  end;

procedure TTimeStruct.SetMinute(const Value: TClockMinute);
  begin
    Self.fMinute := Value;
    while Self.fMinute > 59 do begin
      Self.fMinute := Self.fMinute - 60;
      Self.Hour := Self.fHour + 1;
    end;
  end;

procedure TTimeStruct.SetSecond(const Value: TClockSecond);
  begin
    Self.fSecond := Value;
    while Self.fSecond > 59 do begin
      Self.fSecond := Self.fSecond - 60;
      Self.Minute := Self.fMinute + 1;
    end;
  end;

procedure TTimeStruct.SetSecond100(const Value: TClockSecond100);
  begin
    Self.fSecond100 := Value;
    while Self.fSecond100 > 99 do begin
      Self.fSecond100 := Self.fSecond100 - 100;
      Self.Second := Self.fSecond + 1;
    end;
  end;


class operator TTimeStruct.+ (ts1, ts2: TTimeStruct): TTimeStruct;
  begin
    Initialize(Result);
    Result.Second100 := ts1.fSecond100 + ts2.fSecond100;
    Result.Second := ts1.fSecond + ts2.fSecond;
    Result.Minute := ts1.fMinute + ts2.fMinute;
    Result.Hour := ts1.fHour + ts2.fHour;
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TClock
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TClock.Create(AInterval: Double);
	begin
  	Self.fInterval := AInterval;
    Self.GetResolution();
    Self.Init();
  end;

procedure TClock.Init();
	begin
  	Self.fRunning := False;
    Self.fCurrentTime := 0;
    Self.fLastTime := 0;
    Self.fTargetTime := 0;
    Self.fCycleTime := 0;
    Self.fElapsedTime := 0;
    Self.fFramesPerSecond := 0;
    Self.fFrames := 0;
    Self.fFrameTime := 0;
  end;

function TClock.GetResolution(): Int64;
	begin
  	clock_getres(CLOCK_MONOTONIC, @Self.TP);
    Self.fResolution := Self.TP.tv_nsec;
    Result := Self.fResolution;
  end;

function TClock.GetTime(): Double;
	begin
    GetTime(Self.fHMS.fHour, Self.fHMS.fMinute, Self.fHMS.fSecond, Self.fHMS.fSecond100);
  	clock_gettime(CLOCK_MONOTONIC, @Self.TP);
    Result := Self.TP.tv_sec + (Self.TP.tv_nsec * 1e-9);
	end;

procedure TClock.Update();
	begin
  	Self.fLastTime := Self.fCurrentTime;
    Self.fCurrentTime := Self.GetTime();
    Self.fTargetTime := Self.fCurrentTime + Self.fInterval;
    Self.fCycleTime := Self.fCurrentTime - Self.fLastTime;
    Self.fElapsedTime := Self.fElapsedTime + Self.fCycleTime;

    Self.fFrameTime := Self.fFrameTime + Self.fCycleTime;
    Self.fFrames := Self.fFrames + 1;
    if (Self.fFrameTime >= 1) then begin
    	Self.fFramesPerSecond := Self.fFrames / Self.fFrameTime;
      Self.fFrameTime := 0;
      Self.fFrames := 0;
    end;

  end;

procedure TClock.Start();
	begin
  	Self.Init();
    Self.fCurrentTime := Self.GetTime();
    Self.fLastTime := Self.fCurrentTime;
    Self.fTargetTime := Self.fCurrentTime + Self.fInterval;
    SElf.fRunning := True;
  end;

procedure TClock.Stop();
	begin
  	Self.fRunning := False;
  end;

procedure TClock.Wait();
	begin
  	while (Self.GetTime() < Self.fTargetTime) do begin
    end;

    Self.Update();
  end;

end.

