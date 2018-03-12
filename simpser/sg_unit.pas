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
public
  FLegSprite: array [0..3] of avk_TSkeletTile;
  FBodySprite: array [0..1] of avk_TSkeletTile;
  Position: zglTPoint2D;
  PosAngle: Single;
  PosSkale: Single;
  procedure SetNotHide(ALegNum, ABodyNum: Integer);
  procedure UsePos;
public
  procedure DoDraw(Sender: TObject);
  procedure DoProc(Sender: TObject);
public
  constructor Create(const InParent: avk_TFraim = nil);
  destructor Destroy; override;
end;

implementation

{ TGamer1 }

procedure TGamer1.SetNotHide(ALegNum, ABodyNum: Integer);
var
  CKL: Integer;
begin
  //ноги
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    FLegSprite[CKL].Hide := not(CKL = ALegNum);
  //тело
  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    FBodySprite[CKL].Hide := not(CKL = ABodyNum);
end;

procedure TGamer1.UsePos;
var
  CKL: Integer;
begin
  //ноги
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    FLegSprite[CKL].SetInternalParameters(Position.X, Position.Y, PosAngle, PosSkale);
  //тело
  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    FBodySprite[CKL].SetInternalParameters(Position.X, Position.Y, PosAngle, PosSkale);
end;

procedure TGamer1.DoDraw(Sender: TObject);
var
  CKL: Integer;
begin
  //ноги
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    if not FLegSprite[CKL].Hide then
       FLegSprite[CKL].DoDraw;
  //тело
  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    if not FBodySprite[CKL].Hide then
      FBodySprite[CKL].DoDraw;
end;

procedure TGamer1.DoProc(Sender: TObject);
var
  CKL: Integer;
begin
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    if FLegSprite[CKL].Animate then
       FLegSprite[CKL].DoProc;

  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    if FBodySprite[CKL].Animate then
      FBodySprite[CKL].DoProc;
end;

constructor TGamer1.Create(const InParent: avk_TFraim);
var
  CKL: Integer;
begin
  inherited Create(InParent);
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    FLegSprite[CKL] := avk_TSkeletTile.Create;
  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    FBodySprite[CKL] := avk_TSkeletTile.Create;
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor TGamer1.Destroy;
var
  CKL: Integer;
begin
  for CKL := 0 to SizeOf(FLegSprite) - 1 do
    FLegSprite[CKL].Destroy;

  for CKL := 0 to SizeOf(FBodySprite) - 1 do
    FBodySprite[CKL].Destroy;

  inherited Destroy;
end;

end.

