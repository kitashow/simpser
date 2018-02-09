unit avk_arbitr;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
  Classes//Блин... не избежать
  , avk_gui
  , avk_btype
  , avk_texmanager
  , avk_input
  , zgl_textures
  , zgl_utils
  , zgl_screen
  //для примера, надо выносить отсюда
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

  avk_PRecAboutImg = ^avk_RecAboutImg;
  avk_RecAboutImg = record
    ID      : Integer;
    ExtId   : Integer;//для общения с сервером
    Name    : String[60];
    NameHost: String[60];//если совпадает с нэйм - то это главный спрайт (родитель)
    HostPnt : avk_PRecAboutImg;//место родителя для быстрого взятия
    Texture : zglPTexture;
    TexFrame : Single;//внутри текстуры, не слой!
    TexAngle : Single;//Внутри текстуры, не поворот спрайта
    RCenter    : zglTPoint2D;//Сдвиг центра относительно центра текстуры
    Hide    : Boolean;
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
    GeoHost   : avk_PRecAboutImg;//если привязан к другому спрайту
    ClassNameHost: String[60];//всегда д/б класс тип главного спрайта
    TypeOfFigure: avk_TTypeOfFigure;//Для стека колизий
    //Расчет кадров
    StartCadre,StopCadre : Integer;//начало и конец отрисовки
    RateCadre, CurrentCadreCalk : Integer;//скорость смены кадров, текущий в цикле "замедления"
    NowCadre : Integer;//текущий кадр
    EndCadre : Integer;//начало всегда 0, это конечный
    //Расчет импульса и скорости движения
    Impulse, MSpead: Single;
  end;

  { avk_TCollectionRecAbotImg }

  avk_TCollectionRecAbotImg = class
  private
    function GetRecByLy(InNum : Integer): avk_RecAboutImg;
  protected
    FSortBy : String;
    FParent : avk_RecAboutImg;
    FList  : array of avk_PRecAboutImg;
    FIndList: array of avk_PRecAboutImg;
    function GetCount: Integer;
    procedure SetCollisionInRec(const inRec, inVerRec: avk_RecAboutImg);
  public
    function GetRecAs_zglTCircle(const inRec: avk_RecAboutImg):zglTCircle;
    function GetRecAs_zglTLine(const inRec: avk_RecAboutImg):zglTLine;
    function GetRecAs_zglTPoint2D(const inRec: avk_RecAboutImg):zglTPoint2D;
    function GetRecAs_zglTRect(const inRec: avk_RecAboutImg):zglTRect;
  public
    function CollizionBtvZone(const inRec, inVerRec: avk_RecAboutImg):boolean;
  public
    function GetMaxExtId: Integer;//сомнительной нужности
    function GetRecByExtId(const inExtId:Integer):avk_RecAboutImg;
    function MakeNextCadre(const inIDPriem : Integer): boolean;//только видимость, не меняет позиции
    function IspectCollizion (const InHostName: String; MakeIvent: boolean = true): boolean;//проверить на коллизии
    function RotateSpr (const InHostName: String; inGraduce: Single; ColUndo: boolean = false):boolean ;//поворот
    function MoveUDSpr (const InHostName: String; inSpead: Single):boolean;//двинуть вперед-назад на точку
    procedure CalcSpr(const InHostName: String; inVisual: zglTRect);//расчет в окне
  public
    function  GetMaxLayer (const inName : String = ''): Integer; //если пустой, то вообще макс слой
    procedure InspectFraims;
    function  GetRecById( const inID : Integer ) : avk_RecAboutImg;
    function  GetRecByNum(const inNum : Integer ) : avk_RecAboutImg;
    function  GetIdByName(const inName : String = ''; InId: Integer = -1) : Integer;//если пустое имя, то максимальный ид, если ид и имя не пустые, то следующий в рамках имени
    procedure SetRecById(const inID : Integer; inFraim: avk_RecAboutImg);
    procedure SetRecByNum( inNum : Integer; inFraim: avk_RecAboutImg);
    procedure SortByID( inLo, inHi : Integer );
    procedure SortByFraim( inLo, inHi : Integer);
    procedure DelById (inId: Integer);
    function AddNewRec(inRec: avk_RecAboutImg):avk_PRecAboutImg;
    procedure ClearAll;
  public
    function GetNextIdInHostName (const inHostName : String = ''; inId: Integer = 0): Integer;
    function GetByHostName (inName : String): avk_TCollectionRecAbotImg;
    function GetMainByHostName (const inName : String = ''): avk_RecAboutImg;
    function GetNextHostName (const inName : String = ''): avk_RecAboutImg;
    function GetCountNames: Integer;
    function RecIsEmpity (inRec: avk_RecAboutImg): boolean;
    procedure DelByHostName (inName : String);
  public
    constructor Create;
    destructor Destroy; override;
  public
    property Count: Integer read GetCount;
    property CountNames: Integer read GetCountNames;
    property Parent: avk_RecAboutImg read FParent;
    property ListId[InID :Integer]: avk_RecAboutImg read GetRecById;
    property ListNm[InNum :Integer]: avk_RecAboutImg read GetRecByNum;
    property ListLy[InNum :Integer]: avk_RecAboutImg read GetRecByLy;
  end;

  { avk_TSpeedPnl }

  avk_TArbitre = class;

  avk_TSpeedPnl = class (TSimpleImage)
  private
    TexSpeedMarker, TexSpeedCentre: zglPTexture;
    AreaSpeedMarker, AreaSpeedCentre : zglTRect;
    AngleSM: Single;
    function GetSpeed: Single;
    procedure SetSpeed(AValue: Single);
  public
    procedure DoClick ( inFraim: avk_TFraim = nil );
    procedure DoProc ( inFraim: avk_TFraim = nil ); override;
    procedure DoDraw ( inFraim: avk_TFraim = nil ); override;
  public
    constructor Create(const InParent: avk_TArbitre; InName: String = '');
    destructor Destroy; override;
  public
    property Speed: Single read GetSpeed write SetSpeed;
  end;

  { avk_TRotationPnl }

  avk_TRotationPnl = class (TSimpleImage)
  private
    AngleBefore, AngleAfter, AngleRot: Single;
    AngleStartPress: PSingle;
    FRotAngle: PSingle;
    function GetRAngle: Single;
    procedure SetRAngle(AValue: Single);
  public
    procedure DoClick ( inFraim: avk_TFraim = nil );
    procedure DoProc ( inFraim: avk_TFraim = nil ); override;
    {$IfDef Debug}
      procedure DoDraw ( inFraim: avk_TFraim = nil ); override;
    {$EndIf}
  public
    constructor Create(const InParent: avk_TArbitre; InName: String = '');
    destructor Destroy; override;
  public
    property RotAngle: Single read GetRAngle;
  end;


  { avk_TArbitre }

  avk_TArbitre = class (avk_TElement)
  private
    FSpeedPnl: avk_TSpeedPnl;
    FRotationPnl: avk_TRotationPnl;
  protected
    FCollectRecSpr  : avk_TCollectionRecAbotImg;//Спрайты
    FCollectRecCln  : avk_TCollectionRecAbotImg;//Коллизии //резерв
    FTexturemanager : avk_TTexmanager;
    FVisualScr      : zglTRect;
    FAbsolyteScr    : zglTRect;
    FHithFactor     : Single;
    FWighFactor     : Single;
    FCentrePersone  : avk_PRecAboutImg;
    FCamMain        : zglTCamera2D;
  public
    {$IfDef Debug}
      PnlHowMany: TNewsDlg; //дестрой не надо
    {$EndIf}
    procedure MakeSimpleEx;
  public
    procedure CreateDrivingPan;
  public
    procedure Draw; override;
    procedure Proc; override;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = ''; inTexman: avk_TTexmanager = nil);
    destructor Destroy; override;
  public
    property Texturemanager : avk_TTexmanager read FTexturemanager write FTexturemanager;
  end;


const
  PIDiv180 = 0.017453292519943295769236907684886;

implementation

procedure Rotate(RotAng: Double; x, y: Single; var Nx, Ny: Single); overload;
var
  SinVal: Single;
  CosVal: Single;
begin
  RotAng := RotAng * PIDiv180;
  m_SinCos(RotAng,SinVal,CosVal);
  //SinVal := Sin(RotAng);
  //CosVal := Cos(RotAng);
  Nx := x * CosVal - y * SinVal;
  Ny := y * CosVal + x * SinVal;
