{ avk_TSkeletPoint }

function avk_TSkeletPoint.GetAngle: Single;
begin
  Result := AngleRad * rad2deg;
end;

function avk_TSkeletPoint.GetCpvPoint: cpVect;
begin
  Result := cpv(Point.X, Point.Y);
end;

procedure avk_TSkeletPoint.SetAngle(AValue: Single);
var
  TmpL: cpFloat;
  TmpRP: cpVect;
begin
  if HostPoint = nil then begin
    AngleRad := AValue * deg2rad;
    Exit;
  end;

  TmpL := cpvlength(cpvPoint);
  TmpRP := cpvforangle(AValue);
  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  Point.X := TmpRP.X;
  Point.Y := TmpRP.Y;
end;

procedure avk_TSkeletPoint.SetPoint(AX, AY: Single);
begin
  Point.X := AX;
  Point.Y := AY;
  AngleRad := cpvtoangle(cpvPoint);
end;

function avk_TSkeletPoint.RealPoint: zglTPoint2D;
var
  TmpX, TmpY, TmpZ, TmpAngle: Single;
  TmpPnt: zglTPoint2D;
  TmpRP: cpVect;
  TmpL: cpFloat;
begin
  if HostPoint = nil then begin
     Result := Point;
     Exit;
  end;

  //TmpAngle := HostPoint.RealAngleRad;
  TmpAngle := RealAngleRad;

  TmpL := cpvlength(cpvPoint);
  TmpRP := cpvforangle(TmpAngle);
  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  TmpPnt := HostPoint.RealPoint;
  Result.X := TmpRP.X + TmpPnt.X;
  Result.Y := TmpRP.Y + TmpPnt.Y;
end;

function avk_TSkeletPoint.RealAngleRad: Single;
begin
  if HostPoint = nil then
    Result := AngleRad
  else
    Result := AngleRad + HostPoint.RealAngleRad;
end;

procedure avk_TSkeletPoint.AddSubPoint(AX, AY: Single);
begin
  SetLength(SubPoints, CountSubPoints +1);
  SubPoints[CountSubPoints] := avk_TSkeletPoint.Create;
  SubPoints[CountSubPoints].SetPoint(AX, AY);
  SubPoints[CountSubPoints].HostPoint := Self;
  INC(CountSubPoints, 1);
end;

{$IfDef Debug}
procedure avk_TSkeletPoint.DoDraw(Sender: TObject);
var
  LRP: zglTPoint2D;
  CKL: Integer;
begin
  LRP := RealPoint;
  {$IfDef ShowPoints}
  if HostPoint = nil then
      pr2d_Circle(LRP.X, LRP.Y, 7, $7a250f, 150 ,250, PR2D_FILL)
  else if CountSubPoints > 0 then
      pr2d_Circle(LRP.X, LRP.Y, 6, $7a250f, 150 ,250, PR2D_FILL);
  pr2d_Circle(LRP.X, LRP.Y, 4, $e52b50, 150 ,250, PR2D_FILL);
  {$EndIf}
  for CKL := 0 to CountSubPoints - 1 do
    SubPoints[CKL].OnDraw(Self);
end;
{$EndIf}

{$IfDef Debug}
constructor avk_TSkeletPoint.Create(const InParent: avk_TFraim = nil; InName: String = '');
{$Else}
constructor avk_TSkeletPoint.Create;
{$EndIf}
begin
  Point.X := 0;
  Point.Y := 0;
  AngleRad := 0;
  HostPoint := nil;
  CountSubPoints := 0;
  {$IfDef Debug}
  inherited Create (InParent, InName);
  OnDraw := DoDraw;
  {$EndIf}
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

