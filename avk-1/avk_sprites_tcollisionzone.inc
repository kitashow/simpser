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
  PRN, TmpRP: zglTPoint2D;
  TmpAngle, TmpL: Single;
  CKL: Integer;
begin

  if FHostSkeletTile = nil then begin
    Exit; // как есть
  end else begin
    PRN := FHostSkeletTile.RealPoint;
    TmpAngle := FHostSkeletTile.RealAngle;
  end;

  case FTypeOfZone of
    CZ_POINT: begin
      FBufferPoints[0].X := PRN.X;
      FBufferPoints[0].Y := PRN.Y;
    end;
    CZ_CIRCLE: begin
      FBufferCircle.cX := PRN.X;
      FBufferCircle.cY := PRN.Y;
      FBufferCircle.Radius := FRadius;
    end;
    CZ_LINE: for CKL := 0 to 1 do begin
      TmpRP := VcForAngle(TmpAngle);
      TmpL := VcLength(FPoints[CKL]);
      FBufferPoints[CKL].X := PRN.X + FPoints[CKL].X * TmpL;
      FBufferPoints[CKL].Y := PRN.Y + FPoints[CKL].Y * TmpL;
    end;
    CZ_LINERECTANGLE: for CKL := 0 to 3 do begin
      TmpRP := VcForAngle(TmpAngle);
      TmpL := VcLength(FPoints[CKL]);
      FBufferPoints[CKL].X := PRN.X + FPoints[CKL].X * TmpL;
      FBufferPoints[CKL].Y := PRN.Y + FPoints[CKL].Y * TmpL;
    end;
    CZ_RECTANGLE: begin
      TmpRP := VcForAngle(TmpAngle);
      TmpL := VcLength(FRectangle.X,  FRectangle.Y);
      FBufferRectangle.X := PRN.X + FRectangle.X * TmpL;
      FBufferRectangle.Y := PRN.Y + FRectangle.Y * TmpL;
      FBufferRectangle.W := FRectangle.W;
      FBufferRectangle.H := FRectangle.H;
    end;
  end;//case FTypeOfZone

end;

function avk_TCollisionZone.Check(AColZone: avk_TCollisionZone): boolean;
begin
  if (FTypeOfZone = CZ_POINT) and (AColZone.FTypeOfZone = CZ_POINT) then
    Result := (FBufferPoints[0].X = AColZone.FBufferPoints[0].X) and (FBufferPoints[0].Y = AColZone.FBufferPoints[0].Y)
  else if (FTypeOfZone = CZ_CIRCLE) and (AColZone.FTypeOfZone = CZ_POINT) then begin
    Result := col2d_PointInCircle(AColZone.FBufferPoints[0].X, AColZone.FBufferPoints[0].Y, FBufferCircle);
  end else if (FTypeOfZone = CZ_POINT) and (AColZone.FTypeOfZone = CZ_CIRCLE) then begin
    Result := col2d_PointInCircle(FBufferPoints[0].X, FBufferPoints[0].Y, AColZone.FBufferCircle);
  end else if (FTypeOfZone = CZ_CIRCLE) and (AColZone.FTypeOfZone = CZ_CIRCLE) then begin
    Result := col2d_Circle(FBufferCircle, AColZone.FBufferCircle)
      or col2d_CircleInCircle(FBufferCircle, AColZone.FBufferCircle);
  end;
end;

constructor avk_TCollisionZone.Create(const AHostSkeletTile: avk_TSkeletTile);
begin
  FHostSkeletTile := nil;
  FHostSkeletTile := AHostSkeletTile;
  FTypeOfZone := CZ_POINT; //точка, берется от точки скелета, нет доп параметров
end;

