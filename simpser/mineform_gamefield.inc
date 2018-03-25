//процедуры игрового поля
procedure TMineForm.DoGameField(Sender: TObject);
var
  CKL, CKL0, CKL1, CKL2: Integer;
  TmpMap: avk_TSimpleMap;
  TmpTileMap: avk_TTileMap;
  NumSpr: Integer;
  SprTile: avk_TSimpleTile;
  TmpNameSpr: UTF8String;
begin
  //тут надо загрузку файла карты

  For CKL := 0 to MineForm.Count - 1 do
    if MineForm.ListNom[CKL].Name <> 'Выход' then
      MineForm.ListNom[CKL].DeleteMe := true;
  MineForm.Wallpaper := MineForm.TexManager.TexName['Обои игрового поля'];

  //пол
  TmpMap := avk_TSimpleMap.Create(MineForm,'Тайловая карта');
  TmpMap.CountStage := 1;
  TmpMap.SetMapSize(100, 90);
  TmpMap.SetWievPanelAndTileSize(1280, 768, 64, 64);
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
  TmpMap.SetAreaElement(0,0,MineForm.AreaElement.W, MineForm.AreaElement.H);
  TmpMap.GetMouse := false; //Не должен брать мыш
  TmpMap.Layer := 1;
  //TmpMap.OnBeforeProc := DoPnlSprMove;

end;

