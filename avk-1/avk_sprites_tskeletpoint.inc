{ avk_TSkeletTile }

procedure avk_TSkeletTile.SetAngle(AValue: Single);
var
  TmpL: Single;
  TmpRP: zglTPoint2D;
begin
  if HostPoint = nil then begin
    AngleDeg := AValue;
    Exit;
  end;

  TmpL := VcLength(FPoint);
  TmpRP := VcForAngle(AValue);

  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  SetPoint(Round(TmpRP.X), Round(TmpRP.Y));
end;

procedure avk_TSkeletTile.SetPoint(AX, AY: Single);
begin
  FPoint.X := AX;
  FPoint.Y := AY;
  if HostPoint <> nil then
    AngleDeg := VcToAngle(FPoint);
end;

function avk_TSkeletTile.RealPoint: zglTPoint2D;
var
  TmpAngle, TmpL: Single;
  TmpRP, TmpPnt: zglTPoint2D;
begin
  if HostPoint = nil then begin
     Result := FPoint;
     Exit;
  end;

  TmpAngle := RealAngle;

  TmpL := VcLength(FPoint);
  TmpRP := VcForAngle(TmpAngle);

  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  TmpPnt := HostPoint.RealPoint;
  Result.X := Round(TmpRP.X + TmpPnt.X);
  Result.Y := Round(TmpRP.Y + TmpPnt.Y);
end;

function avk_TSkeletTile.RealAngle: Single;
begin
  if HostPoint = nil then
    Result := AngleDeg
  else
    Result := AngleDeg + HostPoint.RealAngle;
end;

function avk_TSkeletTile.HostAngle: Single;
begin
  if HostPoint = nil then
    Result := AngleDeg
  else
    Result := HostPoint.HostAngle;
end;

procedure avk_TSkeletTile.AddSubPoint(AX, AY: Single);
begin
  SetLength(SubPoints, CountSubPoints + 1);
  SubPoints[CountSubPoints] := avk_TSkeletTile.Create;
  SubPoints[CountSubPoints].HostPoint := Self;
  SubPoints[CountSubPoints].SetPoint(AX, AY);
  INC(CountSubPoints, 1);
end;

procedure avk_TSkeletTile.SetTileParameters(ATexX, ATexY, AWigh, AHeight,
  ATexAngle: Single);
begin
  X := ATexX;
  Y := ATexY;
  W := AWigh;
  H := AHeight;
  TexAngle := ATexAngle;
end;

procedure avk_TSkeletTile.DoDraw;
var
  LRP: zglTPoint2D;
  CmpAngle: Single;
  CKL: Integer;
begin
  LRP := RealPoint;
  if not (Texture = nil) then
    if not Hide then begin
      if Scale <> 0 then
        fx2d_SetScale(Scale, Scale);

      if FTileRotateByHost then
        CmpAngle := HostAngle
      else
        CmpAngle := RealAngle;
      //Всегда от точки поворота
      fx2d_SetRotatingPivot(X * (-1), Y * (-1));
      asprite2d_Draw( Texture, LRP.X + X, LRP.Y + Y, W, H, CmpAngle + TexAngle, TexFrame, Alpha, FxFlags or FX2D_RPIVOT);
    end;

  for CKL := 0 to CountSubPoints - 1 do begin
    SubPoints[CKL].DoDraw;
  end;

  {$IfDef Debug and ShowPoints}
  if HostPoint = nil then
      pr2d_Circle(LRP.X, LRP.Y, 7, $7a250f, 150 ,250, PR2D_FILL)
  else if CountSubPoints > 0 then
      pr2d_Circle(LRP.X, LRP.Y, 6, $7a250f, 150 ,250, PR2D_FILL);
  pr2d_Circle(LRP.X, LRP.Y, 4, $e52b50, 150 ,250, PR2D_FILL);
  {$EndIf}
end;

constructor avk_TSkeletTile.Create;
begin
  FPoint.X := 0;
  FPoint.Y := 0;
  AngleDeg := 0;
  HostPoint := nil;
  CountSubPoints := 0;
  FTileRotateByHost := true;
  inherited Create;
end;

destructor avk_TSkeletTile.Destroy;
var
  CKL: Integer;
begin
  for CKL := 0 to CountSubPoints - 1 do
    SubPoints[CKL].Destroy;
  SetLength(SubPoints, 0);
  inherited Destroy;
end;

