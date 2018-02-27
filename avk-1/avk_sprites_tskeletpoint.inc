{ avk_TSkeletPoint }

procedure avk_TSkeletPoint.SetAngle(AValue: Single);
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

procedure avk_TSkeletPoint.SetPoint(AX, AY: Single);
begin
  FPoint.X := AX;
  FPoint.Y := AY;
  if HostPoint <> nil then
    AngleDeg := VcToAngle(FPoint);
end;

function avk_TSkeletPoint.RealPoint: zglTPoint2D;
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

function avk_TSkeletPoint.RealAngle: Single;
begin
  if HostPoint = nil then
    Result := AngleDeg
  else
    Result := AngleDeg + HostPoint.RealAngle;
end;

procedure avk_TSkeletPoint.AddSubPoint(AX, AY: Single);
begin
  SetLength(SubPoints, CountSubPoints + 1);
  SubPoints[CountSubPoints] := avk_TSkeletPoint.Create;
  SubPoints[CountSubPoints].HostPoint := Self;
  SubPoints[CountSubPoints].SetPoint(AX, AY);
  INC(CountSubPoints, 1);
end;

procedure avk_TSkeletPoint.DoDraw;
var
  LRP: zglTPoint2D;
  CKL: Integer;
begin
  LRP := RealPoint;
  if not (Texture = nil) then
    if not Hide then begin
      if Scale <> 0 then fx2d_SetScale(Scale, Scale);
      //Всегда от точки поворота
      fx2d_SetRotatingPivot(X * (-1), Y * (-1));
      asprite2d_Draw( Texture, LRP.X + X, LRP.Y + Y, W, H, RealAngle + TexAngle, TexFrame, Alpha, FxFlags or FX2D_RPIVOT);
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

constructor avk_TSkeletPoint.Create;
begin
  FPoint.X := 0;
  FPoint.Y := 0;
  AngleDeg := 0;
  HostPoint := nil;
  CountSubPoints := 0;
  inherited Create;
end;

destructor avk_TSkeletPoint.Destroy;
var
  CKL: Integer;
begin
  for CKL := 0 to CountSubPoints - 1 do
    SubPoints[CKL].Destroy;
  SetLength(SubPoints, 0);
  inherited Destroy;
end;

