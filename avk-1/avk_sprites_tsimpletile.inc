{ avk_TSimpleTile }


procedure avk_TSimpleTile.stSetTexture(AValue: zglPTexture);
begin
  FTexture := AValue;
  FCoolSprite := nil;
end;

procedure avk_TSimpleTile.stSetCoolSprite(AValue: clPSprite);
begin
  FCoolSprite := AValue;
  FTexture := nil;
end;

procedure avk_TSimpleTile.SetTexFrameSize(AValueW, AValueH: Word);
begin
  tex_SetFrameSize(FTexture, AValueW, AValueH);
end;

procedure avk_TSimpleTile.DoDraw;
begin
  if Hide then Exit; // скрыт
  if (FTexture = nil) and (FCoolSprite = nil) then Exit;
  if not(FTexture = nil) then begin
    if Scale <> 0 then fx2d_SetScale(Scale, Scale);
    asprite2d_Draw( Texture, X, Y, W, H, TexAngle, TexFrame, Alpha, FxFlags );
  end;
  if not(FCoolSprite = nil) then
    clSprite_Draw( FCoolSprite );
end;

procedure avk_TSimpleTile.DoProc;
begin
  if not (FTexture = nil) then begin
    if Animate then begin
      if StopCadre = StartCadre then Exit;//А чего считать то
      INC(CurrentCadreCalk,1);
      if CurrentCadreCalk >= RateCadre then begin
         INC(NowCadre,1);
         if NowCadre >= StopCadre then NowCadre := StartCadre;
         CurrentCadreCalk := 0;
      end;
      TexFrame := NowCadre;
    end
  end;
  if not (FCoolSprite = nil) then begin
    if Animate then begin
      FCoolSpriteFrame := FCoolSpriteFrame + FCoolSprite^.AnimFPS * 4 / 1000;
      if FCoolSpriteFrame > FCoolSprite^.EndFrame then FCoolSpriteFrame := FCoolSprite^.StartFrame;
      clSprite_Calculate( FCoolSprite, X, Y, Scale, TexAngle, FCoolSpriteFrame );
    end else begin
      FCoolSpriteFrame := FCoolSprite^.EndFrame;
      clSprite_Calculate( FCoolSprite, X, Y, Scale, TexAngle, FCoolSpriteFrame );
    end;
  end;
end;

constructor avk_TSimpleTile.Create;
begin
  TexFrame := 1;
  TexAngle := 0;
  Hide    := false;
  X       := 0; Y := 0;
  W       := 0; H := 0;
  Scale   := 0;
  Alpha   := 255;
  FxFlags := FX_BLEND;
  RateCadre := 10;
  CurrentCadreCalk := 0;
  StartCadre := 1;
  StopCadre:=1;
  NowCadre := 1;
  Animate  := true;
  FTexture := nil;
  FCoolSprite := nil;
  FCoolSpriteFrame := 0;
end;

destructor avk_TSimpleTile.Destroy;
begin
  inherited Destroy;
end;