end;

procedure Rotate(RotAng: Double; x, y, ox, oy: Single; var Nx, Ny: Single); overload;
begin
  Rotate(RotAng, x - ox, y - oy, Nx, Ny);
  Nx := Nx + ox;
  Ny := Ny + oy;
end;

function avk_GetEmpityRecAboutImg: avk_RecAboutImg;
var
  li: byte;
  function emppnt: zglTPoint2D;
  begin
    Result.X:=0;
    Result.Y:=0;
  end;

begin
  with result do begin
    Id      := -1;
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
  end;
end;

function avk_EqualRecAboutImg (const inRec1, inRec2: avk_RecAboutImg): boolean;
begin
  Result := false;
  with inRec1 do begin
    Result := (Id      = inRec2.ID)
    and(ExtId   = inRec2.ID)
    and(TexFrame = inRec2.TexFrame)
    and(Layer   = inRec2.Layer)
    and(X       = inRec2.X) and (Y = inRec2.Y)
    and(W       = inRec2.W) and (H = 0)
    and(MCenter.x = inRec2.MCenter.X)
    and(MCenter.Y = inRec2.MCenter.Y)
    and(Angle   = 0);
    //да вроде хватит
    //Scale   = 0;
    //Alpha   = 0;
    //FxFlags = 0;
    //NameHost= '';
    //ClassNameHost := '';
    //GeoHost   := nil;
    //TypeOfFigure := avk_Rectangle;
    //RateCadre := 10;
    //StartCadre := 0;
    //NowCadre := 0;
  end;

end;

{ avk_TRotationPnl }

function avk_TRotationPnl.GetRAngle: Single;
begin
  Result := 0;
  if FRotAngle <> nil then begin
    Result := FRotAngle^;
    Dispose (FRotAngle);
    FRotAngle:=nil;
  end;
end;

procedure avk_TRotationPnl.SetRAngle(AValue: Single);
begin
  if FRotAngle = nil then begin
    new(FRotAngle);
    FRotAngle^:=(AValue);
  end;
end;

procedure avk_TRotationPnl.DoClick(inFraim: avk_TFraim);
var
  InspectFinger: byte;
begin
  //уже ясно что мыш тут, надо понять какая
  for InspectFinger := 0 to FingerAnalyses do begin
    if avk_MouseInRect(GetAbsolyteArea,InspectFinger) then Break;
  end;
  AngleAfter := 0;
  if avk_MouseIsDown(M_BLEFT,InspectFinger) then begin
     AngleAfter:= m_Angle( avk_MouseIsX (InspectFinger), avk_MouseIsY (InspectFinger),
                           GetAbsolyteArea.X, GetAbsolyteArea.Y+AreaElement.H );
     if AngleStartPress = nil then begin
        new(AngleStartPress);
        AngleStartPress^ := AngleAfter;
        AngleBefore := AngleAfter;
     end;
     if FRotAngle = nil then begin
       new(FRotAngle);
       FRotAngle^:= - (AngleBefore - AngleAfter);
     end;
  end;
  if avk_MouseIsUp (M_BLEFT,InspectFinger) then begin
     AngleAfter :=  m_Angle( avk_MouseIsX (InspectFinger), avk_MouseIsY (InspectFinger),
                           GetAbsolyteArea.X, GetAbsolyteArea.Y+AreaElement.H );
     if AngleStartPress <> nil then begin
        Angle := AngleRot - ((AngleStartPress^ - AngleAfter)*5);
        Dispose(AngleStartPress);
        AngleStartPress := nil;
        Exit;
     end;
  end;
  if MouseState <> MsoePassive then begin
    Angle := AngleRot - ((AngleBefore - AngleAfter)*5);
    if Assigned(FRotAngle) and (FRotAngle <> nil) then FRotAngle^ := - (AngleBefore - AngleAfter);
  end;
end;

procedure avk_TRotationPnl.DoProc(inFraim: avk_TFraim);
begin
  inherited DoProc(inFraim);
  if avk_TArbitre(Parent).FCentrePersone <> nil then begin
    Angle := avk_TArbitre(Parent).FCentrePersone^.Angle;
  end;
  if MouseState = MsoeMouseDown then DoClick(Self);
  if MouseState = MsoePassive then begin
    AngleRot := Angle;
  end;
end;
{$IfDef Debug}
procedure avk_TRotationPnl.DoDraw(inFraim: avk_TFraim);
begin
  inherited DoDraw(inFraim);
  if Assigned(FRotAngle) then
    if FRotAngle <> nil then begin
      fx2d_SetVCA( $000000, $000000, $000000, $0000000, 255, 255, 255, 255 );
      text_Draw( Font, 7, GetAbsolyteArea.Y + (GetAbsolyteArea.H/2) - 17,
                 u_FloatToStr(FRotAngle^), TEXT_FX_VCA);
    end;
end;
{$EndIf}
constructor avk_TRotationPnl.Create(const InParent: avk_TArbitre; InName: String
  );
begin
  inherited Create(InParent,InName,InParent.Texturemanager.GetTextureNames('Штурвал'));
  Clickable := true;
  OnClick:=@DoClick;
  AngleBefore := 0;
  AngleAfter := 0;
  AngleStartPress := nil;
  FRotAngle := nil;
end;

destructor avk_TRotationPnl.Destroy;
begin
  inherited Destroy;
  if FRotAngle<>nil then Dispose(FRotAngle);
  if AngleStartPress<>nil then Dispose(AngleStartPress);
end;

{ avk_TSpeedPnl }

function avk_TSpeedPnl.GetSpeed: Single;
begin
  Result := (AngleSM - 315) * 0.1;
end;

procedure avk_TSpeedPnl.SetSpeed(AValue: Single);
begin
  AngleSM := 315 + (AValue * 10);
end;

procedure avk_TSpeedPnl.DoClick(inFraim: avk_TFraim);
var
  InspectFinger: byte;
  TmpAngle: Single;
begin
  //уже ясно что мыш тут, надо понять какая
  for InspectFinger := 0 to FingerAnalyses do begin
    if avk_MouseInRect(GetAbsolyteArea,InspectFinger) then Break;
  end;
  AngleSM := m_Angle( avk_MouseIsX (InspectFinger), avk_MouseIsY (InspectFinger),
           GetAbsolyteArea.X+AreaElement.W, GetAbsolyteArea.Y+AreaElement.H) + 90;
end;

procedure avk_TSpeedPnl.DoProc(inFraim: avk_TFraim);
begin
  inherited DoProc(inFraim);// переписать целиком, там только клик
  if MouseState = MsoeMouseDown then DoClick(Self);
  if MouseState = MsoePassive then AngleSM := 315;
  if AreaSpeedCentre.W <> (AreaElement.W / 2) then begin
     AreaSpeedCentre.X := GetAbsolyteArea.X + (AreaElement.W / 2);
     AreaSpeedCentre.Y := GetAbsolyteArea.Y + (AreaElement.H / 2);
     AreaSpeedCentre.W := (AreaElement.W / 2);
     AreaSpeedCentre.H := (AreaElement.H / 2);
     AreaSpeedMarker.X := GetAbsolyteArea.X + (AreaElement.W - 10) + 3;
     AreaSpeedMarker.Y := GetAbsolyteArea.Y +3;
     AreaSpeedMarker.W := 20;
     AreaSpeedMarker.H := AreaElement.H;
  end;
end;

