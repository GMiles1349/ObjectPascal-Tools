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

  TEventProc = procedure();
  TTriggerType = (TRIGGER_ON_INTERVAL = 0, TRIGGER_ON_TIME = 1);

  TClockHour = INT32;
  TClockMinute = INT32;
  TClockSecond = INT32;
  TClockSecond100 = INT32;

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

      // 000,000,000
      // | |  |  |
			// | |  |  Second100 * 100
			// | |  Second * 10,000
			// | Minute * 1,000,000
			// Hour * 100,000,000
      function GetIntValue(): UINT32

    public
      property Hour: TClockHour read fHour write SetHour;
      property Minute: TClockMinute read fMinute write SetMinute;
      property Second: TClockSecond read fSecond write SetSecond;
      property Second100: TClockSecond100 read fSecond100 write SetSecond100;

	    class operator Initialize(var aTimeStruct: TTimeStruct);
      class operator + (ts1, ts2: TTimeStruct): TTimeStruct;
      class operator - (ts1, ts2: TTimeStruct): TTimeStruct;
      class operator > (ts1, ts2: TTimeStruct): Boolean;
      class operator < (ts1, ts2: TTimeStruct): Boolean;
      class operator >= (ts1, ts2: TTimeStruct): Boolean;
      class operator <= (ts1, ts2: TTimeStruct): Boolean;
      class operator = (ts1, ts2: TTimeStruct): Boolean;
      class operator <> (ts1, ts2: TTimeStruct): Boolean;
  end;


  TClock = class(TPersistent)
  	private
    	fRunning: Boolean;
      fInterval: Double;
      fInitTime: Double;
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
      fInitHMS: TTimeStruct;
      fElapsedHMS: TTimeStruct;
      TP: timespec;

      fEvents: Array of TClockEvent;

      procedure Init();
      procedure Update();

      function GetResolution(): Int64;
      function GetTime(): Double;
      function GetEvent(Index: UINT32): TClockEvent;

      procedure SetInterval(const aInterval: Double); inline;

      procedure AddEvent(const aEvent: TClockEvent); inline;
      procedure RemoveEvent(const aEvent: TClockEvent); inline;
      procedure HandleEvents(); inline;

    public
      property Running: Boolean read fRunning;
      property Interval: Double read fInterval write SetInterval;
      property CurrentTime: Double read fCurrentTime;
      property LastTime: Double read fLastTime;
      property TargetTime: Double read fTargetTime;
      property CycleTime: Double read fCycleTime;
      property ElapsedTime: Double read fElapsedTime;
      property FramesPerSecond: Double read fFramesPerSecond;
      property Resolution: Int64 read fResolution;
      property HMS: TTimeStruct read fHMS;
      property InitTime: Double read fInitTime;
      property InitHMS: TTimeStruct read fInitHMS;
      property ElapsedHMS: TTimeStruct read fElapsedHMS;
      property Event[Index: UINT32]: TClockEvent read GetEvent;

      constructor Create(AInterval: Double);
      destructor Destroy(); override;

      procedure Start(); inline;
      procedure Stop(); inline;
      procedure Wait(); inline;
      function PollCPUTime(): Double; inline;
      function PollHMSTime(): TTimeStruct; inline;
      function CPUTimeToHMS(const aCPUTime: Double): TTimeStruct; inline;
      function HMStoCPUTime(const aHMS: TTimeStruct): Double; inline;
      function EventList(): specialize TArray<TClockEvent>;

  end;


  TClockEvent = class(TPersistent)
    private
      fActive: Boolean;
      fRepeating: Boolean;
      fTriggerType: TTriggerType;
      fTriggerInterval: Double;
      fLastTrigger: Double;
      fNextTrigger: Double;
      fTriggerTime: TTimeStruct;
      fOwner: TClock;
      fEventProc: TEventProc;

      procedure SetActive(const aActive: Boolean); inline;
      procedure SetRepeating(const aRepeating: Boolean); inline;
      procedure SetTriggerType(const aTriggerType: TTriggerType); inline;
      procedure SetTriggerInterval(const aTriggerInterval: Double); inline;
      procedure SetTriggerTime(const aTriggerTime: TTimeStruct); inline;
      procedure SetOwner(const aOwner: TClock); inline;
      procedure SetEventProc(const aEventProc: TEventProc); inline;

      function GetTriggerInterval(): Double; inline;
      function GetTriggerTime(): TTimeStruct; inline;
      function GetNextTrigger(): Double; inline;

      procedure CheckTrigger(); inline;
      procedure TryExecute(); inline;

    public
      property Active: Boolean read fActive write SetActive;
      property Repeating: Boolean read fRepeating write SetRepeating;
      property TriggerType: TTriggerType read fTriggerType write SetTriggerType;
      property TriggerInterval: Double read GetTriggerInterval write SetTriggerInterval;
      property NextTrigger: Double read GetNextTrigger;
      property TriggerTime: TTimeStruct read GetTriggerTime write SetTriggerTime;
      property Owner: TClock read fOwner write SetOwner;
      property EventProc: TEventProc read fEventProc write SetEventProc;

      constructor Create(); overload;
      constructor Create(aOwner: TClock; aTriggerType: TTriggerType; aRepeating: Boolean); overload;
      destructor Destroy(); override;

  end;


  function TimeStruct(aHour: TClockHour = 0; aMinute: TClockMinute = 0; aSecond: TClockSecond = 0; aSecond100: TClockSecond100 = 0): TTimeStruct;


