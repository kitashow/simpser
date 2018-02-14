
{ TMineForm }
procedure TMineForm.DoClose(Sender: TObject);
begin
  zgl_Exit;
end;

procedure TMineForm.DoMassiveSpritesCl(Sender: TObject);
begin
  if MineForm.ListName['Панелька под листочки'] <> nil then begin
    MineForm.ListName['Панелька под листочки'].DeleteMe:= true;
  end;
end;

procedure TMineForm.DoMassiveSprites(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpSpr: avk_TSimpleSprite;
  CKL: Integer;
  TSX, TSY: Single;
  TSW, TSH: Single;
  TSAngle: Single;
begin
  if MineForm.ListName['Панелька под листочки'] <> nil then begin
    //MineForm.ListName['Панелька под листочки'].DeleteMe:= true;
    Exit;
  end;
  tmpTestForm     := avk_TElement.Create(MineForm,'Панелька под листочки');
  tmpTestForm.SetAreaElement(0,0,MineForm.AreaElement.W,MineForm.AreaElement.H);
  tmpTestForm.Layer := 2;
  tmpTestForm.GetMouse := false;

  for CKL := 1 to 200 do begin
    TmpSpr := avk_TSimpleSprite.Create(tmpTestForm,'List'+avk_IntToStr(CKL));
    TmpSpr.Layer := Random(100);
    while TmpSpr.Layer < 30 do TmpSpr.Layer := Random(100);
    TmpSpr.Texture := MineForm.TexManager.TexName['Листочек'];
    TSX := Random(Trunc(MineForm.AreaElement.W));
    TSY := -1 * Random(100) - 50;
    TSW := 50 + TmpSpr.Layer;
    TSH := 50 + TmpSpr.Layer;
    TSAngle := Random(180);
    TmpSpr.SetParameters(TSX, TSY, TSW, TSH, TSAngle);
    TmpSpr.OnBeforeProc := TMineForm.DoDropList;
  end;
end;

procedure TMineForm.DoDropList(Sender: TObject);
var
  tempPar: avk_TElement;
  SpeedLost: Single;
begin
  if Sender.ClassName <> 'avk_TSimpleSprite' then Exit;

  with avk_TSimpleSprite(Sender) do begin
    tempPar := avk_TElement(Parent);
    SpeedLost := 0.005 * Layer;
    if SpeedLost < 0.01 then SpeedLost:= 0.01;
    CPY := CPY + SpeedLost;
    if CPY > tempPar.AreaElement.H then begin
      CPY := -1 * Random(100) - 200;
      CPX := Random(Trunc(tempPar.AreaElement.W));
    end;
    if key_Down( K_A ) or key_Down( K_LEFT ) then begin
      CPX := CPX - (0.25+ 0.2*SpeedLost);
    end;
    if key_Down( K_D ) or key_Down( K_RIGHT ) then begin
      CPX := CPX + (0.25+ 0.2*SpeedLost);
    end;
  end;
end;

procedure TMineForm.DoClickOnSimpleLabel(Sender: TObject);
var
  TmpSL: avk_TSimpleLabel;
begin
  TmpSL           := avk_TSimpleLabel(Sender);
  TmpSL.Caption   := 'Простая надпись была нажата.';
end;

procedure TMineForm.DoClickOnClosePnl(Sender: TObject);
begin
  avk_TFraim(Sender).Parent.DeleteMe := true;
end;

procedure TMineForm.DoProverka(Sender: TObject);
var
  TmpSL: avk_TSimpleLabel;
  TmpBttn: avk_TSimpleButton;
  TmpCHB: avk_TSwitchButton;
  TmpInp: avk_TSimpleInput;
  tmpTestForm: avk_TElement;
  TmpPnl: avk_TPanel;
begin
  if MineForm.ListName['Пример вложенного окна'] <> nil then Exit;

  tmpTestForm     := avk_TElement.Create(MineForm,'Пример вложенного окна');
  tmpTestForm.Wallpaper := MineForm.TexManager.TexName['Обои фрейма'];
  tmpTestForm.SetAreaElement(150,50,800,600);
    TmpSL           := avk_TSimpleLabel.Create(tmpTestForm,'Простая надпись');
    TmpSL.OnClick   := MineForm.DoClickOnSimpleLabel;
    TmpSL.Caption   := 'Простая надпись, которую можно нажать.';
    TmpSL.SetAreaElement(400,570,200,30);
    TmpBttn           := avk_TSimpleButton.Create(tmpTestForm,'Меню1');
    TmpBttn.SetAreaElement(0,575,100,25);
    TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
    TmpBttn.LabelCaption.Caption := 'Проверка кнопки';
    TmpBttn           := avk_TSimpleButton.Create(tmpTestForm,'Открытые элементы');
    TmpBttn.SetAreaElement(100,575,120,25);
    TmpBttn.LabelCaption.FontColor := $000FFF;
    TmpBttn.LabelCaption.Caption := 'Еще одна проверка';
    TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];

    TmpCHB            := avk_TSwitchButton.Create(tmpTestForm,'ЧекВключенный');
    TmpCHB.TexButton := MineForm.TexManager.TexName['Чекбокс'];
    TmpCHB.SetAreaElement(700,100,75,25);
    TmpSL           := avk_TSimpleLabel.Create(tmpTestForm,'К радиокнопке');
    TmpSL.OnClick   := MineForm.DoClickOnSimpleLabel;
    TmpSL.Caption   := 'Какой-то параметр который можно переключить, надпись тоже можно нажать.';
    TmpSL.SetAreaElement(400,100,300,25);
    TmpCHB           := avk_TSwitchButton.Create(tmpTestForm,'ЧекВыключенный');
    TmpCHB.TexButton := MineForm.TexManager.TexName['Чекбокс'];
    TmpCHB.SetAreaElement(700,130,75,25);
    TmpCHB.Disable  := true;
    TmpSL           := avk_TSimpleLabel.Create(tmpTestForm,'К радиокнопке');
    TmpSL.Caption   := 'Какой-то параметр который можно переключить, выключен сейчас.';
    TmpSL.SetAreaElement(400,130,300,25);

    TmpInp          := avk_TSimpleInput.Create(tmpTestForm,'Ввод примера');
    TmpInp.SetAreaElement(50,130,300,25);
    TmpInp.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_CENTER or TEXT_HALIGN_LEFT;
    TmpInp.TransparentBackground := false;

    TmpInp          := avk_TSimpleInput.Create(tmpTestForm,'Ввод примера');
    TmpInp.SetAreaElement(50,160,300,25);
    TmpInp.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_CENTER or TEXT_HALIGN_LEFT;
    TmpInp.ShadowCaption:='А это пример с выключенной прозрачностью';

    TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька');
    TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька'];
    TmpPnl.SetAreaElement(400,200,192,74);
    //TmpPnl.Disable := true;
      TmpSL           := avk_TSimpleLabel.Create(TmpPnl,'Простая надпись');
      //TmpSL.OnClick   := MineForm.DoClickOnSimpleLabel;
      TmpSL.Caption   := 'Простая надпись, которую нельзя нажать, она просто демонстрирует какую-то надпись в панельке.';
      TmpSL.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_TOP or TEXT_HALIGN_JUSTIFY;
      TmpSL.GetMouse := false;
      TmpSL.SetAreaElement(5,5,182,64);

    TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька1');
    TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька'];
    TmpPnl.SetAreaElement(600,200,192,74);
    TmpPnl.Disable := true;
      TmpSL           := avk_TSimpleLabel.Create(TmpPnl,'Простая надпись');
      //TmpSL.OnClick   := MineForm.DoClickOnSimpleLabel;
      TmpSL.Caption   := 'Простая надпись, которую нельзя нажать, она просто демонстрирует какую-то надпись в выключенной панельке.';
      TmpSL.FontColor:= $5F9EA0;
      TmpSL.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_TOP or TEXT_HALIGN_JUSTIFY;
      TmpSL.GetMouse := false;
      TmpSL.SetAreaElement(5,5,182,64);

    TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька2');
    TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька пуст'];
    TmpPnl.SetAreaElement(400,280,192,74);
    TmpPnl.EmpityCentre := true;
    TmpPnl.Disable := true;
      TmpSL           := avk_TSimpleLabel.Create(TmpPnl,'Простая надпись');
      TmpSL.Caption   := 'Надпись демонстрирует какую-то надпись в панельке c пустым центром (считай рамка).';
      TmpSL.FontColor:= $556B2F;
      TmpSL.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_TOP or TEXT_HALIGN_JUSTIFY;
      TmpSL.GetMouse := false;
      TmpSL.SetAreaElement(5,5,182,64);

    TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька3');
    TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька пуст'];
    TmpPnl.SetAreaElement(600,280,192,74);
    TmpPnl.EmpityCentre := true;
    TmpPnl.Disable := false;
      TmpBttn           := avk_TSimpleButton.Create(TmpPnl,'Кнопка в панельке');
      TmpBttn.SetAreaElement(5,5,182,64);
      TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
      TmpBttn.LabelCaption.Caption := 'Кнопка в панельке демонстрирующая возможность комбинировать рамку и кнопку';
      TmpBttn.LabelCaption.FontColor := $8B0000;

    TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька3');
    TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька пуст'];
    TmpPnl.SetAreaElement(400,360,392,54);
    TmpPnl.EmpityCentre := true;
    TmpPnl.Disable := false;
      TmpBttn           := avk_TSimpleButton.Create(TmpPnl,'Кнопка в панельке');
      TmpBttn.SetAreaElement(5,5,382,44);
      TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
      TmpBttn.LabelCaption.Caption := 'Вывести пример простого спрайта';
      TmpBttn.LabelCaption.FontColor := $000FFF;

    TmpBttn           := avk_TSimpleButton.Create(tmpTestForm,'Закрыть панель');
    TmpBttn.SetAreaElement(700,0,100,25);
    TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
    TmpBttn.LabelCaption.Caption := 'Закрыть панель';
    TmpBttn.LabelCaption.FontColor := $8B0000;
    TmpBttn.OnClick := MineForm.DoClickOnClosePnl;
