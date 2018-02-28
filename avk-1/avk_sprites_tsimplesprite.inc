{ avk_TSimpleSprite }

procedure avk_TSimpleSprite.SetParameters(APntX, APntY, ATexX, ATexY, AWigh,
  AHeight, ATexAngle: Single);
begin
  with FSkeletPoint do begin
    SetPoint(APntX, APntY);
    SetTileParameters(ATexX, ATexY, AWigh, AHeight, ATexAngle);
  end;
end;

procedure avk_TSimpleSprite.SetParameters(APntX, APntY, AWigh, AHeight: Single;
  ATexAngle: Single = 0);
var
  ASquareX, ASquareY: Single;
begin
  ASquareX := -AWigh / 2;
  ASquareY := -AHeight / 2;
  SetParameters(APntX, APntY, ASquareX, ASquareY, AWigh, AHeight, ATexAngle);
end;

procedure avk_TSimpleSprite.DoDraw(Sender: TObject);
begin
  FSkeletPoint.DoDraw;
end;

procedure avk_TSimpleSprite.DoProc(Sender: TObject);
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);
  FSkeletPoint.DoProc;
  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;


constructor avk_TSimpleSprite.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  FSkeletPoint := avk_TSkeletPoint.Create;
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor avk_TSimpleSprite.Destroy;
begin
  FSkeletPoint.Destroy;
  inherited Destroy;
end;

