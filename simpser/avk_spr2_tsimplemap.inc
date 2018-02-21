{ avk_TSimpleMap }

procedure avk_TSimpleMap.ClearMap;
var
  CKL: Integer;
begin
  for CKL := 0 to FCountStage - 1 do
      FStage[CKL].Destroy;
  SetLength(FStage, 0);
end;

function avk_TSimpleMap.FGetStage(InID : Integer): avk_TTileMap;
begin
  Result := FStage[InId];
end;

procedure avk_TSimpleMap.FSetCountStage(AValue: Integer);
var
  CKL: Integer;
begin
  if FCountStage <> 0 then ClearMap;
  SetLength(FStage, AValue);
  FCountStage := AValue;
  for CKL := 0 to FCountStage - 1 do begin
    FStage[CKL] := avk_TTileMap.Create;
  end;
end;

function avk_TSimpleMap.FGetTileSizeW: Integer;
begin
  Result := FStage[FCurrentStage].TileSizeW;
end;

function avk_TSimpleMap.FGetTileSizeH: Integer;
begin
  Result := FStage[FCurrentStage].TileSizeH;
end;

function avk_TSimpleMap.FGetWievPanel: zglTRect;
begin
  Result := FStage[FCurrentStage].WievPanel;
end;

{$IfDef Debug}
function avk_TSimpleMap.CalcPrgs: Integer;
begin
  Result := FStage[FCurrentStage].CalcPrgs;
end;

function avk_TSimpleMap.CalcDraw: Integer;
begin
  Result := FStage[FCurrentStage].CalcDraw;
end;

function avk_TSimpleMap.FSFrecvency: Integer;
begin
  Result := FStage[FCurrentStage].FSFrecvency;
end;
{$EndIf}

procedure avk_TSimpleMap.DoDraw(Sender: TObject);
var
  CKL: Integer;
begin
  for CKL := 0 to FCountStage - 1 do begin
    if FCurrentStage > CKL then Continue;
    //Рисовка в обратном порядке
    FStage[(FCountStage - 1) - CKL].Draw(GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H);
  end;
end;

procedure avk_TSimpleMap.DoProc(Sender: TObject);
var
  CKL: Integer;
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);
  for CKL := 0 to FCountStage - 1 do begin
    if FCurrentStage > CKL then Continue;
    //FStage[CKL].NeedToRender := true;
    FStage[CKL].DoProc(Self);
  end;
  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure avk_TSimpleMap.SetStageAndPercentDistance(const ACurrentStage,
  APercentDistance: Integer);
var
  CKL: Integer;
  LocTileSizeW: Integer;
  LocTileSizeH: Integer;
  Coef: Single;
  PrevStage, CurrStage: avk_TTileMap;
  FWP: zglTRect;
begin
  PrevStage := FStage[FCurrentStage];

  LocTileSizeW := PrevStage.FTileSizeW;
  LocTileSizeH := PrevStage.FTileSizeH;
  FWP := PrevStage.FWievPanel;

  for CKL := 0 to FCountStage - 1 do begin
    if CKL < ACurrentStage then Continue;

    CurrStage := FStage[CKL];

    //размеры тайла на PercentDistance% меньше на этаже ниже
    Coef := ((APercentDistance * (CKL - ACurrentStage)) * 0.01);

    LocTileSizeW := PrevStage.FTileSizeW - trunc(PrevStage.FTileSizeW * Coef);
    LocTileSizeH := PrevStage.FTileSizeH - trunc(PrevStage.FTileSizeH * Coef);

    FWP.W := FWP.W + trunc(PrevStage.FWievPanel.W * Coef);
    FWP.X := PrevStage.FWievPanel.X - trunc(PrevStage.FWievPanel.X * Coef);

    FWP.H := FWP.H + trunc(PrevStage.FWievPanel.H * Coef);
    FWP.Y := PrevStage.FWievPanel.Y - trunc(PrevStage.FWievPanel.Y * Coef);

    CurrStage.FTileSizeW := LocTileSizeW;
    CurrStage.FTileSizeH := LocTileSizeH;
    CurrStage.FSetWievPanel(FWP);
  end;

  //Переключаем
  FCurrentStage := ACurrentStage;
  FPercentDistance := APercentDistance;

end;

procedure avk_TSimpleMap.SetWievPanelAndTileSize(const AWievPanelW, AWievPanelH: Single;
  const ATileSizeW, ATileSizeH: Integer);
begin
  with FStage[FCurrentStage] do begin
    FTileSizeW := ATileSizeW;
    FTileSizeH := ATileSizeH;
    FWievPanel.W := AWievPanelW;
    FWievPanel.H := AWievPanelH;
  end;
  SetStageAndPercentDistance(CurrentStage, PercentDistance);
end;

procedure avk_TSimpleMap.SetMapSize(const ACountW, ACountH: Integer;
  const AOnlyCurrent: Boolean);
var
  TmpStage: avk_TTileMap;
  CKL: Integer;
begin
  TmpStage := FStage[FCurrentStage];
  TmpStage.SetSizeMap(ACountW, ACountH);

  if AOnlyCurrent then Exit;//меняем только этот

  for CKL := (FCurrentStage + 1) to (FCountStage - 1) do begin
    TmpStage := FStage[CKL];
    TmpStage.SetSizeMap(ACountW, ACountH);
  end;

end;


constructor avk_TSimpleMap.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  FSetCountStage(1);
  FCurrentStage := 0;
  FPercentDistance := 30;

  OnProc := DoProc;
  OnDraw := DoDraw;


end;

destructor avk_TSimpleMap.Destroy;
begin
  ClearMap;
  inherited Destroy;
end;
