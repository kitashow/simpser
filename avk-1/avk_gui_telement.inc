
{ avk_TElement }

function avk_TElement.GetParentAsElement: avk_TElement;
begin
  Result := nil;
  if not Assigned(Parent) then exit;
  if Parent = nil then exit;
  if not Parent.ClassNameIs('avk_TFraim') then begin
    // по любому будет наследник фрейма
    if Parent is avk_TElement then Result := avk_TElement(Parent);
  end;
end;

procedure avk_TElement.SetTransparence(const InTransp: Byte);
var
   tmpObhod: Integer;
begin
  if FTransparence = InTransp then Exit;
  FTransparence := InTransp;
  for tmpObhod:=0 to Count - 1 do begin
    if GetFraimById(tmpObhod) <> nil then begin
      if not GetFraimById(tmpObhod).ClassNameIs('avk_TFraim') then
        avk_TElement(GetFraimById(tmpObhod)).Transparence := FTransparence;
    end;
  end;
end;

procedure avk_TElement.Draw;
begin
  if Parent = nil then batch2d_Begin();
  if Wallpaper <> nil then ssprite2d_Draw( Wallpaper, GetAbsolyteArea.X, GetAbsolyteArea.Y,
                           AreaElement.W, AreaElement.H, 0, Transparence );
  {$IfDef Debug}
    DrawRect( GetAbsolyteArea, $4c5866, 150, PR2D_SMOOTH);
  {$EndIf}
  inherited Draw;
  if Parent = nil then batch2d_End();
end;

function avk_TElement.GetBorderColor: LongWord;
begin
  Result := 0;
  if FBorderColor = 0 then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.BorderColor;
  end else
    Result := FBorderColor;
end;

function avk_TElement.GetBorderStyle: byte;
begin
  Result := BS_NONE;
  if FBorderStyle = BS_PARENT then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.BorderStyle;
  end else
    Result := FBorderStyle;
end;

function avk_TElement.GetFont: zglPFont;
begin
  Result := nil;
  if FFont = nil then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.Font;
  end else
    Result := FFont;
end;

function avk_TElement.GetFontColor: LongWord;
begin
  Result := $000000;
  if FFontColor = 0 then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.FontColor;
  end else
    Result := FFontColor;
end;

function avk_TElement.GetPositionOnScreen: byte;
begin
  Result := POS_DESIGN;
  if FPositionOnScreen = POS_DESIGN then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.Position;
  end else
    Result := FPositionOnScreen;
end;

function avk_TElement.GetStyleElement: byte;
begin
  Result := 0;
  if FStyleElement = 0 then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.StyleElement;
  end else
    Result := FStyleElement;
end;

function avk_TElement.GetWallpaper: zglPTexture;
begin
  if (FWallpaper = nil) and (FStyleElement = STYLE_GEOMETRIC) then CreateGeometric;
  Result := FWallpaper;
end;

function avk_TElement.GetWallpaperColor: LongWord;
begin
  Result := 0;
  if FWallpaperColor = 0 then begin
    if Self.ParentAsElement <> nil then
      Result := ParentAsElement.WallpaperColor;
  end else
    Result := FWallpaperColor;
end;

procedure avk_TElement.intProc;
begin
  if not Disable then
    if GetMouse then
      if (MouseHost = nil) or (MouseHost = avk_TFraim(Parent)) or (MouseHost = avk_TFraim(self)) then
        LastMouseState := GetMouseState;
  if Parent = nil then begin
    avk_ClearAllStates;
  end;
  inherited intProc;
end;

procedure avk_TElement.SetBorderColor(AValue: LongWord);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  if Assigned(OnChangeStyle) then OnChangeStyle(Self);
end;

procedure avk_TElement.SetBorderStyle(AValue: byte);
begin
  if FBorderStyle = AValue then Exit;
  FBorderStyle := AValue;
  if Assigned(OnChangeStyle) then OnChangeStyle(Self);
end;

procedure avk_TElement.SetDisable(AValue: boolean);
var
   i: Integer;
begin
  if FDisable=AValue then Exit;
  FDisable:=AValue;
  for i := 0 to Count-1 do begin
    if ListNom[i] = nil then Continue;
    if not ListNom[i].ClassNameIs('avk_TFraim') then begin
       avk_TElement(ListNom[i]).Disable := AValue;
    end;
  end;
end;

procedure avk_TElement.SetAreaElement(const InX, InY, InW, InH: Single);
var
  CKL: Integer;
  PrW,PrH: Single;
