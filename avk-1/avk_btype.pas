unit avk_btype;

{$mode DELPHI}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes;
type
  avk_TFraim = class;

  { avk_TFraim }

  avk_TFraim = class (TObject)
  private
    FID: Integer;
    FID_child: Integer;
    FError : TNotifyEvent;
    FDraw, FTimer, FProc: TNotifyEvent;
    FAnyOneGotProc: boolean;
    FNowProc: boolean;
    FNowPause: boolean;
    function GetCount: Integer;
    function GetMaxFID: Integer;
    function GetMinFID: Integer;
    function GetMaxLayer: Integer;
    function GetMinLayer: Integer;
    function GetMouseHost: avk_TFraim;
    procedure SetAnyOneGotProc(inVal: boolean);
    function GetAnyOneGotProc: boolean;
    procedure SetInputText(inVal: avk_TFraim);
    function GetInputText: avk_TFraim;
    procedure SetLayer(AValue: Integer);
    procedure SetMouseHost(AValue: avk_TFraim);
  private //реализация паузы
    CalcPause: Integer;
    StopPause: Integer;
  //protected
  private
    FParent : avk_TFraim;
    FInputText : avk_TFraim;
    FMouseHost : avk_TFraim;
    FName  : String;
    FLayer : Integer;
    FNoDelete: boolean;
    FList : TStringList;
    FDeleteMe: boolean;
  public
    HardControlErrors: boolean;
    HardControlNames: boolean;
    procedure SetMeLastInParent;
    function  GetFraimById( inID : Integer ) : avk_TFraim;
    function  GetIdByName( inName : String ) : Integer;
    procedure  SetFraimById( inID : Integer; inFraim: avk_TFraim);
    function AddFraim (inFraim: avk_TFraim): boolean;
    procedure SortByID(ForLoToHi: boolean = true);
    procedure SortByLayer(ForLoToHi: boolean = true);
    procedure DelById (inId: Integer);
    procedure ClearAll;
    procedure MakePause(InTact: Integer);
  private
    FDrawing: boolean;
    FFinishDraw: TNotifyEvent;
    FStartDraw: TNotifyEvent;
    FTiming: boolean;
    function GetFraimByName(InID : String): avk_TFraim;
    function GetFraimByNom(InID : Integer): avk_TFraim;
    procedure SetDeleteMe(AValue: boolean);
  protected
    procedure Draw; virtual;
    procedure Proc; virtual;
    procedure intProc; virtual;
  public
    constructor Create (InParent: avk_TFraim = nil);
    destructor Destroy; override;
  public
    procedure SetName(inName: String);
  public
    property DeleteMe: boolean read FDeleteMe write SetDeleteMe;
    property Drawing: boolean read FDrawing write FDrawing;
    property Timing: boolean read FTiming write FTiming;
    property AnyOneGotProc: boolean read GetAnyOneGotProc write SetAnyOneGotProc;
    property Layer: Integer read FLayer write SetLayer;
    property InputText: avk_TFraim read GetInputText write SetInputText;
    property MouseHost: avk_TFraim read GetMouseHost write SetMouseHost;
    property Name: String read FName write SetName;
    property Count: Integer read GetCount;
    property Parent: avk_TFraim read FParent;
    property Id: Integer read FID;
    property MinLayer: Integer read GetMinLayer;
    property MinId: Integer read GetMinFID;
    property MaxLayer: Integer read GetMaxLayer;
    property MaxId: Integer read GetMaxFID;
    property List[InID :Integer]: avk_TFraim read GetFraimById;
    property ListName[InID :String]: avk_TFraim read GetFraimByName;
    property ListNom[InID :Integer]: avk_TFraim read GetFraimByNom;
    property NowPause: boolean read FNowPause;
  public
    property OnError: TNotifyEvent read FError write FError;
    property OnDraw: TNotifyEvent read FDraw write FDraw;
    property OnProc: TNotifyEvent read FProc write FProc;
    property OnStartDraw: TNotifyEvent read FStartDraw write FStartDraw;
    property OnFinishDraw: TNotifyEvent read FFinishDraw write FFinishDraw;
  end;

  function avk_IntToStr( Value : Integer ) : UTF8String;
  {$IFNDEF DEBUG}
  procedure FreeAndNil(APoint: TObject);
  {$ENDIF}

implementation

function avk_IntToStr( Value : Integer ) : UTF8String;
begin
  Str( Value, Result );
end;

{$IFNDEF DEBUG}
procedure FreeAndNil(APoint: TObject);
begin
  APoint.Destroy;
  APoint := nil;
end;
{$ENDIF}


{ avk_TFraim }

{$I avk_sort_btype.inc}

procedure avk_TFraim.SetAnyOneGotProc(inVal: boolean);
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    TmpPar := TmpPar.Parent;
  end;
  TmpPar.FAnyOneGotProc := inVal;
end;