end;

procedure TMineForm.DoSpriteProverka(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpPnl: avk_TPanel;
  TmpBttn: avk_TSimpleButton;
  TmpSpr: avk_TSimpleSprite;
  SubTmpSpr: avk_TSimpleSprite;
begin
  if MineForm.ListName['Пример второго'] <> nil then Exit;
  tmpTestForm := avk_TElement.Create(MineForm,'Пример второго');
  tmpTestForm.SetAreaElement(250,20,800,640);
  TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька');
  TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька пуст'];
  TmpPnl.SetAreaElement(0,0,800,40);
  TmpPnl.EmpityCentre := true;
  TmpBttn := avk_TSimpleButton.Create(TmpPnl,'Закрыть панель');
  TmpBttn.SetAreaElement(700,5,95,30);
  TmpBttn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBttn.LabelCaption.Caption := 'Закрыть панель';
  TmpBttn.LabelCaption.FontColor := $8B0000;
  TmpBttn.OnClick := TMineForm.DoClickOnClosePnlSpr;
  TmpPnl := avk_TPanel.Create(tmpTestForm,'Панелька спрайта');
  TmpPnl.TexPanel := MineForm.TexManager.TexName['Панелька пуст'];
  TmpPnl.SetAreaElement(0,40,800,600);
  TmpPnl.EmpityCentre := true;
  TmpPnl.OnProc := DoInspectBullet; //пульки

  //теперь делаем спрайтик
  TmpSpr := avk_TSimpleSprite.Create(TmpPnl,'Шагающий солдатик');
  TmpSpr.Texture := MineForm.TexManager.TexName['Шагающий стрелок'];
  tex_SetFrameSize( TmpSpr.Texture, 69, 52);
  TmpSpr.SetParameters(590, 240, 69, 52, 0);
  TmpSpr.AddAdditionalPoint('Вылет пульки', 26, 30);

  TmpSpr.StopCadre := 12;
  TmpSpr.RateCadre := 90;
  TmpSpr.OnBeforeProc := DoAPforSpr;//чтоб двигать
  TmpSpr.SetCollisionZone(0, 0, 35);

end;

procedure TMineForm.DoAPforSpr(Sender: TObject);
var
  Nazata: Boolean;
  tempPar: avk_TPanel;

begin
  if Sender.ClassName <> 'avk_TSimpleSprite' then Exit;
  Nazata := false;
  with avk_TSimpleSprite(Sender) do begin
    tempPar := avk_TPanel(Parent);
    if key_Down( K_W ) or key_Down( K_UP ) then begin
      Angle := - 90;
      CPY := CPY - 0.25;
      Nazata := true;
    end;

    if key_Down( K_S ) or key_Down( K_DOWN ) then begin
      Angle := 90;
      CPY := CPY + 0.25;
      Nazata := true;
    end;
    if key_Down( K_A ) or key_Down( K_LEFT ) then begin
      Angle := 180;
      CPX := CPX - 0.25;
      Nazata := true;
    end;
    if key_Down( K_D ) or key_Down( K_RIGHT ) then begin
      Angle := 0;
      CPX := CPX + 0.25;
      Nazata := true;
    end;

    //ограничения
    if CPY < tempPar.GetAbsolyteArea.Y then CPY := CPY + 1;
    if CPX < tempPar.GetAbsolyteArea.X then CPX := CPX + 1;
    if (CPX + W) > (tempPar.GetAbsolyteArea.X + tempPar.AreaElement.W) then CPX := CPX - 1;
    if (CPY + H) > (tempPar.GetAbsolyteArea.Y + tempPar.AreaElement.H) then CPY := CPY - 1;
    Animate := Nazata;
  end;
end;

procedure TMineForm.DoClickOnClosePnlSpr(Sender: TObject);
begin
  avk_TFraim(Sender).Parent.Parent.DeleteMe := true;
end;

constructor TMineForm.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
end;

destructor TMineForm.Destroy;
begin
  if Assigned(TCPServer) then TCPServer.Destroy;
  inherited Destroy;
end;

procedure TMineForm.DoSpecPnlSpr(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpBtn: avk_TSimpleButton;
  TmpMap: avk_TSimpleMap;
  SprTile: avk_TSimpleTile;
  CKL1: Integer;
  CKL2: Integer;
  NumSpr: Integer;
  TmpNameSpr: UTF8String;
begin
  if MineForm.ListName['Пример тайлового поля'] <> nil then Exit;

  tmpTestForm     := avk_TElement.Create(MineForm,'Пример тайлового поля');
  tmpTestForm.SetAreaElement(150,10,1000,680);
  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Закрыть');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(905,1,95,30);
  TmpBtn.LabelCaption.Caption := 'Закрыть панель';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoClickOnClosePnl;
  TmpBtn.Layer := 50;
  TmpMap := avk_TSimpleMap.Create(tmpTestForm,'Тайловая карта');
  TmpMap.TileSizeW := 64;
  TmpMap.TileSizeH := 64;

  TmpMap.SetSizeMap(1, 100, 90);

  TmpMap.SetWievPanelSize(2048, 1536);
  TmpMap.SetWiewPanelX(780);
  TmpMap.SetWiewPanelY(250);

  for CKL1 := 0 to TmpMap.CountTileW - 1 do begin
    for CKL2 := 0 to TmpMap.CountTileH - 1 do begin
      NumSpr := Random(6);
      SprTile := avk_TSimpleTile.Create;
      if NumSpr = 0 then begin
        SprTile.Texture := MineForm.TexManager.TexName['пол7'];
        tex_SetFrameSize( SprTile.Texture, 64, 64);
        SprTile.X := 0;
        SprTile.Y := 0;
        SprTile.W := 64;
        SprTile.H := 64;
        SprTile.StopCadre := 37;
        SprTile.RateCadre := 10;
        SprTile.Angle := 0;
      end else begin
        TmpNameSpr := 'пол' + avk_IntToStr(NumSpr);
        SprTile.Texture := MineForm.TexManager.TexName[TmpNameSpr];
      end;
      SprTile.W := TmpMap.TileSizeW;
      SprTile.H := TmpMap.TileSizeH;
      TmpMap.LOT[0, CKL1,CKL2] := SprTile;
    end;
  end;
  TmpMap.SetAreaElement(0,0,1000,680);
  TmpMap.GetMouse := false; //Не должен брать мыш
  TmpMap.Layer := 1;
  TmpMap.OnBeforeProc := DoPnlSprMove;

  {$IfDef Debug}
  TmpBtn := avk_TSimpleButton.Create(TmpMap,'Производительность');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(1,649,100,30);
  TmpBtn.LabelCaption.Caption := '000000';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  {$EndIf}

end;

procedure TMineForm.DoStopStartServer(Sender: TObject);
begin
  if not Assigned(TCPServer) then begin
    TCPServer := avk_TServer.Create(6638);
    //TCPServer.OnSomeError := WasError;
    TCPServer.OnMessageInput := TCPMessage;
    TCPServer.OnNewConnect := TCPNewCon;
    TCPServer.Echo := true;
    TCPServer.Connected := true;
    if TCPServer.Connected then
       TCPMessage('Подключение прошло.');
  end else begin
    TCPServer.Destroy;
    TCPServer := nil;
    TCPMessage('Выключен.');
  end;
end;

procedure TMineForm.TCPMessage(InMessage: String; InParent: TObject);
begin
  if MineForm.ListName['Пример простого сервера'] = nil then Exit;
  if MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений'] = nil then Exit;
  avk_TMessagePanel(MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений']).Report(InMessage,'i');
  if InParent is TLSocket then begin
     TLSocket(InParent).SendMessage('Принял');
  //   TCPServer.EchoMessage(avk_TSocket(InParent).Socket,InMessage);
  end;
end;

procedure TMineForm.TCPNewCon(InMessage: String; InParent: TObject);
begin
  if MineForm.ListName['Пример простого сервера'] = nil then Exit;
  if MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений'] = nil then Exit;
  avk_TMessagePanel(MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений']).Report(InMessage,'!!!');
end;

procedure TMineForm.WasError( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
begin
  if MineForm.ListName['Пример простого сервера'] = nil then Exit;
  if MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений'] = nil then Exit;
  avk_TMessagePanel(MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений']).Report(InCommand,'ОШИБКА');
  avk_TMessagePanel(MineForm.ListName['Пример простого сервера'].ListName['Панель сообщений']).Report(InMessage,'>');
end;

procedure TMineForm.DoInputTCPMessage(Sender: TObject);
begin
  if not Assigned(TCPServer) then Exit;
end;

procedure TMineForm.DoPanelServer(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpBtn: avk_TSimpleButton;
  TmpCHB: avk_TSwitchButton;
  TmpSL: avk_TSimpleLabel;
  TmpInp: avk_TSimpleInput;
  tmpTestFormkl: avk_TElement;
  FMessagePanel: avk_TMessagePanel;
begin
  if MineForm.ListName['Пример простого сервера'] <> nil then Exit;
  tmpTestForm := avk_TElement.Create(MineForm,'Пример простого сервера');
  tmpTestForm.SetAreaElement(2,36,480,680);
  tmpTestForm.Wallpaper := MineForm.TexManager.TexName['Обои фрейма'];
  //закрыть
  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Закрыть');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(2,648,475,30);
  TmpBtn.LabelCaption.Caption := 'Закрыть панель (сервер продолжит работать)';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoClickOnClosePnl;
  //включить выключить сервер
  TmpSL := avk_TSimpleLabel.Create(tmpTestForm,'Описание состояния сервера');
  TmpSL.Caption := 'Описание состояния сервера:';
  TmpSL.Font := MineForm.FontManager.FontName['Calibri Light-Regular-20'];;
  TmpSL.FontColor:= $000000;
  TmpSL.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_TOP or TEXT_HALIGN_JUSTIFY;
  TmpSL.SetAreaElement(2, 2, 400, 30);
  TmpSL.GetMouse := false;
  //переключатель
  TmpCHB := avk_TSwitchButton.Create(tmpTestForm,'СерверВключен');
  TmpCHB.Checked := true;
  TmpCHB.TexButton := MineForm.TexManager.TexName['Чекбокс'];
  TmpCHB.SetAreaElement(400,4,75,25);
  TmpCHB.OnClick := MineForm.DoStopStartServer;
  //порт
  TmpSL := avk_TSimpleLabel.Create(tmpTestForm,'порт сервера');
  TmpSL.Caption := 'Порт сервера:';
  TmpSL.Font := MineForm.FontManager.FontName['Calibri Light-Regular-20'];;
  TmpSL.FontColor:= $000000;
  TmpSL.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_TOP or TEXT_HALIGN_JUSTIFY;
  TmpSL.SetAreaElement(2, 32, 400, 30);
  TmpSL.GetMouse := false;
  //ввод порта сервера
  TmpInp := avk_TSimpleInput.Create(tmpTestForm,'Порт сервера');
  TmpInp.Font := MineForm.FontManager.FontName['Calibri Light-Regular-20'];;
  TmpInp.SetAreaElement(400,32,75,30);
  TmpInp.ZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_CENTER or TEXT_HALIGN_LEFT;
  TmpInp.TransparentBackground := false;
  TmpInp.Text := '6638';
  FMessagePanel := avk_TMessagePanel.Create(tmpTestForm,'Панель сообщений');
  FMessagePanel.FontColor := $010101;
  FMessagePanel.Position := POS_DESIGN;
  FMessagePanel.CaptionButton.Disable := true;
  FMessagePanel.SetAreaElement(2,64,475,580);
  FMessagePanel.OnAfterParentResize(MineForm);

end;

procedure TMineForm.DoPanelCompSprite(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpBtn: avk_TSimpleButton;
  TmpSklPnt, TmpSklPntSl: avk_TSkeletSprite;
begin
  if MineForm.ListName['Пример собранного спрайта'] <> nil then Exit;
  tmpTestForm := avk_TElement.Create(MineForm,'Пример собранного спрайта');
  tmpTestForm.SetAreaElement(270,66,760,580);
  tmpTestForm.Wallpaper := MineForm.TexManager.TexName['Обои фрейма'];

  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Закрыть');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(663,2,95,30);
  TmpBtn.LabelCaption.Caption := 'Закрыть панель';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoClickOnClosePnl;

  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Повернуть на 5');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(566,2,95,30);
  TmpBtn.LabelCaption.Caption := 'Повернуть на 5';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoRotateCompSprite5gr;

  //делаем скелет
  TmpSklPnt := avk_TSkeletSprite.Create(tmpTestForm, 'lo1');
  TmpSklPnt.StartPoint.X := 756;
  TmpSklPnt.StartPoint.Y := 271;
  TmpSklPnt.Calk;
  TmpSklPnt.SetSprite('шлем', MineForm.TexManager.TexName['спрайт шлем'],
  0, 0, //если есть вложенные
  13, 13, // ось
  25, 25, // ширина высота
  0, 13, 13,
  0, 0);

  TmpSklPntSl := avk_TSkeletSprite.Create(TmpSklPnt, 'lo2');
  TmpSklPntSl.Host := TmpSklPnt;
  TmpSklPntSl.StartPoint.X := -15;
  TmpSklPntSl.StartPoint.Y := 24;
  TmpSklPntSl.Calk;

  TmpSklPntSl := avk_TSkeletSprite.Create(avk_TSkeletPoint(TmpSklPnt.ListName['lo2']), 'lo3');
  TmpSklPntSl.Host := avk_TSkeletPoint(TmpSklPnt.ListName['lo2']);
  TmpSklPntSl.StartPoint.X := -42;
  TmpSklPntSl.StartPoint.Y := -16;
  TmpSklPntSl.Calk;

end;

procedure TMineForm.DoRotateCompSprite5gr(Sender: TObject);
var
  TmpSPnt: avk_TSkeletPoint;
begin
  if MineForm.ListName['Пример собранного спрайта'] = nil then Exit;
  TmpSPnt := avk_TSkeletPoint(avk_TElement(MineForm.ListName['Пример собранного спрайта']).ListName['lo1']);
  TmpSPnt.StartAngle := TmpSPnt.StartAngle + 5;
  if TmpSPnt.StartAngle > 360 then TmpSPnt.StartAngle := 0;
end;

procedure TMineForm.DoPnlSprMove(Sender: TObject);
var
  tempEl: avk_TSimpleMap;
  SpeedLost: Single;
begin
  if Sender.ClassName <> 'avk_TSimpleMap' then Exit;
  tempEl := avk_TSimpleMap(Sender);
  with tempEl do begin
    SpeedLost := 0.5;
    {$IfDef Debug}
    avk_TSimpleButton(GetFraimById(GetIdByName('Производительность'))).LabelCaption.Caption:= 'P - D ' + avk_IntToStr(CalcPrgs - CalcDraw);
    {$EndIf}
    if key_Down( K_A ) or key_Down( K_LEFT ) then begin
      SetWiewPanelX(WievPanel.X - SpeedLost);
    end;
    if key_Down( K_D ) or key_Down( K_RIGHT ) then begin
      SetWiewPanelX(WievPanel.X + SpeedLost);
    end;
    if key_Down( K_W ) or key_Down( K_UP ) then begin
      SetWiewPanelY(WievPanel.Y - SpeedLost);
    end;
    if key_Down( K_S ) or key_Down( K_DOWN ) then begin
      SetWiewPanelY(WievPanel.Y + SpeedLost);
      //SetWievPanelSize(WievPanel.W + 20,  WievPanel.H + 20);
    end;
  end;
end;

procedure TMineForm.DoInspectBullet(Sender: TObject);
var
  TmpPnl: avk_TPanel;
  TmpSpr: avk_TSimpleSprite;
begin
  if avk_MouseIsClick(M_BLEFT) then begin
    //теперь делаем спрайтик
    TmpPnl := avk_TPanel(Sender);
    TmpSpr := avk_TSimpleSprite.Create(TmpPnl,'Пулька');
    TmpSpr.Texture := MineForm.TexManager.TexName['пулька'];
    //tex_SetFrameSize( TmpSpr.Texture, 69, 52);
    TmpSpr.SetParameters(80, 80, 6, 14, 0);
    TmpSpr.StopCadre := 0;
    TmpSpr.RateCadre := 0;
    TmpSpr.OnBeforeProc := DoAPforSpr;//чтоб двигать
  end;
end;

