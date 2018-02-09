{ avk_TSimpleLabel }

procedure avk_TSimpleLabel.DoInspectClick(Sender: TObject);
begin
  if MouseState = MsoeMouseClick then begin
    if Assigned(OnClick) then OnClick(Self);
  end;
end;

procedure avk_TSimpleLabel.DoDraw(Sender: TObject);
begin
  fx2d_SetVCA( FontColor, FontColor, FontColor, FontColor, 255, 255, 255, 255 );
  text_DrawInRectEx( Font, GetAbsolyteArea, Scale, Step, Caption, 0, FontColor, TEXT_FX_VCA or FZglTextFlags);
end;

constructor avk_TSimpleLabel.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent, InName);
  FCaption              := InName;
  FZglTextFlags         := TEXT_HALIGN_JUSTIFY or TEXT_VALIGN_CENTER;
  OnDraw                := DoDraw;
  OnProc                := DoInspectClick;
  Scale                 := 1;
  Step                  := 0;
end;

destructor avk_TSimpleLabel.Destroy;
begin
  inherited Destroy;
end;