procedure avk_TSpeedPnl.DoDraw(inFraim: avk_TFraim);
begin
  inherited DoDraw(inFraim);
  if Scale <> 1 then  begin
    fx2d_SetScale( Scale, Scale );
    asprite2d_Draw( TexSpeedCentre, AreaSpeedCentre.X, AreaSpeedCentre.Y, AreaSpeedCentre.W,
                    AreaSpeedCentre.H, Angle, Round( Frame ), Transparence, FxFlags or FX2D_SCALE );
  end else begin
    asprite2d_Draw( TexSpeedCentre, AreaSpeedCentre.X, AreaSpeedCentre.Y, AreaSpeedCentre.W,
                    AreaSpeedCentre.H, Angle, Round( Frame ), Transparence, FxFlags );
  end;
  fx2d_SetRotatingPivot(AreaSpeedMarker.W/2,AreaSpeedMarker.H);//Верхний левый угол спрайта начало коорд
  if Scale <> 1 then  begin
    fx2d_SetScale( Scale, Scale );
    asprite2d_Draw( TexSpeedMarker, AreaSpeedMarker.X, AreaSpeedMarker.Y, AreaSpeedMarker.W,
                    AreaSpeedMarker.H, AngleSM, Round( Frame ), Transparence, FxFlags or FX2D_SCALE or FX2D_RPIVOT);
  end else begin
    asprite2d_Draw( TexSpeedMarker, AreaSpeedMarker.X, AreaSpeedMarker.Y, AreaSpeedMarker.W,
                    AreaSpeedMarker.H, AngleSM, Round( Frame ), Transparence, FxFlags or FX2D_RPIVOT);
  end;
  {$IfDef Debug}
    fx2d_SetVCA( $000000, $000000, $000000, $0000000, 255, 255, 255, 255 );
    text_Draw( Font, GetAbsolyteArea.X + GetAbsolyteArea.W - 40, GetAbsolyteArea.Y + GetAbsolyteArea.H - 17,
               u_FloatToStr(Speed), TEXT_FX_VCA);
  {$EndIf}
end;

constructor avk_TSpeedPnl.Create(const InParent: avk_TArbitre; InName: String);
begin
  TexSpeedMarker := InParent.Texturemanager.GetTextureNames('Стрелка скорости');
  TexSpeedCentre := InParent.Texturemanager.GetTextureNames('Центр шкалы скорости');
  AngleSM := 315;
  inherited Create(InParent,InName,InParent.Texturemanager.GetTextureNames('Шкала скорости'));
  Clickable := true;
  OnClick:=@DoClick;
end;

destructor avk_TSpeedPnl.Destroy;
begin
  inherited Destroy;
end;

{ avk_TArbitre }

procedure avk_TArbitre.MakeSimpleEx;
var
  p1: avk_RecAboutImg;
  Nmm: String;
  Ph1: avk_PRecAboutImg;
  ForDubl: avk_TCollectionRecAbotImg;
  Nexx: Integer;
begin
  p1 := avk_GetEmpityRecAboutImg;
  with p1 do begin
    ClassNameHost := 'avk_TBaseSprite';
    Name:='Ex1';
    NameHost := Name;
    Hide     := False;
    ExtId := 1;
    X := 123; Y := 200;
    MCenter.X := 300; LCenter.X := -61;
    MCenter.Y := 300; LCenter.Y := -61;
    W := 122; H := 122;
    Texture := FTexturemanager.GetTexNames('ПерсонажТест').Texture;
    TexFrame   := 2;
    TexAngle   := 0;
    Angle   := 0;
    Scale := 1;
    Layer := 0;
    Alpha := 255;
    EndCadre:=8;
    StopCadre:=4;
    FxFlags := FX_BLEND;
  end;
  Ph1 := FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    ClassNameHost := 'avk_TBaseSprite';
    Name:='Ex3';
    NameHost := 'Ex1';
    HostPnt := Ph1;
    Hide     := False;
    ExtId := 1;
    X := 123; Y := 200;
    MCenter.X := 0; LCenter.X := -61;
    MCenter.Y := 0; LCenter.Y := -61;
    W := 122; H := 122;
    TexFrame   := 1;
    Angle   := 0;
    Scale := 1;
    Layer := 0;
    Alpha := 255;
    StartCadre := 4;
    StopCadre := 8;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex2';
    NameHost := 'Ex1';
    Hide     := False;
    ExtId := 1;
    X := 210; Y := 220;
    MCenter.X := 100; LCenter.X := -61;
    MCenter.Y := 20; LCenter.Y := -61;
    W := 122; H := 122;
    Texture := FTexturemanager.GetTexNames('Кнопка Закрыть').Texture;
    TexFrame   := 1;
    Layer := 0;
    TexAngle   := 170;
    Angle   := 0;
    Scale := 1;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=20;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex10';
    StartCadre := 18;
    StopCadre := 20;
    EndCadre:=20;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex4';
    X := 205; Y := 230;
    MCenter.X := 105; LCenter.X := -61;
    MCenter.Y := 30; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 173;
    StartCadre := 3;
    StopCadre := 5;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex9';
    StartCadre := 15;
    StopCadre := 17;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex5';
    X := 200; Y := 240;
    MCenter.X := 100; LCenter.X := -61;
    MCenter.Y := 40; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 176;
    StartCadre := 6;
    StopCadre := 8;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex8';
    StartCadre := 12;
    StopCadre := 14;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex6';
    X := 200; Y := 250;
    MCenter.X := 100; LCenter.X := -61;
    MCenter.Y := 50; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 180;
    StartCadre := 9;
    StopCadre := 11;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);

  with p1 do begin
    Name:='Ex11';
    NameHost := 'Ex1';
    Hide     := False;
    ExtId := 1;
    X := 210; Y := 220;
    MCenter.X := -100; LCenter.X := -61;
    MCenter.Y := 20; LCenter.Y := -61;
    W := 122; H := 122;
    Texture := FTexturemanager.GetTexNames('Кнопка Закрыть').Texture;
    TexFrame   := 1;
    Layer := 0;
    TexAngle   := 190;
    Angle   := 0;
    Scale := 1;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=20;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex12';
    StartCadre := 18;
    StopCadre := 20;
    EndCadre:=20;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex13';
    X := 205; Y := 230;
    MCenter.X := -105; LCenter.X := -61;
    MCenter.Y := 30; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 187;
    StartCadre := 3;
    StopCadre := 5;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex14';
    StartCadre := 15;
    StopCadre := 17;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex15';
    X := 200; Y := 240;
    MCenter.X := -100; LCenter.X := -61;
    MCenter.Y := 40; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 184;
    StartCadre := 6;
    StopCadre := 8;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex16';
    StartCadre := 12;
    StopCadre := 14;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex17';
    X := 200; Y := 250;
    MCenter.X := -100; LCenter.X := -61;
    MCenter.Y := 50; LCenter.Y := -61;
    W := 122; H := 122;
    TexAngle   := 180;
    StartCadre := 9;
    StopCadre := 11;
    FxFlags := FX_BLEND;
  end;
  FCollectRecSpr.AddNewRec(p1);
//Колизии
  p1 := avk_GetEmpityRecAboutImg;
  with p1 do begin
    ClassNameHost := 'avk_TBaseSprite';
    Name:='Ex18';
    NameHost := 'Ex1';
    HostPnt := Ph1;
    Hide     := False;
    ExtId := 1;
    X := 123; Y := 200;
    MCenter.X := 0; LCenter.X := 0;
    MCenter.Y := 0; LCenter.Y := 0;
    W := 0; H := 43;
    TexFrame   := 2;
    TexAngle   := 0;
    Angle   := 0;
    Scale := 1;
    Layer := 0;
    Alpha := 255;
    EndCadre:=4;
    StopCadre:=4;
    TypeOfFigure := avk_Circle;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex19';
    Hide     := False;
    ExtId := 1;
    X := 210; Y := 220;
    TypeOfFigure := avk_Line;
    MCenter.X := 0;
    MCenter.Y := 0;
    LCenter.X := -90;
    LCenter.Y := 10;
    W := 5; H := 5;
    Layer := 0;
    Angle   := 0;
    Scale := 1;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=2;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex20';
    Hide     := False;
    ExtId := 1;
    X := 210; Y := 220;
    TypeOfFigure := avk_Line;
    MCenter.X := 0;
    MCenter.Y := 0;
    LCenter.X := 90;
    LCenter.Y := 10;
    W := 5; H := 5;
    Layer := 0;
    Angle   := 0;
    Scale := 1;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=2;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex21';
    Hide     := False;
    ExtId := 1;
    TypeOfFigure := avk_Circle;
    MCenter.X := 100;
    MCenter.Y := 20;
    LCenter.X := 0;
    LCenter.Y := 0;
    W := 0; H := 40;
    Layer := 0;
    Angle   := 0;
    Scale := 1;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=20;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex22';
    StartCadre := 18;
    StopCadre := 20;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex23';
    MCenter.X := 105;
    MCenter.Y := 30;
    StartCadre := 3;
    StopCadre := 5;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex24';
    StartCadre := 15;
    StopCadre := 17;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex25';
    MCenter.X := 100;
    MCenter.Y := 40;
    StartCadre := 6;
    StopCadre := 8;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex26';
    StartCadre := 12;
    StopCadre := 14;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex27';
    MCenter.X := 100;
    MCenter.Y := 50;
    StartCadre := 9;
    StopCadre := 10;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex28';
    TypeOfFigure := avk_Circle;
    MCenter.X := -100;
    MCenter.Y := 20;
    W := 0; H := 40;
    StartCadre := 0;
    StopCadre := 2;
    EndCadre:=20;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex29';
    StartCadre := 18;
    StopCadre := 21;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex30';
    MCenter.X := -105;
    MCenter.Y := 30;
    StartCadre := 3;
    StopCadre := 5;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex31';
    StartCadre := 15;
    StopCadre := 17;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex32';
    MCenter.X := -100;
    MCenter.Y := 40;
    StartCadre := 6;
    StopCadre := 8;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex33';
    StartCadre := 12;
    StopCadre := 14;
  end;
  FCollectRecSpr.AddNewRec(p1);
  with p1 do begin
    Name:='Ex34';
    MCenter.X := -100;
    MCenter.Y := 50;
    StartCadre := 9;
    StopCadre := 10;
  end;
  FCollectRecSpr.AddNewRec(p1);
  FCentrePersone := Ph1;
  //Теперь его продублим
  ForDubl := FCollectRecSpr.GetByHostName('Ex1');
  Nmm := 'Exm2_0';
  for Nexx:=0 to ForDubl.Count - 1 do begin
    p1 := ForDubl.ListNm[Nexx];
    p1.Name := 'Exm2_'+u_IntToStr(Nexx);
    p1.NameHost := Nmm;
    if p1.Name = p1.NameHost then begin
      p1.Name := Nmm;
      p1.NameHost := Nmm;
      p1.MCenter.X := 800; p1.MCenter.Y := 300;
      p1.HostPnt:=nil;
      Ph1 := FCollectRecSpr.AddNewRec(p1);
    end else begin
      p1.HostPnt:=Ph1;
      FCollectRecSpr.AddNewRec(p1);
    end;
  end;
  ForDubl.Destroy;

