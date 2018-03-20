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

TShotEvent = procedure (const Sender: avk_TFraim; const AStartPoint, ATargetPoint: zglTPoint2D) of object;

{ TGamer1 }

TGamer1 = class(avk_TSprite)
private
  FBulletStep :Integer;
  FOnRelizeShot: TShotEvent;
public
  MoveSpeed: Single;
  BulletPause :Integer;
  FMinimalRadiusTarget: Single;
  FCurrentRadiusTarget: Single;
  FStepWarmRadiusTarget: Single;
  FStepColdRadiusTarget: Single;
  procedure MoveSprite(AFlag: byte; AMousePosition: zglTPoint2D);
  {$IfDef Debug}
  procedure DoFinishDraw(Sender: TObject);
  {$EndIf}

public
  property OnRelizeShot: TShotEvent read FOnRelizeShot write FOnRelizeShot;
public
  constructor Create(const InParent: avk_TFraim = nil);
  destructor Destroy; override;
end;

{ TBullet1 }

TBullet1 = class(avk_TSprite)
private
  FOnRelizeDethBullet: TNotifyEvent;
  procedure DoSimpleDethBullet(Sender: TObject);
public
  FStartPoint, FFinishPoint: zglTPoint2D;
  FCurAngle: Single;
  FPower: Single;
  FLosePowerInStep: Single;
  FSpeedFly: Single;
  {$IfDef Debug}
  procedure DoDraw(Sender: TObject);
  {$EndIf}
  procedure DoProc(Sender: TObject);
  procedure StartMoveBullet(AStartPoint, AFinishPoint: zglTPoint2D);
public
  constructor Create(const InParent: avk_TFraim = nil);
public
  property OnRelizeDethBullet: TNotifyEvent read FOnRelizeDethBullet write FOnRelizeDethBullet;
end;


implementation

//TGamer1
{$INCLUDE tgamer1.inc}

//TBullet1
{$INCLUDE tbullet1.inc}

end.

