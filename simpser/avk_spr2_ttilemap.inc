
{ avk_TTileMap }

procedure avk_TTileMap.Draw(AX, AY, AW, AH: Single);
var
  WHAT: String;
begin
  CalcDraw := CalcDraw + 1;
  if CalcDraw = High(CalcDraw) then CalcDraw := 0;

  if Hide then Exit; // скрыт
  if WrtSCR = nil then Exit;//нет рабочей
  WHAT := FloatToStr(AX);
  WHAT := FloatToStr(AY);
  WHAT := FloatToStr(AW);
  WHAT := FloatToStr(AH);

  ssprite2d_Draw( WrtSCR.Surface, AX, AY, AW, AH, Angle, Alpha, FxFlags );
end;

procedure avk_TTileMap.DoProc(Sender: TObject);
begin
  if FFrecvency > FSFrecvency then begin

    CalcPrgs := CalcPrgs + 1;
    if CalcPrgs = High(CalcPrgs) then CalcPrgs := 0;

    if ((CalcPrgs - CalcDraw) > 200) or ((CalcPrgs - CalcDraw) < -200) then begin
      if (CalcPrgs - CalcDraw) > 200 then
        INC(FSFrecvency, 1);
      if (CalcPrgs - CalcDraw) < -200 then
        INC(FSFrecvency, -1);
      CalcPrgs := 0;
      CalcDraw := 0;
      FSFrecvency := trunc(max(FSFrecvency, 2));
    end;

    DoProcLot;
    FFrecvency := 0;
  end else
     INC(FFrecvency, 1);
end;

procedure avk_TTileMap.DoLoyer;
var
  STPntX, STPntY: Single;
  FTD1, FTD2: Integer;
  DrawSpr: avk_TSimpleTile;
