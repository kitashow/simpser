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

  { avk_TSimpleMap2 }

  avk_TSimpleMap = class (avk_TElement)
  public
    HowManyConvert: Integer;
    PrevRoundPnt: zglTPoint2D;
    procedure DoProc(Sender: TObject);
  public
    FCountTileX: integer;
    FCountTileY: integer;
    FOnAfterProc: TNotifyEvent;
    FOnBeforeProc: TNotifyEvent;
    StrX: Integer;
    StpX: Integer;
    StrY: Integer;
    StpY: Integer;
    rtSCR1: zglPRenderTarget;//буфер 1
    rtSCR2: zglPRenderTarget;//буфер 2
    WrtSCR: zglPRenderTarget;//рабочий
    FTileSizeW: Integer;
    FTileSizeH: Integer;
    procedure DoProcLot();
    procedure SetCountTileX(AValue: integer);
    procedure SetTileSizeH(AValue: Integer);
    procedure SetTileSizeW(AValue: Integer);
  public
    WievPanel: zglTRect;
    Hide: boolean;
    FxFlags : LongWord;//флаги, для маштаба не забыть!
    NeedToRender: boolean;
    LOT : array of array of avk_TSimpleTile;
    EmpityTex : zglPTexture;
    Animate: boolean;

 {$IfDef Debug}
  public
    CalcPrgs: Integer;
    CalcDraw: Integer;
 {$EndIf}
  public
    procedure SetAreaElement(const InX,InY,InW,InH: Single);
    procedure DoDraw(Sender: TObject);
    procedure SetSizeMap(const CountW,CountH: Integer);
  public
    property TileSizeW: Integer read FTileSizeW write SetTileSizeW;
    property TileSizeH: Integer read FTileSizeH write SetTileSizeH;
    property CountTileW: Integer read FCountTileX;
    property CountTileH: Integer read FCountTileY;
  public
    property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
    property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;


implementation

//avk_TSimpleTile
{$INCLUDE avk_spr2_tsimpletile.inc}

//avk_TSimpleMap
{$INCLUDE avk_spr2_tsimplemap.inc}

end.
