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

  { avk_TCircleCollisionZone }

  avk_PCircleCollisionZone = ^avk_TCircleCollisionZone;

  avk_TCircleCollisionZone = record
    Centre: zglTPoint2D;
    Radius: Single;
    //Quality: Word;
  end;

  avk_TRotate4Points = array [0..3] of zglTPoint2D;

  { avk_TAdditionalPoint }

  avk_TAdditionalPoint = class
  private
    FX, FY, FAngle: Single;
    function FGetX: Single;
    function FGetY: Single;
  public
    property Angle: Single read FAngle write FAngle;
    property X: Single read FGetX write FX;//с учетом угла
    property Y: Single read FGetY write FY;//с учетом угла
    constructor Create;
  end;

  avk_TRealPointsSprite = record
    //реальные координаты для рисования предварительный расчет
    CPX: Single;
    CPY: Single;
    X: Single;
    Y: Single;
    W: Single;
    H: Single;
    Angle: Single;
    TexAngle: Single;
    RotatingPivot: zglTPoint2D;
    CollisionZone: avk_TCircleCollisionZone;
  end;

  { avk_TSimpleSprite }

  avk_TSimpleSprite = class (avk_TFraim)
  private
    FCentralPoint: zglTPoint2D; //Центральная точка, начало координат
    FWighHeght: zglTPoint2D; //Ширина и высота
    FWighHeghtScale: zglTPoint2D; //Размер точки по ширине и высоте при изменении разрешения монитора например, так то 1, 1.
    FSquarePoint: zglTPoint2D; //Откуда начинать рисовать
    FTexAngle: Single; //Поворот внутри текстуры
    FAngle: Single; //Поворот спрайта
    FOnAfterProc: TNotifyEvent; //После расчетов
    FOnBeforeProc: TNotifyEvent; //перед расчетами
    FRotationPivot: boolean; //ось координат не в центре текстуры
    procedure FSetAngle(AValue: Single); //Установка поворота
    procedure FSetCPX(AValue: Single);
    procedure FSetCPY(AValue: Single);
  public
    //установки
    procedure SetSquarePoint(InX, InY: Single); //задать отклонения начала рисования от центральной точки
    procedure SetScaleWH(AScaleW, AScaleH: Single); //задать масштаб по ширине и высоте
    procedure SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle: Single); overload; //задать размеры без отклонений по оси вращения
    procedure SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle, ASquareX, ASquareY: Single); overload; //задать размеры и ось вращения
  private
    //координаты с учетом центральной точки
    function FGetX: Single;
    function FGetY: Single;
    function FGetW: Single;
    function FGetH: Single;
  public
    property CentralPoint: zglTPoint2D read FCentralPoint;
    property CPX: Single read FCentralPoint.X write FSetCPX;
    property CPY: Single read FCentralPoint.Y write FSetCPY;
  public
    property X: Single read FGetX; //верх лево вершина угол при 0% угле точка начала рисования
    property Y: Single read FGetY; //верх лево вершина угол при 0% угле точка начала рисования
    property W: Single read FGetW; //Ширина
    property H: Single read FGetH; //Высота
    property Angle: Single read FAngle write FSetAngle;//поворот спрайта
    property IsRotatingPivot: boolean read FRotationPivot;//ось вращения для внешних функций расчета
  public
    CollisionZone: avk_PCircleCollisionZone; //Главная зона коллизий спрайта
    procedure SetCollisionZone(X, Y, Radius: Single); //Установить  главную зону коллизий
  private
    //реальные координаты для рисования
    fRPS: avk_TRealPointsSprite;
    function GetRotatePoints: avk_TRotate4Points;
    procedure FCalkRealPoint;
  public
    //Расчет кадров
    StartCadre,StopCadre : Integer; //начало и конец отрисовки
    RateCadre, CurrentCadreCalk : Integer; //скорость смены кадров, текущий в цикле "замедления"
    NowCadre : Integer; //текущий кадр
    EndCadre : Integer; //начало всегда 0, это конечный
  public
    Scale   : Single; //масштаб
    Alpha   : Integer; //прозрачность
    FxFlags : LongWord; //флаги, для маштаба не забыть!
    Texture : zglPTexture; //текстура
    Hide    : boolean; //скрыть
    Animate : boolean; //анимировать
    TexFrame: Word; //номер фрейма внутри текстуры
    property TexAngle:Single read FTexAngle write FTexAngle; //внутренний поворот текстуры
  public
    AdditionalPoints: TStringList; //список дополнительных точек
    procedure AddAdditionalPoint(Name: String; INX, INY: Single); //координаты относительные
    function GetAdditionalPointByName(AName : String): avk_TAdditionalPoint; //объект по имени
    function GetRealAdditionalPointByName(AName : String): zglTPoint2D; //включая родительские координаты
  public
    property OnBeforeProc: TNotifyEvent read FOnBeforeProc write FOnBeforeProc;
    property OnAfterProc: TNotifyEvent read FOnAfterProc write FOnAfterProc;
  public
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
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
  private
    PrevRoundPnt: zglTPoint2D;
    procedure DoProc(Sender: TObject);
  private
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
    procedure DoProcLot(InMode: boolean);
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

  { avk_TSkeletPoint }

  avk_TSkeletPoint = class (avk_TFraim)
  private
    FAngle: Single;
    function GetAngle: Single;
    procedure SetAngle(AValue: Single);
  public
    property Angle: Single read GetAngle;
    property StartAngle: Single read FAngle write SetAngle;
  private
    FCalkPoint: zglTPoint2D;
  public
    property X: Single read FCalkPoint.X;
    property Y: Single read FCalkPoint.Y;
  public
    WighHeghtScale: zglTPoint2D;
    Host: avk_TSkeletPoint;
    StartPoint: zglTPoint2D;
    procedure Calk;
    {$IfDef Debug}
    procedure DoAfterDraw(Sender: TObject);
    {$EndIf}
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { avk_TSkeletSprite }

  avk_TSkeletSprite = class (avk_TSkeletPoint)
  public
    Sprite: avk_TSimpleSprite;
    procedure SetSprite(InName: Utf8String = ''; InTexture: zglPTexture = nil;
      InFrameWidth: Word = 0; InFrameHeight: Word = 0;
      ACentralX: Single = 0; ACentralY: Single = 0;
      AWigh: Single = 0; AHeight: Single = 0;
      AAngle: Single = 0; ASquareX: Single = 0;
      ASquareY: Single = 0;
      StopCadre: Integer = 0; RateCadre: Integer = 0);

  public
    Tile: avk_TSimpleTile;
    //procedure SetTile();
  public
    constructor Create(const InParent: avk_TFraim; InName: Utf8String; InSx: Single = 0; InSy: Single = 0; InSprite: avk_TSimpleSprite = nil);
    destructor Destroy; override;
  end;
  //служебные функции

  function avk_GetRotatePoints(X, Y, Width, Height, Angle: Single): avk_TRotate4Points; overload;

  function avk_GetRotatePoint (X, Y, XAxle, YAxle, Angle: Single): zglTPoint2D; overload;
  function avk_GetRotatePoint (X, Y, Angle: Single): zglTPoint2D; overload;

implementation

const
  FLIP_TEXCOORD : array[ 0..3 ] of zglTTexCoordIndex = ( ( 0, 1, 2, 3 ), ( 1, 0, 3, 2 ), ( 3, 2, 1, 0 ), ( 2, 3, 0, 1 ) );

//avk_GetRotatePoints
{$INCLUDE avk_sprites_getrotatepoints.inc}

//avk_TAdditionalPoint
{$INCLUDE avk_sprites_tadditionalpoint.inc}

//avk_TSimpleSprite
{$INCLUDE avk_sprites_tsimplesprite.inc}

//avk_TSimpleTile
{$INCLUDE avk_sprites_tsimpletile.inc}

//avk_TSimpleMap
{$INCLUDE avk_sprites_tsimplemap.inc}

//avk_TCompSprite
{$INCLUDE avk_tcompsprite.inc}

end.

