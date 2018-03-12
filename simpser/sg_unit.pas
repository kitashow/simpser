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

type

{ TGamer1 }

TGamer1 = class(avk_TFraim)
private
  FSprites: array of array of avk_TSkeletTile;
private
  function GetColAngle(const ACol: Integer): Single;
  function GetColPosition(const ACol: Integer): zglTPoint2D;
  function GetColVisible(const ACol: Integer): Integer;
  function GetSprite(const ACol, ARow: Integer): avk_TSkeletTile;
  procedure SetColAngle(const ACol: Integer; AValue: Single);
  procedure SetColPosition(const ACol: Integer; AValue: zglTPoint2D);
  procedure SetColVisible(const ACol: Integer; ARow: Integer);
  procedure SetSprite(const ACol, ARow: Integer; AValue: avk_TSkeletTile = nil);
public
  Position: zglTPoint2D;
  PosAngle: Single;
  PosScale: Single;
  procedure SetPosForAll;
public
  PosHide: boolean;
  PosAnimate: boolean;
public
  property ColPosition[const ACol: Integer]: zglTPoint2D read GetColPosition write SetColPosition;
  property ColAngle[const ACol: Integer]: Single read GetColAngle write SetColAngle;
  property ColVisible[const ACol: Integer]: Integer read GetColVisible write SetColVisible;
  property Sprite[const ACol, ARow: Integer]: avk_TSkeletTile read GetSprite write SetSprite;
public
  constructor Create(const InParent: avk_TFraim = nil);
  destructor Destroy; override;
end;

implementation

{ TGamer1 }

function TGamer1.GetColAngle(const ACol: Integer): Single;
begin
  Result := FSprites[ACol, 1].Angle; //первый и все
end;

procedure TGamer1.SetColAngle(const ACol: Integer; AValue: Single);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Angle := AValue;
end;

function TGamer1.GetColPosition(const ACol: Integer): zglTPoint2D;
begin
  Result := FSprites[ACol, 1].Point; //первый и все
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
  Result := -1;
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
      FSprites[CKL1, CKL2].SetPoint(Position.X, Position.Y);
      FSprites[CKL1, CKL2].Angle := PosAngle;
      FSprites[CKL1, CKL2].Scale := PosScale;
    end;
end;

constructor TGamer1.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  SetLength(FSprites, 0);
  //OnDraw := DoDraw;
  //OnProc := DoProc;
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

end.

