{ avk_TSkeletPoint }

function avk_TSkeletPoint.GetAngle: Single;
begin
  Result := FAngle;
  if not (Host = nil) then
    Result := Result + Host.Angle;
end;

procedure avk_TSkeletPoint.SetAngle(AValue: Single);
begin
  if FAngle=AValue then Exit;
  FAngle := AValue;
  Calk;
end;

procedure avk_TSkeletPoint.Calk;
var
  ckl: Integer;
begin
  FCalkPoint := StartPoint;

  FCalkPoint.X := FCalkPoint.X * WighHeghtScale.X;
  FCalkPoint.Y := FCalkPoint.Y * WighHeghtScale.Y;

  if not (Host = nil) then begin
    FCalkPoint := avk_GetRotatePoint(StartPoint.X, StartPoint.Y, Host.Angle);
    FCalkPoint.X := Host.X + FCalkPoint.X;
    FCalkPoint.Y := Host.Y + FCalkPoint.Y;
  end;

  if Count > 0 then begin
    for ckl := 0 to Count - 1 do
      if ListNom[ckl] is avk_TSkeletPoint then begin
          avk_TSkeletPoint(ListNom[ckl]).Calk;
      end;
  end;
end;

{$IfDef Debug}
procedure avk_TSkeletPoint.DoAfterDraw(Sender: TObject);
begin
    {$IfDef ShowPoints}
    if Host = nil then
        pr2d_Circle(X, Y, 7, $7a250f, 150 ,250, PR2D_FILL)
    else if Count > 0 then
        pr2d_Circle(X, Y, 6, $7a250f, 150 ,250, PR2D_FILL);

    pr2d_Circle(X, Y, 5, $e52b50, 150 ,250, PR2D_FILL);
    {$EndIf}
end;
{$EndIf}

constructor avk_TSkeletPoint.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  Host := nil;
  FAngle := 0;
  WighHeghtScale.X := 1;
  WighHeghtScale.Y := 1;
  {$IfDef Debug}
  OnFinishDraw := DoAfterDraw;
  {$EndIf}
end;

destructor avk_TSkeletPoint.Destroy;
begin
  inherited Destroy;
end;

{ avk_TSkeletSprite }

procedure avk_TSkeletSprite.SetSprite(InName: Utf8String; InTexture: zglPTexture;
      InFrameWidth: Word; InFrameHeight: Word;
      ACentralX: Single = 0; ACentralY: Single = 0;
      AWigh: Single = 0; AHeight: Single = 0;
      AAngle: Single = 0; ASquareX: Single = 0;
      ASquareY: Single = 0;
      StopCadre: Integer = 0; RateCadre: Integer = 0);
begin
  if not (Sprite = nil) then begin
      while Assigned(Sprite) do
        Sprite.DeleteMe := true;
      Sprite := nil;
  end;

  if InName = '' then Exit;

  Sprite := avk_TSimpleSprite.Create(Self, InName);
  Sprite.Texture := InTexture;
  if not((InFrameWidth = 0) and (InFrameHeight = 0)) then
    tex_SetFrameSize( Sprite.Texture, InFrameWidth, InFrameHeight);

  Sprite.SetParameters(ACentralX, ACentralY, AWigh, AHeight, AAngle, ASquareX, ASquareY);

  Sprite.StopCadre := StopCadre;
  Sprite.RateCadre := RateCadre;
  Sprite.SetScaleWH(WighHeghtScale.X, WighHeghtScale.Y);
end;

constructor avk_TSkeletSprite.Create(const InParent: avk_TFraim; InName: Utf8String; InSx: Single = 0; InSy: Single = 0; InSprite: avk_TSimpleSprite = nil);
begin
  inherited Create(InParent, InName);
  if InParent is avk_TSkeletPoint then
      Host := avk_TSkeletPoint(InParent);
  StartPoint.X := InSx;
  StartPoint.Y := InSy;
  Sprite := InSprite;
end;

destructor avk_TSkeletSprite.Destroy;
begin
  inherited Destroy;
end;

