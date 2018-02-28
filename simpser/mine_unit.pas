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
  //
  avk_coolspritetest,
  //
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
    procedure DoMoveCoolSprite(Sender: TObject);
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
   {$INCLUDE mineform_loadresource.inc}
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
  {$IfNDef Debug}
    {$ifndef ANDROID}
    wnd_SetCaption( 'Test avk components. FPS ' + u_IntToStr( zgl_Get( RENDER_FPS )));
    {$EndIf}
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
  TmpBttn: avk_TSimpleButton;
begin
  MineForm := TMineForm.Create(nil,'Рабочий стол');
  LoadResourse;
  MineForm.TextureCursor := MineForm.TexManager.TexName['Cursor'];;
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
end;

//процедуры
{$INCLUDE TMineForm_proc.inc}

end.