begin
  if DeleteMe then exit;
  with FAreaElement do begin
    PrW:=W; PrH:=H;
    X := InX; Y := InY; W := InW; H := InH;
  end;
  if Assigned(OnResize) then OnResize(Self);
  for CKL := 0 to Count - 1 do begin
    if ListNom[CKL].DeleteMe then Continue;
    if ListNom[CKL] is avk_TElement then
      if Assigned(avk_TElement(ListNom[CKL]).OnAfterParentResize) then
        avk_TElement(ListNom[CKL]).OnAfterParentResize(Self);
  end;
  if (PrW<>FAreaElement.W) or (PrH<>FAreaElement.H) then begin
    //CreateGeometric;
    if Assigned(OnChangeStyle) then OnChangeStyle(Self);
  end;
end;

procedure avk_TElement.SetAreaElement(const InArea: zglTRect);
begin
  SetAreaElement(InArea.X,InArea.Y,InArea.W, InArea.H);
end;

function avk_TElement.GetAbsolyteArea: zglTRect;
var
   TmpParent: avk_TElement;
begin
  TmpParent:= ParentAsElement;
  if TmpParent = nil then
    with Result do begin
      X := FAreaElement.X; Y := FAreaElement.Y;
      W := FAreaElement.W; H := FAreaElement.H;
      Exit;
    end;
  Result.X := TmpParent.GetAbsolyteArea.X + FAreaElement.X;
  Result.Y := TmpParent.GetAbsolyteArea.Y + FAreaElement.Y;
  Result.W := FAreaElement.W;
  Result.H := FAreaElement.H;
end;

function avk_TElement.GetMouseState: avk_TMouseState;
var
  CanBeHost: Boolean;
begin
  if not avk_MouseInRect( GetAbsolyteArea ) then begin
    Result := MsoePassive;
    HelpInfo.PopUpTime := 0;
    MouseHost := nil;
    Exit;
  end else begin
    CanBeHost := CanBeMouseHost;
    if MouseHost <> nil then
      if MouseHost = avk_TFraim(Self) then begin
        if not CanBeHost then begin //ужжас
          Result := MsoePassive;
          HelpInfo.PopUpTime := 0;
          MouseHost := nil;
          Exit;
        end;
      end;
    if CanBeHost and GetMouse then begin
      MouseHost := avk_TFraim(Self);
    end;
    if MouseHost <> avk_TFraim(Self) then Exit;
    Result := MsoeMouseInArea;
    if  avk_MouseIsDown ( M_BLEFT ) then
      Result := MsoeMouseDown;
    if  avk_MouseIsUp ( M_BLEFT ) then
      Result := MsoeMouseClick;
    if  avk_MouseIsClick ( M_BLEFT ) then
      Result := MsoeMouseClick;
    if  avk_MouseIsDblClick ( M_BLEFT ) then
      Result := MsoeMouseClick;
  end;
end;

function avk_TElement.GetCanBeMouseHost: boolean;
var
  CKL: Integer;
  TmpParent: avk_TElement;
  TmpPrevParent: avk_TElement;

  function AnyBodyHasMouseInChild (InPar: avk_TElement): boolean;
  var
    CKL2: Integer;
  begin
    Result := false;
    for CKL2:= 0 to (InPar.Count - 1) do
      if InPar.ListNom[CKL2] is avk_TElement then
        if avk_MouseInRect( avk_TElement(InPar.ListNom[CKL2]).GetAbsolyteArea ) then
          if InPar.GetMouse then begin
            Result := true;
            Exit;
          end else
            if InPar.ListNom[CKL2].Count > 0 then
              if AnyBodyHasMouseInChild(avk_TElement(InPar.ListNom[CKL2])) then begin
                Result := true;
                Exit;
              end;
  end;

begin
  Result := true;
  //TmpLayer := Layer;
  //соседи
  TmpParent := Self;
  while TmpParent.Parent <> nil do begin
    if not (TmpParent.Parent is avk_TElement) then Break;
    TmpPrevParent := TmpParent;
    TmpParent := TmpParent.ParentAsElement;

    if TmpParent = nil then Continue;

    for CKL:= 0 to (TmpParent.Count - 1) do begin
      if (TmpParent.ListNom[CKL] <> TmpPrevParent) then
        if Assigned(TmpParent.ListNom[CKL]) then //может быть убит в этот момент
          if TmpParent.ListNom[CKL].Layer >= TmpPrevParent.Layer then
            if TmpParent.ListNom[CKL] is avk_TElement then
              if avk_MouseInRect( avk_TElement(TmpParent.ListNom[CKL]).GetAbsolyteArea ) then
                if avk_TElement(TmpParent.ListNom[CKL]).GetMouse then begin
                  Result := false;
                  Exit;//кто то из соседей перехватил
                end else if TmpParent.ListNom[CKL].Count > 0 then
                  //у соседа тоже ж дети
                  if AnyBodyHasMouseInChild(avk_TElement(TmpParent.ListNom[CKL])) then begin
                    Result := false;
                    Exit;//кто то из детей соседей перехватил
                  end;
    end;
  end;
