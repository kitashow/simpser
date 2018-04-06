{ avk_TCollisionZone }

procedure avk_TCollisionZone.SetZone(ARadius: Single);
begin
  FTypeOfZone := CZ_CIRCLE;
  FRadius := ARadius;
end;

procedure avk_TCollisionZone.SetZone(APoint1, APoint2: zglTPoint2D);
begin
  FTypeOfZone := CZ_LINE;
  FPoints[0] := APoint1;
  FPoints[1] := APoint2;
end;

procedure avk_TCollisionZone.SetZone(APoint1, APoint2, APoint3,
  APoint4: zglTPoint2D);
begin
  SetZone(APoint1, APoint2);
  FTypeOfZone := CZ_LINERECTANGLE;
  FPoints[2] := APoint3;
  FPoints[3] := APoint4;
end;

procedure avk_TCollisionZone.SetZone(AX, AY, AW, AH: Single);
begin
  FTypeOfZone := CZ_RECTANGLE;
  FRectangle.X := AX;
  FRectangle.Y := AY;
  FRectangle.W := AW;
  FRectangle.H := AH;
end;

procedure avk_TCollisionZone.CalkBuffer;
var
  PRN: zglTPoint2D;
begin
  if FHostSkeletTile = nil then begin
    PRN.X := 0;
    PRN.Y := 0;
  end else begin
    PRN := FHostSkeletTile.RealPoint;
  end;
  //TODO: РАССЧЕТЕГЕ
end;

constructor avk_TCollisionZone.Create(const AHostSkeletTile: avk_TSkeletTile);
begin
  FHostSkeletTile := AHostSkeletTile;
  FTypeOfZone := CZ_POINT; //точка, берется от точки скелета, нет доп параметров
end;