end;

procedure avk_TArbitre.CreateDrivingPan;
begin
  if GetIdByName('СкоростьПан') > -1 then Exit;//Уже создана
  FSpeedPnl := avk_TSpeedPnl.Create(Self,'СкоростьПан');
  FSpeedPnl.SetAreaElement(FVisualScr.W - 100, FVisualScr.H - 100, 100, 100);
  FRotationPnl := avk_TRotationPnl.Create(Self,'ГрадусПан');
  FRotationPnl.SetAreaElement(- 100, FVisualScr.H - 100, 200, 200);
end;

procedure avk_TArbitre.Draw;
var
  lokNXT: Integer;
  TmpRec: avk_RecAboutImg;
  {$IfDef Debug}
    TmpPar: avk_RecAboutImg;
    ColColZone,SMFL: LongWord;
  {$EndIf}
begin
  //Тут всякая отрисовка соответственно максимально высокая скорость должна быть
  if Assigned(FCollectRecSpr) then
  if FCollectRecSpr.Count > 0 then begin
    if FCentrePersone <> nil then begin//вращаем камеру;
      FCamMain.Angle := 180 - FCentrePersone^.Angle;
      cam2d_Set( @FCamMain );
    end;
    for lokNXT:= 0 to FCollectRecSpr.Count - 1 do begin
      TmpRec := FCollectRecSpr.ListLy[lokNXT];
      with TmpRec do begin
        if Hide then Continue;//не казать
        if TypeOfFigure = avk_Image then begin
          {$IfDef Debug}
            pr2d_Rect( X * FWighFactor, Y * FHithFactor, W * FWighFactor, H * FHithFactor, $4c5866, 150, PR2D_SMOOTH);
          {$EndIf}
          if Scale <> 1 then  begin
            fx2d_SetScale( Scale, Scale );
            asprite2d_Draw( Texture, X * FWighFactor, Y * FHithFactor, W * FWighFactor, H * FHithFactor, (Angle + TexAngle), Round( TexFrame ), Alpha, FxFlags or FX2D_SCALE );
          end else begin
            asprite2d_Draw( Texture, X * FWighFactor, Y * FHithFactor, W * FWighFactor, H * FHithFactor, (Angle + TexAngle), Round( TexFrame ), Alpha, FxFlags );
          end;
        end;
        {$IfDef Debug}
          if TypeOfFigure <> avk_Image then begin
            if TmpRec.Collizion then begin
              ColColZone := $be7377;
              SMFL := PR2D_FILL;
            end else begin
              ColColZone := $006633;
              SMFL := PR2D_SMOOTH;
            end;
          end;
          case TypeOfFigure of
            avk_Circle: begin
              pr2d_Circle(X* FWighFactor , Y * FHithFactor, H, ColColZone, 150, 32, SMFL);
            end;
            avk_Point: begin
              pr2d_Circle(X * FWighFactor, Y * FHithFactor, 3, ColColZone, 150, 32, SMFL);
            end;
            avk_Line: begin
              TmpPar := FCollectRecSpr.GetMainByHostName(NameHost);
              pr2d_Line( (TmpPar.MCenter.X + MCenter.X + LCenter.X - FAbsolyteScr.X) * FWighFactor, (TmpPar.MCenter.Y + MCenter.Y + LCenter.Y - FAbsolyteScr.Y) * FHithFactor,
                         (TmpPar.MCenter.X + MCenter.X + H - FAbsolyteScr.X) * FWighFactor, (TmpPar.MCenter.Y + MCenter.Y + W - FAbsolyteScr.Y)* FHithFactor,
                         ColColZone, 150, SMFL);
            end;
            avk_Rectangle: begin
              pr2d_Rect( X * FWighFactor, Y * FHithFactor, W * FWighFactor, H * FHithFactor, ColColZone, 150, SMFL);
            end;
          end;
          if Name <> NameHost then begin
             TmpPar := FCollectRecSpr.GetMainByHostName(NameHost);
             pr2d_Line( (TmpPar.MCenter.X - FAbsolyteScr.X)* FWighFactor, (TmpPar.MCenter.Y - FAbsolyteScr.Y)* FHithFactor,
                        ((TmpPar.MCenter.X + MCenter.X) - FAbsolyteScr.X)* FWighFactor, ((TmpPar.MCenter.Y + MCenter.Y) - FAbsolyteScr.Y)* FHithFactor, $dae4da, 150, PR2D_SMOOTH);
          end;
        {$EndIf}
      end;
    end;
    if FCentrePersone <> nil then begin//сбрасываем камеру;
      cam2d_Set( nil );
    end;
  end;
  inherited Draw;
end;

procedure avk_TArbitre.Proc;
var
  lokNXT: Integer;
  TmpRec: avk_RecAboutImg;
  {$IfDef Debug}
    Anle1: array [0..3] of Single;
  {$EndIf}