implementation

function TimeStruct(aHour: TClockHour = 0; aMinute: TClockMinute = 0; aSecond: TClockSecond = 0; aSecond100: TClockSecond100 = 0): TTimeStruct;
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
  end;


procedure TTimeStruct.SetMinute(const Value: TClockMinute);
  begin
    Self.fMinute := Value;
    while Self.fMinute > 59 do begin
      Self.fMinute := Self.fMinute - 60;
      Self.Hour := Self.fHour + 1;
    end;

    while Self.fMinute < 0 do begin
      Self.fMinute := Self.fMinute + 60;
      Self.Hour := Self.fHour - 1;
    end;
  end;


procedure TTimeStruct.SetSecond(const Value: TClockSecond);
  begin
    Self.fSecond := Value;
    while Self.fSecond > 59 do begin
      Self.fSecond := Self.fSecond - 60;
      Self.Minute := Self.fMinute + 1;
    end;

    while Self.fSecond < 0 do begin
      Self.fSecond := Self.fSecond + 60;
      Self.Minute := Self.fMinute - 1;
    end;
  end;


procedure TTimeStruct.SetSecond100(const Value: TClockSecond100);
  begin
    Self.fSecond100 := Value;
    while Self.fSecond100 > 99 do begin
      Self.fSecond100 := Self.fSecond100 - 100;
      Self.Second := Self.fSecond + 1;
    end;

    while Self.fSecond100 < 0 do begin
      Self.fSecond100 := Self.fSecond100 + 100;
      Self.Second := Self.fSecond - 1;
    end;
  end;


function TTimeStruct.GetIntValue(): UINT32;
  begin
    Result := Self.fSecond100 * 100;
    Result += self.fSecond * 10000;
    Result += Self.fMinute * 1000000;
    Result += Self.fHour * 100000000;
  end;

class operator TTimeStruct.+ (ts1, ts2: TTimeStruct): TTimeStruct;
  begin
    Initialize(Result);
    Result.Second100 := ts1.fSecond100 + ts2.fSecond100;
    Result.Second := ts1.fSecond + ts2.fSecond;
    Result.Minute := ts1.fMinute + ts2.fMinute;
    Result.Hour := ts1.fHour + ts2.fHour;
  end;


class operator TTimeStruct.- (ts1, ts2: TTimeStruct): TTimeStruct;
  begin
    Initialize(Result);
    Result.Second100 := ts1.fSecond100 - ts2.fSecond100;
    Result.Second := ts1.fSecond - ts2.fSecond;
    Result.Minute := ts1.fMinute - ts2.fMinute;
    Result.Hour := ts1.fHour - ts2.fHour;
  end;

class operator TTimeStruct.> (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue > ts2.GetIntValue);
  end;

class operator TTimeStruct.< (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue < ts2.GetIntValue);
  end;

class operator TTimeStruct.>= (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue >= ts2.GetIntValue);
  end;

class operator TTimeStruct.<= (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue <= ts2.GetIntValue);
  end;

class operator TTimeStruct.= (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue = ts2.GetIntValue);
  end;

class operator TTimeStruct.<> (ts1, ts2: TTimeStruct): Boolean;
  begin
    Exit(ts1.GetIntValue <> ts2.GetIntValue);
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

destructor TClock.Destroy();
  begin
    while Length(Self.fEvents) > 0 do begin
      Self.RemoveEvent(Self.fEvents[0]);
    end;

    inherited;
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
var
Th, Tm, Ts, Ts100: WORD;
	begin
    Th := 0;
    Tm := 0;
    Ts := 0;
    Ts100 := 0;
    Time.GetTime(Th, Tm, Ts, Ts100);
    Self.fHMS := TimeStruct(Th, Tm, Ts, Ts100);
  	clock_gettime(CLOCK_MONOTONIC, @Self.TP);
    Result := Self.TP.tv_sec + (Self.TP.tv_nsec * 1e-9);
	end;

function TClock.GetEvent(Index: UINT32): TClockEvent;
  begin
    if Index > High(Self.fEvents) then Exit(nil);
    Exit(Self.fEvents[Index]);
  end;

