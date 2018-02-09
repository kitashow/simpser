{ avk_TSimpleInput }

procedure avk_TSimpleInput.DoInspectClick(Sender: TObject);
begin
  if FFocuseNow then begin
    if FlineAlpha > 5 Then DEC( FlineAlpha, 1 ) else FlineAlpha := 255;
    if key_Press( K_ENTER )or key_Press( K_ESCAPE ) Then FocuseNow:=false;
    FTxtBuffer := key_GetText();
  end else begin
    if MouseState = MsoeMouseClick then FocuseNow:=true;
  end;
end;

procedure avk_TSimpleInput.SetCountSymbols(AValue: Integer);
begin
  if FCountSymbols=AValue then Exit;
  if AValue = 0 then  FCountSymbols := 1000 else
    FCountSymbols:=AValue;
end;

procedure avk_TSimpleInput.SetFocuseNow(AValue: boolean);
begin
  if FFocuseNow=AValue then Exit;
  if not AValue then begin
    Text := FTxtBuffer;
    key_EndReadText();
    InputText := nil;
    if Assigned(OnTextDone) then OnTextDone(Self);
  end else begin
    if InputText <> nil then
      if InputText.ClassName = Self.ClassName then
        avk_TSimpleInput(InputText).FocuseNow := false;
    FTxtBuffer := Text;
    InputText := avk_TFraim(Self);
    key_BeginReadText( FTxtBuffer, FCountSymbols );
  end;
  FFocuseNow:=AValue;
end;

procedure avk_TSimpleInput.DoDraw(Sender: TObject);
var
  TmpCapt: String;
  TmpPrintCol: LongWord = $000000;
  TmpWighT: Single;
begin
  if (FTxtBuffer <> '') then
    TmpCapt := FTxtBuffer
    else if Text = '' then begin
      TmpCapt := ShadowCaption;
      TmpPrintCol := FontColour;
    end else TmpCapt := Text;
  if not TransparentBackground then begin
    DrawRect(GetAbsolyteArea,$000000, Transparence, PR2D_SMOOTH);
    if FocuseNow then begin
      DrawRect(GetAbsolyteArea,ColMouseClick,Transparence, PR2D_FILL);
    end else Case MouseState of
      MsoePassive:    DrawRect(GetAbsolyteArea,ColPassive,Transparence, PR2D_FILL);
      MsoeMouseDown:  DrawRect(GetAbsolyteArea,ColMouseDown,Transparence, PR2D_FILL);
      MsoeMouseInArea:DrawRect(GetAbsolyteArea,ColMouseInArea,Transparence, PR2D_FILL);
      MsoeMouseClick: DrawRect(GetAbsolyteArea,ColMouseClick,Transparence, PR2D_FILL);
    end;
    DrawRect(GetAbsolyteArea,$000000,Transparence, PR2D_SMOOTH);
  end;
  if FocuseNow then begin
    TmpWighT := text_GetWidth( Font, TmpCapt );
    if FZglTextFlags and TEXT_HALIGN_CENTER > 0 Then TmpWighT := TmpWighT / 2 + GetAbsolyteArea.W / 2;
    if FZglTextFlags and TEXT_HALIGN_LEFT > 0 Then TmpWighT := TmpWighT + 2;
    pr2d_Rect( GetAbsolyteArea.x + TmpWighT, GetAbsolyteArea.Y + 2, 10, 20, TmpPrintCol, FlineAlpha, PR2D_FILL );
  end;
  fx2d_SetVCA( TmpPrintCol, TmpPrintCol, TmpPrintCol, TmpPrintCol, 255, 255, 255, 255 );
  text_DrawInRect( Font, GetAbsolyteArea, TmpCapt, FZglTextFlags);
end;

constructor avk_TSimpleInput.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  FocuseNow:=false;
  OnProc := DoInspectClick;
  OnDraw := DoDraw;
  TransparentBackground := true;
  FCursorDemo := 0;
  ColPassive := $fffee0;
  ColMouseInArea := $a3d5b2;
  ColMouseDown := $669acc;
  ColMouseClick := $FFFFFF;
  ColPrintText := $4c5866;
  FontColour := $4c5866;
  FZglTextFlags := TEXT_FX_VCA or TEXT_VALIGN_CENTER or TEXT_HALIGN_CENTER;
  FTxtBuffer := '';
  ShadowCaption := InName;
  Text := '';
  FCountSymbols := 250;
  Step       := 0;
  Scale      := 1;
end;

destructor avk_TSimpleInput.Destroy;
begin
  inherited Destroy;
end;

