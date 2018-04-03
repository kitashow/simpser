unit avk_checks;

{$mode delphi}
{$codepage UTF8}

{$ifdef DEBUG}
  {$DEFINE ShowPoints}
{$endif}

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
  , zgl_textures_png
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

  { avk_Checker }

  avk_Checker = class (avk_TFraim)
  private
    FOnBeforeCheck: TNotifyEvent;
  public
    OffCheck: boolean;
    property OnBeforeCheck: TNotifyEvent read FOnBeforeCheck write FOnBeforeCheck;
    procedure DoProc(Sender: TObject);
  public
    constructor Create(const InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

function SpriteFall(AMap: avk_TSimpleMap; ASprite: avk_TSprite; DoCorrectPosition: boolean = false): boolean;

function SpriteInMapFall(AMap: avk_TSimpleMap; ASprite: avk_TSprite): boolean;

implementation

function SpriteFall(AMap: avk_TSimpleMap; ASprite: avk_TSprite; DoCorrectPosition: boolean = false): boolean;
var
  TmpWPort: zglTRect;
  InTileX, InTileY: Integer;
begin
  TmpWPort := AMap.Stage[AMap.CurrentStage].WievPanel;
  InTileX := Trunc((TmpWPort.X + ASprite.Position.X) / AMap.Stage[AMap.CurrentStage].TileSizeW);
  InTileY := Trunc((TmpWPort.Y + ASprite.Position.Y) / AMap.Stage[AMap.CurrentStage].TileSizeH);
  Result := AMap.Stage[AMap.CurrentStage].LOT[InTileX, InTileY] = nil;
  if Result and DoCorrectPosition then begin
    ASprite.Position.X := (InTileX * AMap.Stage[AMap.CurrentStage].TileSizeW - TmpWPort.X) + (AMap.Stage[AMap.CurrentStage].TileSizeW / 2);
    ASprite.Position.Y := (InTileY * AMap.Stage[AMap.CurrentStage].TileSizeH - TmpWPort.Y) + (AMap.Stage[AMap.CurrentStage].TileSizeH / 2);
  end;
end;

function SpriteInMapFall(AMap: avk_TSimpleMap; ASprite: avk_TSprite): boolean;
var
  InTileX, InTileY: Integer;
begin
  InTileX := Trunc(ASprite.MapPosition.X / AMap.Stage[AMap.CurrentStage].TileSizeW);
  InTileY := Trunc(ASprite.MapPosition.Y / AMap.Stage[AMap.CurrentStage].TileSizeH);
  Result := AMap.Stage[AMap.CurrentStage].LOT[InTileX, InTileY] = nil;
end;

{ avk_Checker }

procedure avk_Checker.DoProc(Sender: TObject);
var
  PMF: avk_THostForm;
begin
  if Assigned(OnBeforeCheck) then FOnBeforeCheck(Self);
  //тут проверка столкновений
  PMF := avk_THostForm(Parent);
  //список столкновений это стринглистстринг листов

end;

constructor avk_Checker.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  OnProc := DoProc;
end;

destructor avk_Checker.Destroy;
begin
  inherited Destroy;
end;


end.