begin
  if NeedToRender then begin
    STPntX := (FTileBildInWP.X * FTileSizeW) - FWievPanel.X;
    STPntY := (FTileBildInWP.Y * FTileSizeH) - FWievPanel.Y;
  end;
  for FTD1 := FTileBildInWP.X to FTileBildInWP.X + FTileBildInWP.W do
    for FTD2 := FTileBildInWP.Y to FTileBildInWP.Y + FTileBildInWP.H do begin
      if (FTD1 < 0) or (FTD2 < 0) or (FTD1 > (FCountTileX - 1)) or (FTD2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[FTD1, FTD2];
      end;

      if not(DrawSpr = nil)then begin
        if Animate and (NeedToRender or DrawSpr.Animate) then
          DrawSpr.DoProc(Self); // анимация
        if NeedToRender then begin
          DrawSpr.X := STPntX + ((FTD1 - FTileBildInWP.X) * FTileSizeW);
          DrawSpr.Y := STPntY + ((FTD2 - FTileBildInWP.Y) * FTileSizeH);
          DrawSpr.W := FTileSizeW;
          DrawSpr.H := FTileSizeH;
        end;
        DrawSpr.DoDraw(Self);
      end;
    end;//FTD2

end;


procedure avk_TTileMap.DoProcLot;
var
  TMPRt: zglPRenderTarget;
  CKL1: Integer;
begin
  if (WrtSCR = nil) or (rtSCR1 = WrtSCR) then
    TMPRt := rtSCR2 else TMPRt := rtSCR1;

  //теперь рендерим в нее
  rtarget_Set( TMPRt );//начали

  DoLoyer;
  NeedToRender := false;

  rtarget_Set( nil );//закончили

  WrtSCR := TMPRt;
end;

procedure avk_TTileMap.SetTileSizeH(AValue: Integer);
begin
  if FTileSizeH = AValue then Exit;
  FTileSizeH := AValue;
  FSetWievPanel(FWievPanel);
end;

procedure avk_TTileMap.SetTileSizeW(AValue: Integer);
begin
  if FTileSizeW = AValue then Exit;
  FTileSizeW := AValue;
  FSetWievPanel(FWievPanel);
end;

procedure avk_TTileMap.FSetWievPanel(AValue: zglTRect; AAdditionTile: Integer = 1);
begin
  if AAdditionTile = 0 then AAdditionTile := 1;
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FTileBildInWP.X := trunc(AValue.X / TileSizeW) - AAdditionTile;
  FTileBildInWP.W := trunc(AValue.W / TileSizeW) + (AAdditionTile * 2);

  FTileBildInWP.Y := trunc(AValue.Y / TileSizeH) - AAdditionTile;
  FTileBildInWP.H := trunc(AValue.H / TileSizeH) + (AAdditionTile * 2);

  //if (not ((AValue.W = FWievPanel.W) and (AValue.H = FWievPanel.H))) or (rtSCR1 = nil) then begin
    if rtSCR1 <> nil then rtarget_Del(rtSCR1);
    rtSCR1 := rtarget_Add( tex_CreateZero( Trunc(AValue.W), Trunc(AValue.H) ), RT_CLEAR_COLOR );
    if rtSCR2 <> nil then rtarget_Del(rtSCR2);
    rtSCR2 := rtarget_Add( tex_CreateZero( Trunc(AValue.W), Trunc(AValue.H) ), RT_CLEAR_COLOR );
  //end;

  FWievPanel:=AValue;
  NeedToRender := true;

  FSFrecvency := trunc(max((FTileBildInWP.W * 0.1), (FTileBildInWP.H * 0.1)));
  FSFrecvency := trunc(max(FSFrecvency, 2));
end;

procedure avk_TTileMap.SetWievPanelSize(W, H: Single);
var
  OutVal: zglTRect;
begin
  OutVal.X := FWievPanel.X;
  OutVal.Y := FWievPanel.Y;
  OutVal.W := W;
  OutVal.H := H;
  FSetWievPanel(OutVal);
end;

procedure avk_TTileMap.SetWiewPanelX(AValue: Single);
begin
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FWievPanel.X := AValue;
  FTileBildInWP.X := trunc(FWievPanel.X / TileSizeW) - 1;
  NeedToRender := true;
end;

procedure avk_TTileMap.SetWiewPanelY(AValue: Single);
begin
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FWievPanel.Y := AValue;
  FTileBildInWP.Y := trunc(FWievPanel.Y / TileSizeH) - 1;
  NeedToRender := true;
end;

procedure avk_TTileMap.SetSizeMap(const ACountW, ACountH: Integer);
var
  CKL1, CKL2: Integer;
begin
  if (ACountW = FCountTileX) and (ACountH = FCountTileY) then Exit;

  if not((FCountTileX = 0) and (FCountTileY = 0)) then ClearMap;

  SetLength(LOT, ACountW);

  for CKL1 := 0 to ACountW - 1 do begin
    SetLength(LOT[CKL1], ACountH);
    for CKL2 := 0 to ACountH - 1 do
        LOT[CKL1, CKL2] := nil;
  end;

  FCountTileX := ACountW;
  FCountTileY := ACountH;
end;

constructor avk_TTileMap.Create;
begin
  rtSCR1 := nil;
  rtSCR2 := nil;
  FFrecvency := 0;
  FSFrecvency := 2;
  Hide := false;
  NeedToRender := true;
  FxFlags := FX_BLEND;
  Animate := true;
  Angle := 0;
  Alpha := 255;
  FTileSizeW := 32;
  FTileSizeH := 32;
  FWievPanel.X := 0;
  FWievPanel.Y := 0;
  FWievPanel.W := 0;
  FWievPanel.H := 0;
  SetSizeMap(1,1);
  SetWievPanelSize(32,32);
  CalcPrgs := 0;
  CalcDraw := 0;
end;

procedure avk_TTileMap.ClearMap;
var
  CKL1, CKL2: Integer;
begin
  for CKL1 := 0 to CountTileW - 1 do begin
    for CKL2 := 0 to CountTileH - 1 do begin
      if LOT[CKL1, CKL2] <> nil then
        LOT[CKL1, CKL2].Destroy;
    end;
    SetLength(LOT[CKL1] ,0);
  end;
  SetLength(LOT,0);
end;

destructor avk_TTileMap.Destroy;
begin
  ClearMap;
  inherited Destroy;
end;

