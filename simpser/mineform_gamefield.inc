//процедуры игрового поля
procedure TMineForm.DoGameField(Sender: TObject);
var
  {$IfDef Debug}
  TmpBtn: avk_TSimpleButton;
  {$endif}
  CKL, CKL0, CKL1, CKL2: Integer;
  TmpMap: avk_TSimpleMap;
  TmpTileMap: avk_TTileMap;
  MapArray: TMapArray;
  TmpSpr: TGamer1;
  Supervisor: avk_Checker;
  TmpSprTr: avk_TSimpleSprite;
  WHAT: Boolean;

    function GetTile(NumTile: Word):avk_TSimpleTile;
    var
      SprTile: avk_TSimpleTile;
    begin

      SprTile := avk_TSimpleTile.Create;
      SprTile.SetTexFrameSize(64, 64);
      SprTile.X := 0;
      SprTile.Y := 0;
      SprTile.W := TmpMap.TileSizeW;
      SprTile.H := TmpMap.TileSizeH;

      case NumTile of
        12: begin
          SprTile.Texture := MineForm.TexManager.TexName['угол со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 10;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 0;
        end;
        1: begin
          SprTile.Texture := MineForm.TexManager.TexName['угол со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 10;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 90;
        end;
        2: begin
          SprTile.Texture := MineForm.TexManager.TexName['угол со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 10;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 180;
        end;
        3: begin
          SprTile.Texture := MineForm.TexManager.TexName['угол со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 10;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := -90;
        end;
        4: begin
          SprTile.Texture := MineForm.TexManager.TexName['край со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 12;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 0;
        end;
        5: begin
          SprTile.Texture := MineForm.TexManager.TexName['край со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 12;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 90;
        end;
        6: begin
          SprTile.Texture := MineForm.TexManager.TexName['край со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 12;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := 180;
        end;
        7: begin
          SprTile.Texture := MineForm.TexManager.TexName['край со стрелкой'];
          SprTile.SetTexFrameSize(64, 64);
          SprTile.StopCadre := 12;
          SprTile.RateCadre := 12;
          SprTile.TexAngle := -90;
        end;
        8: begin
          SprTile.Texture := MineForm.TexManager.TexName['пол1'];
        end;
        9: begin
          SprTile.Texture := MineForm.TexManager.TexName['пол2'];
        end;
        10: begin
          SprTile.Texture := MineForm.TexManager.TexName['пол3'];
        end;
        11: begin
          SprTile.Texture := MineForm.TexManager.TexName['пол4'];
        end;
      else
          SprTile.Destroy;
          SprTile := nil;
      end;
      Result := SprTile;
    end;

begin
  For CKL := 0 to MineForm.Count - 1 do
    if Assigned(MineForm.ListNom[CKL]) then
      if MineForm.ListNom[CKL].Name <> UTF8String('Выход') then
        if MineForm.ListNom[CKL].Name <> UTF8String('Проверяющий') then
          MineForm.ListNom[CKL].DeleteMe := true;

  MineForm.Wallpaper := MineForm.TexManager.TexName['Обои игрового поля'];

  if MineForm.ListName['Проверяющий'] = nil then begin
    Supervisor := avk_Checker.Create(MineForm);
    Supervisor.Name := UTF8String('Проверяющий');
    Supervisor.OnBeforeCheck := DoSupervision;
  end else
    Supervisor := avk_Checker(MineForm.ListName['Проверяющий']);

  //пол
  MapArray := MineForm.MapManager.MapArrayName['пример карты'];

  //переводим файла карты
  TmpMap := avk_TSimpleMap.Create(MineForm,'Тайловая карта');
  TmpMap.Name := UTF8String('Тайловая карта');
  TmpMap.CountStage := 1;
  TmpMap.SetMapSize(Length(MapArray[0]), Length(MapArray));
  TmpMap.SetWievPanelAndTileSize(1280, 768, 64, 64);
  for CKL0 := 0 to TmpMap.CountStage - 1 do begin
    TmpTileMap := TmpMap.Stage[CKL0];
    for CKL1 := 0 to TmpTileMap.CountTileW - 1 do begin
      for CKL2 := 0 to TmpTileMap.CountTileH - 1 do begin
        TmpTileMap.LOT[CKL1,CKL2] :=  GetTile(MapArray[CKL2, CKL1]);
      end;
    end;
  end;
  TmpMap.SetStageAndPercentDistance(0, 5);
  TmpMap.SetAreaElement(0,0,MineForm.AreaElement.W, MineForm.AreaElement.H);
  TmpMap.GetMouse := false; //Не должен брать мыш
  TmpMap.Layer := 1;

  //Игрок
  TmpSpr := TGamer1.Create(MineForm);
  TmpSpr.Name := UTF8String('Ид игрока');
  //ноги
  TmpSpr.Sprite[0, 0].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример ноги'];
  //тело
  TmpSpr.Sprite[1, 0].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример тело'];
  TmpSpr.Sprite[1, 1].CoolSprite := MineForm.CoolSpriteManager.CoolSpriteName['пример тело выстрел'];
  TmpSpr.Sprite[1, 1].AddSubPoint(19, -75);

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

  TmpSpr.OnBeforeProc := DoMoveGamerInGameField;
  TmpSpr.OnRelizeShot := DoShotBullet;

  {$IfDef Debug}
  TmpBtn := avk_TSimpleButton.Create(MineForm,'Кадры');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(1,1,100,30);
  TmpBtn.LabelCaption.Caption := '000000';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  {$EndIf}

  //мишеньки
  for CKL := 0 to 25 do begin
    TmpSprTr := avk_TSimpleSprite.Create(MineForm);
    TmpSprTr.Name := UTF8String('Мишень'+u_IntToStr(CKL));
    TmpSprTr.SkPnt.Texture := MineForm.TexManager.TexName['Ящик мишень'];
    TmpSprTr.SkPnt.SetInternalParameters(0, 0, 0, 1, -32, -32, 64, 64);
    TmpSprTr.SkPnt.SetTexFrameSize(128, 128);
    TmpSprTr.SkPnt.StopCadre := 3;
    TmpSprTr.SkPnt.RateCadre := 15;
    TmpSprTr.SkPnt.Animate := false;
    TmpSprTr.SkPnt.CreateCollizionZone(30);

    TmpSprTr.MapPosition.X := 32 + Random(2500);
    TmpSprTr.MapPosition.Y := 32 + Random(1400);
    //TmpSprTr.SkPnt.CollizionZone.CalkBuffer;
    TmpSprTr.SkPnt.CollizionZone.FBufferCircle.cX := TmpSprTr.MapPosition.X;
    TmpSprTr.SkPnt.CollizionZone.FBufferCircle.cX := TmpSprTr.MapPosition.Y;

    WHAT := false;
    if Supervisor.ColZoneHaveCollision(TmpSprTr.SkPnt.CollizionZone) then
      WHAT := true;


    while SpriteInMapFall(TmpMap, avk_TSprite(TmpSprTr)) or
          Supervisor.ColZoneHaveCollision(TmpSprTr.SkPnt.CollizionZone) do begin
      TmpSprTr.MapPosition.X := 32 + Random(2500);
      TmpSprTr.MapPosition.Y := 32 + Random(1400);
      TmpSprTr.SkPnt.CollizionZone.CalkBuffer;
    end;

    TmpSprTr.PosAngle := Random(180);
    TmpSprTr.PosHide := true;
    TmpSprTr.Layer := 3;
    Supervisor.DoProc(nil);
  end;

end;

procedure TMineForm.MoveAllObjectInGameField(AX, AY: Single);
var
  CKL: Integer;
  TFR: avk_TFraim;
begin
  for CKL := 0 to MineForm.Count - 1 do begin
    TFR := MineForm.ListNom[CKL];
    if not Assigned(TFR) then Continue;
    if TFR.Name = UTF8String('Тайловая карта') then Continue;
    if TFR.Name = UTF8String('Ид игрока') then Continue;
    if TFR is avk_TSprite then begin
      avk_TSprite(TFR).Position.X := trunc(avk_TSprite(TFR).Position.X + AX);
      avk_TSprite(TFR).Position.Y := trunc(avk_TSprite(TFR).Position.Y + AY);
      avk_TSprite(TFR).SetPosForAll;
    end;
  end;
end;

procedure TMineForm.MoveFloorInGameField(FTG: TGamer1; CPY, CPX, TMS: Single);
var
  TmpStageSize: zglTPoint2D;
  TmpWPort, TmpBorder: zglTRect;
  TmpMap: avk_TSimpleMap;
begin
  TmpBorder := avk_TElement(FTG.Parent).GetAbsolyteArea;
  TmpBorder.W := TmpBorder.X + TmpBorder.W;
  TmpBorder.H := TmpBorder.Y + TmpBorder.H;

  //считаем новый центр въюпорта
  TmpMap := avk_TSimpleMap(FTG.Parent.ListName['Тайловая карта']);

  TmpWPort := TmpMap.Stage[TmpMap.CurrentStage].WievPanel;
  TmpStageSize.X := (TmpMap.Stage[TmpMap.CurrentStage].CountTileW * TmpMap.Stage[TmpMap.CurrentStage].TileSizeW);
  TmpStageSize.Y := (TmpMap.Stage[TmpMap.CurrentStage].CountTileH * TmpMap.Stage[TmpMap.CurrentStage].TileSizeH);

  if CPX > (TmpWPort.W / 2) then //wp x +
    if (TmpWPort.X + TmpWPort.W) <  TmpStageSize.X then
      if FTG.Position.X > TmpBorder.X then
        begin
          TmpMap.MoveWievPanelMap(TMS, 0);
          MoveAllObjectInGameField(-TMS, 0);
          FTG.Position.X := FTG.Position.X - TMS;
        end;

  if CPX < (TmpWPort.W / 2) then //wp x -
    if TmpWPort.X > 0 then
      if FTG.Position.X < TmpBorder.W then
        begin
          TmpMap.MoveWievPanelMap( -TMS, 0);
          MoveAllObjectInGameField( TMS, 0);
          FTG.Position.X := FTG.Position.X + TMS;
        end;

  if CPY > (TmpWPort.H / 2) then //wp y +
    if (TmpWPort.Y + TmpWPort.H) <  TmpStageSize.Y then
      if FTG.Position.Y > TmpBorder.Y then
        begin
          TmpMap.MoveWievPanelMap(0, TMS);
          MoveAllObjectInGameField(0, -TMS);
          FTG.Position.Y := FTG.Position.Y - TMS;
        end;

  if CPY < (TmpWPort.H / 2) then //wp y -
    if TmpWPort.Y > 0 then
      if FTG.Position.Y < TmpBorder.H then
        begin
          TmpMap.MoveWievPanelMap( 0, -TMS);
          MoveAllObjectInGameField(0, TMS);
          FTG.Position.Y := FTG.Position.Y + TMS;
        end;
end;

procedure TMineForm.DoMoveGamerInGameField(Sender: TObject);
var
  FlP: byte;
  CPY, CPX, TMS: Single;
  FTG: TGamer1;
  TmpMousePosition: zglTPoint2D;
  TmpBorder: zglTRect;
  TmpUD: avk_TElement;
begin
  if Sender.ClassName <> 'TGamer1' then Exit;
  FTG := TGamer1(Sender);

  //Проверка на падения в дырки
  if SpriteFall(avk_TSimpleMap(FTG.Parent.ListName['Тайловая карта']), FTG, true) then begin
      {$IfDef Debug}
      with avk_TElement(FTG.Parent) do begin
        avk_TSimpleButton(GetFraimById(GetIdByName('Кадры'))).LabelCaption.Caption := UTF8String('Падение: ') + u_FloatToStr(FTG.PosScale);
      end;
      {$EndIf}

      if MineForm.GetIdByName('Твоя умирать') = -1 then begin
        TmpUD := avk_TElement.Create(MineForm, 'Твоя умирать');
        TmpUD.Wallpaper := MineForm.TexManager.TexName['Твоя умирать'];
        TmpUD.SetAreaElement(0, 0, MineForm.AreaElement.W, MineForm.AreaElement.H);
        TmpUD.Layer := MineForm.ListName['Выход'].Layer - 1;
        TmpUD.Transparence := 0;
      end;
      TmpUD := avk_TElement(MineForm.ListName['Твоя умирать']);
      if TmpUD.Transparence < 254 then
        TmpUD.Transparence := TmpUD.Transparence + 1;

      FTG.PosScale := FTG.PosScale - 0.001;
      FTG.SetPosForAll;
      if FTG.PosScale <= 0 then
        FTG.DeleteMe := true;
      Exit;
    end;

  //Прямое управление
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

  TmpBorder := avk_TElement(FTG.Parent).GetAbsolyteArea;
  TmpBorder.W := TmpBorder.X + TmpBorder.W;
  TmpBorder.H := TmpBorder.Y + TmpBorder.H;

  if CPY < TmpBorder.Y then CPY := CPY + 1;
  if CPX < TmpBorder.X then CPX := CPX + 1;
  if CPX > TmpBorder.W then CPX := CPX - 1;
  if CPY > TmpBorder.H then CPY := CPY - 1;

  FTG.Position.X := CPX;
  FTG.Position.Y := CPY;


  {$IfDef Debug}
  with avk_TElement(FTG.Parent) do begin
    avk_TSimpleButton(GetFraimById(GetIdByName('Кадры'))).LabelCaption.Caption := UTF8String('Нагрев: ') + avk_IntToStr(Round(FTG.FCurrentRadiusTarget - FTG.FMinimalRadiusTarget));
  end;
  {$EndIf}

  //Перемещение пола
  if FLP = FLAG_K_NO then
    TMS := 0.5
  else
    TMS := FTG.MoveSpeed + 0.5;

  CPX := FTG.Position.X - ((FTG.Position.X - TmpMousePosition.X) / 2);
  CPY := FTG.Position.Y - ((FTG.Position.Y - TmpMousePosition.Y) / 2);

  MoveFloorInGameField(FTG, CPY, CPX, TMS);

end;

procedure TMineForm.DoSupervision(Sender: TObject);
var
  CKL: Integer;
  TmpWPort: zglTRect;
  MPS: zglTPoint2D;
  TMap: avk_TSimpleMap;
  TCS: avk_TTileMap;
begin
  if MineForm.ListName['Ид игрока'] = nil then begin
    //нужно пересоздать персонажа
    if (MineForm.GetIdByName('Ид игрока') = -1) and (MineForm.GetIdByName('Тайловая карта') = -1) then
      MineForm.DoGameField(Sender)
    else
      For CKL := 0 to MineForm.Count - 1 do
        if Assigned(MineForm.ListNom[CKL]) then
          if MineForm.ListNom[CKL].Name <> UTF8String('Выход') then
            if MineForm.ListNom[CKL].Name <> UTF8String('Проверяющий') then
              MineForm.ListNom[CKL].DeleteMe := true;

    Exit; //Дальше на тесте не надо
  end;

  TMap := avk_TSimpleMap(MineForm.ListName['Тайловая карта']);
  TCS := TMap.Stage[TMap.CurrentStage];
  TmpWPort := TMap.Stage[TMap.CurrentStage].WievPanel;
  For CKL := 0 to MineForm.Count - 1 do
    if Assigned(MineForm.ListNom[CKL]) then
      if MineForm.ListNom[CKL].Name <> UTF8String('Ид игрока') then
        if MineForm.ListNom[CKL] is avk_TSprite then
          with avk_TSprite(MineForm.ListNom[CKL]) do begin
            MPS := MapPosition;
            PosHide := false;
            PosHide := (MPS.X < (TmpWPort.X - TCS.TileSizeW)) or
              (MPS.X > (TmpWPort.X + TmpWPort.W + TCS.TileSizeW)) or
              (MPS.Y < (TmpWPort.Y - TCS.TileSizeH)) or
              (MPS.Y > (TmpWPort.Y + TmpWPort.H + TCS.TileSizeH));

            Position.X := MPS.X - TmpWPort.X;
            Position.Y := MPS.Y - TmpWPort.Y;
            SetPosForAll;
         end;

end;
