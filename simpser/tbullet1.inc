{ TBullet1 }

procedure TBullet1.DoSimpleDethBullet(Sender: TObject);
begin
  TBullet1(Sender).DeleteMe := true;
end;

{$IfDef Debug}
procedure TBullet1.DoDraw(Sender: TObject);
var
  CKL1, CKL2: Integer;
begin
  if not PosHide then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if not FSprites[CKL1, CKL2].Hide then begin
          FSprites[CKL1, CKL2].DoDraw;
        end;
end;
{$EndIf}

procedure TBullet1.DoProc(Sender: TObject);
var
  TmpRP: zglTPoint2D;
  CKL1, CKL2: Integer;
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);

  SetPosForAll;

  if PosAnimate then
    for CKL1 := 0 to Length(FSprites) - 1 do
      for CKL2 := 0 to Length(FSprites[CKL1]) - 1 do
        if FSprites[CKL1, CKL2].Animate then
          FSprites[CKL1, CKL2].DoProc;

  //После реализации предыдущего шага считаем новый
  if FPower <= 0 then
    if Assigned(OnRelizeDethBullet) then OnRelizeDethBullet(Self);
  FPower := FPower - FLosePowerInStep;

  TmpRP := VcForAngle(FCurAngle);
  Position.X := Position.X + (TmpRP.X * FSpeedFly);
  Position.Y := Position.Y + (TmpRP.Y * FSpeedFly);

  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

procedure TBullet1.StartMoveBullet(AStartPoint, AFinishPoint: zglTPoint2D);
begin
  FStartPoint := AStartPoint;
  FFinishPoint := AFinishPoint;
  Position := AStartPoint;
  FCurAngle := m_Angle(AFinishPoint.X, AFinishPoint.Y, AStartPoint.X, AStartPoint.Y);
  case Sprite[0,0].TypeOfTile of
    TILE_TEXTURE: PosAngle := FCurAngle + 90;
    TILE_COOLSPRITE: PosAngle := FCurAngle - 90;
    else PosAngle := FCurAngle;
  end;
  SetPosForAll;
end;

constructor TBullet1.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  OnProc := DoProc;
  {$IfDef Debug}
  OnDraw := DoDraw;
  {$EndIf}
  OnRelizeDethBullet := DoSimpleDethBullet;
end;

