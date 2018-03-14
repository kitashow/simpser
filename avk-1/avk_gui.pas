unit avk_gui;

{$mode DELPHI}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  {$IFDEF LINUX}
    ,Unix, UnixType
  {$ENDIF}
  {$IFDEF WINDOWS}
    ,Windows
  {$ENDIF}
  {$ifdef DEBUG}
    , SysUtils
  {$endif}

  //avk
  , avk_btype
  , avk_input
  , avk_resmanager
  , avk_cls
  //zgl
  , zgl_file
  , zgl_render_2d
  , zgl_math_2d
  , zgl_screen
  , zgl_font
  , zgl_primitives_2d
  , zgl_fx
  , zgl_text
  , zgl_textures
  , zgl_textures_tga
  , zgl_textures_png
  , zgl_textures_jpg
  , zgl_sprite_2d
  , zgl_particles_2d
  , zgl_utils
  //, zgl_types
  , zgl_keyboard
  , zgl_main
  , zgl_memory
  , zgl_sound
  , zgl_sound_wav
  , zgl_sound_ogg
  , zgl_render_target
  ;

type

  avk_TMouseState = ( MsoePassive,//статическое состояние
                  MsoeMouseInArea,//Над элементом мыша или палец
                  MsoeMouseDown,//Над элементом нажатая мыша или палец
                  MsoeMouseClick//Элемент кликнули или отжали или тапнули
                  );

  avk_THelpInfo = record
    LabelHelp: String;//о чем справка
    BodyHelp:  String;//Пояснение
    PopUpWndW: Single;//ширина
    PopUpWndH: Single;//высота всплывающего окна
    PopUpTime: Integer;
  end;

  avk_TColorSetElement = record
    FoneColor, FontColor, BorderColor: LongWord;
  end;

const
  POS_DESIGN = 0;
  POS_TOP = 1;
  POS_RIGHT = 2;
  POS_BOTTOM = 3;
  POS_LEFT = 4;

  STYLE_DESIGN = 0;
  STYLE_GEOMETRIC = 1;

  BS_PARENT = 0;
  BS_NONE = 1;
  BS_LINE = 2;

