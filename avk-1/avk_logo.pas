unit avk_logo;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
  avk_gui, avk_btype, zgl_sprite_2d, zgl_textures, zgl_textures_png,
  avk_texmanager, zgl_fx,zgl_main;
type

  { TLogo }

  TLogo = class (avk_TElement)
  private
    LogoSucsess: boolean;
    LogoTime: Integer;
  public
    texLogo: zglPTexture;
    procedure DoProc ( inFraim: avk_TFraim = nil );
    procedure DoDraw ( inFraim: avk_TFraim = nil );
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

  { TSpecButton }

  TSpecButton = class (TSimpleImage)
    SecImg: TSimpleImage;
    procedure DoExit(inFraim: avk_TFraim=nil);
    procedure DoDraw(inFraim: avk_TFraim=nil); override;
    procedure SetAreaElement(const InX, InY, InW, InH: Single); override;
    constructor Create(const InParent: avk_TElement; InName: String='';
      inTexture: zglPTexture=nil; inSecTexture: zglPTexture=nil);
  end;

  { TLogPasWind }
  TProcStartBtnLogPsw = procedure (inLogin, inPassword: String) of object;

  TLogPasWind = class (TNoGraphButton)
  private
    FLoginPassEvent: TProcStartBtnLogPsw;
    FLoginNPEvent: TProcStartBtnLogPsw;
  public
    procedure DoClicStart ( inFraim: avk_TFraim = nil );
    procedure DoClicNewPl ( inFraim: avk_TFraim = nil );
  public
    procedure DoDraw ( inFraim: avk_TFraim = nil ); override;
    procedure SetAreaElement(const InX,InY,InW,InH: Single); override;
    constructor Create(const InParent: avk_TElement = nil; InName: String = ''; Texmanager: avk_TTexmanager = nil);
    destructor Destroy; override;
  public
    property LoginPassEvent: TProcStartBtnLogPsw read FLoginPassEvent write FLoginPassEvent;
    property LoginNpEvent: TProcStartBtnLogPsw read FLoginNPEvent write FLoginNPEvent;
  end;

  { TGirBtn }

  TGirBtn = class (TNoGraphButton)
  private
    LtAngleSpeed, BgAngleSpeed: Single;
  public
    AngleSpeed: Single;
    procedure SetAreaElement(const InX,InY,InW,InH: Single); override;
    procedure DoProc ( inFraim: avk_TFraim = nil );override;
    procedure DoDraw ( inFraim: avk_TFraim = nil );override;
    constructor Create(const InParent: avk_TElement = nil; InName: String = ''; Texmanager: avk_TTexmanager = nil);
    destructor Destroy; override;
  end;

implementation

{ TGirBtn }

procedure TGirBtn.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  if Count = 0 then Exit;
  avk_TElement(List[GetIdByName('Большая шестеренка')]).SetAreaElement(0, 0, AreaElement.H+0.1*AreaElement.H, AreaElement.H);
  avk_TElement( List[GetIdByName('Малая шестеренка')]).SetAreaElement
              ( AreaElement.W - (3*(AreaElement.H/4)), AreaElement.H-(3*(AreaElement.H/4)) ,
               3*(AreaElement.H/4), 3*(AreaElement.H/4));
end;

procedure TGirBtn.DoProc(inFraim: avk_TFraim);
var
 TmpSimpleImageB:TSimpleImage;
 TmpSimpleImageL:TSimpleImage;
begin
  inherited DoProc(inFraim);
  TmpSimpleImageB := TSimpleImage(List[GetIdByName('Большая шестеренка')]);
  if TmpSimpleImageB = nil then exit;
  TmpSimpleImageB.Angle:=TmpSimpleImageB.Angle + BgAngleSpeed;
  if TmpSimpleImageB.Angle > 360 then TmpSimpleImageB.Angle := 0;
  TmpSimpleImageL := TSimpleImage( List[GetIdByName('Малая шестеренка')]);
  TmpSimpleImageL.Angle:=TmpSimpleImageL.Angle - LtAngleSpeed;
  if TmpSimpleImageL.Angle < -1800 then begin
    TmpSimpleImageB.Angle := 0;
    TmpSimpleImageL.Angle := 0;
  end;
  BgAngleSpeed := 0.1 * 20/AngleSpeed;
  LtAngleSpeed := 0.12965 * 20/AngleSpeed;
end;

procedure TGirBtn.DoDraw(inFraim: avk_TFraim);
begin
  //inherited DoDraw(inFraim);
end;

constructor TGirBtn.Create(const InParent: avk_TElement; InName: String;
  Texmanager: avk_TTexmanager);
var
  TmpStImg: TSimpleImage;
begin
  inherited Create(InParent, InName);
  AngleSpeed := 1;
  //Drawing := false;
  TmpStImg := TSimpleImage.Create(Self,'Большая шестеренка',Texmanager.GetTextureNames('Большая шестеренка'));
  TmpStImg.SetAreaElement( 0, 0, 64, 64);
  TmpStImg.GetMouse:=False;
  TmpStImg := TSimpleImage.Create(Self,'Малая шестеренка',Texmanager.GetTextureNames('Малая шестеренка'));
  TmpStImg.SetAreaElement( 0, 0, 64, 64);
  TmpStImg.GetMouse:=False;
