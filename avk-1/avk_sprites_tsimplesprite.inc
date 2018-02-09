
{ avk_TSimpleSprite }

procedure avk_TSimpleSprite.FSetAngle(AValue: Single);
var
  CKL: Integer;
  PAngle: Single;
begin
  if FAngle = AValue then Exit;
  FAngle := AValue;

  if AdditionalPoints.Count > 0 then
    for CKL := 0 to AdditionalPoints.Count - 1 do
      avk_TAdditionalPoint(AdditionalPoints.Objects[CKL]).Angle := AValue;

  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.FSetCPX(AValue: Single);
begin
  FCentralPoint.X := AValue;
  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.FSetCPY(AValue: Single);
begin
  FCentralPoint.Y := AValue;
  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.SetSquarePoint(InX, InY: Single);
begin
  FSquarePoint.X := InX;
  FSquarePoint.Y := InY;
  FRotationPivot := true;
  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.SetScaleWH(AScaleW, AScaleH: Single); //задать масштаб по ширине и высоте
begin
  FWighHeghtScale.X := AScaleW;
  FWighHeghtScale.Y := AScaleH;
  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle, ASquareX, ASquareY: Single); overload;
begin
  FCentralPoint.X := ACentralX;
  FCentralPoint.Y := ACentralY;
  FWighHeght.X := AWigh;
  FWighHeght.Y := AHeight;
  FSetAngle(AAngle);
  SetSquarePoint(ASquareX, ASquareY);
  FCalkRealPoint;
end;

procedure avk_TSimpleSprite.SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle: Single); overload;
var
  ASquareX, ASquareY: Single;
begin
  ASquareX := -AWigh / 2;
  ASquareY := -AHeight / 2;
  SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle, ASquareX, ASquareY);
  FRotationPivot := false;
end;

function avk_TSimpleSprite.FGetX: Single;
begin
  Result := FCentralPoint.X + FSquarePoint.X;
end;

function avk_TSimpleSprite.FGetY: Single;
begin
  Result := FCentralPoint.Y + FSquarePoint.Y;
end;

function avk_TSimpleSprite.FGetW: Single;
begin
  Result := FWighHeght.X;
end;

function avk_TSimpleSprite.FGetH: Single;
begin
  Result := FWighHeght.Y;
end;


function avk_TSimpleSprite.GetRotatePoints: avk_TRotate4Points;
begin
  if IsRotatingPivot then
    Result := avk_GetRotatePoints(FRPS.X, FRPS.Y, FRPS.RotatingPivot.X * 2, FRPS.RotatingPivot.Y * 2, Angle)
  else
    Result := avk_GetRotatePoints(FRPS.X, FRPS.Y, FRPS.W, FRPS.H, Angle);
end;


procedure avk_TSimpleSprite.FCalkRealPoint;
var
  PR: avk_TSimpleSprite;
  PRS: avk_TSkeletSprite;
begin
  FRPS.Angle := FAngle;
  FRPS.CPX := FCentralPoint.X * FWighHeghtScale.X;
  FRPS.CPY := FCentralPoint.Y * FWighHeghtScale.Y;

  if Parent is avk_TSimpleSprite then begin
    PR := avk_TSimpleSprite(Parent);
    FRPS.Angle := FAngle + PR.FRPS.Angle;
    FRPS.CPX := PR.FRPS.CPX + FRPS.CPX;
    FRPS.CPY := PR.FRPS.CPY + FRPS.CPY;
  end;

  if Parent is avk_TSkeletSprite then begin
    PRS := avk_TSkeletSprite(Parent);
    FRPS.Angle := FAngle + PRS.Angle;
    FRPS.CPX := PRS.X + FRPS.CPX;
    FRPS.CPY := PRS.Y + FRPS.CPY;
  end;


  FRPS.RotatingPivot.X := -FSquarePoint.X * FWighHeghtScale.X;
  FRPS.RotatingPivot.Y := -FSquarePoint.Y * FWighHeghtScale.Y;
  FRPS.X := X * FWighHeghtScale.X;
  FRPS.Y := Y * FWighHeghtScale.Y;
  FRPS.W := FWighHeght.X * FWighHeghtScale.X;
  FRPS.H := FWighHeght.Y * FWighHeghtScale.Y;
  FRPS.TexAngle := FRPS.Angle + FTexAngle;

  if CollisionZone <> nil then begin
    FRPS.CollisionZone.Centre := avk_GetRotatePoint(CollisionZone^.Centre.X, CollisionZone^.Centre.Y, FRPS.Angle);
    FRPS.CollisionZone.Centre.X := FRPS.CPX + (FRPS.CollisionZone.Centre.X * FWighHeghtScale.X);
    FRPS.CollisionZone.Centre.Y := FRPS.CPY + (FRPS.CollisionZone.Centre.Y * FWighHeghtScale.Y);
    FRPS.CollisionZone.Radius := CollisionZone^.Radius * max(FWighHeghtScale.Y, FWighHeghtScale.X);
  end;
end;

function avk_TSimpleSprite.GetAdditionalPointByName(AName: String): avk_TAdditionalPoint;
var
  Number: Integer;
begin
  Number := -1;
  if not AdditionalPoints.Find(AName, Number) then
    Result := nil
  else
    Result := avk_TAdditionalPoint(AdditionalPoints.Objects[Number]);
end;

function avk_TSimpleSprite.GetRealAdditionalPointByName(AName : String): zglTPoint2D;
var
  TmpObj: avk_TAdditionalPoint;
begin
  Result.X := 0;
  Result.Y := 0;

  TmpObj := GetAdditionalPointByName(AName);
  if not (TmpObj = nil) then begin
    Result.X := FRPS.CPX + (TmpObj.X * FWighHeghtScale.X);
    Result.Y := FRPS.CPY + (TmpObj.Y * FWighHeghtScale.Y);
  end;