begin
  if Texturemanager <> nil then CreateDrivingPan;
  if Assigned(FCollectRecSpr) then
    if FCollectRecSpr.Count > 0 then begin
      if FCentrePersone <> nil then begin//вращаем камеру;
        FAbsolyteScr.X := FCentrePersone^.MCenter.X - (FAbsolyteScr.W / 2);
        FAbsolyteScr.Y := FCentrePersone^.MCenter.Y - (FAbsolyteScr.H / 2);
      end;
      //FCollectRecSpr.SortByID(0,FCollectRecSpr.Count - 1);
      for lokNXT:= 0 to FCollectRecSpr.Count - 1 do begin
        if FCollectRecSpr.ListId[lokNXT].NameHost = FCollectRecSpr.ListId[lokNXT].Name then
          FCollectRecSpr.CalcSpr(FCollectRecSpr.ListId[lokNXT].NameHost,FAbsolyteScr);
        FCollectRecSpr.MakeNextCadre(lokNXT);
      end;
      //FCollectRecCln.SortByID(0,FCollectRecCln.Count - 1);
      for lokNXT:= 0 to FCollectRecCln.Count - 1 do begin
        if FCollectRecCln.ListId[lokNXT].NameHost = FCollectRecCln.ListId[lokNXT].Name then
          FCollectRecCln.CalcSpr(FCollectRecCln.ListId[lokNXT].NameHost,FAbsolyteScr);
        FCollectRecCln.MakeNextCadre(lokNXT);
      end;
    end;
  {$IfDef Debug}
    PnlHowMany.HeaderNews:='Объектов анализа: '+u_IntToStr(FCollectRecSpr.CountNames)+'->'+u_IntToStr(FCollectRecSpr.Count);
    PnlHowMany.TextNews:='';
    if FCentrePersone <> nil then begin
      PnlHowMany.TextNews := PnlHowMany.TextNews + 'Центр: '+FCentrePersone^.NameHost + '.'+FCentrePersone^.Name
                                  + '(' + FCentrePersone^.ClassNameHost + '),(X.Y):' + u_FloatToStr(FCentrePersone^.MCenter.X)
                                  + '.'+u_FloatToStr(FCentrePersone^.MCenter.Y)+', угол:'+u_FloatToStr(FCentrePersone^.Angle)+ #13+#10;
    end;
    for lokNXT:= 0 to FCollectRecSpr.Count - 1 do begin
      TmpRec := FCollectRecSpr.ListNm[lokNXT];
      if TmpRec.Name<>TmpRec.NameHost then Continue;
      with TmpRec do begin
        PnlHowMany.TextNews := PnlHowMany.TextNews + 'Имя: '+TmpRec.NameHost + '.'+TmpRec.Name
                            + '(' + TmpRec.ClassNameHost + ')'
                            + ', колл: ' + u_BoolToStr(Collizion);
        if Scale <> 1 then  begin
          PnlHowMany.TextNews := PnlHowMany.TextNews + ', маштаб: '+u_FloatToStr(Scale);
        end;
        //PnlHowMany.TextNews := PnlHowMany.TextNews + ', кадр: '
        //                    + u_IntToStr(NowCadre) + '('+u_IntToStr(CurrentCadreCalk)+')';
        PnlHowMany.TextNews := PnlHowMany.TextNews + #13+#10;
      end;
    end;
    Anle1[0] := random( 10 )* - 0.05;
    Anle1[1] := random( 10 )* 0.05;
    Anle1[2] := random( 10 ) * 0.1;
    Anle1[3] := random( 10 ) * 0.1;

    if FSpeedPnl = nil then begin
      if FCollectRecSpr.RotateSpr('Ex1', Anle1[0]) then
         FCollectRecSpr.MoveUDSpr('Ex1', Anle1[2]);
    end else begin
      Anle1[2] := FRotationPnl.RotAngle;
      if Anle1[2] <> 0 then
        FCollectRecSpr.RotateSpr('Ex1', Anle1[2]*0.01);
      if FSpeedPnl.Speed <> 0 then FCollectRecSpr.MoveUDSpr('Ex1', FSpeedPnl.Speed * 0.5);
    end;
    if FCollectRecSpr.RotateSpr('Exm2_0', Anle1[1]) then
      FCollectRecSpr.MoveUDSpr('Exm2_0', Anle1[3]);
  {$EndIf}
  {$ifdef MOUSE3KEY}
    //Клавиатура наше все
    if key_Press( K_UP ) or key_Press( K_W ) Then begin
      FSpeedPnl.Speed := FSpeedPnl.Speed + 1;
    end;
    if key_Press( K_DOWN ) or key_Press( K_S ) Then begin
      FSpeedPnl.Speed := FSpeedPnl.Speed - 1;
    end;
  {$endif}
  inherited Proc;
end;

constructor avk_TArbitre.Create(const InParent: avk_TFraim; InName: String; inTexman: avk_TTexmanager = nil);
begin
  inherited Create(InParent, InName);
  FTexturemanager := inTexman;
  OnError:=nil;
  OnDraw:=nil;
  OnProc:=nil;
  OnTimer:=nil;
  FSpeedPnl := nil;
  FRotationPnl:= nil;
  FCentrePersone := nil;
  FVisualScr.X := 0; FVisualScr.Y := 0;
  FVisualScr.W := scrViewportW; FVisualScr.H := scrViewportH;
  {$IfDef Debug}
    FVisualScr.H := scrViewportH - 24;
    SetAreaElement(0,0,scrViewportW,scrViewportH - 24);
  {$else}
    SetAreaElement(0,0,scrViewportW,scrViewportH);
  {$endif}
  FAbsolyteScr.X := 0; FAbsolyteScr.Y := 0;
  FAbsolyteScr.W := 1024; FAbsolyteScr.H := 768;
  FHithFactor    := FVisualScr.H / FAbsolyteScr.H;
  FWighFactor    := FVisualScr.W / FAbsolyteScr.W;
  FCollectRecCln := avk_TCollectionRecAbotImg.Create;
  FCollectRecSpr := avk_TCollectionRecAbotImg.Create;
  if FTexturemanager <> nil then CreateDrivingPan;
  cam2d_Init( FCamMain );
  {$IfDef Debug}
    MakeSimpleEx;
    //FCentrePersone:=FCollectRecSpr.FList[FCollectRecSpr.GetMainByHostName('Ex1').Id];
    PnlHowMany := TNewsDlg.Create(Self,'Список.');
    PnlHowMany.SetAreaElement( scrViewportW - 351, 6, 350, scrViewportH - 100);
    PnlHowMany.HeaderNews:='Информация по выведеным объектам';
    PnlHowMany.TextNews:='Пока ничего.';
    PnlHowMany.Collapsed := true;
  {$endif}
end;

destructor avk_TArbitre.Destroy;
begin
  FCollectRecCln.Destroy;
  FCollectRecSpr.Destroy;
  inherited Destroy;
end;

{ avk_TCollectionRecAbotImg }

function avk_TCollectionRecAbotImg.GetRecByLy(InNum : Integer): avk_RecAboutImg;
var
  TmpCkl: Integer;
  procedure SortByLy(inLo, inHi: Integer);
  var
    lo, hi, mid : Integer;
    IndMid: Integer;
    t : avk_PRecAboutImg;
  begin
    lo   := inLo;
    hi   := inHi;
    IndMid := ( lo + hi ) shr 1;
    if (IndMid > (Length(FIndList)-1)) or (IndMid<0) then Exit;
    mid  := FIndList[( lo + hi ) shr 1 ]^.Layer;
    repeat
     while FIndList[ lo ]^.Layer < mid do INC( lo );
     while FIndList[ hi ]^.Layer > mid do DEC( hi );
     if Lo <= Hi then
        begin
          t           := FIndList[ lo ];
          FIndList[ lo ] := FIndList[ hi ];
          FIndList[ hi ] := t;
          INC( lo );
          DEC( hi );
        end;
    until lo > hi;
    if hi > inLo Then SortByLy( inLo, hi );
    if lo < inHi Then SortByLy( lo, inHi );
  end;

begin
  if Length(FIndList)<>Count then begin
     SetLength(FIndList,Count);
     for TmpCkl:=0 to Count-1 do FIndList[TmpCkl] := FList[TmpCkl];
     SortByLy(0,Count-1);
  end;
  Result:=FIndList[InNum]^;
end;

function avk_TCollectionRecAbotImg.GetCount: Integer;
begin
  if Assigned(FList) then Result := Length(FList)
    else Result := 0;
end;

function avk_TCollectionRecAbotImg.GetRecAs_zglTCircle(const inRec: avk_RecAboutImg): zglTCircle;
begin
  with Result do
    if inRec.HostPnt = nil then begin
      cX := inRec.MCenter.X;
      cY := inRec.MCenter.Y;
      Radius := inRec.H;
    end else begin
      cX := inRec.HostPnt^.MCenter.X + inRec.MCenter.X;
      cY := inRec.HostPnt^.MCenter.Y + inRec.MCenter.Y;
      Radius := inRec.H;
    end;
end;

function avk_TCollectionRecAbotImg.GetRecAs_zglTLine(const inRec: avk_RecAboutImg): zglTLine;
begin
  with Result do
    if inRec.HostPnt = nil then begin
      x0 := inRec.MCenter.X + inRec.LCenter.X;
      y0 := inRec.MCenter.Y + inRec.LCenter.Y;
      x1 := inRec.MCenter.X + inRec.H;
      y1 := inRec.MCenter.Y + inRec.W;
    end else begin
      x0 := inRec.HostPnt^.MCenter.X + inRec.MCenter.X + inRec.LCenter.X;
      y0 := inRec.HostPnt^.MCenter.X + inRec.MCenter.X + inRec.LCenter.Y;
      x1 := inRec.HostPnt^.MCenter.X + inRec.MCenter.X + inRec.H;
      y1 := inRec.HostPnt^.MCenter.X + inRec.MCenter.X + inRec.W;
    end;
