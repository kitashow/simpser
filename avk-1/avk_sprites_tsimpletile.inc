{ avk_TSimpleTile }

procedure avk_TSimpleTile.DoDraw;
begin
  if Texture = nil then Exit;
  if Hide then Exit; // скрыт
  if Scale <> 0 then fx2d_SetScale(Scale, Scale);
  asprite2d_Draw( Texture, X, Y, W, H, TexAngle, TexFrame, Alpha, FxFlags );
end;

procedure avk_TSimpleTile.DoProc;
begin
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

constructor avk_TSimpleTile.Create;
begin
  Texture := nil;
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
end;

destructor avk_TSimpleTile.Destroy;
begin
  inherited Destroy;
end;

