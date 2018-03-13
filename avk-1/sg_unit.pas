unit sg_unit;

{$mode delphi}
{$codepage UTF8}

interface

uses

{$IFNDEF WINDOWS}
 cwstring,
{$ENDIF}
Classes
{$IFDEF WINDOWS}
  ,Windows
{$ELSE}
  ,Unix, UnixType
{$ENDIF}
{$ifdef DEBUG}
  , SysUtils
{$endif}
//avk
, avk_btype
, avk_gui
, avk_input
, avk_resmanager
, avk_vector
, avk_cls
, avk_sprites
//zgl
{$IFNDEF ANDROID}   //Не андроид
, zgl_opengl
, zgl_opengl_all
{$ELSE}
, zgl_opengles
, zgl_opengles_all
{$ENDIF}
, zgl_file
, zgl_render_2d
, zgl_camera_2d
, zgl_math_2d
, zgl_screen
, zgl_font
, zgl_primitives_2d
, zgl_fx
, zgl_text
, zgl_textures
//, zgl_textures_tga
, zgl_textures_png
//, zgl_textures_jpg
, zgl_sprite_2d
, zgl_particles_2d
, zgl_render_target
, zgl_utils
, zgl_types
, zgl_keyboard
, zgl_main
, zglChipmunk
;

const
  FLAG_K_NO = $00;
  FLAG_K_UP = $01;
  FLAG_K_DOWN = $02;
  FLAG_K_LEFT = $04;
  FLAG_K_RIGHT = $08;
  FLAG_M_RIGHT_Cl = $10;
  FLAG_M_LEFT_Cl = $20;

type

{ TGamer1 }

TGamer1 = class(avk_TFraim)
private
  FSprites: array of array of avk_TSkeletTile;
private
  FOnAfterProc: TNotifyEvent;
  FOnBeforeProc: TNotifyEvent;
  function GetColAngle(const ACol: Integer): Single;
  function GetColAnimate(const ACol, ARow: Integer): boolean;
  function GetColPosition(const ACol: Integer): zglTPoint2D;
  function GetColVisible(const ACol: Integer): Integer;
  function GetSprite(const ACol, ARow: Integer): avk_TSkeletTile;
  procedure SetColAngle(const ACol: Integer; AValue: Single);
  procedure SetColAnimate(const ACol, ARow: Integer; AValue: boolean);
  procedure SetColPosition(const ACol: Integer; AValue: zglTPoint2D);
  procedure SetColVisible(const ACol: Integer; ARow: Integer);
  procedure SetSprite(const ACol, ARow: Integer; AValue: avk_TSkeletTile = nil);
public
  property ColPosition[const ACol: Integer]: zglTPoint2D read GetColPosition write SetColPosition;
  property ColAngle[const ACol: Integer]: Single read GetColAngle write SetColAngle;
  property ColVisible[const ACol: Integer]: Integer read GetColVisible write SetColVisible;
  property ColAnimate[const ACol, ARow: Integer]: boolean read GetColAnimate write SetColAnimate;
  property Sprite[const ACol, ARow: Integer]: avk_TSkeletTile read GetSprite write SetSprite;
public
  Position: zglTPoint2D;
  PosAngle: Single;
  PosScale: Single;
  procedure SetPosForAll;
public
  PosHide: boolean;
  PosAnimate: boolean;
public
  property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
  property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
public
  procedure DoDraw(Sender: TObject);
  procedure DoProc(Sender: TObject);
public
  constructor Create(const InParent: avk_TFraim = nil);
  destructor Destroy; override;
public
  MoveSpeed: Single;
  procedure MoveSprite(AFlag: byte; AValMX, AValMY: Single);
end;

implementation

{ TGamer1 }

function TGamer1.GetColAngle(const ACol: Integer): Single;
begin
  Result := FSprites[ACol, 0].Angle; //первый и все
end;

procedure TGamer1.SetColAngle(const ACol: Integer; AValue: Single);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Angle := AValue;
end;

function TGamer1.GetColAnimate(const ACol, ARow: Integer): boolean;
begin
  Result := FSprites[ACol, ARow].Animate;
end;


procedure TGamer1.SetColAnimate(const ACol, ARow: Integer; AValue: boolean);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Animate := false;
  FSprites[ACol, ARow].Animate := AValue;
end;

function TGamer1.GetColPosition(const ACol: Integer): zglTPoint2D;
begin
  Result := FSprites[ACol, 0].Point; //первый и все
end;

procedure TGamer1.SetColPosition(const ACol: Integer; AValue: zglTPoint2D);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].SetPoint(AValue.X, AValue.Y);
end;

function TGamer1.GetSprite(const ACol, ARow: Integer): avk_TSkeletTile;
begin
  if ACol > (Length(FSprites) - 1) then
    SetSprite(ACol, ARow);

  if ARow > (Length(FSprites[ACol]) - 1) then
    SetSprite(ACol, ARow);

  Result := FSprites[ACol, ARow];
end;

procedure TGamer1.SetSprite(const ACol, ARow: Integer; AValue: avk_TSkeletTile);
var
  PrevSize, CKL: Integer;
