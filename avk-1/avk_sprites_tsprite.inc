{ TSprite }

function avk_TSprite.GetColCount: Integer;
begin
  Result := Length(FSprites);
end;

function avk_TSprite.GetColAngle(const ACol: Integer): Single;
begin
  Result := FSprites[ACol, 0].Angle; //первый и все
end;

procedure avk_TSprite.SetColAngle(const ACol: Integer; AValue: Single);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Angle := AValue;
end;

function avk_TSprite.GetColAnimate(const ACol, ARow: Integer): boolean;
begin
  Result := FSprites[ACol, ARow].Animate;
end;


procedure avk_TSprite.SetColAnimate(const ACol, ARow: Integer; AValue: boolean);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Animate := false;
  FSprites[ACol, ARow].Animate := AValue;
end;

function avk_TSprite.GetColPosition(const ACol: Integer): zglTPoint2D;
begin
  Result := FSprites[ACol, 0].Point; //первый и все
end;

procedure avk_TSprite.SetColPosition(const ACol: Integer; AValue: zglTPoint2D);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].SetPoint(AValue.X, AValue.Y);
end;

function avk_TSprite.GetSprite(const ACol, ARow: Integer): avk_TSkeletTile;
begin
  if ACol > (Length(FSprites) - 1) then
    SetSprite(ACol, ARow);

  if ARow > (Length(FSprites[ACol]) - 1) then
    SetSprite(ACol, ARow);

  Result := FSprites[ACol, ARow];
end;

procedure avk_TSprite.SetSprite(const ACol, ARow: Integer; AValue: avk_TSkeletTile);
var
  PrevSize, CKL: Integer;
begin
  if ACol > (Length(FSprites) - 1) then
    SetLength(FSprites, ACol + 1);

  if ARow > (Length(FSprites[ACol]) - 1) then begin
    PrevSize := Length(FSprites[ACol]) + 1;
    for CKL := PrevSize to ARow - 1 do begin
      SetLength(FSprites[ACol], CKL);
      FSprites[ACol, CKL - 1] := avk_TSkeletTile.Create(Self);
    end;
    SetLength(FSprites[ACol], ARow + 1);
  end;

  if Assigned(FSprites[ACol, ARow]) then
    FSprites[ACol, ARow].Destroy;

  FSprites[ACol, ARow] := AValue;

  if not Assigned(FSprites[ACol, ARow]) then
    FSprites[ACol, ARow] := avk_TSkeletTile.Create(Self);
end;

function avk_TSprite.GetColVisible(const ACol: Integer): Integer;
var
  CKL: Integer;
begin
  Result := 0; //мало ли все скрыты
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    if not FSprites[ACol, CKL].Hide then Result := CKL;
end;

function avk_TSprite.GetRowCount(const ACol: Integer): Integer;
begin
  Result := Length(FSprites[ACol]);
end;

procedure avk_TSprite.SetColVisible(const ACol: Integer; ARow: Integer);
var
  CKL: Integer;
begin
  for CKL := 0 to Length(FSprites[ACol]) - 1 do
    FSprites[ACol, CKL].Hide := not(CKL = ARow);
end;

procedure avk_TSprite.SetPosForAll;
var
  CKL1, CKL2: Integer;
begin
  for CKL1 := 0 to Length(FSprites) - 1 do
    for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do begin
      FSprites[CKL1, CKL2].SetInternalParameters(Position.X, Position.Y, PosAngle, PosScale,
        FSprites[CKL1, CKL2].X, FSprites[CKL1, CKL2].Y, FSprites[CKL1, CKL2].W, FSprites[CKL1, CKL2].H);
      if Assigned(FSprites[CKL1, CKL2].CollizionZone) then
        FSprites[CKL1, CKL2].CollizionZone.CalkBuffer;
    end;
end;

procedure avk_TSprite.DoDraw(Sender: TObject);
var
  CKL1, CKL2: Integer;
begin

  if not PosHide then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if not FSprites[CKL1, CKL2].Hide then
          FSprites[CKL1, CKL2].DoDraw;
end;

procedure avk_TSprite.DoProc(Sender: TObject);
var
  CKL1, CKL2: Integer;
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

  if PosAnimate then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if FSprites[CKL1, CKL2].Animate then
          FSprites[CKL1, CKL2].DoProc;

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

constructor avk_TSprite.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  SetLength(FSprites, 0);
  PosAnimate := true;
  OnDraw := DoDraw;
  OnProc := DoProc;
  FMap := nil;
end;

destructor avk_TSprite.Destroy;
var
  CKL0, CKL1: Integer;
begin
  for CKL0 := 0 to Length(FSprites) - 1 do
    for CKL1 := 0 to Length(FSprites[CKL0]) - 1 do begin
      FSprites[CKL0, CKL1].Destroy;
    end;

  inherited Destroy;
end;

