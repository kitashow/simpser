{ avk_TSkeletTile }

procedure avk_TSkeletTile.SetAngle(AValue: Single);
var
  TmpL: Single;
  TmpRP: zglTPoint2D;
begin
  if (HostPoint = nil) or ZeroPoint(FPoint) then begin
    AngleDeg := AValue;
    Exit;
  end;

  TmpL := VcLength(FPoint);
  TmpRP := VcForAngle(AValue);

  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  SetPoint(TmpRP.X, TmpRP.Y);
end;

procedure avk_TSkeletTile.SetCollizionZone(AValue: avk_TCollisionZone);
begin
  if FCollizionZone=AValue then Exit;
  if Assigned(FCollizionZone) then FCollizionZone.Destroy;
  FCollizionZone:=AValue;
end;

procedure avk_TSkeletTile.stSetCoolSprite(AValue: clPSprite);
begin
  FCoolSprite := AValue;
  FTexture := nil;
  FEmitter := nil;
  FTypeOfTile := TILE_COOLSPRITE;
  FDrawRealisation := DrawCoolSprite;
  FProcRealisation := ProcCoolSprite;
  FCoolSpriteFrame := FCoolSprite^.StartFrame;
end;

procedure avk_TSkeletTile.stSetEmitter(AValue: zglPEmitter2D);
begin
  pengine2d_Set( @Fparticles );
  pengine2d_AddEmitter(AValue, @FEmitter, X + trunc(W / 2), Y + trunc(H / 2));
  FCoolSprite := nil;
  FTexture := nil;
  FTypeOfTile := TILE_EMITTER;
  FDrawRealisation := DrawEmitter;
  FProcRealisation := ProcEmitter;
end;

function avk_TSkeletTile.FHostAnimate: Boolean;
begin
  if HostPoint = nil then
    Result := Animate
  else
    Result := HostPoint.FHostAnimate;
end;

procedure avk_TSkeletTile.SetPoint(AX, AY: Single);
begin
  FPoint.X := AX;
  FPoint.Y := AY;
  if HostPoint <> nil then
    AngleDeg := VcToAngle(FPoint);
end;

function avk_TSkeletTile.RealPoint: zglTPoint2D;
var
  TmpAngle, TmpL: Single;
  TmpRP, TmpPnt: zglTPoint2D;
begin
  if HostPoint = nil then begin
     Result := FPoint;
     //проверяем класс родителя и если он на карте, то возвращаем координаты на карте
     if FParent is avk_TSprite then begin

     end;
     Exit;
  end;

  if ZeroPoint(FPoint) then begin
    Result := HostPoint.RealPoint;
    Exit;
  end;

  TmpAngle := RealAngle;

  TmpL := VcLength(FPoint);
  TmpRP := VcForAngle(TmpAngle);

  TmpRP.X := TmpRP.X * TmpL;
  TmpRP.Y := TmpRP.Y * TmpL;

  TmpPnt := HostPoint.RealPoint;
  Result.X := Round(TmpRP.X + TmpPnt.X);
  Result.Y := Round(TmpRP.Y + TmpPnt.Y);
end;

function avk_TSkeletTile.RealAngle: Single;
begin
  if HostPoint = nil then
    Result := AngleDeg
  else
    Result := AngleDeg + HostPoint.RealAngle;
end;

function avk_TSkeletTile.HostAngle: Single;
begin
  if HostPoint = nil then
    Result := AngleDeg
  else
    Result := HostPoint.HostAngle;
end;

procedure avk_TSkeletTile.AddSubPoint(const AX: Single; const AY: Single;
  const AA: Single);
begin
  SetLength(SubPoints, CountSubPoints + 1);
  SubPoints[CountSubPoints] := avk_TSkeletTile.Create;
  SubPoints[CountSubPoints].HostPoint := Self;
  SubPoints[CountSubPoints].SetPoint(AX, AY);
  SubPoints[CountSubPoints].TexAngle := AA;
  INC(CountSubPoints, 1);
