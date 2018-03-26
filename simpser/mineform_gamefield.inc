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
  //тут надо загрузку файла карты

  For CKL := 0 to MineForm.Count - 1 do
    if MineForm.ListNom[CKL].Name <> 'Выход' then
      MineForm.ListNom[CKL].DeleteMe := true;
  MineForm.Wallpaper := MineForm.TexManager.TexName['Обои игрового поля'];

  //пол
  MapArray := MineForm.MapManager.MapArrayName['пример карты'];

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
begin
  DoMoveGamer(Sender); //эта часть не меняется
  //теперь считаем новый центр въюпорта

end;

