unit avk_sprites;

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
  , zgl_collision_2d
  , zgl_render_target
  , zgl_utils
  , zgl_types
  , zgl_keyboard
  , zgl_main
  //, zglChipmunk
  ;

const
  TILE_EMPITY = 0;
  TILE_TEXTURE = 1;
  TILE_COOLSPRITE = 2;
  TILE_EMITTER = 3;

  CZ_POINT = 0; //точка, берется от точки скелета, нет доп параметров
  CZ_CIRCLE = 1;
  CZ_LINE = 3;
  CZ_LINERECTANGLE = 3; //4 линии
  CZ_RECTANGLE = 4;

type

avk_TCollisionZone = class;

{ avk_TIntegerRect }

avk_TIntegerRect = record
  X, Y, W, H : Integer;
end;

{ avk_TSimpleTile }

avk_TSimpleTile = class (TObject)
  private
    FTypeOfTile: byte;
    FProcRealisation: TThreadMethod;
    FDrawRealisation: TThreadMethod;
    FTexture : zglPTexture; //текстура
    FCoolSprite: clPSprite; //кулспрайт
    FEmitter: zglPEmitter2D; //эмиттер
    FParticles: zglTPEngine2D; //движек эмиттера
    FCoolSpriteFrame: Single; //номер фрейма внутри кулспрайта
    TexFrame: Word; //номер фрейма внутри текстуры
    procedure FSetFrame(AValue: Word);
    function FReadFrame: Word;
    procedure stSetTexture(AValue: zglPTexture);
    procedure stSetCoolSprite(AValue: clPSprite);
    procedure stSetEmitter(AValue: zglPEmitter2D);
    procedure DrawNothing;
    procedure ProcNothing;
  protected //процедуры рисования и пересчета
    procedure DrawCoolSprite;
    procedure DrawTexture;
    procedure DrawEmitter;
    procedure ProcCoolSprite;
    procedure ProcTexture;
    procedure ProcEmitter;
  public
    //Расчет кадров
    StartCadre,StopCadre : Integer;//начало и конец отрисовки
    RateCadre, CurrentCadreCalk : Integer;//скорость смены кадров, текущий в цикле "замедления"
    NowCadre : Integer;//текущий кадр
    EndCadre : Integer;//начало всегда 0, это конечный
  public
    X, Y    : Single;//для отрисовки расчитываемые в обработке расчетов
    W       : Single;//ширина
    H       : Single;//высота
    Scale   : Single;//масштаб
    Alpha   : Integer;//прозрачность
    FxFlags : LongWord;//флаги, для маштаба не забыть!
    TexAngle: Single;//угол внутри текстуры
    Hide    : boolean; //скрыть
    Animate : boolean; //это анимированный тайл
    property NowFrame: Word read FReadFrame write FSetFrame;
    property TypeOfTile: byte read FTypeOfTile;
    property Texture: zglPTexture read FTexture write stSetTexture; //текстура
    property CoolSprite: clPSprite read FCoolSprite write stSetCoolSprite; //кул спрайт
    property Emitter: zglPEmitter2D read FEmitter write stSetEmitter; //эмиттер
    procedure SetTexFrameSize(AValueW, AValueH: Word);
  public
    procedure DoDraw;
    property DoProc: TThreadMethod read FProcRealisation;
  public
    constructor Create;
    destructor Destroy; override;
end;

{ avk_TTileMap }