function avk_TFraim.GetMouseHost: avk_TFraim;
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    TmpPar := TmpPar.Parent;
  end;
  if not Assigned(TmpPar.FMouseHost) then
    TmpPar.FMouseHost := nil;
  Result := TmpPar.FMouseHost;
end;

function avk_TFraim.GetCount: Integer;
begin
  Result := FList.Count;
end;

procedure avk_TFraim.SetInputText(inVal: avk_TFraim);
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    TmpPar := TmpPar.Parent;
  end;
  TmpPar.FInputText := inVal;
end;

function avk_TFraim.GetInputText: avk_TFraim;
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    TmpPar := TmpPar.Parent;
  end;
  Result := TmpPar.FInputText;
end;

procedure avk_TFraim.SetLayer(AValue: Integer);
begin
  if FLayer=AValue then Exit;
  FLayer:=AValue;
  if FLayer < 0 then FLayer:=0;
end;

procedure avk_TFraim.SetMouseHost(AValue: avk_TFraim);
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    if not Assigned(TmpPar.Parent) then TmpPar.FParent := nil;//вот такой адъ непонятно почему
    TmpPar := TmpPar.Parent;
  end;
  TmpPar.FMouseHost := AValue;
end;


function avk_TFraim.GetAnyOneGotProc: boolean;
var
  TmpPar: avk_TFraim;
begin
  TmpPar := Self;
  while (TmpPar.Parent <> nil) do begin
    TmpPar := TmpPar.Parent;
  end;
  Result := TmpPar.FAnyOneGotProc;
end;


procedure avk_TFraim.SetMeLastInParent;
begin
  if Parent <> nil then begin
    Parent.SetMeLastInParent;
    FLayer := Parent.MaxLayer + 1;
  end;
end;

function avk_TFraim.GetFraimById(inID: Integer): avk_TFraim;
var
  i: Integer;
begin
  Result := nil;
  if Count = 0 then Exit;
  for i := 0 to FList.Count - 1 do
    if avk_TFraim(FList.Objects[i]).FID = inID then
      Result := avk_TFraim(FList.Objects[i]);

end;

function avk_TFraim.GetIdByName(inName: String): Integer;
var
  i: integer;
begin
  Result := -1;
  for i := 0 to FList.Count - 1 do
    if avk_TFraim(FList.Objects[i]).FName = inName then
      Result := avk_TFraim(FList.Objects[i]).FID;
end;

procedure avk_TFraim.SetFraimById(inID: Integer; inFraim: avk_TFraim);
var
  i: Integer;
  tmpObj: avk_TFraim;
begin
  for i := 0 to FList.Count - 1 do
    if avk_TFraim(FList.Objects[i]).FID = inID then begin
      if Assigned(FList.Objects[i]) then tmpObj := avk_TFraim(FList.Objects[i]);
      FList.Objects[i] := inFraim;
      inFraim.FID := FID_child;
      INC(FID_child);
      if Assigned(tmpObj) then tmpObj.Destroy;
    end;
end;

function avk_TFraim.AddFraim(inFraim: avk_TFraim): boolean;
begin
  Result := true;
  if HardControlNames then begin
    if GetIdByName(inFraim.FName) >= 0 then begin
      if Assigned(OnError) then OnError(Self);
      Result := false;
      Exit;
    end;
  end;
  FList.AddObject(inFraim.Name,inFraim);
  INC(FID_child,1);
end;

procedure avk_TFraim.DelById(inId: Integer);
var
  i : Integer;
  {IfDef Debug}
  NameTmp: String;
  {EndIf}
begin
  if Count < 1 then Exit;
  i := 0;
  while i < Count do
    if avk_TFraim(FList.Objects[i]).FID = inId then begin
      {IfDef Debug}
      NameTmp := avk_TFraim(FList.Objects[ i ]).Name ;
      {EndIf}
      while avk_TFraim(FList.Objects[ i ]).FNoDelete do begin
        //просто ждем
      end;
      avk_TFraim(FList.Objects[i]).Destroy;
      FList.Objects[i] := nil;
      FList.Delete(i);
    end else begin
      INC(i,1);
    end;
end;

procedure avk_TFraim.ClearAll;
var
  i : Integer;
begin
  i := 0;
  while i < FList.Count do begin
    while avk_TFraim(FList.Objects[ i ]).FNoDelete do begin
      //просто ждем
    end;
    avk_TFraim(FList.Objects[ i ]).Destroy;
    //FList.Delete(i);
    Inc( i );
  end;
  FList.Clear;
end;

procedure avk_TFraim.MakePause(InTact: Integer);
begin
  StopPause := InTact;

end;


function avk_TFraim.GetFraimByName(InID : String): avk_TFraim;
var
  i : Integer;
  MemDel: Boolean;
begin
  MemDel := FNoDelete;
  FNoDelete := true;
  Result := nil;
  i := 0;
  while i < FList.Count do begin
    if avk_TFraim(FList.Objects[i]).Name = InID then
      Result := avk_TFraim(FList.Objects[i]);
    Inc( i );
  end;
  FNoDelete:=MemDel;
end;

