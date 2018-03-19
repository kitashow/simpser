{ TGamer1 }

constructor TGamer1.Create(const InParent: avk_TFraim);
begin
  FBulletStep := 0;
  BulletPause := 14;
  MoveSpeed := 1;
  inherited Create(InParent);
  {$IfDef Debug}
  OnFinishDraw := DoFinishDraw;
  {$EndIf}
end;

destructor TGamer1.Destroy;
begin
  inherited Destroy;
end;

procedure TGamer1.MoveSprite(AFlag: byte; AMousePosition: zglTPoint2D);
var
  Leg, Bdy: avk_TSkeletTile;
  CPY, CPX: Single;
  TmpK_UP, TmpK_DOWN, TmpK_LEFT, TmpK_RIGHT, ItIsFire: Boolean;
  LegAngle, Speed45: Single;
begin

  ItIsFire := GetColVisible(1) = 1; //это стрельба

  CPY := Position.Y;
  CPX := Position.X;

  Speed45 := MoveSpeed / 2;

  TmpK_UP := (AFlag and FLAG_K_UP) > 0;
  TmpK_DOWN := (AFlag and FLAG_K_DOWN) > 0;
  TmpK_LEFT := (AFlag and FLAG_K_LEFT) > 0;
  TmpK_RIGHT := (AFlag and FLAG_K_RIGHT) > 0;

  LegAngle := GetColAngle(0);

  if TmpK_UP and TmpK_LEFT then begin
    LegAngle := -45;
    CPX := CPX - Speed45;
    CPY := CPY - Speed45;
  end else if TmpK_UP and TmpK_RIGHT then begin
    LegAngle := 45;
    CPX := CPX + Speed45;
    CPY := CPY - Speed45;
  end else if TmpK_DOWN and TmpK_RIGHT then begin
    LegAngle :=  135;
    CPX := CPX + Speed45;
    CPY := CPY + Speed45;
  end else if TmpK_DOWN and TmpK_LEFT then begin
    LegAngle :=  -135;
    CPX := CPX - Speed45;
    CPY := CPY + Speed45;
  end else if TmpK_DOWN then begin
    LegAngle := 180;
    CPY := CPY + MoveSpeed;
  end else if TmpK_UP then begin
    LegAngle := 0;
    CPY := CPY - MoveSpeed;
  end else if TmpK_LEFT then begin
    LegAngle :=  -90;
    CPX := CPX - MoveSpeed;
  end else if TmpK_RIGHT then begin
    LegAngle :=  90;
    CPX := CPX + MoveSpeed;
  end;

  Position.X := CPX;
  Position.Y := CPY;

  SetColAngle(0, LegAngle);
  SetColPosition(0, Position);

  SetColAngle(1, m_Angle(CPX, CPY, AMousePosition.X, AMousePosition.Y) - 90);
  SetColPosition(1, Position);

  if not ItIsFire then begin
    if (AFlag and FLAG_M_LEFT_Cl) > 0 then begin//стреляем
      SetColVisible(1, 1);
      FSprites[1, 1].NowFrame := FSprites[1, 1].CoolSprite.StartFrame;
    end;
    //в мирном режиме охлаждаем ствол
    if FCurrentRadiusTarget > FMinimalRadiusTarget then
       FCurrentRadiusTarget := FCurrentRadiusTarget - FStepColdRadiusTarget;
  end;

  Leg := FSprites[0, GetColVisible(0)];
  Bdy := FSprites[1, GetColVisible(1)];

  Leg.Animate := true;
  Bdy.Animate := true;

  if AFlag = $00 then begin
    Leg.NowFrame := Leg.CoolSprite.StartFrame;
    if not ItIsFire then begin
      Bdy.NowFrame := Bdy.CoolSprite.StartFrame;
    end;
  end;

  if ItIsFire then begin
    if (Bdy.NowFrame = 6) and (FBulletStep = 0) then begin//момент выстрела
      if Assigned(FOnRelizeShot) then FOnRelizeShot(Self, Bdy.SubPoints[0].RealPoint, AMousePosition);
      FBulletStep := 1;
    end;
    if Round(Bdy.NowFrame) = Bdy.CoolSprite.EndFrame then begin // стрельба окончена
      Bdy.NowFrame := Bdy.CoolSprite.StartFrame;
      SetColVisible(1, 0);
    end;
  end;

  if FBulletStep > 0 then INC(FBulletStep, 1);
  if FBulletStep > BulletPause then FBulletStep := 0;

end;

{$IfDef Debug}
procedure TGamer1.DoFinishDraw(Sender: TObject);
var
  ItIsFire: Boolean;
begin
  ItIsFire := GetColVisible(1) = 1; //это стрельба
  if ItIsFire then begin
    pr2d_Circle(avk_MouseIsX, avk_MouseIsY, FCurrentRadiusTarget, $7a250f, 150 ,250, PR2D_SMOOTH)
  end;
end;
{$EndIf}
