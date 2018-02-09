unit avk_spriterecord;

{$mode objfpc}{$H+}

interface

uses
  Classes//Блин... не избежать
  , avk_gui
  , avk_btype
  , avk_texmanager
  , avk_input
  , zgl_textures
  , zgl_utils
  , zgl_screen
  , zgl_math_2d
  , zgl_font
  , zgl_primitives_2d
  , zgl_collision_2d
  , zgl_fx
  , zgl_text
  , zgl_textures_tga
  , zgl_sprite_2d
  , zgl_types
  , zgl_keyboard
  , zgl_main
  , zgl_camera_2d
  ;

type
  avk_TTypeOfFigure = ( avk_Image,//для спрайтов всегда
                        avk_Circle, avk_Point, avk_Line, avk_Rectangle);

  avk_PRI = ^avk_TRI;
  PArrayOfavk_PRI = ^TArrayOfavk_PRI;
  TArrayOfavk_PRI = array of avk_PRI;

  { avk_RAI }

  avk_TRI = class
  private
    FID      : Integer;
  public
    ExtId   : Integer;//для общения с сервером
    Name    : String[60];
    NameHost: String[60];//если совпадает с нэйм - то это главный спрайт (родитель)
    ClassNameHost: String[60];//всегда д/б класс тип главного спрайта
    HostPnt : avk_PRI;//место родителя для быстрого взятия
    Texture : zglPTexture;
    TexFrame : Single;//внутри текстуры, не слой!
    TexAngle : Single;//Внутри текстуры, не поворот спрайта
    RCenter    : zglTPoint2D;//Сдвиг центра относительно центра текстуры
    Hide    : Boolean;//Прятать
    Collizion: Boolean;//не решенная коллизия прямо сейчас
    Layer   : Integer;//слой, для отрисовки от нижнего к верхнему
    //ключевые точки
    MCenter    : zglTPoint2D;//центр спрайта в абсолютных координатах, он же центр вращения
    LCenter    : zglTPoint2D;//Верхний угол от центра
    VPoint     : zglTPoint2D;//конец вектора движения, начало центр и 0, 0 для расчетов
    X, Y    : Single;//для отрисовки расчитываемые в обработке расчетов
    W       : Single;//ширина
    H       : Single;//высота или радиус для TypeOfFigure = avk_Circle
    Angle   : Single;//поворот спрайта
    Scale   : Single;//масштаб
    Alpha   : Integer;
    FxFlags : LongWord;
    GeoHost   : avk_PRI;//если привязан к другому спрайту
    TypeOfFigure: avk_TTypeOfFigure;//Для стека колизий
    //Расчет кадров
    StartCadre,StopCadre : Integer;//начало и конец отрисовки
    RateCadre, CurrentCadreCalk : Integer;//скорость смены кадров, текущий в цикле "замедления"
    NowCadre : Integer;//текущий кадр
    EndCadre : Integer;//начало всегда 0, это конечный
    //Расчет импульса и скорости движения
    Impulse, MSpead: Single;
    //Подчиненные конвееры
    ImageArPRI, CollArPRI: PArrayOfavk_PRI;
    IndImageArPRI, IndCollArPRI: PArrayOfavk_PRI;
  public
    constructor Create(var inArPRI: PArrayOfavk_PRI);
    destructor Destroy; override;
  public
    property Id: Integer read FID;
  end;

  { avk_CollectionPRI }

  avk_CollectionPRI = class
  private
    FArPRI: PArrayOfavk_PRI;
    FIndArPRI: PArrayOfavk_PRI;
    function GetArPRI: PArrayOfavk_PRI;
    procedure SetArPRI(AValue: PArrayOfavk_PRI);
  public
    constructor Create(var inArPRI: PArrayOfavk_PRI = nil;var inIndArPRI: PArrayOfavk_PRI = nil);
    destructor Destroy; override;
  public
    property ArPRI: PArrayOfavk_PRI read GetArPRI write SetArPRI;
    property IndArPRI: PArrayOfavk_PRI read FIndArPRI write FIndArPRI;
 end;

implementation

{ avk_CollectionPRI }

function avk_CollectionPRI.GetArPRI: PArrayOfavk_PRI;
begin
  Result := FArPRI;
end;

procedure avk_CollectionPRI.SetArPRI(AValue: PArrayOfavk_PRI);
begin
  FArPRI:=AValue;
end;

constructor avk_CollectionPRI.Create(var inArPRI: PArrayOfavk_PRI = nil;var inIndArPRI: PArrayOfavk_PRI = nil);
begin
  if (inArPRI = nil) or (not Assigned(inArPRI)) then
    New(inArPRI);
  if (inIndArPRI = nil) or (not Assigned(inIndArPRI)) then
    New(inIndArPRI);
  FArPRI:=inArPRI;
  FIndArPRI:=inIndArPRI;
end;

destructor avk_CollectionPRI.Destroy;
begin
  if (FArPRI <> nil) and (Assigned(FArPRI)) then begin
  //посмотрим
  end;
  Dispose(FArPRI);
  inherited Destroy;
end;

{ avk_RAI }

constructor avk_TRI.Create(var inArPRI: PArrayOfavk_PRI);
var
  PrevLen: Integer;
  function emppnt: zglTPoint2D;
  begin
    Result.X:=0;
    Result.Y:=0;
  end;

begin
    FId      := -1;
    ExtId   := -1;
    Texture := nil;
    TexFrame := 1;
    TexAngle := 0;
    Hide    := false;
    Collizion := false;
    Layer   := 0;
    X       := 0; Y := 0;
    W       := 0; H := 0;
    MCenter := emppnt;
    LCenter := emppnt;
    RCenter := emppnt;
    VPoint  := emppnt;
    VPoint.X:= 1;//направлен вниз
    Angle   := 0;
    Scale   := 0;
    Alpha   := 0;
    FxFlags := 0;
    NameHost:= '';
    HostPnt := nil;
    ClassNameHost := '';
    GeoHost   := nil;
    TypeOfFigure := avk_Image;
    RateCadre := 10;
    CurrentCadreCalk := 0;
    StartCadre := 0;
    StopCadre:=0;
    NowCadre := 0;
    EndCadre := 0;
    Impulse  := 0;
    MSpead   := 0;
    ImageArPRI := nil;
    CollArPRI := nil;
    IndImageArPRI := nil;
    IndCollArPRI := nil;

  PrevLen := Length(inArPRI^);
  SetLength(inArPRI^,PrevLen+1);
  inArPRI^[PrevLen] := @Self;
  FId := PrevLen;
end;

destructor avk_TRI.Destroy;
var
  i: Integer;
begin
  if ImageArPRI <> nil then begin
    for i := 0 to Length(ImageArPRI^) do
      ImageArPRI^[i]^.Destroy;
    SetLength(ImageArPRI^,0);
    ImageArPRI := nil;
  end;
  if CollArPRI <> nil then begin
    for i := 0 to Length(CollArPRI^) do
      CollArPRI^[i]^.Destroy;
    SetLength(CollArPRI^,0);
    CollArPRI := nil;
  end;
  if IndImageArPRI <> nil then begin//Это индекс,
    SetLength(ImageArPRI^,0);
    ImageArPRI := nil;
  end;
  if CollArPRI <> nil then begin
    for i := 0 to Length(CollArPRI^) do
      CollArPRI^[i]^.Destroy;
    SetLength(CollArPRI^,0);
    CollArPRI := nil;
  end;
  inherited Destroy;
end;

end.

