{ avk_TAdditionalPoint }

function avk_TAdditionalPoint.FGetX: Single;
var
  LokX: Single;
  LokY: Single;
  Rot: zglTPoint2D;
begin
  LokX := FX;
  LokY := FY;
  if FAngle <> 0 then begin
    Rot := avk_GetRotatePoint(LokX, LokY, 0, 0, FAngle);
    Result := Rot.X;
  end else
    Result := LokX;
end;

function avk_TAdditionalPoint.FGetY: Single;
var
  LokX: Single;
  LokY: Single;
  Rot: zglTPoint2D;
begin
  LokX := FX;
  LokY := FY;
  if FAngle <> 0 then begin
    Rot := avk_GetRotatePoint(LokX, LokY, 0, 0, FAngle);
    Result := Rot.Y;
  end else
    Result := LokY;
end;

constructor avk_TAdditionalPoint.Create;
begin
  FX := 0;
  FY := 0;
  FAngle := 0;
end;
