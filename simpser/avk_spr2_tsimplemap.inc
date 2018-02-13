
{ avk_TSimpleMap }

procedure avk_TSimpleMap.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  //WievPanel.X := InX;
  //WievPanel.Y := InY;
  //WievPanel.W := InW;
  //WievPanel.H := InH;
  //StrX := trunc(WievPanel.X) div FTileSizeW;
  //StpX := trunc(WievPanel.W) div FTileSizeW + 1;
  //StrY := trunc(WievPanel.Y) div FTileSizeH;
  //StpY := trunc(WievPanel.H) div FTileSizeH + 1;
  //rtSCR1 := rtarget_Add( tex_CreateZero( Trunc(InW), Trunc(InH) ), RT_CLEAR_COLOR );
  //rtSCR2 := rtarget_Add( tex_CreateZero( Trunc(InW), Trunc(InH) ), RT_CLEAR_COLOR );
  //EmpityTex := tex_CreateZero( Trunc(InW), Trunc(InH), $FF000000 );
  NeedToRender := true;
end;

procedure avk_TSimpleMap.DoDraw(Sender: TObject);
begin
  {$IfDef Debug}
  CalcDraw := CalcDraw + 1;
  if CalcDraw = High(CalcDraw) then CalcDraw := 0;
  {$EndIf}
  if Hide then Exit; // скрыт
  if WrtSCR = nil then Exit;//нет рабочей
  ssprite2d_Draw( WrtSCR.Surface, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, Transparence, FxFlags );
end;

procedure avk_TSimpleMap.DoProc(Sender: TObject);
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

  if HowManyConvert > 2 then begin
    {$IfDef Debug}
    CalcPrgs := CalcPrgs + 1;
    if CalcPrgs = High(CalcPrgs) then CalcPrgs := 0;
    {$EndIf}
    DoProcLot;
    HowManyConvert := 0;
  end else
    HowManyConvert := HowManyConvert + 1;

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure avk_TSimpleMap.FSetWievPanel(AValue: zglTRect);
begin
  if (FWievPanel.X = AValue.X)
    and (FWievPanel.Y = AValue.Y)
    and (FWievPanel.W = AValue.W)
    and (FWievPanel.H = AValue.H)
  then Exit;

  FWievPanel:=AValue;

  TileBildInWP.X := trunc(FWievPanel.X / TileSizeW) - 1;
  TileBildInWP.W := trunc(FWievPanel.W / TileSizeW) + 1;

  TileBildInWP.Y := trunc(FWievPanel.Y / TileSizeH) - 1;
  TileBildInWP.H := trunc(FWievPanel.H / TileSizeH) + 1;

  rtSCR1 := rtarget_Add( tex_CreateZero( Trunc(FWievPanel.W), Trunc(FWievPanel.H) ), RT_CLEAR_COLOR );
  rtSCR2 := rtarget_Add( tex_CreateZero( Trunc(FWievPanel.W), Trunc(FWievPanel.H) ), RT_CLEAR_COLOR );
  EmpityTex := tex_CreateZero( Trunc(FWievPanel.W), Trunc(FWievPanel.H), $FF000000 );
  NeedToRender := true;

end;

procedure avk_TSimpleMap.SetWievPanel(X, Y, W, H: Single);
var
  OutVal: zglTRect;
begin
  OutVal.X := X;
  OutVal.Y := Y;
  OutVal.W := W;
  OutVal.H := H;
  FSetWievPanel(OutVal);
end;

procedure avk_TSimpleMap.DoLoyer(const ALoyer: Integer; const ASVert, ASHort, AFVert, AFHort: Integer);
var
  STPntX, STPntY: Single;
  CKL1, CKL2, LocTileSizeW, LocTileSizeH: Integer;
  MakePreviosFloor: Boolean;
  DrawSpr: avk_TSimpleTile;
  LokTLB: avk_TIntegerRect;
