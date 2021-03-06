
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
    TmpSpr := avk_TSimpleSprite.Create(tmpTestForm);
    TmpSpr.Layer := Random(100);
    while TmpSpr.Layer < 30 do TmpSpr.Layer := Random(100);
    TmpSpr.SkPnt.Texture := MineForm.TexManager.TexName['Листочек'];
    TSX := Random(Trunc(MineForm.AreaElement.W));
    TSY := -1 * Random(100) - 50;
    TSW := 50 + TmpSpr.Layer;
    TSH := 50 + TmpSpr.Layer;
    TSAngle := Random(180);
    TmpSpr.SkPnt.SetInternalParameters(TSX, TSY, TSAngle, 1, -(TSW / 2),  -(TSH / 2), TSW, TSH);
    TmpSpr.OnBeforeProc := TMineForm.DoDropList;
  end;
end;

procedure TMineForm.DoDropList(Sender: TObject);
var
  tempPar: avk_TElement;
  SpeedLost, CPY, CPX: Single;
begin
  if Sender.ClassName <> 'avk_TSimpleSprite' then Exit;

  with avk_TSimpleSprite(Sender) do begin
    tempPar := avk_TElement(Parent);
    SpeedLost := 0.005 * Layer;
    if SpeedLost < 0.01 then SpeedLost:= 0.01;

    CPY := SkPnt.Point.Y;
    CPX := SkPnt.Point.X;

    CPY := CPY + SpeedLost;
    SkPnt.SetPoint(CPX, CPY);

    if CPY > (tempPar.AreaElement.H + 80) then begin
      SkPnt.SetPoint(Random(Trunc(tempPar.AreaElement.W)), -1 * Random(100) - 50);
      SkPnt.Angle := Random(180);
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

  //теперь делаем спрайтик
  TmpSpr := avk_TSimpleSprite.Create(TmpPnl);
  TmpSpr.SkPnt.Texture := MineForm.TexManager.TexName['Шагающий стрелок'];
  TmpSpr.SkPnt.SetTexFrameSize(69, 52);
  TmpSpr.SkPnt.SetInternalParameters(590, 240, 0, 1, -34, -26, 69, 52);
  TmpSpr.SkPnt.AddSubPoint;
  TmpSpr.SkPnt.SubPoints[0].Texture := MineForm.TexManager.TexName['пулька'];
  TmpSpr.SkPnt.SubPoints[0].TileRotateByHost := false;
  TmpSpr.SkPnt.SubPoints[0].SetInternalParameters(26, 30, 90, 1, -3, -7, 6, 14);

  TmpSpr.SkPnt.AddSubPoint(26, -30);
  TmpSpr.SkPnt.SubPoints[1].Texture := MineForm.TexManager.TexName['пулька'];
  //не меняем TmpSpr.SkPnt.SubPoints[0].TileRotateByHost
  TmpSpr.SkPnt.SubPoints[1].SetInternalParameters(26, -30, 90, 1, -3, -7, 6, 14);

  TmpSpr.SkPnt.StopCadre := 12;
  TmpSpr.SkPnt.RateCadre := 15;
  TmpSpr.OnBeforeProc := DoAPforSpr;//чтоб двигать

end;

procedure TMineForm.DoAPforSpr(Sender: TObject);
var
  Nazata, TmpK_UP, TmpK_DOWN, TmpK_LEFT, TmpK_RIGHT: Boolean;
  CPY, CPX: Single;