function TClock.EventList(): specialize TArray<TClockEvent>;
  begin
    Initialize(Result);
    SetLength(Result, Length(Self.fEvents));
    Move(Self.fEvents[0], Result[0], SizeOf(Result[0]) * Length(Self.fEvents));
  end;

procedure TClock.Update();
	begin
  	Self.fLastTime := Self.fCurrentTime;
    Self.fCurrentTime := Self.GetTime();
    Self.fTargetTime := Self.fCurrentTime + Self.fInterval;
    Self.fCycleTime := Self.fCurrentTime - Self.fLastTime;
    Self.fElapsedTime := Self.fCurrentTime - Self.fInitTime;
    Self.fElapsedHMS := Self.fHMS - Self.fInitHMS;

    Self.fFrameTime := Self.fFrameTime + Self.fCycleTime;
    Self.fFrames := Self.fFrames + 1;
    if (Self.fFrameTime >= 1) then begin
    	Self.fFramesPerSecond := Self.fFrames / Self.fFrameTime;
      Self.fFrameTime := 0;
      Self.fFrames := 0;
    end;

    Self.HandleEvents();
  end;

procedure TClock.SetInterval(const aInterval: Double);
  begin
    Self.fInterval := abs(aInterval);
    if Self.fRunning then begin
      Self.fTargetTime := Self.fCurrentTime + Self.fInterval;
    end;
  end;

procedure TClock.Start();
	begin
  	Self.Init();
    Self.fCurrentTime := Self.GetTime();
    Self.fInitTime := Self.fCurrentTime;
    Self.fInitHMS := Self.fHMS;
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

function TClock.PollCPUTime(): Double;
  begin
    clock_gettime(CLOCK_MONOTONIC, @Self.TP);
    Result := Self.TP.tv_sec + (Self.TP.tv_nsec * 1e-9);
  end;

function TClock.PollHMSTime(): TTimeStruct;
var
Th, Tm, Ts, Ts100: WORD;
  begin
    Th := 0;
    Tm := 0;
    Ts := 0;
    Ts100 := 0;
    Time.GetTime(Th, Tm, Ts, Ts100);
    Result := TimeStruct(th, Tm, Ts, Ts100);
  end;

function TClock.CPUTimeToHMS(const aCPUTime: Double): TTimeStruct;
var
Secs, Secs100: INT32;
  begin
    Secs := trunc(Self.fInitTime - aCPUTime);
    Secs100 := trunc((aCPUTime - Secs) * 100);
    Result := Self.fInitHMS + TimeStruct(0, 0, Secs, Secs100);
  end;

function TClock.HMStoCPUTime(const aHMS: TTimeStruct): Double;
var
Secs: Double;
TS: TTimeStruct;
  begin
    TS := aHMS - Self.fInitHMS;
    Secs := ((TS.fHour * 60) * 60);
    Secs := Secs + (TS.fMinute * 60);
    Secs := Secs + TS.fSecond;
    Secs := Secs + (TS.fSecond100 / 100);
    Result := Self.fInitTime + Secs;
  end;

procedure TClock.AddEvent(const aEvent: TClockEvent);
var
I: Integer;
  begin
    if Assigned(aEvent) = False then Exit;

    for I := 0 to High(Self.fEvents) do begin
      if Self.fEvents[I] = aEvent then Exit;
    end;

    I := Length(Self.fEvents);
    SetLength(Self.fEvents, I + 1);
    Self.fEvents[I] := aEvent;

  end;

procedure TClock.RemoveEvent(const aEvent: TClockEvent);
var
I: Integer;
  begin

    for I := 0 to High(Self.fEvents) do begin
      if Self.fEvents[I] = aEvent then begin
        Delete(Self.fEvents, I, 1);
        Exit;
      end;
    end;

  end;

procedure TClock.HandleEvents();
var
I: Integer;
  begin
    if Length(Self.fEvents) = 0 then Exit;

    I := 0;
    while I = High(Self.fEvents) do begin

      if Assigned(Self.fEvents[I]) = False then begin
        Self.RemoveEvent(Self.fEvents[i]);

      end else begin
        if Self.fEvents[I].fActive then begin
          Self.fEvents[I].TryExecute();
        end;

        Inc(I);
      end;

    end;
  end;

