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
  , zgl_render_target
  , zgl_utils
  , zgl_types
  , zgl_keyboard
  , zgl_main
  , zglChipmunk
  ;

type
{ avk_TIntegerRect }

avk_TIntegerRect = record
  X, Y, W, H : Integer;
end;

{ avk_TSimpleTile }

avk_TSimpleTile = class (TObject)
  private
    FProcRealisation: TThreadMethod;
    FDrawRealisation: TThreadMethod;
    FTexture : zglPTexture; //текстура
    FCoolSprite: clPSprite; //кулспрайт
    FCoolSpriteFrame: Single; //номер фрейма внутри кулспрайта
    TexFrame: Word; //номер фрейма внутри текстуры
    procedure FSetFrame(AValue: Word);
    function FReadFrame: Word;
    procedure stSetTexture(AValue: zglPTexture);
    procedure stSetCoolSprite(AValue: clPSprite);
  protected //процедуры рисования и пересчета
    procedure DrawCoolSprite;
    procedure DrawTexture;
    procedure ProcCoolSprite;
    procedure ProcTexture;
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
    property Texture: zglPTexture read FTexture write stSetTexture; //текстура
    property CoolSprite: clPSprite read FCoolSprite write stSetCoolSprite; //кул спрайт
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
    FTileRotateByHost: boolean;
    FPoint: zglTPoint2D;
    AngleDeg: Single;
    procedure SetAngle(AValue: Single);
    procedure stSetCoolSprite(AValue: clPSprite);
  protected
    procedure ProcCoolSprite;
    procedure DrawTexture(APoint: zglTPoint2D; AAngle: Single);
  public
    SubPoints: array of avk_TSkeletTile;
    CountSubPoints: Integer;
    HostPoint: avk_TSkeletTile;
    procedure SetPoint(AX, AY: Single);
    function RealPoint: zglTPoint2D;
    function RealAngle: Single;
    function HostAngle: Single;
    procedure AddSubPoint(AX, AY: Single);
    procedure SetTileParameters(ATexX, ATexY, AWigh, AHeight, ATexAngle: Single);
    procedure DoDraw;
  public
    property Angle: Single read AngleDeg write SetAngle;
    property Point: zglTPoint2D read FPoint;
    property TileRotateByHost: boolean read FTileRotateByHost write FTileRotateByHost;
    //нужно переопределить
    property CoolSprite: clPSprite read FCoolSprite write stSetCoolSprite; //кул спрайт
  public
    constructor Create;
    destructor Destroy; override;
end;

{ avk_TSimpleSprite }

avk_TSimpleSprite = class (avk_TFraim)
  private
    FOnBeforeProc: TNotifyEvent;
    FOnAfterProc: TNotifyEvent;
    FSkeletPoint: avk_TSkeletTile;
  public
    property SkPnt: avk_TSkeletTile read FSkeletPoint write FSkeletPoint;
    procedure SetParameters(APntX, APntY, ATexX, ATexY, AWigh, AHeight,
      ATexAngle: Single); overload;
    procedure SetParameters(APntX, APntY, AWigh, AHeight: Single; ATexAngle: Single = 0); overload;
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



end.