avk_TTileMap = class (TObject)
  private
    FWievPanel: zglTRect;
    FCountTileX: integer; //по Х
    FCountTileY: integer; //по Y
    rtSCR1: zglPRenderTarget;//буфер 1
    rtSCR2: zglPRenderTarget;//буфер 2
    WrtSCR: zglPRenderTarget;//рабочий
    FTileBildInWP: avk_TIntegerRect;
    FTileSizeW: Integer;
    FTileSizeH: Integer;
    procedure FSetWievPanel(AValue: zglTRect; AAdditionTile: Integer=1);
    procedure DoProcLot;
    procedure SetTileSizeH(AValue: Integer);
    procedure SetTileSizeW(AValue: Integer);
  {$IfDef Debug}
  public
  {$Else}
  private
  {$EndIf}
    CalcPrgs, CalcDraw: Integer;
    FFrecvency, FSFrecvency: Integer;
    procedure DoLoyer;
  public
    procedure SetWievPanelSize(W, H : Single);
    procedure SetWiewPanelX(AValue: Single);
    procedure SetWiewPanelY(AValue: Single);
    property WievPanel: zglTRect read FWievPanel write FSetWievPanel;
  public
    Hide: boolean;
    Angle: Single;
    Alpha: Byte;
    FxFlags : LongWord;//флаги, для маштаба не забыть!
    NeedToRender: boolean;
    Animate: boolean;
    LOT : array of array of avk_TSimpleTile; //горизонталь, вертикаль
  public
    procedure Draw(AX, AY, AW, AH: Single);
    procedure DoProc(Sender: TObject);
  public
    property TileSizeW: Integer read FTileSizeW write SetTileSizeW;
    property TileSizeH: Integer read FTileSizeH write SetTileSizeH;
    property CountTileW: Integer read FCountTileX;
    property CountTileH: Integer read FCountTileY;
    procedure SetSizeMap(const ACountW, ACountH: Integer);
  public
    procedure ClearMap;
    constructor Create;
    destructor Destroy; override;
end;

{avk_TSimpleMap}

avk_TSimpleMap = class (avk_TElement)
  private
    FCountStage: Integer; //этажей
    FStage: array of avk_TTileMap;
    procedure ClearMap;
    function FGetStage(InID : Integer): avk_TTileMap;
    procedure FSetCountStage(AValue: Integer);
  private
    FOnAfterProc: TNotifyEvent;
    FOnBeforeProc: TNotifyEvent;
    FCurrentStage: Integer;
    FPercentDistance: Integer;
    function FGetTileSizeW: Integer;
    function FGetTileSizeH: Integer;
    function FGetWievPanel: zglTRect;
  public
    property CountStage: Integer read FCountStage write FSetCountStage;
    property Stage[InID: Integer]: avk_TTileMap read FGetStage;
    property CurrentStage: Integer read FCurrentStage;
    //property PercentDistance: Integer read FPercentDistance;
    property TileSizeW: Integer read FGetTileSizeW;
    property TileSizeH: Integer read FGetTileSizeH;
    //property WievPanel: zglTRect read FGetWievPanel;
    {$IfDef Debug}
    function CalcPrgs: Integer;
    function CalcDraw: Integer;
    function FSFrecvency: Integer;
    {$EndIf}
  public
    procedure SetMapSize(const ACountW, ACountH: Integer;
      const AOnlyCurrent: Boolean = false);
    procedure SetWievPanelAndTileSize(const AWievPanelW, AWievPanelH: Single;
      const ATileSizeW, ATileSizeH: Integer);
    procedure SetStageAndPercentDistance(const ACurrentStage, APercentDistance: Integer);
    procedure MoveWievPanelMap(const AGrowX, AGrowY: Single);
  public
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
    property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
end;

{ avk_TSkeletTile }

