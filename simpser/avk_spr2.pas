unit avk_spr2;

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
  , zgl_main;

type
{ avk_TIntegerRect }

avk_TIntegerRect = record
  X, Y, W, H : Integer;
end;

{ avk_TSimpleTile }

avk_TSimpleTile = class (TObject)
  private
    FAngle: Single;
    FOnAfterProc: TNotifyEvent;
    FOnBeforeProc: TNotifyEvent;
    function GetAngle: Single;
    procedure SetAngle(AValue: Single);
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
    Texture : zglPTexture; //текстура
    Hide    : boolean;
    Animate : boolean;
    TexFrame: Word; //номер фрейма внутри текстуры
    HaveAlpha: boolean;
  public
    property Angle: Single read GetAngle write SetAngle;//поворот спрайта
    property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
    property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
  public
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
end;

{ avk_TSimpleMap }

avk_TSimpleMap = class (avk_TElement)
  {$IfDef Debug}
  public
    CalcPrgs: Integer;
    CalcDraw: Integer;
  {$EndIf}
  private
    FOnAfterProc: TNotifyEvent;
    FOnBeforeProc: TNotifyEvent;
  private
    FWievPanel: zglTRect;
    FCountLoyer: integer; //слоев (этажей)
    FCountTileX: integer; //по Х
    FCountTileY: integer; //по Y
    rtSCR1: zglPRenderTarget;//буфер 1
    rtSCR2: zglPRenderTarget;//буфер 2
    WrtSCR: zglPRenderTarget;//рабочий
    FTileBildInWP: avk_TIntegerRect;
    FTileSizeW: Integer;
    FTileSizeH: Integer;
    procedure DoProcLot();
    procedure SetTileSizeH(AValue: Integer);
    procedure SetTileSizeW(AValue: Integer);
  private
    HowManyConvert: Integer;
    procedure DoLoyer(ALoyer, ASVert, ASHort, AFVert, AFHort: Integer);
  public
    procedure FSetWievPanel(AValue: zglTRect);
    procedure SetWievPanelSize(W, H : Single);
    procedure SetWiewPanelX(AValue: Single);
    procedure SetWiewPanelY(AValue: Single);
    property WievPanel: zglTRect read FWievPanel write FSetWievPanel;
  public
    Hide: boolean;
    FxFlags : LongWord;//флаги, для маштаба не забыть!
    NeedToRender: boolean;
    NowLoyer: Integer;
    LOT : array of array of array of avk_TSimpleTile; //слой, горизонталь, вертикаль
    Animate: boolean;
    PersemtPreviousLoyer: Integer;
  public
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    property TileSizeW: Integer read FTileSizeW write SetTileSizeW;
    property TileSizeH: Integer read FTileSizeH write SetTileSizeH;
    property CountLoyer: Integer read FCountLoyer;
    property CountTileW: Integer read FCountTileX;
    property CountTileH: Integer read FCountTileY;
    procedure SetSizeMap(const ACountL, ACountW, ACountH: Integer);
  public
    property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
    property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
  public
    procedure ClearMap;
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
end;

implementation

//avk_TSimpleTile
{$INCLUDE avk_spr2_tsimpletile.inc}

//avk_TSimpleMap
{$INCLUDE avk_spr2_tsimplemap.inc}

end.