end;

destructor TGirBtn.Destroy;
begin
  inherited Destroy;
end;

{ TSpecButton }

procedure TSpecButton.DoExit(inFraim: avk_TFraim);
begin
  zgl_exit;
end;

procedure TSpecButton.DoDraw(inFraim: avk_TFraim);
begin
  if Assigned(SecImg) then SecImg.DoDraw(Self);
  inherited DoDraw(inFraim);
end;

procedure TSpecButton.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  if Assigned(SecImg) then SecImg.SetAreaElement(Round(InW/2) - 50, Round(InH/2) - 50, 100, 100);
end;

constructor TSpecButton.Create(const InParent: avk_TElement; InName: String;
  inTexture: zglPTexture; inSecTexture: zglPTexture);
begin
  inherited Create (InParent, InName, inTexture);
  if inSecTexture<>nil then begin
    SecImg := TSimpleImage.Create(Self,'Кнопичка',inSecTexture);
    SecImg.Drawing := false;
    SecImg.Clickable := true;
    SecImg.OnClick:=@DoExit;
  end;
end;

{ TLogPasWind }

procedure TLogPasWind.DoClicStart(inFraim: avk_TFraim);
var
  outLogin, outPassword: String;
begin
  outLogin    := TInputWnd(List[GetIdByName('Введите логин')]).TextBuffer;
  outPassword := TInputWnd(List[GetIdByName('Введите пароль')]).TextBuffer;
  if Assigned(LoginPassEvent) then LoginPassEvent(outLogin, outPassword);
end;

procedure TLogPasWind.DoClicNewPl(inFraim: avk_TFraim);
var
  outLogin, outPassword: String;
begin
  outLogin    := TInputWnd(List[GetIdByName('Введите логин')]).TextBuffer;
  outPassword := TInputWnd(List[GetIdByName('Введите пароль')]).TextBuffer;
  if Assigned(LoginPassEvent) then LoginNPEvent(outLogin, outPassword);
end;

procedure TLogPasWind.DoDraw(inFraim: avk_TFraim);
begin
  //inherited DoDraw(inFraim);
end;

procedure TLogPasWind.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  if Count = 0 then Exit;
  avk_TElement(List[GetIdByName('РамкаПВ')]).SetAreaElement( AreaElement.W - 64, 0, 64, 64);
  avk_TElement(List[GetIdByName('РамкаПН')]).SetAreaElement( AreaElement.W - 64, AreaElement.H - 64, 64, 64);
  avk_TElement(List[GetIdByName('РамкаЛН')]).SetAreaElement( 0, AreaElement.H - 64, 64, 64);
  avk_TElement(List[GetIdByName('Линия верх')]).SetAreaElement( 64, 0, AreaElement.W - 128, 24);
  avk_TElement(List[GetIdByName('Линия низ')]).SetAreaElement( 64, AreaElement.H - 24, AreaElement.W - 128, 24);
  avk_TElement(List[GetIdByName('Линия лево')]).SetAreaElement( 0, 64, 24, AreaElement.H - 128);
  avk_TElement(List[GetIdByName('Линия право')]).SetAreaElement( AreaElement.W - 24, 64, 24, AreaElement.H - 128);
  avk_TElement(List[GetIdByName('Введите логин')]).SetAreaElement( AreaElement.W - 256, 100, 180, 25);
  avk_TElement(List[GetIdByName('Введите пароль')]).SetAreaElement( AreaElement.W - 256, 140, 180, 25);
  avk_TElement(List[GetIdByName('Логин:')]).SetAreaElement( AreaElement.W - 380, 100, 100, 25);
  avk_TElement(List[GetIdByName('Пароль:')]).SetAreaElement( AreaElement.W - 380, 140, 100, 25);
  avk_TElement(List[GetIdByName('Гнездо под кнопки')]).SetAreaElement( 104,AreaElement.H - 112, 264, 96);
  avk_TElement(List[GetIdByName('Линия для гнезда под кнопки П')]).SetAreaElement( 350,AreaElement.H - 111, AreaElement.W -365, 18);
  avk_TElement(List[GetIdByName('Линия для гнезда под кнопки Л')]).SetAreaElement( 14,AreaElement.H - 111, 96, 18);
  avk_TElement(List[GetIdByName('Кнопка вход')]).SetAreaElement( 40,AreaElement.H - 103, 164, 96);
  avk_TElement(List[GetIdByName('Кнопка новый')]).SetAreaElement( AreaElement.W - 204,AreaElement.H - 103, 164, 96);
end;

constructor TLogPasWind.Create(const InParent: avk_TElement; InName: String;
  Texmanager: avk_TTexmanager);
var
   TmpTexLbl: TSimpleLabel;
   TmpStImg: TSimpleImage;
   TmpSt1mg: TSpecButton;
   TmpStImg1 : TPuzzleImage;
   TmpImpWind : TInputWnd;