begin
  //размеры тайла на PersemtPreviousLoyer% меньше на этаже ниже
  if ALoyer >= CountLoyer then Exit; //дырка в никуда

  LocTileSizeW := TileSizeW;
  LocTileSizeH := TileSizeH;
  if ALoyer > NowLoyer then begin
     LocTileSizeW := trunc(TileSizeW * (PersemtPreviousLoyer * 0.01));
     LocTileSizeH := trunc(TileSizeH * (PersemtPreviousLoyer * 0.01));
     NeedToRender := true;
  end;

  if NeedToRender then begin
    STPntX := (ASVert * LocTileSizeW) - WievPanel.X;
    STPntY := (ASHort * LocTileSizeH) - WievPanel.Y;
  end;

  MakePreviosFloor := false;

  for CKL1 := ASVert - 1 to ASVert + AFVert + 1 do
    for CKL2 := ASHort - 1 to ASHort + AFHort + 1 do begin
      if (CKL1 < 0) or (CKL2 < 0) or (CKL1 > (FCountTileX - 1)) or (CKL2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[NowLoyer, CKL1, CKL2];
        MakePreviosFloor := DrawSpr = nil;
        if not MakePreviosFloor then
          MakePreviosFloor := DrawSpr.HaveAlpha;
      end;

      if MakePreviosFloor then begin
        DoLoyer(NowLoyer + 1, CKL1, CKL2, 1, 1); //ToDo: большие дырки вызовут пересчеты ((((
        MakePreviosFloor := false;
      end;

      if not(DrawSpr = nil)then begin
        if NeedToRender or DrawSpr.Animate then
          DrawSpr.DoProc(Self); // анимация
        if NeedToRender then begin
          DrawSpr.X := STPntX + (CKL1 * LocTileSizeW);
          DrawSpr.Y := STPntY + (CKL2 * LocTileSizeH);
          DrawSpr.W := LocTileSizeW;
          DrawSpr.H := LocTileSizeH;
        end;
        DrawSpr.DoDraw(Self);
      end;
    end;//CKL2

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

  DoLoyer(NowLoyer, TileBildInWP.X, TileBildInWP.Y, TileBildInWP.W, TileBildInWP.H);

  rtarget_Set( nil );//закончили

  WrtSCR := TMPRt;
end;

procedure avk_TSimpleMap.SetCountTileX(AValue: integer);
begin
  if FCountTileX=AValue then Exit;
  FCountTileX:=AValue;
end;

procedure avk_TSimpleMap.SetTileSizeH(AValue: Integer);
begin
  if FTileSizeH=AValue then Exit;
  FTileSizeH:=AValue;
  SetAreaElement(AreaElement);
end;

procedure avk_TSimpleMap.SetTileSizeW(AValue: Integer);
begin
  if FTileSizeW=AValue then Exit;
  FTileSizeW:=AValue;
  SetAreaElement(AreaElement);
end;

procedure avk_TSimpleMap.SetWiewPanelX(AValue: Single);
begin
  if AValue = FWievPanel.X then Exit;
  FWievPanel.X := AValue;
  TileBildInWP.X := trunc(FWievPanel.X / TileSizeW) - 1;
end;

procedure avk_TSimpleMap.SetWiewPanelY(AValue: Single);
begin
  if AValue = FWievPanel.Y then Exit;
  FWievPanel.Y := AValue;
  TileBildInWP.Y := trunc(FWievPanel.Y / TileSizeH) - 1;
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
  with WievPanel do begin
    X := 0; Y := 0;
    W := 1024; H := 768;
  end;
  HowManyConvert := 0;
  PrevRoundPnt.X := -1;
  PrevRoundPnt.Y := -1;
  FCountTileX := 0;
  FCountTileY := 0;
  TileSizeW := 32;
  TileSizeH := 32;
  Hide := false;
  rtSCR1 := nil;
  rtSCR2 := nil;
  WrtSCR := nil;
  NeedToRender := true;
  FxFlags := FX_BLEND;
  OnDraw := DoDraw;
  OnProc := DoProc;
  Animate := true;

  PersemtPreviousLoyer := 30;
  NowLoyer := 0;
  with TileBildInWP do begin
    X := 0; Y := 0;
    W := 1; H := 1;
  end;

  {$IfDef Debug}
  CalcPrgs := 0;
  CalcDraw := 0;
  {$EndIf}
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

