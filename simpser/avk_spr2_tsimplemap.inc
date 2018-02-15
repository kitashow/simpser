
{ avk_TSimpleMap }

procedure avk_TSimpleMap.DoDraw(Sender: TObject);
begin
  CalcDraw := CalcDraw + 1;
  if CalcDraw = High(CalcDraw) then CalcDraw := 0;

  if Hide then Exit; // скрыт
  if WrtSCR = nil then Exit;//нет рабочей
  ssprite2d_Draw( WrtSCR.Surface, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, Transparence, FxFlags );
end;

procedure avk_TSimpleMap.DoProc(Sender: TObject);
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

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

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure avk_TSimpleMap.DoPreviousLoyer(ALoyer, ASVert, ASHort, AFVert, AFHort: Integer);
var
  STPntX, STPntY: Single;
  Coef: Single;
  FTD1, FTD2: Integer;
  LocTileSizeW, LocTileSizeH: Integer;
  MakePreviosFloor, PrevNTR: Boolean;
  DrawSpr: avk_TSimpleTile;
begin
  //размеры тайла на PersemtPreviousLoyer% меньше на этаже ниже
  if ALoyer >= CountLoyer then Exit; //дырка в никуда

  LocTileSizeW := TileSizeW;
  LocTileSizeH := TileSizeH;
  if ALoyer > NowLoyer then begin
    Coef := ((PersemtPreviousLoyer * (ALoyer - NowLoyer)) * 0.01);
    LocTileSizeW := TileSizeW - trunc(TileSizeW * Coef);
    LocTileSizeH := TileSizeH - trunc(TileSizeH * Coef);
    NeedToRender := true;
  end;

  {$IfNDef Debug}
  if NeedToRender then begin
  {$EndIf}
    //STPntX := (ASVert * LocTileSizeW) - WievPanel.X;
    //STPntY := (ASHort * LocTileSizeH) - WievPanel.Y;
    STPntX := (ASVert * TileSizeW) - WievPanel.X;
    STPntY := (ASHort * TileSizeH) - WievPanel.Y;
  {$IfNDef Debug}
  end;
  {$EndIf}

  MakePreviosFloor := false;

  for FTD1 := ASVert - 1 to ASVert + AFVert + 1 do
    for FTD2 := ASHort - 1 to ASHort + AFHort + 1 do begin
      if (FTD1 < 0) or (FTD2 < 0) or (FTD1 > (FCountTileX - 1)) or (FTD2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[ALoyer, FTD1, FTD2];
        MakePreviosFloor := DrawSpr = nil;
        if not MakePreviosFloor then
          MakePreviosFloor := DrawSpr.HaveAlpha;
      end;

      if MakePreviosFloor then begin
        PrevNTR := NeedToRender;
        DoLoyer(ALoyer + 1, FTD1, FTD2, 1, 1); //ToDo: большие дырки вызовут пересчеты ((((
        MakePreviosFloor := false;
        NeedToRender := PrevNTR;
      end;
    end;


  for FTD1 := ASVert - 1 to ASVert + AFVert + 1 do
    for FTD2 := ASHort - 1 to ASHort + AFHort + 1 do begin
      if (FTD1 < 0) or (FTD2 < 0) or (FTD1 > (FCountTileX - 1)) or (FTD2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[ALoyer, FTD1, FTD2];
      end;

      if not(DrawSpr = nil)then begin
        if NeedToRender or DrawSpr.Animate then
          DrawSpr.DoProc(Self); // анимация
        if NeedToRender then begin
          DrawSpr.X := STPntX + ((FTD1 - ASVert) * LocTileSizeW);
          DrawSpr.Y := STPntY + ((FTD2 - ASHort) * LocTileSizeH);
          DrawSpr.W := LocTileSizeW;
          DrawSpr.H := LocTileSizeH;
        end;
        {$IfDef Debug}
        if ALoyer > LoyerHideBefore then
          DrawSpr.DoDraw(Self);
        {$Else}
        DrawSpr.DoDraw(Self);
        {$EndIf}
      end;

      {$IfDef Debug}
      if (DrawSpr = nil) then begin
        pr2d_Rect( STPntX + ((FTD1 - ASVert) * LocTileSizeW) , STPntY + ((FTD2 - ASHort) * LocTileSizeH) , LocTileSizeW, LocTileSizeH , $DC143C, Transparence, FxFlags);
      end;
      {$EndIf}

    end;//FTD2

  NeedToRender := false;

end;


procedure avk_TSimpleMap.DoLoyer(ALoyer, ASVert, ASHort, AFVert, AFHort: Integer);
var
  STPntX, STPntY: Single;
  Coef: Single;
  FTD1, FTD2: Integer;
  //LocTileSizeW, LocTileSizeH: Integer;
  MakePreviosFloor, PrevNTR: Boolean;
  DrawSpr: avk_TSimpleTile;
begin
  if NeedToRender then begin
    STPntX := (ASVert * TileSizeW) - WievPanel.X;
    STPntY := (ASHort * TileSizeH) - WievPanel.Y;
  end;

  for FTD1 := ASVert - 1 to ASVert + AFVert + 1 do
    for FTD2 := ASHort - 1 to ASHort + AFHort + 1 do begin
      if (FTD1 < 0) or (FTD2 < 0) or (FTD1 > (FCountTileX - 1)) or (FTD2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[ALoyer, FTD1, FTD2];
      end;

      if not(DrawSpr = nil)then begin
        if NeedToRender or DrawSpr.Animate then
          DrawSpr.DoProc(Self); // анимация
        if NeedToRender then begin
          DrawSpr.X := STPntX + ((FTD1 - ASVert) * TileSizeW);
          DrawSpr.Y := STPntY + ((FTD2 - ASHort) * TileSizeH);
          DrawSpr.W := TileSizeW;
          DrawSpr.H := TileSizeH;
        end;
        {$IfDef Debug}
        if ALoyer > LoyerHideBefore then
          DrawSpr.DoDraw(Self);
        {$Else}
        DrawSpr.DoDraw(Self);
        {$EndIf}
      end;

      {$IfDef Debug}
      if (DrawSpr = nil) then begin
        pr2d_Rect( STPntX + ((FTD1 - ASVert) * TileSizeW) , STPntY + ((FTD2 - ASHort) * TileSizeH) , TileSizeW, TileSizeH , $DC143C, Transparence, FxFlags);
      end;
      {$EndIf}

    end;//FTD2

  NeedToRender := false;

end;

procedure avk_TSimpleMap.DoProcLot();
var
  TMPRt: zglPRenderTarget;
begin
  if (WrtSCR = nil) or (rtSCR1 = WrtSCR) then
    TMPRt := rtSCR2 else TMPRt := rtSCR1;

  //теперь рендерим в нее
  rtarget_Set( TMPRt );//начали

  DoLoyer(NowLoyer, FTileBildInWP.X, FTileBildInWP.Y, FTileBildInWP.W, FTileBildInWP.H);

  rtarget_Set( nil );//закончили

  WrtSCR := TMPRt;
end;

procedure avk_TSimpleMap.SetTileSizeH(AValue: Integer);
begin
  if FTileSizeH = AValue then Exit;
  FTileSizeH := AValue;
  FSetWievPanel(FWievPanel);
end;

procedure avk_TSimpleMap.SetTileSizeW(AValue: Integer);
begin
  if FTileSizeW = AValue then Exit;
  FTileSizeW := AValue;
  FSetWievPanel(FWievPanel);
end;

procedure avk_TSimpleMap.FSetWievPanel(AValue: zglTRect);
begin
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FWievPanel:=AValue;

  FTileBildInWP.X := trunc(FWievPanel.X / TileSizeW) - 1;
  FTileBildInWP.W := trunc(FWievPanel.W / TileSizeW) + 1;

  FTileBildInWP.Y := trunc(FWievPanel.Y / TileSizeH) - 1;
  FTileBildInWP.H := trunc(FWievPanel.H / TileSizeH) + 1;

  if rtSCR1 <> nil then rtarget_Del(rtSCR1);
  rtSCR1 := rtarget_Add( tex_CreateZero( Trunc(FWievPanel.W), Trunc(FWievPanel.H) ), RT_CLEAR_COLOR );
  if rtSCR2 <> nil then rtarget_Del(rtSCR2);
  rtSCR2 := rtarget_Add( tex_CreateZero( Trunc(FWievPanel.W), Trunc(FWievPanel.H) ), RT_CLEAR_COLOR );
  NeedToRender := true;

  FSFrecvency := trunc(max((FTileBildInWP.W * 0.1), (FTileBildInWP.H * 0.1)));
  FSFrecvency := trunc(max(FSFrecvency, 2));
end;

procedure avk_TSimpleMap.SetWievPanelSize(W, H: Single);
var
  OutVal: zglTRect;
begin
  OutVal.X := FWievPanel.X;
  OutVal.Y := FWievPanel.Y;
  OutVal.W := W;
  OutVal.H := H;
  FSetWievPanel(OutVal);
end;

procedure avk_TSimpleMap.SetWiewPanelX(AValue: Single);
begin
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FWievPanel.X := AValue;
  FTileBildInWP.X := trunc(FWievPanel.X / TileSizeW) - 1;
  NeedToRender := true;
end;

procedure avk_TSimpleMap.SetWiewPanelY(AValue: Single);
begin
  //Пересчет при любом вызове т.к. менятся может и размер тайла
  FWievPanel.Y := AValue;
  FTileBildInWP.Y := trunc(FWievPanel.Y / TileSizeH) - 1;
  NeedToRender := true;
end;

procedure avk_TSimpleMap.SetSizeMap(const ACountL, ACountW, ACountH: Integer);
var
  CKL1, CKL2, CKL3: Integer;
begin
  if (ACountW = FCountTileX) and (ACountH = FCountTileY) then Exit;

  if not((FCountLoyer = 0) and (FCountTileX = 0) and (FCountTileY = 0)) then ClearMap;

  SetLength(LOT, ACountL);
  for CKL1 := 0 to ACountL - 1 do begin
    SetLength(LOT[CKL1], ACountW);
    for CKL2 := 0 to ACountW - 1 do begin
      SetLength(LOT[CKL1, CKL2], ACountH);
      for CKL3 := 0 to ACountH - 1 do
          LOT[CKL1, CKL2, CKL3] := nil;
    end;
  end;

  FCountLoyer := ACountL;
  FCountTileX := ACountW;
  FCountTileY := ACountH;
end;

constructor avk_TSimpleMap.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  rtSCR1 := nil;
  rtSCR2 := nil;

  FFrecvency := 0;
  FSFrecvency := 2;
  Hide := false;
  NeedToRender := true;
  FxFlags := FX_BLEND;
  OnDraw := DoDraw;
  OnProc := DoProc;
  Animate := true;

  FTileSizeW := 32;
  FTileSizeH := 32;

  FWievPanel.X := 0;
  FWievPanel.Y := 0;
  FWievPanel.W := 0;
  FWievPanel.H := 0;

  SetSizeMap(1,1,1);
  SetWievPanelSize(32,32);

  PersemtPreviousLoyer := 30;
  NowLoyer := 0;

  {$IfDef Debug}
  LoyerHideBefore := -1;
  {$EndIf}
  CalcPrgs := 0;
  CalcDraw := 0;
end;

procedure avk_TSimpleMap.ClearMap;
var
  CKL0, CKL1, CKL2: Integer;
begin
  for CKL0 := 0 to CountLoyer - 1 do begin
    for CKL1 := 0 to CountTileW - 1 do begin
      for CKL2 := 0 to CountTileH - 1 do begin
        if LOT[CKL0, CKL1, CKL2] <> nil then
          LOT[CKL0, CKL1, CKL2].Destroy;
      end;
      SetLength(LOT[CKL0, CKL1] ,0);
    end;
    SetLength(LOT[CKL0] ,0);
  end;
  SetLength(LOT,0);
end;

destructor avk_TSimpleMap.Destroy;
begin
  ClearMap;
  inherited Destroy;
end;