end;

procedure avk_TElement.SetFont(AValue: zglPFont);
begin
  if FFont = AValue then Exit;
  {$IFDEF DEBUG}
  //Перерисовать если был 0
  if (Font = nil) and (AValue <> nil) and (StyleElement = STYLE_GEOMETRIC) then begin
    Wallpaper := nil;
    CreateGeometric;
  end;
  {$ENDIF}
  FFont := AValue;
  if Assigned(OnChangeStyle) then OnChangeStyle(Self);
end;

procedure avk_TElement.SetPositionOnScreen(AValue: byte);
var
  PrevPar: Single;
begin
  if FPositionOnScreen=AValue then Exit;
  case FPositionOnScreen of
    POS_BOTTOM, POS_TOP: PrevPar:= AreaElement.H;
    POS_LEFT, POS_RIGHT: PrevPar:= AreaElement.W;
  end;
  FPositionOnScreen:=AValue;
  if FPositionOnScreen <> POS_DESIGN then begin
    case FPositionOnScreen of
      POS_BOTTOM, POS_TOP: SetAreaElement(0,AreaElement.Y,PrevPar,PrevPar);
      POS_LEFT, POS_RIGHT: SetAreaElement(0,AreaElement.Y,PrevPar,PrevPar);
    end;
  end;
  if Assigned(OnChangeStyle) then OnChangeStyle(Self);
end;

procedure avk_TElement.CreateGeometric;
var
  TMPRt: zglPRenderTarget;
  InTexture: zglPTexture;
begin
  if FWallpaperWasSettingManual then Exit;
  FStyleElement := STYLE_GEOMETRIC;
  InTexture := tex_CreateZero(Round(AreaElement.W), Round(AreaElement.H), WallpaperColor, TEX_DEFAULT_2D);
  InTexture := ReloadAsTGA( InTexture );
  TMPRt := rtarget_Add( InTexture, RT_CLEAR_COLOR );
  rtarget_Set( TMPRt );//начали
  pr2d_Rect( 0, 0, AreaElement.W , AreaElement.H, WallpaperColor, 255, PR2D_FILL);
  pr2d_Rect( 0, 0, AreaElement.W , AreaElement.H, BorderColor, 255, PR2D_SMOOTH);
  {$IFDEF DEBUG}
  fx2d_SetVCA( FontColor, FontColor, FontColor, FontColor, 255, 255, 255, 255 );
  text_DrawInRect( Font, AreaElement, Name, TEXT_FX_VCA or TEXT_VALIGN_CENTER or TEXT_HALIGN_CENTER);
  {$ENDIF}
  rtarget_Set( nil );//закончили
  FWallpaper := InTexture;
end;

procedure avk_TElement.SetStyleElement(AValue: byte);
begin
  if FStyleElement = AValue then Exit;
  FStyleElement := AValue;
  if Assigned(OnChangeStyle) then OnChangeStyle(Self);
end;

procedure avk_TElement.SetWallpaper(AValue: zglPTexture);
begin
  if AValue = FWallpaper then Exit;
  if (not FWallpaperWasSettingManual) and (FStyleElement = STYLE_GEOMETRIC) then
    tex_Del(FWallpaper);
  FWallpaper := AValue;
  FWallpaperWasSettingManual := true;
end;

constructor avk_TElement.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent);
  Name := InName;
  SetAreaElement(0,0,100,50);
  Transparence := 255;
  FWallpaper := nil;
  FFontColor := 0;
  FStyleElement := STYLE_DESIGN;//родителя
  FPositionOnScreen := POS_DESIGN;//родителя
  FWallpaperColor := 0;//родителя
  FBorderColor := 0;//родителя
  FBorderStyle := BS_PARENT;//родителя
  GetMouse := true;
  if Parent = nil then
    SetAreaElement(0,0,scrViewportW,scrViewportH);
  PopUpWait := PopUpWaitForUnspecial;
  Font := nil;
  OnResize := nil;
  FWallpaperWasSettingManual := false;
end;

destructor avk_TElement.Destroy;
begin
  inherited Destroy;
end;

