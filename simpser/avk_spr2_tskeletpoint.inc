{ avk_TSkeletPoint }

procedure avk_TSkeletPoint.SetPoint(AX, AY: Single);
begin
  Point.X := AX;
  Point.Y := AY;
  Angle := Single(cpvtoangle(cpv(AX, AY)));
end;

function avk_TSkeletPoint.RealPoint: zglTPoint2D;
var
  TmpX, TmpY, TmpZ, TmpAngle: Single;
  TmpPnt: zglTPoint2D;
begin
  if HostPoint = nil then begin
     Result := Point;
  end;
  TmpX := Point.X;
  TmpY := Point.Y;
  TmpZ := 0;
  TmpAngle := RealAngle;
  glRotatef(TmpAngle, TmpX, TmpY, TmpZ);
  if HostPoint = nil then
    Result := Point
  else begin
    TmpPnt := HostPoint.RealPoint;
    Result.X := TmpX + TmpPnt.X;
    Result.Y := TmpY + TmpPnt.Y;
  end;
end;

function avk_TSkeletPoint.RealAngle: Single;
begin
  if HostPoint = nil then
    Result := Angle
  else
    Result := Angle + HostPoint.Angle;
end;

constructor avk_TSkeletPoint.Create;
begin
  Point.X := 0;
  Point.Y := 0;
  Angle := 0;
  HostPoint := nil;
end;

destructor avk_TSkeletPoint.Destroy;
begin
  inherited Destroy;
end;