function avk_TFraim.GetFraimByNom(InID : Integer): avk_TFraim;
var
  MemDel: Boolean;
begin
  MemDel := FNoDelete;
  FNoDelete := true;
  Result := nil;
  if InID < FList.Count then
    if not avk_TFraim(FList.Objects[InID]).DeleteMe then
      Result := avk_TFraim(FList.Objects[InID]);
  FNoDelete := MemDel;
end;

procedure avk_TFraim.SetDeleteMe(AValue: boolean);
begin
  if FDeleteMe=AValue then Exit;
  FDeleteMe:=AValue;

end;

procedure avk_TFraim.Draw;
var
  TmpCln: Integer;
  MemDel: Boolean;
begin
  MemDel := FNoDelete;
  FNoDelete := true;
  if not Drawing then begin
    FNoDelete:=MemDel;
    Exit;
  end;
  if Assigned(OnStartDraw) then OnStartDraw(Self);
  if Assigned(OnDraw) then OnDraw(Self);
  SortByLayer(False);
  for TmpCln:=0 to (Count - 1) do begin
    avk_TFraim(FList.Objects[TmpCln]).Draw;
  end;
  //SortById;
  if Assigned(OnFinishDraw) then OnFinishDraw(Self);
  FNoDelete:=MemDel;
end;

procedure avk_TFraim.Proc;
var
  TmpCln, TmpCln1: Integer;
  MemDel: Boolean;
  NTH: avk_TFraim;
  NameOf: String;
begin
  if FNowProc then Exit; //сейчас идет процесс
  FNowProc := true;
  FNowPause := false;
  if StopPause > 0 then begin
    if CalcPause < StopPause then begin
      Inc(CalcPause);
      FNowPause := true;
    end else begin
      CalcPause:=0;
      StopPause:=0;
    end;
  end;

  MemDel    := FNoDelete;
  FNoDelete := true;
  TmpCln    := 0;
  While TmpCln < Count do begin
    if avk_TFraim(FList.Objects[TmpCln]).DeleteMe then begin
      if avk_TFraim(FList.Objects[TmpCln]).ClassNameIs('TErrorWind') then begin
        { TODO : После удаления нужна бы пауза }
      end;
      DelById(avk_TFraim(FList.Objects[TmpCln]).Id);
      TmpCln    := 0;//Дак может так?
    end else begin
      if FList.Objects[TmpCln].ClassNameIs('avk_TSimpleSprite') then begin
        NameOf := avk_TFraim(FList.Objects[TmpCln]).Name;
        if NameOf = 'Шагающий солдатик 2' then begin
          NTH := avk_TFraim(FList.Objects[TmpCln]);
        end;
      end;
      avk_TFraim(FList.Objects[TmpCln]).Proc;
      Inc(TmpCln,1);
    end;
  end;
  intProc;
  FNoDelete := MemDel;
  FNowProc := false;
end;

procedure avk_TFraim.intProc;
begin
  //только в потомках
  //if not FNowPause then //на паузе потомков не опрашиваем
    if Assigned(OnProc) then OnProc(Self);
end;

constructor avk_TFraim.Create(InParent: avk_TFraim = nil);
var
  TmpTestN: Integer;
begin
  FID            := 0;
  FID_child      := 1;
  FParent        := InParent;
  FLayer         := 1;
  FName          := Self.ClassName + '1';
  Drawing        := true;
  Timing         := true;
  DeleteMe       := false;
  FAnyOneGotProc := false;
  FInputText     := nil;
  FNoDelete      := false;
  StopPause      := 0;
  CalcPause      := 0;
  FNowPause      := false;
  FNowProc       := false;
  OnError:=nil;
  OnDraw:=nil;
  OnProc:=nil;
  FList := TStringList.Create;
  //FList.Sorted := true;//НИЗЯ!
  if InParent <> nil then begin
    FLayer            := InParent.GetMaxLayer + 1;
    HardControlErrors := InParent.HardControlErrors;
    HardControlNames  := InParent.HardControlNames;
    OnError           := InParent.OnError;
    TmpTestN          := 1;
    while InParent.GetIdByName(FName) <> (-1) do begin
      Inc(TmpTestN);
      FName           := Self.ClassName + avk_IntToStr(TmpTestN);
    end;
    Parent.AddFraim(Self);
    FID := Parent.FID_child;
  end else begin
    HardControlErrors := true;
    HardControlNames  := true;
    OnError           := nil;
  end;
end;

destructor avk_TFraim.Destroy;
begin
  MouseHost := nil;
  FInputText     := nil;
  ClearAll;
  FList.Destroy;
  inherited Destroy;
end;

procedure avk_TFraim.SetName(inName: String);
begin
  if inName = FName then Exit;
  if Parent = nil then begin
    FName := inName;
    Exit;
  end;
  if Parent.GetIdByName(inName) = (-1) then begin
    FName := inName;
    Exit;
  end else if HardControlNames then
    if Assigned(OnError) then OnError(Self);
end;

end.

