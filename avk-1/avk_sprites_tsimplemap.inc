
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
  NeedToRender := Animate;
  DoProcLot(true);
  if Hide then Exit; // скрыт
  if WrtSCR = nil then Exit;//нет рабочей
  ssprite2d_Draw( WrtSCR.Surface, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, Transparence, FxFlags );
end;

procedure avk_TSimpleMap.SetSizeMap(const CountW, CountH: Integer);
var
  TmpX, TmpY: Integer;
  CKL1: Integer;
  CKL2: Integer;
begin
  if (CountW = FCountTileX) and (CountH = FCountTileY) then Exit;
  TmpX := trunc(max(CountW,FCountTileX)) - 1;
  TmpY := trunc(max(CountH,FCountTileY)) - 1;
  if CountW > FCountTileX then SetLength(LOT,CountW);//Карта меньше, надо заполнять
  for CKL1 := 0 to TmpX do begin
    if CKL1 >= FCountTileY then SetLength(LOT[CKL1],CountH);//Карта меньше, надо заполнять
    for CKL2 := 0 to TmpY do begin
      if (CKL1 > CountW) or (CKL2 >= CountH) then //Карта больше новых значений, надо прибивать
        if LOT[CKL1,CKL2] <> nil then LOT[CKL1,CKL2].Destroy;
      if (CKL1 > FCountTileX) or (CKL2 >= FCountTileY) then //Карта меньше, надо заполнять
        LOT[CKL1,CKL2] := nil;
    end;
    if CKL1 >= CountW then SetLength(LOT[CKL1],0);//Карта больше новых значений, надо прибивать
  end;
  if CountW < FCountTileX then SetLength(LOT,CountW);//Карта меньше, надо заполнять
  FCountTileX := CountW;
  FCountTileY := CountH;
end;

procedure avk_TSimpleMap.DoProc(Sender: TObject);
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

  {$IfDef Debug}
  CalcPrgs := CalcPrgs + 1;
  if CalcPrgs = High(CalcPrgs) then   CalcPrgs := 0;
  {$EndIf}

  NeedToRender := Animate;
  DoProcLot(false);

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure avk_TSimpleMap.DoProcLot(InMode: boolean);
var
  STPntX, STPntY: Single;
  TMPRt: zglPRenderTarget;
  CKL1, CKL2: Integer;
  DrawSpr: avk_TSimpleTile;
  TmpAnimate: BOOLEAN;
begin
  if InMode then if not NeedToRender then Exit;
  if InMode then begin
    NeedToRender := false;
    if not Animate then
      if (round(WievPanel.X) = round(PrevRoundPnt.X))//проверяем а надо ли
         and (round(WievPanel.Y) = round(PrevRoundPnt.Y)) then Exit; //не надо, сдвиг меньше точки
    PrevRoundPnt.X := round(WievPanel.X);
    PrevRoundPnt.Y := round(WievPanel.Y);
  end;

  //все равно жрет производительность... надо думать
  StrX := (trunc(WievPanel.X) div TileSizeW);
  STPntX := (StrX * TileSizeW) - WievPanel.X;
  StrY := trunc(WievPanel.Y) div TileSizeH;
  STPntY := (StrY * TileSizeH) - WievPanel.Y;

  if InMode then
    if (WrtSCR = nil) or (rtSCR1 = WrtSCR) then
     TMPRt := rtSCR2 else TMPRt := rtSCR1;

  //теперь рендерим в нее
  if InMode then begin
    rtarget_Set( TMPRt );//начали
    //TMPRt.
  end;
  TmpAnimate := false;
  for CKL1 := StrX to (StrX + StpX) do
    for CKL2 := StrY to (StrY + StpY) do begin
      if (CKL1 < 0) or (CKL2 < 0) or (CKL1 > (FCountTileX - 1)) or (CKL2 > (FCountTileY - 1)) then
        DrawSpr := nil
      else
        DrawSpr := LOT[CKL1,CKL2];
      if not(DrawSpr = nil) then begin
        if InMode then begin
          DrawSpr.X := STPntX + ((CKL1 - StrX) * TileSizeW);
          DrawSpr.Y := STPntY + ((CKL2 - StrY) * TileSizeH);
          DrawSpr.DoDraw(Self);
          TmpAnimate := TmpAnimate or DrawSpr.Animate;
        end else
          DrawSpr.DoProc(Self);
      end;
    end;
  if InMode then begin
    rtarget_Set( nil );//закончили
    WrtSCR := TMPRt;
  end;
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

constructor avk_TSimpleMap.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  with WievPanel do begin
    X := 0; Y := 0;
    W := 0; H := 0;
  end;
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
  //OnProc := DoProcLot;
  OnProc := DoProc;
  Animate:=true;
  {$IfDef Debug}
  CalcPrgs := 0;
  CalcDraw := 0;
  {$EndIf}
end;

destructor avk_TSimpleMap.Destroy;
var
  CKL1: Integer;
  CKL2: Integer;
begin
  for CKL1 := 0 to CountTileW - 1 do begin
    for CKL2 := 0 to CountTileH - 1 do begin
      LOT[CKL1,CKL2].Destroy;
    end;
    SetLength(LOT[CKL1],0);
  end;
  SetLength(LOT,0);
  inherited Destroy;
end;