end;

procedure avk_TSkeletTile.SetTileParameters(ATexX, ATexY, AWigh, AHeight,
  ATexAngle: Single);
begin
  X := ATexX;
  Y := ATexY;
  W := AWigh;
  H := AHeight;
  TexAngle := ATexAngle;
end;

procedure avk_TSkeletTile.SetInternalParameters(const APositionX: Single;
  const APositionY: Single; const AInternalAngle: Single; const AScale: Single;
  const ATextureX: Single; const ATextureY: Single; const ATextureW: Single;
  const ATextureH: Single);
begin
  case TypeOfTile of
    TILE_EMPITY: begin //просто точка
      SetPoint(APositionX, APositionY); //координаты
      TexAngle := AInternalAngle; //угол внутри
    end;
    TILE_TEXTURE: begin //текстура
      SetPoint(APositionX, APositionY); //координаты
      SetTileParameters(ATextureX, ATextureY, ATextureW, ATextureH, AInternalAngle); //параметры текстуры
    end;
    TILE_COOLSPRITE: begin
      SetPoint(APositionX, APositionY); //координаты
      TexAngle := AInternalAngle; //угол внутри
      Scale := AScale; //увеличение
      ProcCoolSprite;
    end;
    TILE_EMITTER: begin
      SetPoint(APositionX, APositionY); //координаты
      TexAngle := AInternalAngle; //угол внутри
      Scale := AScale; //увеличение
      ProcEmitter;
    end;
  end;
end;

procedure avk_TSkeletTile.DrawTexture(APoint: zglTPoint2D; AAngle: Single);
begin
  if Scale <> 0 then
    fx2d_SetScale(Scale, Scale);
  //Всегда от точки поворота
  fx2d_SetRotatingPivot(X * (-1), Y * (-1));
  asprite2d_Draw( Texture, APoint.X + X, APoint.Y + Y, W, H, AAngle + TexAngle, TexFrame, Alpha, FxFlags or FX2D_RPIVOT);
end;

procedure avk_TSkeletTile.DoDraw;
var
  LRP: zglTPoint2D;
  CmpAngle: Single;
  CKL: Integer;
begin
  if not Hide then
    if (Texture <> nil) or (CoolSprite <> nil) or (Emitter <> nil) then begin
      LRP := RealPoint;

      if FTileRotateByHost then
        CmpAngle := HostAngle
      else
        CmpAngle := RealAngle;

      if Emitter <> nil then
         LRP := LRP;

      if Texture <> nil then
        DrawTexture(LRP, CmpAngle)
      else
        inherited DoDraw;
    end;


  for CKL := 0 to CountSubPoints - 1 do begin
    SubPoints[CKL].DoDraw;
  end;

  {$IfDef Debug}
    {$IfDef ShowPoints}
  LRP := RealPoint;
  if HostPoint = nil then
      pr2d_Circle(LRP.X, LRP.Y, 7, $7a250f, 150 ,250, PR2D_FILL)
  else if CountSubPoints > 0 then
      pr2d_Circle(LRP.X, LRP.Y, 6, $7a250f, 150 ,250, PR2D_FILL);
  pr2d_Circle(LRP.X, LRP.Y, 4, $e52b50, 150 ,250, PR2D_FILL);
    {$EndIf}
  if Assigned(FCollizionZone) then
    with FCollizionZone do
      case TypeCollizionZone of
        CZ_CIRCLE: pr2d_Circle(FBufferCircle.cX, FBufferCircle.cY, FBufferCircle.Radius, $e52b50, 150 ,100, PR2D_FILL);
        //CZ_CIRCLE: pr2d_Circle(LRP.X, LRP.Y, FBufferCircle.Radius, $e52b50, 150 ,100, PR2D_FILL);
        CZ_LINE: pr2d_Line(FBufferPoints[0].X, FBufferPoints[0].Y,
                 FBufferPoints[1].X, FBufferPoints[1].Y,
                 $e52b50, 150 , PR2D_FILL);
        CZ_RECTANGLE: pr2d_Rect(FBufferRectangle.X, FBufferRectangle.Y,
                FBufferRectangle.W, FBufferRectangle.H,
                $e52b50, 150 , PR2D_FILL);
      end;
  {$EndIf}