end;

function avk_TCollectionRecAbotImg.GetRecAs_zglTPoint2D(
  const inRec: avk_RecAboutImg): zglTPoint2D;
begin
  with Result do
    if inRec.HostPnt = nil then begin
      X := inRec.MCenter.X;
      Y := inRec.MCenter.Y;
    end else begin
      X := inRec.HostPnt^.MCenter.X + inRec.MCenter.X;
      Y := inRec.HostPnt^.MCenter.X + inRec.MCenter.X;
    end;
end;

function avk_TCollectionRecAbotImg.GetRecAs_zglTRect(
  const inRec: avk_RecAboutImg): zglTRect;
begin
  with Result do
    if inRec.HostPnt = nil then begin
      X := inRec.MCenter.X + inRec.LCenter.X;
      Y := inRec.MCenter.Y + inRec.LCenter.Y;
      H := inRec.H;
      W := inRec.W;
    end else begin
      X := inRec.HostPnt^.MCenter.X + inRec.MCenter.X + inRec.LCenter.X;
      Y := inRec.HostPnt^.MCenter.X + inRec.MCenter.X  + inRec.LCenter.Y;
      H := inRec.H;
      W := inRec.W;
    end;
end;

function avk_TCollectionRecAbotImg.CollizionBtvZone(const inRec,
  inVerRec: avk_RecAboutImg): boolean;
var
  ColCircle1, ColCircle2: zglTCircle;
  ColLine1, ColLine2: zglTLine;
  ColPoint1, ColPoint2: zglTPoint2D;
  ColRect1, ColRect2: zglTRect;
  ColPoint : zglPPoint2D;
begin
  Result := false;
  case inRec.TypeOfFigure of
    avk_Circle: begin
      ColCircle1 := GetRecAs_zglTCircle(inRec);
      case inVerRec.TypeOfFigure of
        avk_Circle: begin
          ColCircle2 := GetRecAs_zglTCircle(inVerRec);
          Result := col2d_Circle(ColCircle1,ColCircle2);
        end;
        avk_Line: begin
          ColLine2 := GetRecAs_zglTLine(inVerRec);
          Result := col2d_LineVsCircle(ColLine2,ColCircle1);
        end;
        avk_Point: begin
          ColPoint2 := GetRecAs_zglTPoint2D(inVerRec);
          Result := col2d_PointInCircle(ColPoint2.X,ColPoint2.Y,ColCircle1);
        end;
        avk_Rectangle: begin
          ColRect2 := GetRecAs_zglTRect(inVerRec);
          Result := col2d_RectVsCircle(ColRect2,ColCircle1);
        end;
      end;
    end;
    avk_Line: begin
      ColLine1 := GetRecAs_zglTLine(inRec);
      case inVerRec.TypeOfFigure of
        avk_Circle: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Line: begin
          ColLine2 := GetRecAs_zglTLine(inVerRec);
          Result := col2d_Line(ColLine1, ColLine2, ColPoint);
        end;
        avk_Point: begin
          ColPoint2 := GetRecAs_zglTPoint2D(inVerRec);
          ColCircle2.cX := ColPoint2.X;
          ColCircle2.cY := ColPoint2.Y;
          ColCircle2.Radius := 2;
          Result := col2d_LineVsCircle(ColLine1,ColCircle2);
        end;
        avk_Rectangle: begin
          ColRect2 := GetRecAs_zglTRect(inVerRec);
          Result := col2d_LineVsRect(ColLine1,ColRect2);
        end;
      end;
    end;
    avk_Point: begin
      ColPoint1 := GetRecAs_zglTPoint2D(inRec);
      case inVerRec.TypeOfFigure of
        avk_Circle: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Line: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Point: begin
          ColPoint2 := GetRecAs_zglTPoint2D(inVerRec);
          ColCircle2.cX := ColPoint2.X;
          ColCircle2.cY := ColPoint2.Y;
          ColCircle2.Radius := 2;
          ColCircle1.cX := ColPoint1.X;
          ColCircle1.cY := ColPoint1.Y;
          ColCircle1.Radius := 2;
          Result := col2d_Circle(ColCircle1,ColCircle2);
        end;
        avk_Rectangle: begin
          ColRect2 := GetRecAs_zglTRect(inVerRec);
          Result := col2d_PointInRect(ColPoint1.X,ColPoint1.Y,ColRect2);
        end;
      end;
    end;
    avk_Rectangle: begin
      ColRect1 := GetRecAs_zglTRect(inRec);
      case inVerRec.TypeOfFigure of
        avk_Circle: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Line: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Point: Result := CollizionBtvZone(inVerRec,inRec);
        avk_Rectangle: begin
          ColRect2 := GetRecAs_zglTRect(inVerRec);
          Result := col2d_Rect(ColRect1,ColRect2);
        end;
      end;
    end;
  end;
end;

function avk_TCollectionRecAbotImg.GetMaxExtId: Integer;
var
  i : Integer;
begin
  Result := 0;
  for i := 0 to Length(FList) - 1 do
    if FList[ i ]^.ExtId > Result then Result := FList[ i ]^.ExtId;
end;

function avk_TCollectionRecAbotImg.GetRecByExtId(const inExtId: Integer
  ): avk_RecAboutImg;
var
  i: Integer;
begin
  Result := avk_GetEmpityRecAboutImg;
  for i := 0 to Length(FList) - 1 do
    if FList[ i ]^.ExtId = inExtId then Result := FList[ i ]^;
end;

function avk_TCollectionRecAbotImg.MakeNextCadre(const inIDPriem: Integer):boolean;
var
  Tmp: avk_RecAboutImg;
  P1: integer;
begin
  Tmp:=ListId[inIDPriem];
  Inc (Tmp.CurrentCadreCalk);
  P1:= Tmp.CurrentCadreCalk;
  P1:= Tmp.RateCadre;
  if Tmp.CurrentCadreCalk > Tmp.RateCadre then begin
    P1:=Tmp.RateCadre;
    Tmp.CurrentCadreCalk:=0;
    Inc(Tmp.NowCadre);
    if Tmp.NowCadre >= Tmp.EndCadre then Tmp.NowCadre := 0;
   end;
  Tmp.Hide := (Tmp.NowCadre < Tmp.StartCadre) or (Tmp.NowCadre > Tmp.StopCadre);
  SetRecById(inIDPriem,Tmp);
end;

procedure avk_TCollectionRecAbotImg.SetCollisionInRec(const inRec, inVerRec: avk_RecAboutImg);
var
  TmpRec, TmpVerRec: avk_RecAboutImg;
begin
  if inRec.HostPnt <> nil then inRec.HostPnt^.Collizion := true;
  if inVerRec.HostPnt <> nil then inVerRec.HostPnt^.Collizion := true;
  TmpRec.Collizion := true;
  TmpVerRec.Collizion := true;
  SetRecById(TmpRec.ID,TmpRec);
  SetRecById(TmpVerRec.ID,TmpVerRec);
end;

function avk_TCollectionRecAbotImg.IspectCollizion(const InHostName: String;
  MakeIvent: boolean): boolean;
var
  GeneralRec, GeneralRecVer, TmpRec, TmpVerRec: avk_RecAboutImg;
  TmpNxt, lokNXT: integer;
begin
  Result := false;
  for lokNXT:= 0 to Count - 1 do begin
    TmpRec := ListNm[lokNXT];
    if TmpRec.NameHost <> InHostName then Continue;
    if TmpRec.Hide then Continue;//пассивные не проверяем
    if TmpRec.TypeOfFigure = avk_Image then Continue;
    for TmpNxt:= 0 to Count - 1 do begin
      TmpVerRec := ListNm[TmpNxt];
      if (TmpVerRec.NameHost = InHostName) then Continue;
      if TmpVerRec.Hide then Continue;//пассивные не проверяем
      if TmpVerRec.TypeOfFigure = avk_Image then Continue;
      if CollizionBtvZone(TmpRec,TmpVerRec) then begin
        //да, столкнулись
        Result := true;
        SetCollisionInRec(TmpRec,TmpVerRec);//отметили коллизию
        if MakeIvent then begin
          //Вызываем процедуру
        end;
      end;
    end;
  end;
end;