end;


procedure avk_TSimpleSprite.AddAdditionalPoint(Name: String; INX, INY: Single);
var
  NAP: avk_TAdditionalPoint;
begin
  NAP := avk_TAdditionalPoint.Create;
  NAP.X := INX;
  NAP.Y := INY;
  AdditionalPoints.AddObject(Name, NAP);
end;

procedure avk_TSimpleSprite.SetCollisionZone(X, Y, Radius: Single);
var
   NCZ: avk_TCircleCollisionZone;
begin
  if CollisionZone = nil then begin
    New(CollisionZone);
  end;
  CollisionZone^.Centre.X := X;
  CollisionZone^.Centre.Y := Y;
  CollisionZone^.Radius := Radius;
end;


procedure avk_TSimpleSprite.DoDraw(Sender: TObject);
{$IfDef Debug}
  var
    p: avk_TRotate4Points;
    RealAddPnt: zglTPoint2D;
    CKL: Integer;
{$EndIf}
begin
  if Texture = nil then Exit;
  if Hide then Exit; // скрыт
  if Scale <> 0 then fx2d_SetScale(Scale, Scale);

  {$IfDef Debug}
    if Angle = 0 then begin
      pr2d_Rect( FRPS.X, FRPS.Y, FRPS.W, FRPS.H, $4c5866, 150, PR2D_SMOOTH);
    end else begin
      p := GetRotatePoints;
      pr2d_Line( p[0].X, p[0].Y, p[1].X, p[1].Y, $4c5866, 150, PR2D_SMOOTH);
      pr2d_Line( p[1].X, p[1].Y, p[2].X, p[2].Y, $4c5866, 150, PR2D_SMOOTH);
      pr2d_Line( p[2].X, p[2].Y, p[3].X, p[3].Y, $4c5866, 150, PR2D_SMOOTH);
      pr2d_Line( p[0].X, p[0].Y, p[3].X, p[3].Y, $4c5866, 150, PR2D_SMOOTH);
    end;
    if CollisionZone <> nil then
      pr2d_Circle(FRPS.CollisionZone.Centre.X, FRPS.CollisionZone.Centre.Y, FRPS.CollisionZone.Radius, $4c5866, 150 ,250, PR2D_FILL);
  {$EndIf}

  if FRotationPivot then begin
    fx2d_SetRotatingPivot(FRPS.RotatingPivot.X, FRPS.RotatingPivot.Y);
    asprite2d_Draw( Texture, FRPS.X, FRPS.Y, FRPS.W, FRPS.H, FRPS.TexAngle, TexFrame, Alpha, FxFlags or FX2D_RPIVOT);
  end else begin
    asprite2d_Draw( Texture, FRPS.X, FRPS.Y, FRPS.W, FRPS.H, FRPS.TexAngle, TexFrame, Alpha, FxFlags );
  end;

  {$IfDef Debug}
    {$IfDef ShowPoints}
    //точка центр спрайта
    pr2d_Circle(CPX, CPY, 5, $e52b50, 150 ,250, PR2D_FILL); //розовая
    //дополнительные точки
    if AdditionalPoints.Count > 0 then
      for CKL := 0 to AdditionalPoints.Count - 1 do begin
        RealAddPnt := GetRealAdditionalPointByName(AdditionalPoints.Strings[CKL]);
        pr2d_Circle(RealAddPnt.X, RealAddPnt.Y, 5, $32CD32, 150 ,250, PR2D_FILL); //зеленая
      end;
    {$EndIf}
  {$EndIf}
end;

procedure avk_TSimpleSprite.DoProc(Sender: TObject);
begin
  if Assigned(FOnBeforeProc) then FOnBeforeProc(Self);
  if Animate then begin
    if StopCadre = StartCadre then Exit;//А чего считать то
    INC(CurrentCadreCalk,1);
    if CurrentCadreCalk >= RateCadre then begin
       INC(NowCadre,1);
       if NowCadre >= StopCadre then NowCadre := StartCadre;
       CurrentCadreCalk := 0;
    end;
    TexFrame := NowCadre;
  end;
  if Assigned(FOnAfterProc) then FOnAfterProc(Self);
end;

constructor avk_TSimpleSprite.Create(const InParent: avk_TFraim; InName: String);
var
  PrevLen: Integer;
  function emppnt: zglTPoint2D;
  begin
    Result.X:=0;
    Result.Y:=0;
  end;

begin
  inherited Create(InParent);
  Name := InName;
  Texture := nil;
  TexFrame := 1;
  FTexAngle := 0;

  SetParameters(0, 0, 2, 2, 0);

  FWighHeghtScale.X := 1;
  FWighHeghtScale.Y := 1;

  Hide    := false;
  Scale   := 0;
  Alpha   := 255;
  FxFlags := FX_BLEND;
  RateCadre := 10;
  CurrentCadreCalk := 0;
  StartCadre := 1;
  StopCadre:=1;
  NowCadre := 1;
  Animate  := true;
  OnDraw := DoDraw;
  OnProc := DoProc;
  CollisionZone := nil;
  AdditionalPoints := TStringList.Create;
  AdditionalPoints.Sorted := true;
end;

destructor avk_TSimpleSprite.Destroy;
var
  CKL: Integer;
  APoint: TObject;

begin
  if AdditionalPoints.Count > 0 then
    for CKL := 0 to AdditionalPoints.Count - 1 do begin
      APoint := AdditionalPoints.Objects[CKL];
      FreeAndNil(APoint);
    end;
  AdditionalPoints.Destroy;
  Dispose(CollisionZone);
  inherited Destroy;
end;                                                                      