end;

procedure avk_TSkeletTile.DoProc;
var
  CKL: Integer;
begin
  inherited DoProc;
  for CKL := 0 to CountSubPoints - 1 do begin
    SubPoints[CKL].DoProc;
  end;
end;

procedure avk_TSkeletTile.CreateCollizionZone(ARadius: Single);
begin
  FCollizionZone := avk_TCollisionZone.Create(Self);
  FCollizionZone.SetZone(ARadius);
end;

procedure avk_TSkeletTile.CreateCollizionZone(APoint1, APoint2: zglTPoint2D);
begin
  FCollizionZone := avk_TCollisionZone.Create(Self);
  FCollizionZone.SetZone(APoint1, APoint2);
end;

procedure avk_TSkeletTile.CreateCollizionZone(APoint1, APoint2, APoint3,
  APoint4: zglTPoint2D);
begin
  FCollizionZone := avk_TCollisionZone.Create(Self);
  FCollizionZone.SetZone(APoint1, APoint2, APoint3,
  APoint4);
end;

procedure avk_TSkeletTile.CreateCollizionZone(AX, AY, AW, AH: Single);
begin
  FCollizionZone := avk_TCollisionZone.Create(Self);
  FCollizionZone.SetZone(AX, AY, AW, AH);
end;

procedure avk_TSkeletTile.ProcCoolSprite;
var
  LRP: zglTPoint2D;
  CmpAngle: Single;
begin
  if FCoolSprite = nil then Exit;

  LRP := RealPoint;

  if FTileRotateByHost then
    CmpAngle := HostAngle
  else
    CmpAngle := RealAngle;

  if Animate and FHostAnimate then begin
    FCoolSpriteFrame := FCoolSpriteFrame + FCoolSprite^.AnimFPS * 4 / 1000;
    if FCoolSpriteFrame > FCoolSprite^.EndFrame then FCoolSpriteFrame := FCoolSprite^.StartFrame;
    clSprite_Calculate( FCoolSprite, LRP.X, LRP.Y, Scale, CmpAngle + TexAngle, FCoolSpriteFrame );
  end else begin
    FCoolSpriteFrame := FCoolSprite^.EndFrame;
    clSprite_Calculate( FCoolSprite, LRP.X, LRP.Y, Scale, CmpAngle + TexAngle, FCoolSpriteFrame );
  end;
end;

procedure avk_TSkeletTile.ProcEmitter;
var
  LRP: zglTPoint2D;
  CmpAngle: Single;
begin
  if FEmitter = nil then Exit;

  LRP := RealPoint;

  if FTileRotateByHost then
    CmpAngle := HostAngle
  else
    CmpAngle := RealAngle;

  pengine2d_Set( @Fparticles );
  FEmitter.AsPoint.Direction := (CmpAngle + TexAngle) * deg2rad;
  FEmitter.Params.Position.X := LRP.X;
  FEmitter.Params.Position.Y := LRP.Y;
  pengine2d_Proc(RateCadre);
end;


constructor avk_TSkeletTile.Create(AParent: TObject);
begin
  FPoint.X := 0;
  FPoint.Y := 0;
  AngleDeg := 0;
  HostPoint := nil;
  CountSubPoints := 0;
  FTileRotateByHost := true;
  FCollizionZone := nil;
  inherited Create;
  FParent := AParent;
end;

destructor avk_TSkeletTile.Destroy;
var
  CKL: Integer;
begin
  for CKL := 0 to CountSubPoints - 1 do
    SubPoints[CKL].Destroy;
  SetLength(SubPoints, 0);

  if Assigned(FCollizionZone) then FCollizionZone.Destroy;

  inherited Destroy;
end;