function avk_TCollectionRecAbotImg.RotateSpr(const InHostName: String;
  inGraduce: Single; ColUndo: boolean = false):boolean;
var
   GeneralRec, TmpRec: avk_RecAboutImg;
   TmpNxt, lokNXT: integer;
   TmpAngle: Single;
   NX, NY: Single;
begin
  Result:= false;
  GeneralRec := GetMainByHostName(InHostName);
  if RecIsEmpity(GeneralRec) then
    Exit;//Откуда имя тогда???!!!
  if (not ColUndo) then if GeneralRec.Collizion then Exit;//не решенная колизия.
  Result:= true;
  for lokNXT:= 0 to Count - 1 do begin
    if ListNm[lokNXT].NameHost <> InHostName then Continue;
    if ListNm[lokNXT].Id = GeneralRec.ID then Continue;
    TmpRec := ListNm[lokNXT];
    with TmpRec do begin
        if TypeOfFigure = avk_Line then begin
          //Нужно просчитывать концы по углу поворота от центра
          TmpAngle := Angle - GeneralRec.Angle;
          Rotate( (TmpAngle + inGraduce), MCenter.X + LCenter.X, MCenter.Y + LCenter.Y, 0, 0, NX, NY);
          LCenter.X :=  NX;
          LCenter.Y :=  NY;
          Rotate( (TmpAngle + inGraduce), MCenter.X + H, MCenter.Y + W, 0, 0, NX, NY);
          H :=  NX;
          W :=  NY;
        end;
        TmpAngle := Angle - GeneralRec.Angle;
        Rotate( (TmpAngle + inGraduce), MCenter.X, MCenter.Y, 0, 0, NX, NY);
        MCenter.Y :=  NY;
        MCenter.X :=  NX;
        if TypeOfFigure = avk_Line then begin
           LCenter.X := LCenter.X - MCenter.X;
           LCenter.Y := LCenter.Y - MCenter.Y;
           H :=  H - MCenter.X;
           W :=  W - MCenter.Y;
        end;
        Angle := Angle + inGraduce;
        if (Angle > 360) then Angle := Angle - 360;
        if (Angle < -360) then Angle := Angle + 360;
      end;
    FList[lokNXT]^ := TmpRec;
  end;
  with GeneralRec do begin
    if TypeOfFigure = avk_Line then begin
      //Нужно просчитывать концы по углу поворота от центра
      TmpAngle := Angle;
      Rotate( (TmpAngle + inGraduce), LCenter.X, LCenter.Y, 0, 0, NX, NY);
      LCenter.X :=  NX;
      LCenter.Y :=  NY;
      Rotate( (TmpAngle + inGraduce), H, W, 0, 0, NX, NY);
      H :=  NX;
      W :=  NY;
    end;
    Angle := Angle + inGraduce;
    if (Angle > 360) then Angle := Angle - 360;
    if (Angle < -360) then Angle := Angle + 360;
    SetRecById(Id,GeneralRec);
  end;
  if (not ColUndo) then begin
    if IspectCollizion(GeneralRec.Name) then begin
      while IspectCollizion(GeneralRec.Name) do RotateSpr(InHostName, -inGraduce, true);
      Result := false;
    end;
  end;
end;

function avk_TCollectionRecAbotImg.MoveUDSpr(const InHostName: String;
  inSpead: Single):boolean;
var
  GeneralRec, TmpRec: avk_RecAboutImg;
  lokNXT: integer;
  TmpDistanse, TmpAngle: Single;
  NX, NY: Single;
begin
  //координаты вектора расчитываются при поворотах
  Result:=false;
  GeneralRec := GetMainByHostName(InHostName);
  if RecIsEmpity(GeneralRec) then
    Exit;//Откуда имя тогда???!!!
  if GeneralRec.Collizion then Exit;//не решенная колизия.
  Result:=true;
  with GeneralRec do begin
    TmpAngle := m_Angle(0, 0, VPoint.X, VPoint.Y) + Angle - 90;
    Rotate( TmpAngle , VPoint.X, VPoint.Y, 0, 0, NX, NY);
    TmpDistanse := m_Distance(0, 0, NX, NY);
    NX := (Nx/TmpDistanse)*inSpead;
    NY := (NY/TmpDistanse)*inSpead;
    MCenter.X := MCenter.X + NX;
    MCenter.Y := MCenter.Y + NY;
  end;
  SetRecById(GeneralRec.ID,GeneralRec);
  if IspectCollizion(GeneralRec.Name) then begin
    with GeneralRec do begin
      MCenter.X := MCenter.X - NX;
      MCenter.Y := MCenter.Y - NY;
    end;
    Result:=false;
  end;
  SetRecById(GeneralRec.ID,GeneralRec);
end;

procedure avk_TCollectionRecAbotImg.CalcSpr(const InHostName: String;
  inVisual: zglTRect);
var
   GeneralRec, TmpRec: avk_RecAboutImg;
   TmpNxt, lokNXT: integer;
begin
  GeneralRec := GetMainByHostName(InHostName);
  if RecIsEmpity(GeneralRec) then Exit;//Откуда имя тогда???!!!
  GeneralRec.X := (GeneralRec.MCenter.X + GeneralRec.LCenter.X - inVisual.X);
  GeneralRec.Y := GeneralRec.MCenter.Y + GeneralRec.LCenter.Y - inVisual.Y;
  SetRecById(GeneralRec.ID,GeneralRec);
  for lokNXT:= 0 to Count - 1 do begin
    if ListNm[lokNXT].NameHost <> InHostName then Continue;
    if ListNm[lokNXT].Id = GeneralRec.ID then Continue;
    TmpRec := ListNm[lokNXT];
    with TmpRec do begin
      TmpRec.X := GeneralRec.MCenter.X + TmpRec.MCenter.X + TmpRec.LCenter.X - inVisual.X;
      TmpRec.Y := GeneralRec.MCenter.Y + TmpRec.MCenter.Y + TmpRec.LCenter.Y - inVisual.Y;
    end;
    SetRecById(TmpRec.ID,TmpRec);
  end;
end;

function avk_TCollectionRecAbotImg.GetMaxLayer(const inName: String): Integer;
var
  TmpNxt: integer;
begin
  Result := -1;
  if inName = '' then begin
    for TmpNxt := 0 to (Count-1) do begin
      if Result > GetRecById(TmpNxt).Layer then begin
        Result := GetRecById(TmpNxt).Layer;
      end;
    end;
  end else begin
    for TmpNxt := 0 to (Count-1) do begin
      if GetRecById(TmpNxt).NameHost = inName then
        if Result > GetRecById(TmpNxt).Layer then begin
          Result := GetRecById(TmpNxt).Layer;
        end;
    end;
  end;
end;

procedure avk_TCollectionRecAbotImg.InspectFraims;
begin
  //вообще было бы не плохо проверки делать
  //но пока не понятно как
end;

function avk_TCollectionRecAbotImg.GetRecById(const inID: Integer): avk_RecAboutImg;
var
  TmpNxt: integer;
begin
  if (inID >= Count) or (inID < 0) then
    Result := avk_GetEmpityRecAboutImg
  else
    Result := FList[inID]^;
end;

function avk_TCollectionRecAbotImg.GetRecByNum(const inNum: Integer): avk_RecAboutImg;
begin
  Result := avk_GetEmpityRecAboutImg;
  if  (inNum < Length(FList)) and (inNum >= 0) then
    Result:= FList[inNum]^;
end;

function avk_TCollectionRecAbotImg.GetIdByName(const inName: String; InId: Integer
  ): Integer;
var
  TmpNxt, StartTmpNxt: integer;
  tnpNm:String;
  tnpId: integer;
begin
  Result := -1;
  StartTmpNxt := InId+1;
  if inName = '' then begin
    for TmpNxt := StartTmpNxt to (Count-1) do begin
      if Result > GetRecById(TmpNxt).Id then begin
        Result := GetRecById(TmpNxt).Id;
        Break;
      end;
    end;
  end else begin
    for TmpNxt := StartTmpNxt to (Count-1) do begin
      if GetRecById(TmpNxt).Name = inName then
        if Result < TmpNxt then begin
          Result := TmpNxt;
          Exit;
        end;
    end;
  end;
end;

procedure avk_TCollectionRecAbotImg.SetRecById(const inID: Integer;
  inFraim: avk_RecAboutImg);
var
  TmpId: Integer;