begin
  if Sender.ClassName <> 'avk_TSimpleSprite' then Exit;
  Nazata := false;
  with avk_TSimpleSprite(Sender).SkPnt do begin

    CPY := Point.Y;
    CPX := Point.X;

    Nazata := true;
    TmpK_UP := key_Down( K_W ) or key_Down( K_UP );
    TmpK_DOWN := key_Down( K_S ) or key_Down( K_DOWN );
    TmpK_LEFT := key_Down( K_A ) or key_Down( K_LEFT );
    TmpK_RIGHT := key_Down( K_D ) or key_Down( K_RIGHT );

    if TmpK_UP and TmpK_LEFT then begin
      Angle := - 135;
      CPX := CPX - 0.25;
      CPY := CPY - 0.25;
    end else if TmpK_UP and TmpK_RIGHT then begin
      Angle := - 45;
      CPX := CPX + 0.25;
      CPY := CPY - 0.25;
    end else if TmpK_DOWN and TmpK_RIGHT then begin
      Angle :=  45;
      CPX := CPX + 0.25;
      CPY := CPY + 0.25;
    end else if TmpK_DOWN and TmpK_LEFT then begin
      Angle :=  135;
      CPX := CPX - 0.25;
      CPY := CPY + 0.25;
    end else if TmpK_DOWN then begin
      Angle := 90;
      CPY := CPY + 0.5;
    end else if TmpK_UP then begin
      Angle := - 90;
      CPY := CPY - 0.5;
    end else if TmpK_LEFT then begin
      Angle :=  180;
      CPX := CPX - 0.5;
    end else if TmpK_RIGHT then begin
      Angle :=  0;
      CPX := CPX + 0.5;
    end else Nazata := false;

    //ограничения
    if CPY < avk_TElement(avk_TSimpleSprite(Sender).Parent).GetAbsolyteArea.Y then CPY := CPY + 1;
    if CPX < avk_TElement(avk_TSimpleSprite(Sender).Parent).GetAbsolyteArea.X then CPX := CPX + 1;
    if (CPX + W) > (avk_TElement(avk_TSimpleSprite(Sender).Parent).GetAbsolyteArea.X + avk_TElement(avk_TSimpleSprite(Sender).Parent).AreaElement.W) then CPX := CPX - 1;
    if (CPY + H) > (avk_TElement(avk_TSimpleSprite(Sender).Parent).GetAbsolyteArea.Y + avk_TElement(avk_TSimpleSprite(Sender).Parent).AreaElement.H) then CPY := CPY - 1;
    SetPoint(CPX, CPY);
    if CountSubPoints > 0 then //вращающийся вокруг эмиттер
      if SubPoints[0].TypeOfTile = TILE_EMITTER then begin
        SubPoints[0].Angle := SubPoints[0].Angle - 0.5;
        if SubPoints[0].Angle < 0 then SubPoints[0].Angle := 360;
        if CountSubPoints = 2 then begin
          SubPoints[1].Angle := SubPoints[1].Angle + 1;
          if SubPoints[1].Angle > 360 then SubPoints[1].Angle := 0;
        end;
      end;
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
  NumSpr, CKL0: Integer;
  TmpNameSpr: UTF8String;
  TmpTileMap: avk_TTileMap;
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
  TmpMap.CountStage := 3;
  TmpMap.SetMapSize(100, 90);
  TmpMap.SetWievPanelAndTileSize(1024, 768, 64, 64);
  for CKL0 := 0 to TmpMap.CountStage - 1 do begin
    TmpTileMap := TmpMap.Stage[CKL0];
    for CKL1 := 0 to TmpTileMap.CountTileW - 1 do begin
      for CKL2 := 0 to TmpTileMap.CountTileH - 1 do begin
        NumSpr := Random(13);
        SprTile := avk_TSimpleTile.Create;
        if NumSpr = 7 then begin
          SprTile.Texture := MineForm.TexManager.TexName['пол7'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.X := 0;
          SprTile.Y := 0;
          SprTile.W := 64;
          SprTile.H := 64;
          SprTile.StopCadre := 37;
          SprTile.RateCadre := 10;
        end else if NumSpr >= 12 then begin
          SprTile.Texture := MineForm.TexManager.TexName['край со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.X := 0;
          SprTile.Y := 0;
          SprTile.W := 64;
          SprTile.H := 64;
          SprTile.StopCadre := 12;
          SprTile.RateCadre := trunc(20 / TmpMap.CountStage);
          SprTile.TexAngle := Random(3) * 90;
        end else begin
          TmpNameSpr := 'пол' + avk_IntToStr(NumSpr);
          SprTile.Texture := MineForm.TexManager.TexName[TmpNameSpr];
        end;
        SprTile.W := TmpMap.TileSizeW;
        SprTile.H := TmpMap.TileSizeH;
        if NumSpr = 0 then begin
          if (Random(2) = 1) and (CKL0 = 0) then begin
            TmpTileMap.LOT[CKL1, CKL2] := nil;
            SprTile.Destroy;
          end else
            TmpTileMap.LOT[CKL1,CKL2] := SprTile;
        end else
          TmpTileMap.LOT[CKL1,CKL2] := SprTile;
      end;
    end;
  end;
  TmpMap.SetStageAndPercentDistance(0, 5);
  TmpMap.SetAreaElement(0,0,1000,680);
  TmpMap.GetMouse := false; //Не должен брать мыш
  TmpMap.Layer := 1;
  TmpMap.OnBeforeProc := DoPnlSprMove;

  {$IfDef Debug}
  //TmpMap.LoyerHideBefore := 0;
  TmpBtn := avk_TSimpleButton.Create(TmpMap,'Производительность');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(1,649,100,30);
  TmpBtn.LabelCaption.Caption := '000000';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  {$EndIf}

end;

procedure TMineForm.DoPnlSprMove(Sender: TObject);
var
  tempEl: avk_TSimpleMap;
  SpeedLost, SpeedLostX, SpeedLostY: Single;
begin
  if Sender.ClassName <> 'avk_TSimpleMap' then Exit;
  tempEl := avk_TSimpleMap(Sender);
  SpeedLost := 1;
  with tempEl do begin
    SpeedLostX := 0;
    SpeedLostY := 0;
    {$IfDef Debug}
    avk_TSimpleButton(GetFraimById(GetIdByName('Производительность'))).LabelCaption.Caption:= 'P - D ' + avk_IntToStr(CalcPrgs - CalcDraw) + '[' + avk_IntToStr(FSFrecvency) + ']';
    {$EndIf}
    if key_Down( K_A ) or key_Down( K_LEFT ) then begin
      SpeedLostX := SpeedLostX - SpeedLost;
    end;
    if key_Down( K_D ) or key_Down( K_RIGHT ) then begin
      SpeedLostX := SpeedLostX + SpeedLost;
    end;
    if key_Down( K_W ) or key_Down( K_UP ) then begin
      SpeedLostY := SpeedLostY - SpeedLost;
    end;
    if key_Down( K_S ) or key_Down( K_DOWN ) then begin
      SpeedLostY := SpeedLostY + SpeedLost;
    end;
    if not ((SpeedLostX = 0) and (SpeedLostY = 0)) then begin
      SpeedLostX := SpeedLostX / 2;
      SpeedLostY := SpeedLostY / 2;
    end;
    if not((SpeedLostX = 0) and (SpeedLostY = 0)) then
      MoveWievPanelMap(SpeedLostX, SpeedLostY);
  end;
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
  TmpSpr: avk_TSimpleSprite;
  CKL: Integer;
begin
  if MineForm.ListName['Пример собранного спрайта'] <> nil then Exit;
  tmpTestForm := avk_TElement.Create(MineForm,'Пример собранного спрайта');
  tmpTestForm.SetAreaElement(270,66,760,580);

  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Закрыть');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(663,2,95,30);
  TmpBtn.LabelCaption.Caption := 'Закрыть панель';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoClickOnClosePnl;

  //делаем табун
  for CKL := 0 to 4 do begin
    //кулспрайтов
    TmpSpr := avk_TSimpleSprite.Create(tmpTestForm);
    case random(2) of
      0: TmpSpr.SkPnt.CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример'];
      1: TmpSpr.SkPnt.CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['паук тело'];
    end;
    //TmpSpr.SkPnt.SetTexFrameSize(69, 52);
    TmpSpr.SkPnt.SetInternalParameters(270 + Random(500), 66 + Random(500), 90, 0.4);
    TmpSpr.SkPnt.Animate := false;
    TmpSpr.OnBeforeProc := DoAPforSpr;

    //эмиттеров
    TmpSpr.SkPnt.AddSubPoint(26, 30);
    case random(3) of
      0: TmpSpr.SkPnt.SubPoints[0].Emitter := MineForm.EmitterManager.EmitterName['дымок'];
      1: TmpSpr.SkPnt.SubPoints[0].Emitter := MineForm.EmitterManager.EmitterName['горение'];
      2: TmpSpr.SkPnt.SubPoints[0].Emitter := MineForm.EmitterManager.EmitterName['сияние'];
      3: TmpSpr.SkPnt.SubPoints[0].Emitter := MineForm.EmitterManager.EmitterName['дымок'];
    end;
    TmpSpr.SkPnt.SubPoints[0].RateCadre := 4;
    if random(3)= 2 then
      TmpSpr.SkPnt.SubPoints[0].TileRotateByHost := false;
    //TmpSpr.SkPnt.SubPoints[0].Hide := true;
    //TmpSpr.SkPnt.AddSubPoint(26, -30);
    //TmpSpr.SkPnt.SubPoints[1].Emitter := MineForm.EmitterManager.EmitterName['дымок'];
    //TmpSpr.SkPnt.SubPoints[1].RateCadre := 4;
  end;

end;

procedure TMineForm.DoPanelGamer(Sender: TObject);
var
  tmpTestForm: avk_TElement;
  TmpSpr: TGamer1;
  TmpBtn: avk_TSimpleButton;
begin
  if MineForm.ListName['Пример игрок'] <> nil then Exit;
  tmpTestForm := avk_TElement.Create(MineForm,'Пример игрок');
  tmpTestForm.SetAreaElement(270,66,760,580);

  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Закрыть');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(663,2,95,30);
  TmpBtn.LabelCaption.Caption := 'Закрыть панель';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  TmpBtn.OnClick := MineForm.DoClickOnClosePnl;

  TmpSpr := TGamer1.Create(tmpTestForm);
  //ноги
  TmpSpr.Sprite[0, 0].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример ноги'];
  //тело
  TmpSpr.Sprite[1, 0].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример тело'];
  TmpSpr.Sprite[1, 1].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример тело выстрел'];
  TmpSpr.Sprite[1, 1].AddSubPoint(22, -85);

  //общие настройки
  TmpSpr.Position.X := 470;
  TmpSpr.Position.Y := 266;
  TmpSpr.PosAngle := 0;
  TmpSpr.PosScale := 0.4;
  TmpSpr.SetPosForAll;

  TmpSpr.ColVisible[0] := 0;
  TmpSpr.ColAnimate[0, 0] := false;
  TmpSpr.ColVisible[1] := 0;
  TmpSpr.ColAnimate[1, 1] := false;
  TmpSpr.MoveSpeed := 1;

  TmpSpr.BulletPause := 7;
  //{1 = 15 пуль, отключить}
  //2 = 7 //3 = 5 //4 = 4
  //5,6 = 3 //7-13 = 2 //14 = 1

  TmpSpr.FMinimalRadiusTarget := 10;
  TmpSpr.FCurrentRadiusTarget := 10;
  TmpSpr.FStepWarmRadiusTarget := 10;
  TmpSpr.FStepColdRadiusTarget := 0.2;

  TmpSpr.OnBeforeProc := DoMoveGamer;
  TmpSpr.OnRelizeShot := DoShotBullet;

  {$IfDef Debug}
  TmpBtn := avk_TSimpleButton.Create(tmpTestForm,'Кадры');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(1,549,100,30);
  TmpBtn.LabelCaption.Caption := '000000';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  {$EndIf}
end;

procedure TMineForm.DoMoveGamer(Sender: TObject);
var
  FlP: byte;
  CPY, CPX: Single;
  FTG: TGamer1;
  TmpMousePosition: zglTPoint2D;
begin
  if Sender.ClassName <> 'TGamer1' then Exit;
  FTG := TGamer1(Sender);
  TmpMousePosition.X := avk_MouseIsX;
  TmpMousePosition.Y := avk_MouseIsY;

  //собираем нажатия
  FlP := FLAG_K_NO;
  if key_Down( K_W ) or key_Down( K_UP ) then FlP := FlP or FLAG_K_UP;
  if key_Down( K_S ) or key_Down( K_DOWN ) then FlP := FlP or FLAG_K_DOWN;
  if key_Down( K_A ) or key_Down( K_LEFT ) then FlP := FlP or FLAG_K_LEFT;
  if key_Down( K_D ) or key_Down( K_RIGHT ) then FlP := FlP or FLAG_K_RIGHT;
  if avk_MouseIsClick(M_BLEFT) then FlP := FlP or FLAG_M_LEFT_Cl;
  if avk_MouseIsClick(M_BRIGHT) then FlP := FlP or FLAG_M_RIGHT_Cl;
  FTG.MoveSprite(FlP, TmpMousePosition);

  //ограничения
  CPY := FTG.Position.Y;
  CPX := FTG.Position.X;

  if CPY < avk_TElement(FTG.Parent).GetAbsolyteArea.Y then CPY := CPY + 1;
  if CPX < avk_TElement(FTG.Parent).GetAbsolyteArea.X then CPX := CPX + 1;
  if CPX > (avk_TElement(FTG.Parent).GetAbsolyteArea.X + avk_TElement(FTG.Parent).AreaElement.W) then CPX := CPX - 1;
  if CPY > (avk_TElement(FTG.Parent).GetAbsolyteArea.Y + avk_TElement(FTG.Parent).AreaElement.H) then CPY := CPY - 1;

  FTG.Position.X := CPX;
  FTG.Position.Y := CPY;

  {$IfDef Debug}
  with avk_TElement(FTG.Parent) do begin
    //avk_TSimpleButton(GetFraimById(GetIdByName('Кадры'))).LabelCaption.Caption:= UTF8String('Н: ') + avk_IntToStr(Round(FTG.Sprite[0, FTG.ColVisible[0]].NowFrame)) + UTF8String(', Т:') + avk_IntToStr(Round(FTG.Sprite[1, FTG.ColVisible[1]].NowFrame));
    avk_TSimpleButton(GetFraimById(GetIdByName('Кадры'))).LabelCaption.Caption := UTF8String('Нагрев: ') + avk_IntToStr(Round(FTG.FCurrentRadiusTarget - FTG.FMinimalRadiusTarget));
  end;
  {$EndIf}

end;

procedure TMineForm.DoShotBullet(const Sender: avk_TFraim; const AStartPoint,
  ATargetPoint: zglTPoint2D);
var
  Pnl: avk_TElement;
  AlM: Single;
  TmpSpr: avk_TSimpleSprite;
  TmpBullet: TBullet1;
  Gmr: TGamer1;
  TmWarm: zglTPoint2D;
  TmpRad: Single;
  {$IfDef Debug}
  TmpBtn: avk_TSimpleButton;
  {$EndIf}
begin
  Pnl := avk_TElement(Sender.Parent);
  Gmr := TGamer1(Sender);

  //меняем точку прицеливания на нагрев ствола
  TmWarm := VcForAngle(Random(360));
  TmpRad := Round(Random(Round(Gmr.FCurrentRadiusTarget - Gmr.FMinimalRadiusTarget)) + Gmr.FMinimalRadiusTarget);
  TmWarm.X := ATargetPoint.X + (TmWarm.X * TmpRad);
  TmWarm.Y := ATargetPoint.Y + (TmWarm.Y * TmpRad);

  Gmr.FCurrentRadiusTarget := Gmr.FStepWarmRadiusTarget + Gmr.FCurrentRadiusTarget;

  AlM := m_Angle(TmWarm.X, TmWarm.Y, AStartPoint.X, AStartPoint.Y);

  //в рамках родителя создаем дым
  TmpSpr := avk_TSimpleSprite.Create(Pnl);
  case random(2) of
    0: TmpSpr.SkPnt.Emitter := MineForm.EmitterManager.EmitterName['дымок'];
    1: TmpSpr.SkPnt.Emitter := MineForm.EmitterManager.EmitterName['дым выстрела'];
    2: TmpSpr.SkPnt.Emitter := MineForm.EmitterManager.EmitterName['дым выстрела']; //не наступает никогда
  end;
  TmpSpr.SkPnt.Angle := AlM;
  TmpSpr.SkPnt.Emitter.Params.Loop := false;
  TmpSpr.SkPnt.RateCadre := 4;
  TmpSpr.SkPnt.SetInternalParameters(AStartPoint.X, AStartPoint.Y, 0, 0.4);
  TmpSpr.DoProc(Self);
  TmpSpr.OnAfterProc := DoCloseBulletSmoke;

  {$IfDef Debug}
  with Pnl do
    if GetFraimById(GetIdByName('Углы')) = nil then begin
      TmpBtn := avk_TSimpleButton.Create(Pnl,'Углы');
      TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
      TmpBtn.SetAreaElement(103,1,100,30);
      TmpBtn.LabelCaption.Caption := avk_IntToStr(Round(TmpSpr.SkPnt.Angle)) +
        UTF8String('[') + avk_IntToStr(Round(TmWarm.X)) + UTF8String(':') +
        avk_IntToStr(Round(TmWarm.Y)) + UTF8String(']');
      TmpBtn.LabelCaption.FontColor := $8B0000;
    end else begin
      TmpBtn := avk_TSimpleButton(GetFraimById(GetIdByName('Углы')));
      TmpBtn.LabelCaption.Caption := avk_IntToStr(Round(TmpSpr.SkPnt.Angle)) +
        UTF8String('[') + avk_IntToStr(Round(TmWarm.X)) + UTF8String(':') +
        avk_IntToStr(Round(TmWarm.Y)) + UTF8String(']');
    end;
  {$EndIf}

  TmpBullet := TBullet1.Create(Pnl);
  TmpBullet.Sprite[0, 0].Texture := MineForm.TexManager.TexName['пулька'];
  TmpBullet.Sprite[0, 0].SetInternalParameters(0, 0, 0, 1, -3, -7, 6, 14);
  TmpBullet.FPower := 100;
  TmpBullet.FLosePowerInStep := 0.2;
  TmpBullet.FSpeedFly := 2;
  TmpBullet.StartMoveBullet(AStartPoint, TmWarm);
end;

procedure TMineForm.DoCloseBulletSmoke(Sender: TObject);
var
  Blt: avk_TSimpleSprite;
begin
  Blt := avk_TSimpleSprite(Sender);
  if Blt.SkPnt.Emitter = nil then Blt.DeleteMe := true;
end;



