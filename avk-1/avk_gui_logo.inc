
{ avk_TLogotip }

procedure avk_TLogotip.DoDraw(Sender: TObject);
begin
  if texLogo = nil then Exit;
  if Ftime <= 255 Then
    ssprite2d_Draw( texLogo, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, Ftime )
  else
    if Ftime < 510 Then
      begin
        ssprite2d_Draw( texLogo, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0, 510 - Ftime );
      end
    else
      DeleteMe := true;
end;

procedure avk_TLogotip.DoTimer(Sender: TObject);
begin
  Inc(Ftime,1);
end;

constructor avk_TLogotip.Create(const InParent: avk_TFraim; InName: String);
begin
  texLogo:= nil;
  Ftime := 0;
  inherited Create(InParent,InName);
  OnDraw := DoDraw;
  OnProc := DoTimer;
end;

