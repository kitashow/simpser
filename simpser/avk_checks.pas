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
    ColZoneList: TStringList;
  public
    OffCheck: boolean;
    property OnBeforeCheck: TNotifyEvent read FOnBeforeCheck write FOnBeforeCheck;
    procedure DoProc(Sender: TObject);
    function ColZoneHaveCollision(AColZone: avk_TCollisionZone): boolean;
  public
    constructor Create(const InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

function SpriteFall(ASprite: avk_TSprite; AMapCheck: avk_TTileMap = nil; DoCorrectPosition: boolean = false): boolean;

implementation

function SpriteFall(ASprite: avk_TSprite; AMapCheck: avk_TTileMap = nil; DoCorrectPosition: boolean = false): boolean;
var
  TmpWPort: zglTRect;
  InTileX, InTileY: Integer;
  AMap: avk_TTileMap;
  ASP: zglTPoint2D;
begin
  AMap := nil;
  ASP := ASprite.Position;

  if AMapCheck = nil then
    AMap := ASprite.Map
  else begin
    AMap := AMapCheck;
    ASP.X := ASP.X + AMap.WievPanel.X;
    ASP.Y := ASP.Y + AMap.WievPanel.Y;
  end;

  if AMap = nil then Exit;

  InTileX := Trunc(ASP.X / AMap.TileSizeW);
  InTileY := Trunc(ASP.Y / AMap.TileSizeH);

  Result := false;
  Result := (InTileX >= AMap.CountTileW) or
         (InTileY >= AMap.CountTileH) or
         (InTileX < 0) or (InTileY < 0);

  if not Result then
    Result := AMap.LOT[InTileX, InTileY] = nil;

  if Result and DoCorrectPosition then begin
    TmpWPort := AMap.WievPanel;
    ASprite.Position.X := (InTileX * AMap.TileSizeW - TmpWPort.X) + (AMap.TileSizeW / 2);
    ASprite.Position.Y := (InTileY * AMap.TileSizeH - TmpWPort.Y) + (AMap.TileSizeH / 2);
  end;
end;

{ avk_Checker }

procedure avk_Checker.DoProc(Sender: TObject);
var
  PMF: avk_THostForm;
  CKL, CKL1: Integer;
begin
  if Assigned(OnBeforeCheck) then FOnBeforeCheck(Self);
  //тут проверка столкновений
  PMF := avk_THostForm(Parent);

  //пересчет всех зон коллизий
  //список столкновений это стринглист стринглистов
  //формирование списка
  ColZoneList.Clear;

  for CKL := 0 to PMF.Count - 1 do begin
    if not(PMF.ListNom[CKL] is avk_TSprite) then Continue;
    with avk_TSprite(PMF.ListNom[CKL]) do
      for CKL1 := 0 to ColCount - 1 do
        if Assigned(Sprite[CKL1, ColVisible[CKL1]].CollizionZone) then begin
           Sprite[CKL1, ColVisible[CKL1]].CollizionZone.CalkBuffer;
           ColZoneList.AddObject(Name + '.' + u_IntToStr(CKL1) + '.' + u_IntToStr(ColVisible[CKL1]), Sprite[CKL1, ColVisible[CKL1]].CollizionZone);
        end;
  end;
end;

function avk_Checker.ColZoneHaveCollision(AColZone: avk_TCollisionZone): boolean;
var
  CKL: Integer;
begin
  Result := false;
  for CKL := 0 to ColZoneList.Count - 1 do begin
    if not Assigned(ColZoneList.Objects[CKL]) then Continue;
    Result := Result or AColZone.Check(avk_TCollisionZone(ColZoneList.Objects[CKL]));
    if Result then Break;
  end;
end;

constructor avk_Checker.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  OnProc := DoProc;
  ColZoneList := TStringList.Create;
  ColZoneList.Sorted := true;
end;

destructor avk_Checker.Destroy;
begin
  inherited Destroy;
  ColZoneList.Destroy;
end;


end.
