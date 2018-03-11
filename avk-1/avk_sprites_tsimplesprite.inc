{ avk_TSimpleSprite }

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
  FSkeletPoint := avk_TSkeletTile.Create;
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor avk_TSimpleSprite.Destroy;
begin
  FSkeletPoint.Destroy;
  inherited Destroy;
end;