(*///////////////////////////////////////////////////////////////////////////////////////)
(----------------------------------------------------------------------------------------)
                                      TClockEvent
(----------------------------------------------------------------------------------------)
(///////////////////////////////////////////////////////////////////////////////////////*)

constructor TClockEvent.Create();
  begin
    Self.fOwner := nil;
    Self.fRepeating := False;
    Self.fActive := False;
    Self.fTriggerInterval := 0;
    Self.fTriggerTime := TimeStruct(0,0,0,0);
    Self.fTriggerType := TRIGGER_ON_INTERVAL;
    Self.fEventProc := nil;
    Self.fLastTrigger := 0;
    Self.fNextTrigger := 0;
  end;

constructor TClockEvent.Create(aOwner: TClock; aTriggerType: TTriggerType; aRepeating: Boolean);
  begin
    Self.Owner := aOwner;
    Self.fRepeating := aRepeating;
    Self.fActive := False;
    Self.fTriggerInterval := 0;
    Self.fTriggerTime := TimeStruct(0,0,0,0);
    Self.fTriggerType := aTriggerType;
    Self.fEventProc := nil;
    Self.fLastTrigger := 0;
    Self.fNextTrigger := 0;
  end;

destructor TClockEvent.Destroy();
  begin
    if Assigned(Self.fOwner) then begin
      Self.fOwner.RemoveEvent(Self);
    end;

    inherited;
  end;

procedure TClockEvent.CheckTrigger();
  begin
    case Self.fTriggerType of

      TRIGGER_ON_INTERVAL:
        begin

        end;

      TRIGGER_ON_TIME:
        begin
          if Self.fTriggerTime > Self.fOwner.HMS then Self.fActive := False;
        end;

    end;
  end;

procedure TClockEvent.TryExecute();
  begin

    case Self.fTriggerType of

      TRIGGER_ON_INTERVAL:
        begin
          if Self.fOwner.PollCPUTime >= Self.fNextTrigger then begin

            if Self.fRepeating then begin
              Self.fLastTrigger := Self.fNextTrigger;
              Self.fNextTrigger := Self.fNextTrigger + Self.fTriggerInterval;
            end else begin
              Self.SetActive(False);
            end;

            Self.fEventProc();

          end;

        end;

      TRIGGER_ON_TIME:
        begin
          if Self.fOwner.PollHMSTime >= Self.fTriggerTime then begin
            Self.SetActive(False);
            Self.fEventProc();
          end;
        end;

    end;

  end;

procedure TClockEvent.SetActive(const aActive: Boolean);         
  begin
    if Assigned(Self.fOwner) then begin
      Self.fActive := aActive;
      Self.fLastTrigger := Self.fOwner.fCurrentTime;
      Self.CheckTrigger();
    end else begin
      Self.fActive := False;
    end;

    if Self.fActive = False then begin
      Self.fNextTrigger := 0;
      Self.fLastTrigger := 0;
    end;
  end;

procedure TClockEvent.SetRepeating(const aRepeating: Boolean);      
  begin
    Self.fRepeating := aRepeating;
  end;

procedure TClockEvent.SetTriggerType(const aTriggerType: TTriggerType); 
  begin
    Self.fTriggerType := aTriggerType;
    Self.CheckTrigger();
  end;

procedure TClockEvent.SetTriggerInterval(const aTriggerInterval: Double); 
  begin
    Self.fTriggerInterval := abs(aTriggerInterval);

    if Self.fActive then begin
      Self.fNextTrigger := Self.fLastTrigger + Self.fTriggerInterval;
    end;
  end;

procedure TClockEvent.SetTriggerTime(const aTriggerTime: TTimeStruct);     
  begin
    Self.fTriggerTime := aTriggerTime;
    Self.CheckTrigger();
  end;

procedure TClockEvent.SetOwner(const aOwner: TClock);     
  begin

    if aOwner = Self.fOwner then Exit;

    if Assigned(aOwner) then begin
      if Assigned(Self.fOwner) then begin
      Self.fOwner.RemoveEvent(Self);
      end;
      Self.fOwner := aOwner;
      Self.fOwner.AddEvent(Self);
    end else begin
      Self.fOwner := nil;
      Self.Active := False;
    end;

  end;

procedure TClockEvent.SetEventProc(const aEventProc: TEventProc);    
  begin
    Self.fEventProc := aEventProc;
  end;

function TClockEvent.GetTriggerInterval(): Double;    
  begin
    case Self.fTriggerType of
      TRIGGER_ON_INTERVAL: Exit(Self.fTriggerInterval);
      TRIGGER_ON_TIME: Exit(-1);
    end;
  end;

function TClockEvent.GetTriggerTime(): TTimeStruct;      
  begin
    Initialize(Result);
    case Self.fTriggerType of
      TRIGGER_ON_INTERVAL: Exit;
      TRIGGER_ON_TIME: Exit(Self.fTriggerTime);
    end;
  end;

function TClockEvent.GetNextTrigger(): Double;
  begin
    case Self.fTriggerType of
      TRIGGER_ON_INTERVAL: Exit(Self.fNextTrigger);
      TRIGGER_ON_TIME: Exit(-1);
    end;
  end;

end.

