
{ avk_TSimpleMap }

procedure avk_TSimpleMap.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  WievPanel.X := InX;
  WievPanel.Y := InY;
  WievPanel.W := InW;
  WievPanel.H := InH;
  StrX := trunc(WievPanel.X) div FTileSizeW;
  StpX := trunc(WievPanel.W) div FTileSizeW + 1;
  StrY := trunc(WievPanel.Y) div FTileSizeH;
  StpY := trunc(WievPanel.H) div FTileSizeH + 1;
  rtSCR1 := rtarget_Add( tex_CreateZero( Trunc(InW), Trunc(InH) ), RT_CLEAR_COLOR );
  rtSCR2 := rtarget_Add( tex_CreateZero( Trunc(InW), Trunc(InH) ), RT_CLEAR_COLOR );
  EmpityTex := tex_CreateZero( Trunc(InW), Trunc(InH), $FF000000 );
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

  {$IfDef Debug}
  CalcPrgs := CalcPrgs + 1;
  if CalcPrgs = High(CalcPrgs) then CalcPrgs := 0;
  {$EndIf}
  //if HowManyConvert > 3 then begin
    //NeedToRender := Animate;
    DoProcLot;
    HowManyConvert := 0;
  //end else
  //  HowManyConvert := HowManyConvert + 1;

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure avk_TSimpleMap.DoLoyer(const ALoyer: Integer; const ASVert, ASHort, AFVert, AFHort: Integer);
var
  STPntX, STPntY: Single;
  CKL1, CKL2, LocTileSizeW, LocTileSizeH: Integer;
  MakePreviosFloor: Boolean;
  DrawSpr: avk_TSimpleTile;
begin
  //размеры тайла на PersemtPreviousLoyer% меньше на этаже ниже
  if ALoyer >= CountLoyer then Exit; //дырка в никуда

  LocTileSizeW := TileSizeW;
  LocTileSizeH := TileSizeH;
  if ALoyer > NowLoyer then begin
     LocTileSizeW := trunc(TileSizeW * (PersemtPreviousLoyer * 0.01));
     LocTileSizeH := trunc(TileSizeH * (PersemtPreviousLoyer * 0.01));
  end;

  if NeedToRender then begin
    STPntX := (ASVert * LocTileSizeW) - WievPanel.X;
    STPntY := (ASHort * LocTileSizeH) - WievPanel.Y;
  end;

  for CKL1 := ASVert - 1 to AFVert + 1 do
    for CKL2 := ASHort - 1 to AFHort + 1 do begin
      if (CKL1 < 0) or (CKL2 < 0) or (CKL1 > (FCountTileX - 1)) or (CKL2 > (FCountTileY - 1)) then begin
        DrawSpr := nil;
      end else begin
        DrawSpr := LOT[NowLoyer, CKL1, CKL2];
        MakePreviosFloor := DrawSpr = nil;
        if not MakePreviosFloor then
          MakePreviosFloor := DrawSpr.HaveAlpha;
      end;

      if MakePreviosFloor then begin
        DoPreviousLoyer(NowLoyer + 1, CKL1, CKL2, CKL1, CKL2); //ToDo: большие дырки вызовут пересчеты ((((
      end;

      if not(DrawSpr = nil) then begin
        DrawSpr.DoProc(Self); // анимация
        if NeedToRender then begin
          DrawSpr.X := STPntX + (CKL1 * LocTileSizeW);
          DrawSpr.Y := STPntY + (CKL2 * LocTileSizeH);
        end;
        DrawSpr.DoDraw(Self);
      end;

    end;//CKL2
end;

procedure avk_TSimpleMap.DoProcLot();
var
  TMPRt: zglPRenderTarget;
begin
  if (WrtSCR = nil) or (rtSCR1 = WrtSCR) then
    TMPRt := rtSCR2 else TMPRt := rtSCR1;

  //теперь рендерим в нее
  rtarget_Set( TMPRt );//начали

  DoPreviousLoyer(NowLoyer, TileBildInWP.X, TileBildInWP.Y, TileBildInWP.W, TileBildInWP.H);

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

procedure avk_TSimpleMap.CalcAfterMove(const AWievPanelKoord: Single; const ATileSizeWH: Integer;
  var ATileBildInWPKoord, ATileBildInWP_WH: Integer);
var
  PrevValueKoord: Integer;
  CurrValueKoord: Integer;
begin
  PrevRoundPnt.X := round(WievPanel.X);
  PrevValueKoord := ATileBildInWPKoord;

  CurrValueKoord := trunc(AWievPanelKoord / ATileSizeWH); //это с какой начинать
  if CurrValueKoord = PrevValueKoord then
    Exit
  else begin
    //для скорости просто вычту
    ATileBildInWP_WH := ATileBildInWP_WH + CurrValueKoord - PrevValueKoord;
    NeedToRender := true;
  end;

end;

procedure avk_TSimpleMap.SetWiewPanelX(AValue: Single);
begin
  if AValue = WievPanel.X then Exit;
  CalcAfterMove(WievPanel.X, TileSizeW, TileBildInWP.X, TileBildInWP.W);
end;

procedure avk_TSimpleMap.SetWiewPanelY(AValue: Single);
begin
  if AValue = WievPanel.Y then Exit;
  CalcAfterMove(WievPanel.Y, TileSizeH, TileBildInWP.Y, TileBildInWP.H);
end;

procedure avk_TSimpleMap.SetSizeMap(const ACountL, ACountW, ACountH: Integer);
var
  CKL1: Integer;
  CKL2: Integer;
begin
  if (CountW = FCountTileX) and (CountH = FCountTileY) then Exit;

  if not((FCountLoyer = 0) and (FCountTileX = 0) and (FCountTileY = 0)) then ClearMap;

  for CKL0 := 0 to ACountL - 1 do
    for CKL1 := 0 to ACountW - 1 do begin
      SetLength(LOT[CKL0, CKL1], ACountH);
      for CKL2 := 0 to ACountH - 1 do
          LOT[CKL0, CKL1, CKL2] := nil;
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
    W := 0; H := 0;
  end;
  HowManyConvert := 0;
  PrevRoundPnt.X := -1;
  PrevRoundPnt.Y := -1;
  FCountTileX := 0;
  FCountTileY := 0;
  TileSizeW := 0;
  TileSizeH := 0;
  Hide := false;
  rtSCR1 := nil;
  rtSCR2 := nil;
  WrtSCR := nil;
  NeedToRender := true;
  FxFlags := FX_BLEND;
  OnDraw := DoDraw;
  OnProc := DoProc;
  Animate:=true;
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

