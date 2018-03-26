//процедуры игрового поля
procedure TMineForm.DoGameField(Sender: TObject);
var
  CKL, CKL0, CKL1, CKL2: Integer;
  TmpMap: avk_TSimpleMap;
  TmpTileMap: avk_TTileMap;
  MapArray: TMapArray;
  TmpSpr: TGamer1;
  {$IfDef Debug}
  TmpBtn: avk_TSimpleButton;
  {$endif}

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
    if MineForm.ListNom[CKL].Name <> 'Выход' then
      MineForm.ListNom[CKL].DeleteMe := true;
  MineForm.Wallpaper := MineForm.TexManager.TexName['Обои игрового поля'];

  //пол
  MapArray := MineForm.MapManager.MapArrayName['пример карты'];

  //переводим файла карты
  TmpMap := avk_TSimpleMap.Create(MineForm,'Тайловая карта');
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
  //TmpMap.OnBeforeProc := DoPnlSprMove;

  TmpSpr := TGamer1.Create(MineForm);
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

  TmpSpr.OnBeforeProc := DoMoveGamerInGameField;
  TmpSpr.OnRelizeShot := DoShotBullet;

  {$IfDef Debug}
  TmpBtn := avk_TSimpleButton.Create(MineForm,'Кадры');
  TmpBtn.TexButton := MineForm.TexManager.TexName['Кнопка'];
  TmpBtn.SetAreaElement(1,1,100,30);
  TmpBtn.LabelCaption.Caption := '000000';
  TmpBtn.LabelCaption.FontColor := $8B0000;
  {$EndIf}

end;

procedure TMineForm.DoMoveGamerInGameField(Sender: TObject);
var
  FlP: byte;
  CPY, CPX, OldC_X, OldC_Y, NMX, NMY: Single;
  FTG: TGamer1;
  TmpMousePosition: zglTPoint2D;
  TmpMap: avk_TSimpleMap;
  TmpSpr: avk_TSimpleSprite;
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

  //считаем новый центр въюпорта
  TmpMap := avk_TSimpleMap(FTG.Parent.ListName['Тайловая карта']);
  //TmpMap.MoveWievPanelMap( TmpMap.Stage[TmpMap.CurrentStage].WievPanel.X + CPX - TmpMap.Stage[TmpMap.CurrentStage].WievPanel.W / 2,
  //                         TmpMap.Stage[TmpMap.CurrentStage].WievPanel.Y + CPY - TmpMap.Stage[TmpMap.CurrentStage].WievPanel.Y / 2);
  OldC_X := TmpMap.Stage[TmpMap.CurrentStage].WievPanel.W / 2;
  OldC_Y := TmpMap.Stage[TmpMap.CurrentStage].WievPanel.H / 2;

  CPX := FTG.Position.X - ((FTG.Position.X - TmpMousePosition.X) / 2);
  CPY := FTG.Position.Y - ((FTG.Position.Y - TmpMousePosition.Y) / 2);

  NMX := CPX - OldC_X;
  NMY := CPY - OldC_Y;

  if NMX > 0 then TmpMap.MoveWievPanelMap(1, 0);
  if NMX < 0 then TmpMap.MoveWievPanelMap(-1, 0);
  if NMY > 0 then TmpMap.MoveWievPanelMap(0, 1);
  if NMY < 0 then TmpMap.MoveWievPanelMap(0, -1);


  ////в рамках родителя создаем дым
  //TmpSpr := avk_TSimpleSprite.Create(avk_TElement(FTG.Parent));
  //TmpSpr.SkPnt.Emitter := MineForm.EmitterManager.EmitterName['дымок'];
  //TmpSpr.SkPnt.Angle := 0;
  //TmpSpr.SkPnt.Emitter.Params.Loop := false;
  //TmpSpr.SkPnt.RateCadre := 15;
  //TmpSpr.SkPnt.SetInternalParameters(NMX, NMY, 0, 0.4);
  //TmpSpr.DoProc(Self);
  //TmpSpr.OnAfterProc := DoCloseBulletSmoke;


  //TmpMap.MoveWievPanelMap( TmpMap.Stage[TmpMap.CurrentStage].WievPanel.W / 2 - CPX,
  //                         TmpMap.Stage[TmpMap.CurrentStage].WievPanel.H / 2 - CPY);
end;

