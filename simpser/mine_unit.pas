unit mine_unit;

{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes,
  avk_btype, avk_gui, avk_addgui,
  avk_server, LNet,
  avk_input, avk_texmanager, avk_sprites,

  zgl_main, zgl_timers, zgl_render_2d,
  zgl_textures, zgl_types
  , zgl_textures_png
  , zgl_textures_jpg
  , zgl_textures_tga
  , zgl_font, zgl_utils
  , zgl_primitives_2d, zgl_fx, zgl_text
  , zgl_resources, zgl_file
  , zgl_keyboard
  , zgl_window
  ;
const
  {$IfDef LOCALHOST}
    HostS73 = '127.0.0.1';
  {$else}
    {$IfDef LOCALNET}
      HostS73 = '10.9.8.45';
    {$else}
      HostS73 = '81.211.37.59';
    {$endif}
  {$endif}

type

  { TMineForm }

  TMineForm = class (avk_THostForm)
  private
    procedure DoAPforSpr(Sender: TObject);
    procedure DoClickOnClosePnl(Sender: TObject);
    procedure DoClickOnClosePnlSpr(Sender: TObject);
    procedure DoClose(Sender: TObject);
    procedure DoDropList(Sender: TObject);
    procedure DoMassiveSprites(Sender: TObject);
    procedure DoMassiveSpritesCl(Sender: TObject);
    procedure DoPnlSprMove(Sender: TObject);
    procedure DoProverka(Sender: TObject);
    procedure DoSpecPnlSpr(Sender: TObject);
    procedure DoPanelServer(Sender: TObject);
    procedure DoPanelCompSprite(Sender: TObject);
    procedure DoRotateCompSprite5gr(Sender: TObject);
  public
    TCPServer: avk_TServer;
    procedure DoStopStartServer(Sender: TObject);
    procedure TCPMessage(InMessage:String; InParent: TObject = nil);
    procedure TCPNewCon(InMessage: String; InParent: TObject);
    procedure WasError(const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil);
    procedure DoInputTCPMessage(Sender: TObject);
  public
    procedure DoInspectBullet(Sender: TObject);
  public
    procedure DoClickOnSimpleLabel(Sender: TObject);
    procedure DoSpriteProverka(Sender: TObject);
  public
    constructor Create(const InParent: avk_TFraim; InName: String);
    destructor Destroy; override;
  end;

var
  Version: String = '3';

  MineForm: TMineForm;
  ErrorImg, texLogo, Wallpaper: zglPTexture; //логотипчик
  fntMine, fntMessage, fntCaption: zglPFont;

  procedure Proc;
  procedure Init;
  procedure Draw;
  procedure Update( dt : Double );
  procedure Quit;
  {$ifdef ANDROID}
  procedure Restore;
  {$endif}

implementation

procedure LoadResourse;
var
  TmpPrefix: String = '';
  TmpResFName: String = '';
begin
   {$ifdef ANDROID}
   TmpResFName := PAnsiChar( zgl_Get( DIRECTORY_APPLICATION ) )
   TmpPrefix:='assets/';
   {$ELSE}
   TmpResFName := 'A_resources.zip';
   TmpPrefix   := '';
   {$endif}
   MineForm.FileResourses   := TmpResFName;
   MineForm.ArhResNowOpen  := true;
   MineForm.LoadResource(TmpPrefix+'Calibri Light-Regular-10pt.zfi','Calibri Light-Regular-10');
   MineForm.LoadResource(TmpPrefix+'Calibri Light-Regular-20pt.zfi','Calibri Light-Regular-20');
   MineForm.LoadResource(TmpPrefix+'Calibri Light-Regular-36pt.zfi','Calibri Light-Regular-36');
   MineForm.LoadResource(TmpPrefix+'main.png','Логотип');
   MineForm.LoadResource(TmpPrefix+'ErrorImg.png','for error');
   MineForm.LoadResource(TmpPrefix+'blueback.png', 'wallpaper');
   MineForm.LoadResource(TmpPrefix+'simplebutton.png', 'Кнопка');
   MineForm.LoadResource(TmpPrefix+'fraimwallpaper.png', 'Обои фрейма');
   MineForm.LoadResource(TmpPrefix+'connor_btn.png', 'Угловая кнопка');
   MineForm.LoadResource(TmpPrefix+'swichbutton.png', 'Чекбокс');
   MineForm.LoadResource(TmpPrefix+'bevelpanel.png', 'Панелька');
   MineForm.LoadResource(TmpPrefix+'bevelpanelec.png', 'Панелька пуст');
   MineForm.LoadResource(TmpPrefix+'PersonSteps.png', 'Шагающий стрелок');
   MineForm.LoadResource(TmpPrefix+'leafs.png', 'Листочек');
   MineForm.LoadResource(TmpPrefix+'m_a_tilefloor01.png', 'пол1');
   MineForm.LoadResource(TmpPrefix+'m_a_tilefloor05.png', 'пол2');
   MineForm.LoadResource(TmpPrefix+'m_m_metaltiles02.png', 'пол3');
   MineForm.LoadResource(TmpPrefix+'m_m_platform01.png', 'пол4');
   MineForm.LoadResource(TmpPrefix+'m_m_platform03.png', 'пол5');
   MineForm.LoadResource(TmpPrefix+'m_m_platform04.png', 'пол6');
   MineForm.LoadResource(TmpPrefix+'plat_anim.png', 'пол7');
   MineForm.LoadResource(TmpPrefix+'bullet.png', 'пулька');

   MineForm.LoadResource(TmpPrefix+'helmet.png', 'спрайт шлем');
   MineForm.LoadResource(TmpPrefix+'arrow head.png', 'спрайт стрелка на шлем');
   MineForm.LoadResource(TmpPrefix+'right_shoulder.png', 'спрайт правое плечо');
   MineForm.LoadResource(TmpPrefix+'left_shoulder.png', 'спрайт левое плечо');
   MineForm.LoadResource(TmpPrefix+'left_hand.png', 'спрайт левая рука');
   MineForm.LoadResource(TmpPrefix+'right_hand.png', 'спрайт правая рука');
   MineForm.LoadResource(TmpPrefix+'backpack.png', 'спрайт рюкзак');
   MineForm.LoadResource(TmpPrefix+'star.png', 'спрайт звездочка');
   MineForm.LoadResource(TmpPrefix+'left_foot.png', 'спрайт левая нога');
   MineForm.LoadResource(TmpPrefix+'right_foot.png', 'спрайт правая нога');

   MineForm.ArhResNowOpen  := false;
   MineForm.Font := MineForm.FontManager.FontName['Calibri Light-Regular-10'];//базовый шрифт системы
   MineForm.Wallpaper := MineForm.TexManager.TexName['wallpaper'];
end;

{$ifdef ANDROID}
procedure Restore;
begin
  if Assigned(MineForm)then MineForm.Restore;
end;
{$endif}

procedure Proc;
begin
  if Assigned(MineForm)then MineForm.Proc;
end;

procedure Draw;
begin
  if Assigned(MineForm) then MineForm.Draw;
  {$IfDef Debug}
  {$Else}
    wnd_SetCaption( 'Test avk components. FPS ' + u_IntToStr( zgl_Get( RENDER_FPS )));
  {$EndIf}
end;

procedure Update(dt: Double);
begin
  //if Assigned(MineForm) then MineForm.Proc;
end;

procedure Quit;
begin
  MineForm.Destroy;
end;

procedure Init;
var
  TmpLogo: avk_TLogotip;
  TmpBttn: avk_TSimpleButton;
  SCwight, SChight: Integer;
  tmpTestForm: avk_TElement;
begin
  MineForm := TMineForm.Create(nil,'Рабочий стол');
  LoadResourse;
  TmpLogo := avk_TLogotip.Create(MineForm,'Логотип');
  SCwight := Round(MineForm.AreaElement.W / 2);
  SChight := Round(MineForm.AreaElement.H / 2);
  //TmpLogo.SetAreaElement(MineForm.AreaElement.W - 100, MineForm.AreaElement.H - 70, 100, 70);
  TmpLogo.SetAreaElement(SCwight - 200, SChight - 70, 400, 140);
  TmpLogo.texLogo := MineForm.TexManager.TexName['Логотип'];

  TmpBttn           := avk_TSimpleButton.Create(MineForm,'Проверка');
  TmpBttn.SetAreaElement(2,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Пример окна';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.OnClick := MineForm.DoProverka;
  TmpBttn.Layer := 120;

  TmpBttn           := avk_TSimpleButton.Create(MineForm,'Проверка спрайта');
  TmpBttn.SetAreaElement(124,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Пример спрайта';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.OnClick := MineForm.DoSpriteProverka;
  TmpBttn.Layer := 120;

  TmpBttn := avk_TSimpleButton.Create(MineForm,'Проверка спрайтов');
  TmpBttn.SetAreaElement(246,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Много спрайтов';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoMassiveSprites;

  TmpBttn := avk_TSimpleButton.Create(MineForm,'Проверка тайлов');
  TmpBttn.SetAreaElement(368,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Тайлы';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoSpecPnlSpr;

  TmpBttn := avk_TSimpleButton.Create(MineForm,'Убрать спрайтов');
  TmpBttn.SetAreaElement(490,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Убрать много спрайтов';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoMassiveSpritesCl;

  TmpBttn := avk_TSimpleButton.Create(MineForm,'Проверить сервер');
  TmpBttn.SetAreaElement(612,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Проверить сервер';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoPanelServer;

  TmpBttn := avk_TSimpleButton.Create(MineForm,'Сборный спрайт');
  TmpBttn.SetAreaElement(734,2,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Сборный спрайт';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoPanelCompSprite;


  TmpBttn := avk_TSimpleButton.Create(MineForm,'Выход');
  TmpBttn.SetAreaElement(MineForm.AreaElement.W - 121,1,120,32);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Выход';
  TmpBttn.LabelCaption.FontColor := $1E90FF;
  TmpBttn.Layer := 120;
  TmpBttn.OnClick := TMineForm.DoClose;

  TmpLogo.Layer:=TmpLogo.Layer+150;
end;
//процедуры
{$INCLUDE TMineForm_proc.inc}

end.