type
  { avk_TElement }

  avk_TElement = class (avk_TFraim)
  private
    FStyleElement: byte;
    FPositionOnScreen: byte;
    FWallpaperColor: LongWord;
    FBorderColor: LongWord;
    FWallpaperWasSettingManual: Boolean;
    FWallpaper: zglPTexture;
  private
    LastMouseState: avk_TMouseState;
    FAreaElement: zglTRect;//Квадрат формы элемента, задается ОТНОСИТЕЛЬНО ВЛАДЕЛЬЦА
    FTransparence: byte;//прозрачность
    function GetParentAsElement:avk_TElement;
    procedure SetTransparence(const InTransp:Byte);
  private
    FBorderStyle: byte;
    FDisable: boolean;
    FOnAfterParentResize: TNotifyEvent;
    FOnChangeStyle: TNotifyEvent;
    FOnResize: TNotifyEvent;
    FFont: zglPFont;
    FFontColor: LongWord;
    procedure Draw; override;
    procedure intProc; override;
    function GetBorderColor: LongWord;
    function GetBorderStyle: byte;
    function GetFont: zglPFont;
    function GetFontColor: LongWord;
    function GetPositionOnScreen: byte;
    function GetStyleElement: byte;
    function GetWallpaper: zglPTexture;
    function GetWallpaperColor: LongWord;
    procedure SetBorderColor(AValue: LongWord);
    procedure SetBorderStyle(AValue: byte);
    procedure SetDisable(AValue: boolean);
    function GetCanBeMouseHost: boolean;
    procedure SetFont(AValue: zglPFont);
    procedure SetPositionOnScreen(AValue: byte);
    procedure SetStyleElement(AValue: byte);
    procedure SetWallpaper(AValue: zglPTexture);
  public
    PopUpWait: Integer;
    GetMouse: boolean;
    HelpInfo: avk_THelpInfo;
    procedure SetAreaElement(const InX,InY,InW,InH: Single); overload; virtual;
    procedure SetAreaElement(const InArea: zglTRect); overload; virtual;
    function GetAbsolyteArea: zglTRect; virtual;
    function GetMouseState: avk_TMouseState; virtual;
    procedure CreateGeometric; virtual;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  public
    property Disable: boolean read FDisable write SetDisable;
    property Font: zglPFont read GetFont write SetFont;
    property FontColor: LongWord read GetFontColor write FFontColor;
    property AreaElement: zglTRect read FAreaElement write SetAreaElement;
    property ParentAsElement:avk_TElement read GetParentAsElement;
    property MouseState: avk_TMouseState read LastMouseState;
    property Transparence: byte read FTransparence write SetTransparence;
    property CanBeMouseHost: boolean read GetCanBeMouseHost;
    property Position: byte read GetPositionOnScreen write SetPositionOnScreen;
    property BorderColor: LongWord read GetBorderColor write SetBorderColor;
    property BorderStyle: byte read GetBorderStyle write SetBorderStyle;
    property StyleElement: byte read GetStyleElement write SetStyleElement;
    property Wallpaper: zglPTexture read GetWallpaper write SetWallpaper;
    property WallpaperColor: LongWord read GetWallpaperColor write FWallpaperColor;
    property WallpaperWasSettingManual: boolean read FWallpaperWasSettingManual;
  public
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnAfterParentResize: TNotifyEvent read FOnAfterParentResize write FOnAfterParentResize;
    property OnChangeStyle: TNotifyEvent read FOnChangeStyle write FOnChangeStyle;
  end;

  { avk_TLogotip }

  avk_TLogotip = class (avk_TElement)
  private
    Ftime: Integer;
    procedure DoDraw(Sender: TObject);
    procedure DoTimer(Sender: TObject);
  public
    texLogo: zglPTexture;
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
  end;

  { avk_TSimpleLabel }

  avk_TSimpleLabel = class (avk_TElement)
  private
    FCaption: UTF8String;
    FOnClick: TNotifyEvent;
    FZglTextFlags: LongWord;
    procedure DoInspectClick(Sender: TObject);
    procedure DoDraw(Sender: TObject);
  public
    Step       : Single;
    Scale      : Single;
    property Caption: UTF8String read FCaption write FCaption;
    property ZglTextFlags: LongWord read FZglTextFlags write FZglTextFlags;
  public
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { avk_TSimpleButton }

  avk_TSimpleButton = class (avk_TElement)
  private
    FAutoSizeLabel: boolean;
    FCountModesButton: Integer;
    FLabel: avk_TSimpleLabel;
    FOnClick: TNotifyEvent;
    FTexButton: zglPTexture;
    CalkAfterClick: Integer;
    procedure SetCountModesButton(AValue: Integer);
    procedure SetTexButton(AValue: zglPTexture);
  public
    procedure DoDraw(Sender: TObject); virtual;
    procedure DoInspectClick(Sender: TObject); virtual;
    procedure SetAreaElement(const InX,InY,InW,InH: Single); overload; override;
  public
    NormalCol,SelectCol,DisableCol: avk_TColorSetElement;
    procedure CreateGeometric; override;
  public
    AutoDivideTexture: boolean;
    PauseAfterClick: Integer;
    Disable: boolean;
    property CountModesButton: Integer read FCountModesButton write SetCountModesButton;
    property TexButton: zglPTexture read FTexButton write SetTexButton;
    property AutoSizeLabel: boolean read FAutoSizeLabel write FAutoSizeLabel;
    property LabelCaption: avk_TSimpleLabel read FLabel;
  public
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { avk_TCircleButton }

  avk_TCircleButton = class (avk_TSimpleButton)
  public
    procedure CreateGeometric; override;
    procedure DoInspectClick(Sender: TObject);
  end;

  { avk_TSwitchButton }

  avk_TSwitchButton = class (avk_TElement)
  private
    FChecked: boolean;
    FCountModesButton: Integer;
    FOnClick: TNotifyEvent;
    FTexButton: zglPTexture;
    CalkAfterClick: Integer;
    procedure DoInspectClick(Sender: TObject);
    procedure SetCountModesButton(AValue: Integer);
    procedure SetTexButton(AValue: zglPTexture);
    procedure DoDraw(Sender: TObject);
  public
    AutoDivideTexture: boolean;
    PauseAfterClick: Integer;
    property Checked:boolean read FChecked write FChecked;
    property TexButton: zglPTexture read FTexButton write SetTexButton;
    property CountModesButton: Integer read FCountModesButton write SetCountModesButton;
  public
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { avk_TSimpleInput }

  avk_TSimpleInput = class (avk_TElement)
  private
    FCountSymbols: Integer;
    FFocuseNow: boolean;
    FOnClick: TNotifyEvent;
    FTextDone: TNotifyEvent;
    FZglTextFlags: LongWord;
    FCursorDemo: Integer;
    FlineAlpha  : Byte;//Чтоб курсор мигал
    FTxtBuffer : String;
    procedure DoInspectClick(Sender: TObject);
    procedure SetCountSymbols(AValue: Integer);
    procedure SetFocuseNow(AValue: boolean);
    procedure DoDraw(Sender: TObject);
  public
    ColPassive : LongWord;
    ColMouseInArea: LongWord;
    ColMouseDown: LongWord;
    ColMouseClick: LongWord;
    ColPrintText: LongWord;
    FontColour : LongWord;
    Step       : Single;
    Scale      : Single;
    ShadowCaption : String;
    Text          : String;
    TransparentBackground: boolean;
    property ZglTextFlags: LongWord read FZglTextFlags write FZglTextFlags;
  public
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnTextDone: TNotifyEvent read FTextDone write FTextDone;
    property FocuseNow: boolean read FFocuseNow write SetFocuseNow;
    property CountSymbols: Integer read FCountSymbols write SetCountSymbols;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { avk_TPanel }

  avk_TPanel = class (avk_TElement)
  private
    FEmpityCentre: boolean;
    FTexPanel: zglPTexture;
    FAutoDivideTexture: boolean;
    FCountModesButton : Integer;
    FSizeOfBlock: zglTRect;
    procedure SetEmpityCentre(AValue: boolean);
    procedure SetTexPanel(AValue: zglPTexture);
    procedure DoDraw(Sender: TObject);
  public
    property TexPanel: zglPTexture read FTexPanel write SetTexPanel;
    property EmpityCentre: boolean read FEmpityCentre write SetEmpityCentre;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;


  { avk_THostForm }

  avk_THostForm = class (avk_TElement)
  private
    FGoDraw: boolean;
    FArhiveNowOpen: boolean;
    FFileResourses: String;
    FFontManager: avk_TFontManager;
    FTextureManager: avk_TTextureManager;
    FSoundManager: avk_TSoundManager;
    FCoolSpriteManager: avk_TCoolSpriteManager;
    FEmitterManager: avk_TEmitterManager;
    procedure FSetFileResourses(inNameFile: String);
    procedure FSetModeArhive(inOpen: boolean);
  protected
    procedure Draw; override;
    procedure intProc; override;
  public
    procedure LoadResource(inNameFile,inNameRes:UTF8String);
    {$ifdef ANDROID}
    procedure Restore;
    {$endif}
    function CalcX2D(const X: Single): Single;
    function CalcY2D(const Y: Single): Single;
  public
    TextureCursor: zglPTexture;
    property FileResourses: String read FFileResourses write FSetFileResourses;
    property FontManager: avk_TFontManager read FFontManager;
    property TexManager: avk_TTextureManager read FTextureManager;
    property SoundManager: avk_TSoundManager read FSoundManager;
    property CoolSpriteManager: avk_TCoolSpriteManager read FCoolSpriteManager;
    property EmitterManager: avk_TEmitterManager read FEmitterManager;
    property ArhResNowOpen: boolean read FArhiveNowOpen write FSetModeArhive;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;


var
  PopUpWaitForUnspecial : Integer = 500;
  ClickTimeoutForUnspecial: Integer = 200;
  function ReloadAsTGA( Texture : zglPTexture): zglPTexture;
  function GetMilliseconds: Double;
  function IdentRect(const FrRect, ScRect:zglTRect): boolean;

implementation
//процедуры
{$INCLUDE avk_gui_proc.inc}
//Элемент
{$INCLUDE avk_gui_telement.inc}
//главное окно
{$INCLUDE avk_gui_thostform.inc}
//логотип
{$INCLUDE avk_gui_logo.inc}
//простая надпись
{$INCLUDE avk_gui_simplelabel.inc}
//простая кнопка
{$INCLUDE avk_gui_tsimplebutton.inc}
//простая круглая кнопка
{$INCLUDE avk_gui_tcirclebutton.inc}
//переключатель
{$INCLUDE avk_gui_tswitchbutton.inc}
//поле ввода
{$INCLUDE avk_gui_tsimpleinput.inc}
//панелька
{$INCLUDE avk_gui_tpanel.inc}

end.