begin
  TmpId := inID;
  if (inId > Count) then Exit;
  if (inId < 0) then begin
    TmpId := Count;
  end;
  if TmpId = Count then
    AddNewRec(inFraim)
    else begin
      FList[inID]^ := inFraim;
    end;
end;

procedure avk_TCollectionRecAbotImg.SetRecByNum(inNum: Integer;
  inFraim: avk_RecAboutImg);
begin
  if  (inNum < Length(FList)) and (inNum >= 0) then
    FList[inNum]^ :=inFraim;
end;

procedure avk_TCollectionRecAbotImg.SortByID(inLo, inHi: Integer);
var
  lo, hi, mid : Integer;
  IndMid: Integer;
  t : avk_PRecAboutImg;
begin
  if Count < 1 then Exit;
  lo   := inLo;
  hi   := inHi;
  IndMid := ( lo + hi ) shr 1;
  if (IndMid > (Count-1)) or (IndMid<0) then Exit;
  mid  := FList[ ( lo + hi ) shr 1 ]^.ID;
  repeat
    while FList[ lo ]^.ID < mid do INC( lo );
    while FList[ hi ] = nil do DEC( hi );
    while FList[ hi ]^.ID > mid do DEC( hi );
    if Lo <= Hi then
      begin
        t           := FList[ lo ];
        FList[ lo ] := FList[ hi ];
        FList[ hi ] := t;
        INC( lo );
        DEC( hi );
      end;
  until lo > hi;
  if hi > inLo Then SortByID( inLo, hi );
  if lo < inHi Then SortByID( lo, inHi );
end;

procedure avk_TCollectionRecAbotImg.SortByFraim(inLo, inHi: Integer);
var
  lo, hi, mid : Integer;
  IndMid: Integer;
  t : avk_PRecAboutImg;
begin
  lo   := inLo;
  hi   := inHi;
  IndMid := ( lo + hi ) shr 1;
  if (IndMid > (Length(FList)-1)) or (IndMid<0) then Exit;
  mid  := FList[( lo + hi ) shr 1 ]^.Layer;
  repeat
   while FList[ lo ]^.Layer < mid do INC( lo );
   while FList[ hi ]^.Layer > mid do DEC( hi );
   if Lo <= Hi then
      begin
        t           := FList[ lo ];
        FList[ lo ] := FList[ hi ];
        FList[ hi ] := t;
        INC( lo );
        DEC( hi );
      end;
  until lo > hi;
  if hi > inLo Then SortByFraim( inLo, hi );
  if lo < inHi Then SortByFraim( lo, inHi );
end;

procedure avk_TCollectionRecAbotImg.DelById(inId: Integer);
var
  i : Integer;
begin
  if ( inID < 0 ) or ( inID > Count - 1 ) or ( Count = 0 ) Then exit;
  for i := InID to Count - 2 do
    begin
      FList[ i ]^     := FList[ i + 1 ]^;
      FList[ i ]^.ID  := i;
    end;
  Dispose(FList[Length(FList) - 1]);
  SetLength( FList, Length(FList) - 1 );
end;

function avk_TCollectionRecAbotImg.AddNewRec(inRec: avk_RecAboutImg):avk_PRecAboutImg;
var
  p1: avk_PRecAboutImg;
  procedure SetIdInAr;
  var
    i : Integer;
    t : avk_PRecAboutImg;
  begin
    for i:= Count-1 downto 1 do begin
      if FList[i]^.ID < FList[i-1]^.ID then begin
        t           := FList[i];
        FList[i] := FList[i-1];
        FList[i-1] := t;
      end;
    end;
  end;

begin
  SetLength( FList, Count+1);
  New(p1);
  p1^ := inRec;
  p1^.ID := Count-1;
  FList [Count-1] := p1;
  Result := p1;
  SetIdInAr;
  Result := p1;
end;

procedure avk_TCollectionRecAbotImg.ClearAll;
var
  i : Integer;
begin
  for i := 0 to Length(FList)-1 do Dispose(FList[i]);
  SetLength( FList, 0 );
  SetLength( FIndList, 0 );
  //Count := 0;
end;

function avk_TCollectionRecAbotImg.GetNextIdInHostName(
  const inHostName: String; inId: Integer): Integer;
var
  TmpLastId: Integer;
  TmpCopyValue: avk_RecAboutImg;
  LokStartId, CKLid: Integer;
begin
  Result := -1;
  if inHostName = '' then Exit;
  LokStartId := inId;
  if LokStartId > Count - 1 then Exit;
  for TmpLastId := LokStartId to Count - 1 do begin
    TmpCopyValue := ListId[TmpLastId];
    if TmpCopyValue.NameHost = inHostName then begin
      Result := TmpLastId;
      Exit;
    end;
  end;
end;

function avk_TCollectionRecAbotImg.GetByHostName(inName: String
  ): avk_TCollectionRecAbotImg;
var
  TmpLastId: Integer;
  TmpCopyValue: avk_RecAboutImg;
begin
  TmpLastId := -1;
  Result := avk_TCollectionRecAbotImg.Create;
  if GetIdByName(inName, TmpLastId) = -1 then Exit;
  if GetMainByHostName(inName).ID = -1 then Exit;
  TmpLastId:=GetNextIdInHostName(inName, 0);
  while TmpLastId <> -1 do begin
    TmpCopyValue := ListId[TmpLastId];
    with Result do begin
      AddNewRec(TmpCopyValue);
    end;
    TmpLastId:=GetNextIdInHostName(inName, TmpLastId + 1);
  end;
end;

function avk_TCollectionRecAbotImg.GetMainByHostName(const inName: String
  ): avk_RecAboutImg;
var
  TmpLastId: Integer;
  TmpCopyValue: avk_RecAboutImg;
begin
  TmpLastId := GetIdByName(inName, -1);
  Result := avk_GetEmpityRecAboutImg;
  if TmpLastId = -1 then Exit;
  while TmpLastId <> -1 do begin
    TmpCopyValue := ListId[TmpLastId];
    if TmpCopyValue.Name = TmpCopyValue.NameHost then begin
       Result := TmpCopyValue;
       if Result.Name = inName then Exit;
    end;
    TmpLastId := GetIdByName(inName,TmpLastId);
  end;
end;

function avk_TCollectionRecAbotImg.GetNextHostName(const inName: String
  ): avk_RecAboutImg;
var
  LokStartId, CKLid: Integer;
begin
  Result := avk_GetEmpityRecAboutImg;
  if Count = 0 then Exit;
  //SortByID(0,(Count - 1));
  if inName = '' then LokStartId:= 0
    else LokStartId := GetMainByHostName(inName).ID + 1;
  for CKLid := LokStartId to Count - 1 do
    if (ListId[CKLid].Name <> inName) and (ListId[CKLid].Name = ListId[CKLid].NameHost) then
      begin
        Result := ListId[CKLid];
        Exit;
      end;
end;

function avk_TCollectionRecAbotImg.GetCountNames: Integer;
var
  LstName: String;
begin
  Result:=0;
  LstName:='';
  While not RecIsEmpity(GetNextHostName(LstName)) do begin
    Inc (Result);
    LstName:=GetNextHostName(LstName).Name;
  end;
end;

function avk_TCollectionRecAbotImg.RecIsEmpity(inRec: avk_RecAboutImg): boolean;
begin
 Result :=  avk_EqualRecAboutImg(inRec,avk_GetEmpityRecAboutImg) or (inRec.Id = -1);
end;

procedure avk_TCollectionRecAbotImg.DelByHostName(inName: String);
var
  TmpLastId: Integer;

  function GetMeFirstHostNameId(InName: String): Integer;
  var
    TmpI: Integer;
  begin
    Result := -1;
    For TmpI:= 0 to Count - 1 do begin
      if FList[TmpI]^.NameHost = InName then begin
        Result := FList[TmpI]^.ID;
        Break;
      end;
    end;
  end;

begin
  if inName = '' then Exit;
  TmpLastId := GetMeFirstHostNameId(inName);
  while TmpLastId <> -1 do begin
    DelById(TmpLastId);
    TmpLastId := GetMeFirstHostNameId(inName);
  end;
end;

constructor avk_TCollectionRecAbotImg.Create;
begin
  //Count         := 0;
  SetLength( FList, 0 );
  SetLength( FIndList, 0);
  FSortBy := '';
end;

destructor avk_TCollectionRecAbotImg.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;

end.