avk_TSkeletTile = class (avk_TSimpleTile)
  private
    FCollisionZone: avk_TCollisionZone;
    FTileRotateByHost: boolean;
    FPoint: zglTPoint2D;
    AngleDeg: Single;
    procedure SetAngle(AValue: Single);
    procedure stSetCoolSprite(AValue: clPSprite);
    procedure stSetEmitter(AValue: zglPEmitter2D);
    procedure SetTileParameters(ATexX, ATexY, AWigh, AHeight, ATexAngle: Single);
    function FHostAnimate: Boolean;
  protected
    procedure ProcCoolSprite;
    procedure ProcEmitter;
    procedure DrawTexture(APoint: zglTPoint2D; AAngle: Single);
  public
    SubPoints: array of avk_TSkeletTile;
    CountSubPoints: Integer;
    HostPoint: avk_TSkeletTile;
    procedure SetPoint(AX, AY: Single);
    function RealPoint: zglTPoint2D;
    function RealAngle: Single;
    function HostAngle: Single;
    procedure AddSubPoint(const AX: Single = 0; const AY: Single = 0; const AA: Single = 0);
    procedure SetInternalParameters(const APositionX: Single = 0;
      const APositionY: Single = 0; const AInternalAngle: Single = 0;
      const AScale: Single = 0; const ATextureX: Single = 0; const ATextureY: Single = 0;
      const ATextureW: Single = 0; const ATextureH: Single = 0);
    procedure DoDraw;
    procedure DoProc;
  public
    property Angle: Single read AngleDeg write SetAngle;
    property Point: zglTPoint2D read FPoint;
    property TileRotateByHost: boolean read FTileRotateByHost write FTileRotateByHost;
    //нужно переопределить
    property CoolSprite: clPSprite read FCoolSprite write stSetCoolSprite; //кул спрайт
    property Emitter: zglPEmitter2D read FEmitter write stSetEmitter; //эмиттер
  public
    constructor Create;
    destructor Destroy; override;
end;

{ avk_TCollisionZone }

avk_TCollisionZone = class (TObject)
  FTypeOfZone: byte;
  FHostSkeletTile: avk_TSkeletTile;
  FRadius: Single; //Радиус, если тип круг
  FRectangle: zglTRect; //прямоугольник
  FPoints: array [0..3] of zglTPoint2D; //4 точки для реализации разных типов

  FBufferCircle: Single;
  FBufferRectangle: zglTRect;
  FBufferPoints: array [0..3] of zglTPoint2D;

public
  procedure SetZone(ARadius: Single); overload; //это зона круг
  procedure SetZone(APoint1, APoint2: zglTPoint2D); overload; //это зона линия
  procedure SetZone(APoint1, APoint2, APoint3, APoint4: zglTPoint2D); overload; //это зона прямоугольник 4 линии
  procedure SetZone(AX, AY, AW, AH: Single); overload; //это зона прямоугольник
  procedure CalkBuffer;
  //function Check(AColZone: avk_TCollisionZone): boolean;
public
  constructor Create(const AHostSkeletTile: avk_TSkeletTile = nil);
end;


{ avk_TSprite }

avk_TSprite = class(avk_TFraim)
private
  FSprites: array of array of avk_TSkeletTile;
  function GetColCount: Integer;
  function GetRowCount(const ACol: Integer): Integer;
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
  property ColCount: Integer read GetColCount;
  property RowCount[const ACol: Integer]: Integer read GetRowCount;
public
  MapPosition: zglTPoint2D;
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
end;

{ avk_TSimpleSprite }

avk_TSimpleSprite = class (avk_TSprite)
public
  property SkPnt: avk_TSkeletTile read FSprites[0, 0] write FSprites[0, 0];
  constructor Create(const InParent: avk_TFraim = nil);
end;


implementation

//avk_TSimpleTile
{$INCLUDE avk_sprites_tsimpletile.inc}

//avk_TTileMap
{$INCLUDE avk_sprites_ttilemap.inc}

//avk_TSimpleMap
{$INCLUDE avk_sprites_tsimplemap.inc}

//avk_TSkeletPoint
{$INCLUDE avk_sprites_tskeletpoint.inc}

//avk_TSimpleSprite
{$INCLUDE avk_sprites_tsimplesprite.inc}

//avk_TCollisionZone
{$INCLUDE avk_sprites_tcollisionzone.inc}

//avk_TSprite
{$INCLUDE avk_sprites_tsprite.inc}

end.