begin
  if ACol > (Length(FSprites) - 1) then
    SetLength(FSprites, ACol + 1);

  if ARow > (Length(FSprites[ACol]) - 1) then begin
    PrevSize := Length(FSprites[ACol]) + 1;
    for CKL := PrevSize to ARow - 1 do begin
      SetLength(FSprites[ACol], CKL);
      FSprites[ACol, CKL - 1] := avk_TSkeletTile.Create;
    end;
    SetLength(FSprites[ACol], ARow + 1);
  end;

  if Assigned(FSprites[ACol, ARow]) then
    FSprites[ACol, ARow].Destroy;

  FSprites[ACol, ARow] := AValue;

  if not Assigned(FSprites[ACol, ARow]) then
    FSprites[ACol, ARow] := avk_TSkeletTile.Create;
end;

function TGamer1.GetColVisible(const ACol: Integer): Integer;
var
  CKL: Integer;
begin
  Result := 0; //мало ли все скрыты
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    if not FSprites[ACol, CKL].Hide then Result := CKL;
end;

procedure TGamer1.SetColVisible(const ACol: Integer; ARow: Integer);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Hide := not(CKL = ARow);
end;

procedure TGamer1.SetPosForAll;
var
  CKL1, CKL2: Integer;
begin
  for CKL1 := 0 to Length(FSprites) - 1 do
    for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do begin
      FSprites[CKL1, CKL2].SetInternalParameters(Position.X, Position.Y, PosAngle, PosScale);
    end;
end;

procedure TGamer1.DoDraw(Sender: TObject);
var
  CKL1, CKL2: Integer;
begin
  if not PosHide then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if not FSprites[CKL1, CKL2].Hide then
          FSprites[CKL1, CKL2].DoDraw;
end;

procedure TGamer1.DoProc(Sender: TObject);
var
  CKL1, CKL2: Integer;
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

  if PosAnimate then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if FSprites[CKL1, CKL2].Animate then
          FSprites[CKL1, CKL2].DoProc;

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

constructor TGamer1.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  SetLength(FSprites, 0);
  PosAnimate := true;
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor TGamer1.Destroy;
var
  CKL0, CKL1: Integer;
begin
  for CKL0 := 0 to Length(FSprites) - 1 do
    for CKL1 := 0 to Length(FSprites[CKL0]) - 1 do begin
      FSprites[CKL0, CKL1].Destroy;
    end;

  inherited Destroy;
end;

procedure TGamer1.MoveSprite(AFlag: byte; AValMX, AValMY: Single);
var
  Leg, Bdy: avk_TSkeletTile;
  CPY, CPX: Single;
  TmpK_UP, TmpK_DOWN, TmpK_LEFT, TmpK_RIGHT: Boolean;
  LegAngle, Speed45: Single;
begin

  CPY := Position.Y;
  CPX := Position.X;

  Speed45 := MoveSpeed / 2;

  TmpK_UP := (AFlag and FLAG_K_UP) > 0;
  TmpK_DOWN := (AFlag and FLAG_K_DOWN) > 0;
  TmpK_LEFT := (AFlag and FLAG_K_LEFT) > 0;
  TmpK_RIGHT := (AFlag and FLAG_K_RIGHT) > 0;

  LegAngle := GetColAngle(0);

  if TmpK_UP and TmpK_LEFT then begin
    LegAngle := -45;
    CPX := CPX - Speed45;
    CPY := CPY - Speed45;
  end else if TmpK_UP and TmpK_RIGHT then begin
    LegAngle := 45;
    CPX := CPX + Speed45;
    CPY := CPY - Speed45;
  end else if TmpK_DOWN and TmpK_RIGHT then begin
    LegAngle :=  135;
    CPX := CPX + Speed45;
    CPY := CPY + Speed45;
  end else if TmpK_DOWN and TmpK_LEFT then begin
    LegAngle :=  -135;
    CPX := CPX - Speed45;
    CPY := CPY + Speed45;
  end else if TmpK_DOWN then begin
    LegAngle := 180;
    CPY := CPY + MoveSpeed;
  end else if TmpK_UP then begin
    LegAngle := 0;
    CPY := CPY - MoveSpeed;
  end else if TmpK_LEFT then begin
    LegAngle :=  -90;
    CPX := CPX - MoveSpeed;
  end else if TmpK_RIGHT then begin
    LegAngle :=  90;
    CPX := CPX + MoveSpeed;
  end;

  Position.X := CPX;
  Position.Y := CPY;

  SetColAngle(0, LegAngle);
  SetColPosition(0, Position);

  SetColAngle(1, m_Angle(CPX, CPY, AValMX, AValMY) - 90);
  SetColPosition(1, Position);

  Leg := FSprites[0, GetColVisible(0)];
  Bdy := FSprites[1, GetColVisible(1)];

  if AFlag = $00 then begin
    Leg.CoolSprite.Frame := Leg.CoolSprite.StartFrame;
    Leg.DoProc;
    Leg.Animate := false;
    Bdy.CoolSprite.Frame := Bdy.CoolSprite.StartFrame;
    Bdy.DoProc;
    Bdy.Animate := false;
    Exit;
  end;

  Leg.Animate := true;
  Bdy.Animate := true;

end;

end.