begin
  inherited Create(InParent, InName);
  //Рамка по краю
  begin
    TmpStImg := TSimpleImage.Create(Self,'РамкаЛВ',Texmanager.GetTextureNames('Углы окна ЛП'));
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.Angle := - 180;
    TmpStImg := TSimpleImage.Create(Self,'РамкаПВ',Texmanager.GetTextureNames('Углы окна ЛП'));
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.Angle := -90;
    TmpStImg := TSimpleImage.Create(Self,'РамкаПН',Texmanager.GetTextureNames('Углы окна ЛП'));
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.Angle := 0;
    TmpStImg := TSimpleImage.Create(Self,'РамкаЛН',Texmanager.GetTextureNames('Углы окна ЛП'));
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.Angle := 90;
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия верх',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 16;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := 180;
    TmpStImg1.SetAreaElement( 0, 0, 16, 16 );
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия низ',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 16;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := 0;
    TmpStImg1.SetAreaElement( 0, 0, 16, 16 );
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия лево',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 24;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := -90;
    TmpStImg1.FxFlags := (FX_BLEND or FX2D_FLIPY);
    TmpStImg1.SetAreaElement( 0, 0, 16, 16 );
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия право',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 24;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := -90;
    TmpStImg1.SetAreaElement( 0, 0, 16, 16 );
    if InParent.Wallpaper <> nil then Wallpaper := InParent.Wallpaper;
  end;
  //Нижняя часть
  begin
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия для гнезда под кнопки Л',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 24;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := 180;
    TmpStImg1.SetAreaElement( 0, 0, 24, 24 );
    TmpStImg1 := TPuzzleImage.Create(Self,'Линия для гнезда под кнопки П',Texmanager.GetTextureNames('Верх и низ границы'));
    TmpStImg1.WF := 24;
    TmpStImg1.HF := 24;
    TmpStImg1.Angle := 180;
    TmpStImg1.SetAreaElement( 0, 0, 24, 24 );
    TmpStImg := TSimpleImage.Create(Self,'Кнопка вход',Texmanager.GetTextureNames('Кнопка СС'));
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.Scale:=1.7;
    TmpStImg.Clickable:=True;
    TmpStImg.OnClick:=@DoClicStart;
    TmpStImg := TSimpleImage.Create(Self,'Кнопка новый',Texmanager.GetTextureNames('Кнопка СС'));
    TmpStImg.Scale:=1.7;
    TmpStImg.FxFlags := FX_BLEND or FX2D_FLIPX;
    TmpStImg.Clickable:=True;
    TmpStImg.SetAreaElement( 0, 0, 64, 64);
    TmpStImg.OnClick:=@DoClicNewPl;
    TmpSt1mg := TSpecButton.Create(Self,'Гнездо под кнопки', Texmanager.GetTextureNames('Гнездо под кнопки'), Texmanager.GetTextureNames('Кнопка Закрыть'));
    TmpSt1mg.SetAreaElement( 0, 0, 64, 64);
    TmpSt1mg.GetMouse:=false;
  end;
  //Окна ввода
  begin
    TmpTexLbl  := TSimpleLabel.Create(Self,'Логин:');
    TmpImpWind := TInputWnd.Create(Self,'Введите логин');
    TmpImpWind.SetAreaElement(0,0,10,10);
    TmpTexLbl  := TSimpleLabel.Create(Self,'Пароль:');
    TmpImpWind := TInputWnd.Create(Self,'Введите пароль');
    TmpImpWind.SetAreaElement(0,0,10,10);
  end;
end;

destructor TLogPasWind.Destroy;
begin
  inherited Destroy;
end;

{ TLogo }

procedure TLogo.DoProc(inFraim: avk_TFraim);
begin
  LogoTime := LogoTime + 1;
  if LogoSucsess then begin
    Timing := false;
    DeleteMe := true;
  end;
end;

procedure TLogo.DoDraw(inFraim: avk_TFraim);
var
   SCwight, SChight: Integer;
begin
  SCwight := Round(ParentAsElement.AreaElement.W / 2);
  SChight := Round(ParentAsElement.AreaElement.H / 2);
  if not LogoSucsess then
    if LogoTime <= 255 Then
      begin
        ssprite2d_Draw( texLogo, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, LogoTime );
      end
    else
      if LogoTime < 510 Then
        begin
          ssprite2d_Draw( texLogo, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, 510 - LogoTime );
        end
      else
        LogoSucsess := true;
end;

constructor TLogo.Create(const InParent: avk_TFraim; InName: String);
var
   SCwight, SChight: Integer;
begin
  inherited Create(InParent, InName);
  SCwight := Round(ParentAsElement.AreaElement.W / 2);
  SChight := Round(ParentAsElement.AreaElement.H / 2);
  SetAreaElement(SCwight - 256, SChight - 195, 512, 390);
  LogoSucsess:=false;
  LogoTime := 0;
  OnProc:=@DoProc;
  OnDraw:=@DoDraw;
end;

destructor TLogo.Destroy;
begin
  inherited Destroy;
end;

end.

