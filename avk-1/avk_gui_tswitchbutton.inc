{ avk_TSwitchButton }

procedure avk_TSwitchButton.SetTexButton(AValue: zglPTexture);
begin
  if not (FTexButton = AValue) then FTexButton:=AValue;
  if FTexButton = nil then Exit;
  if AutoDivideTexture then begin
     //куда делим
    if FTexButton.Height > FTexButton.Width then begin
      tex_SetFrameSize( FTexButton, FTexButton.Width, (FTexButton.Height div CountModesButton) );
    end else begin
      tex_SetFrameSize( FTexButton, (FTexButton.Width  div CountModesButton), FTexButton.Height );
    end;
  end;
end;

procedure avk_TSwitchButton.DoDraw(Sender: TObject);
var
  tmpFraimTexture: Word;
  tmpCheckPlus: Word;
begin
  tmpFraimTexture := 1;
  if not FChecked then tmpFraimTexture := 4;
  if FTexButton <> nil then begin
    if Disable then tmpFraimTexture := tmpFraimTexture + 2
    else if MouseHost = Self then tmpFraimTexture := tmpFraimTexture + 1;
    asprite2d_Draw( FTexButton, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0.0, tmpFraimTexture, Transparence);
  end;
end;

procedure avk_TSwitchButton.DoInspectClick(Sender: TObject);
begin
  if CalkAfterClick > 0 then Inc(CalkAfterClick,1);
  if CalkAfterClick > PauseAfterClick then CalkAfterClick := 0;
  if MouseState = MsoeMouseClick then begin
    if CalkAfterClick = 0 then begin
       FChecked := not FChecked;
       if Assigned(OnClick) then OnClick(Self);
       Inc(CalkAfterClick,1);
    end;
  end;

end;

procedure avk_TSwitchButton.SetCountModesButton(AValue: Integer);
begin
  if FCountModesButton=AValue then Exit;
  FCountModesButton:=AValue;
  if FCountModesButton < 6 then FCountModesButton := 6;
  SetTexButton(FTexButton);
end;

constructor avk_TSwitchButton.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  PauseAfterClick    := ClickTimeoutForUnspecial;
  CalkAfterClick     := 0;
  OnProc             := DoInspectClick;
  AutoDivideTexture  := true;
  FTexButton         := nil;
  FCountModesButton   := 6;
  OnDraw             := DoDraw;
  FChecked            := false;
end;

destructor avk_TSwitchButton.Destroy;
begin
  inherited Destroy;
end;



