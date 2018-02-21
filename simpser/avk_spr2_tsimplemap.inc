{ avk_TSimpleMap }

procedure avk_TSimpleMap.ClearMap;
var
  CKL: Integer;
begin
  for CKL := 0 to FCountLoyer - 1 do
      FLoyer[CKL].Destroy;
  SetLength(FLoyer, 0);
end;

function avk_TSimpleMap.FGetLoyer(InID : Integer): avk_TTileMap;
begin
  Result := FLoyer[InId];
end;

procedure avk_TSimpleMap.FSetCountLoyer(AValue: Integer);
var
  CKL: Integer;
begin
  if FCountLoyer <> 0 then ClearMap;
  SetLength(FLoyer, AValue);
  FCountLoyer := AValue;
  for CKL := 0 to FCountLoyer - 1 do begin
    FLoyer[CKL] := avk_TTileMap.Create;
  end;
end;

function avk_TSimpleMap.FGetTileSizeW;
begin
  Result := FLoyer[FNowLoyer].TileSizeW;
end;

function avk_TSimpleMap.FGetTileSizeH;
begin
  Result := FLoyer[FNowLoyer].TileSizeH;
end;

function avk_TSimpleMap.FGetWievPanel;
begin
  Result := FLoyer[FNowLoyer].WievPanel;
end;

procedure avk_TSimpleMap.DoDraw(Sender: TObject);
var
  CKL: Integer;
begin
  for CKL := 0 to FCountLoyer - 1 do begin
    if FNowLoyer > CKL then Continue;
    FLoyer[CKL].Draw(GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.X, AreaElement.Y);
  end;
end;

procedure avk_TSimpleMap.SetMapParam(ANowLoyer: Integer; APercentDistance: Integer);
var
  CKL, LocTileSizeW: Integer;
  LocTileSizeH: Integer;
  Coef: Single;
  PrevLoyer, CurrLoyer: avk_TTileMap;
  FWP: zglTRect;
begin
  PrevLoyer := FLoyer[FNowLoyer];

  LocTileSizeW := PrevLoyer.FTileSizeW;
  LocTileSizeH := PrevLoyer.FTileSizeH;
  FWP := PrevLoyer.FWievPanel;

  for CKL := 0 to FCountLoyer - 1 do begin
    if ANowLoyer > CKL then Continue;

    CurrLoyer := FLoyer[CKL];

    //размеры тайла на PercentDistance% меньше на этаже ниже
    Coef := ((APercentDistance * (CKL - ANowLoyer)) * 0.01);
    LocTileSizeW := PrevLoyer.FTileSizeW - trunc(PrevLoyer.FTileSizeW * Coef);
    LocTileSizeH := PrevLoyer.FTileSizeH - trunc(PrevLoyer.FTileSizeH * Coef);

    FWP.W := FWP.W + trunc(PrevLoyer.FWievPanel.W * Coef);
    FWP.X := PrevLoyer.FWievPanel.X - trunc((FWP.W - PrevLoyer.FWievPanel.W) / 2);

    FWP.H := FWP.H + trunc(PrevLoyer.FWievPanel.H * Coef);
    FWP.Y := PrevLoyer.FWievPanel.Y - trunc((FWP.H - PrevLoyer.FWievPanel.H) / 2);

    CurrLoyer.FTileSizeW := LocTileSizeW;
    CurrLoyer.FTileSizeH := LocTileSizeH;
    CurrLoyer.FSetWievPanel(FWP);
  end;

  //Переключаем
  FNowLoyer := ANowLoyer;
  FPercentDistance := APercentDistance;

end;

constructor avk_TSimpleMap.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  FSetCountLoyer(1);
  FNowLoyer := 0;
  FPercentDistance := 0;
end;

destructor avk_TSimpleMap.Destroy;
begin
  ClearMap;
  inherited Destroy;
end;
