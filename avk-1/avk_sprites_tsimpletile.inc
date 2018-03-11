{ avk_TSimpleTile }


procedure avk_TSimpleTile.stSetTexture(AValue: zglPTexture);
begin
  FTexture := AValue;
  FCoolSprite := nil;
  FEmitter := nil;
  FTypeOfTile := TILE_TEXTURE;
  FDrawRealisation := DrawTexture;
  FProcRealisation := ProcTexture;
end;

procedure avk_TSimpleTile.stSetCoolSprite(AValue: clPSprite);
begin
  FCoolSprite := AValue;
  FTexture := nil;
  FEmitter := nil;
  FTypeOfTile := TILE_COOLSPRITE;
  FDrawRealisation := DrawCoolSprite;
  FProcRealisation := ProcCoolSprite;
end;

procedure avk_TSimpleTile.stSetEmitter(AValue: zglPEmitter2D);
begin
  pengine2d_Set( @Fparticles );
  pengine2d_AddEmitter(AValue, @FEmitter, X + trunc(W / 2), Y + trunc(H / 2));
  FCoolSprite := nil;
  FTexture := nil;
  FTypeOfTile := TILE_EMITTER;
  FDrawRealisation := DrawEmitter;
  FProcRealisation := ProcEmitter;
end;

procedure avk_TSimpleTile.FSetFrame(AValue: Word);
begin
  if not(FCoolSprite = nil) then
    FCoolSpriteFrame := AValue
  else
    TexFrame := AValue;
end;

function avk_TSimpleTile.FReadFrame: Word;
begin
  if not(FCoolSprite = nil) then
    Result := round(FCoolSpriteFrame)
  else
    Result := TexFrame;
end;


procedure avk_TSimpleTile.SetTexFrameSize(AValueW, AValueH: Word);
begin
  tex_SetFrameSize(FTexture, AValueW, AValueH);
end;

procedure avk_TSimpleTile.DrawTexture;
begin
  if not(FTexture = nil) then begin
    if Scale <> 0 then fx2d_SetScale(Scale, Scale);
    asprite2d_Draw( Texture, X, Y, W, H, TexAngle, TexFrame, Alpha, FxFlags );
  end;
end;

procedure avk_TSimpleTile.DrawEmitter;
{$IfDef Debug}
var
  i: Integer;
{$EndIf}
begin
  if Assigned(FEmitter) then begin
    pengine2d_Set( @Fparticles );
    pengine2d_Draw();
    {$IfDef Debug}
    for i := 0 to FParticles.Count.Emitters - 1 do
      with FParticles.List[ i ].BBox do
        pr2d_Rect( MinX, MinY, MaxX - MinX, MaxY - MinY, $FF0000, 255 );
    {$EndIf}
  end;
end;

procedure avk_TSimpleTile.DrawCoolSprite;
begin
  if not(FCoolSprite = nil) then
    clSprite_Draw( FCoolSprite );
end;

procedure avk_TSimpleTile.DoDraw;
begin
  if Hide then Exit; // скрыт
  if (FTexture = nil) and (FCoolSprite = nil) and (FEmitter = nil) then Exit;
  FDrawRealisation;
end;

procedure avk_TSimpleTile.ProcTexture;
begin
  if FTexture = nil then Exit;
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
end;

procedure avk_TSimpleTile.ProcEmitter;
begin
  if Assigned(FEmitter) then begin
    pengine2d_Set( @Fparticles );
    FEmitter.AsLine.Direction := TexAngle;
    FEmitter.Params.Position.X := X + trunc(W / 2);
    FEmitter.Params.Position.Y := Y + trunc(H / 2);
    pengine2d_Proc(RateCadre);
  end;
end;

procedure avk_TSimpleTile.ProcCoolSprite;
begin
  if FCoolSprite = nil then Exit;
  if Animate then begin
    FCoolSpriteFrame := FCoolSpriteFrame + FCoolSprite^.AnimFPS * 4 / 1000;
    if FCoolSpriteFrame > FCoolSprite^.EndFrame then FCoolSpriteFrame := FCoolSprite^.StartFrame;
    clSprite_Calculate( FCoolSprite, X + trunc(W / 2), Y + trunc(H / 2), Scale, TexAngle, FCoolSpriteFrame );
  end else begin
    FCoolSpriteFrame := FCoolSprite^.EndFrame;
    clSprite_Calculate( FCoolSprite, X + trunc(W / 2), Y + trunc(H / 2), Scale, TexAngle, FCoolSpriteFrame );
  end;
end;

procedure avk_TSimpleTile.DrawNothing;
begin
  //заглушка
end;

procedure avk_TSimpleTile.ProcNothing;
begin
  //заглушка
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
  FEmitter := nil;
  FTypeOfTile := TILE_EMPITY;
  FCoolSpriteFrame := 0;
  FProcRealisation := ProcNothing;
  FDrawRealisation := DrawNothing;
end;

destructor avk_TSimpleTile.Destroy;
begin
  //if Assigned(FCoolSprite) then Dispose(FCoolSprite);
  if FTypeOfTile = TILE_EMITTER then begin
    pengine2d_Set( @FParticles );
    pengine2d_ClearAll();
  end;
  inherited Destroy;
end;

