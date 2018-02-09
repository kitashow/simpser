{ avk_TSwitchButton }

procedure avk_TSimpleSwitchButton.SetTexButton(AValue: zglPTexture);
begin
  if not (FTexButton = AValue) then FTexButton:=AValue;
  if FTexButton = nil then Exit;
  if AutoDivideTexture then begin
     //куда делим
    if FTexButton.Height > FTexButton.Width then begin
      tex_SetFrameSize( FTexButton, FTexButton.Width, (FTexButton.Height div (CountModesButton*2)) );
    end else begin
      tex_SetFrameSize( FTexButton, (FTexButton.Width  div (CountModesButton*2)), FTexButton.Height );
    end;
  end;
end;

procedure avk_TSimpleSwitchButton.DoDraw(Sender: TObject);
var
  tmpFraimTexture: Word;
  tmpCheckPlus: Integer;
begin
  tmpCheckPlus := 0;
  if not FChecked then tmpCheckPlus := FCountModesButton + 1;

  if FTexButton <> nil then begin
    tmpFraimTexture := tmpCheckPlus;
    if Disable and (CountModesButton > avk_ButtonHas3Modes) then
      tmpFraimTexture := tmpCheckPlus + 3
    else begin
      if (MouseHost = Self) and (CountModesButton > avk_ButtonHas2Modes) then begin
        tmpFraimTexture := tmpCheckPlus + 2;
      end;
      if LastMouseState = MsoeMouseClick then begin
        tmpFraimTexture := tmpCheckPlus + 1;
      end;
    end;
    asprite2d_Draw( FTexButton, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0.0, tmpFraimTexture, Transparence);
  end;
end;

procedure avk_TSimpleSwitchButton.DoInspectClick(Sender: TObject);
begin
  if MouseState = MsoeMouseClick then begin
    FChecked := not FChecked;
    if Assigned(OnClick) then OnClick(Self);
  end;
end;

procedure avk_TSimpleSwitchButton.SetCountModesButton(AValue: Integer);
begin
  if FCountModesButton=AValue then Exit;
  FCountModesButton:=AValue;
  if FCountModesButton < 2 then FCountModesButton := avk_ButtonHas2Modes;
  SetTexButton(FTexButton);
end;

constructor avk_TSimpleSwitchButton.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  OnProc             := DoInspectClick;
  AutoDivideTexture  := true;
  FTexButton         := nil;
  CountModesButton   := avk_ButtonHas3Modes;
  OnDraw             := DoDraw;
  FChecked            := false;
end;

destructor avk_TSimpleSwitchButton.Destroy;
begin
  inherited Destroy;
end;



