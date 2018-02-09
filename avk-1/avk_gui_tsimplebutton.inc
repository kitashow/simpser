{ avk_TSimpleButton }

procedure avk_TSimpleButton.DoInspectClick(Sender: TObject);
begin
  if CalkAfterClick > 0 then Inc(CalkAfterClick,1);
  if CalkAfterClick > PauseAfterClick then CalkAfterClick := 0;
  if MouseState = MsoeMouseClick then
    if (CalkAfterClick = 0) then begin
       if Assigned(OnClick) then OnClick(Self);
       Inc(CalkAfterClick,1);
    end;
end;

procedure avk_TSimpleButton.SetCountModesButton(AValue: Integer);
begin
  if FCountModesButton=AValue then Exit;
  FCountModesButton:=AValue;
  if FCountModesButton < 2 then FCountModesButton := 3;
  SetTexButton(FTexButton);
end;

procedure avk_TSimpleButton.SetTexButton(AValue: zglPTexture);
begin
  if not (FTexButton = AValue) then FTexButton:=AValue;
  if FTexButton = nil then Exit;
  if AutoDivideTexture then begin
     //куда делим
    if FTexButton.Height >= FTexButton.Width then begin
      tex_SetFrameSize( FTexButton, FTexButton.Width, (FTexButton.Height div CountModesButton) );
    end else begin
      tex_SetFrameSize( FTexButton, (FTexButton.Width  div CountModesButton), FTexButton.Height );
    end;
  end;
end;

procedure avk_TSimpleButton.CreateGeometric;
var
  TMPRt: zglPRenderTarget;
  InTexture: zglPTexture;
  TmpArea: zglTRect;
  GorizontalStyle: boolean = false;

  procedure SimRect (X,Y:Single;ColW,ColB:LongWord);
  begin
    pr2d_Rect( X, Y, AreaElement.W , AreaElement.H, ColW, 255, PR2D_FILL);
    if BorderStyle = BS_LINE then
      pr2d_Rect( X, Y, AreaElement.W , AreaElement.H, ColB, 255, PR2D_SMOOTH);
  end;

begin
  with TmpArea do begin
    X:=0; Y:=0;
    W := AreaElement.W;
    H := AreaElement.H * CountModesButton;
    GorizontalStyle := false;
    if AreaElement.H < AreaElement.W then begin
       GorizontalStyle := true;
       W := AreaElement.W * CountModesButton;
       H := AreaElement.H;
    end;
  end;
  InTexture := tex_CreateZero(Round(TmpArea.W), Round(TmpArea.H), WallpaperColor, TEX_DEFAULT_2D);
  InTexture := ReloadAsTGA( InTexture );
  TMPRt := rtarget_Add( InTexture, RT_CLEAR_COLOR );
  rtarget_Set( TMPRt );//начали
  if GorizontalStyle then begin
    SimRect (0, 0, NormalCol.FoneColor, NormalCol.BorderColor);
    SimRect (AreaElement.W , 0, SelectCol.FoneColor, SelectCol.BorderColor);
    SimRect (AreaElement.W * 2 , 0, DisableCol.FoneColor, DisableCol.BorderColor);
  end else begin//вертикально
    SimRect (0, 0, WallpaperColor, BorderColor);
    SimRect (0, AreaElement.H , WallpaperColor, BorderColor);
    SimRect (0, AreaElement.H * 2 , WallpaperColor, BorderColor);
  end;
  rtarget_Set( nil );//закончили
  SetTexButton(InTexture);
end;

procedure avk_TSimpleButton.DoDraw(Sender: TObject);
var
  tmpFraimTexture: Word;
begin
  if FTexButton <> nil then begin
    tmpFraimTexture := 1;
    if Disable or (CalkAfterClick > 0) then tmpFraimTexture := 3
    else if MouseHost = Self then tmpFraimTexture := 2;
    asprite2d_Draw( FTexButton, GetAbsolyteArea.X, GetAbsolyteArea.Y, AreaElement.W, AreaElement.H, 0.0, tmpFraimTexture, Transparence);
  end;
end;

procedure avk_TSimpleButton.SetAreaElement(const InX, InY, InW, InH: Single);
begin
  inherited SetAreaElement(InX, InY, InW, InH);
  if not AutoSizeLabel then exit;
  FLabel.SetAreaElement(1,1,AreaElement.W-2,AreaElement.H-2);
end;

constructor avk_TSimpleButton.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  FLabel             := avk_TSimpleLabel.Create(Self,'Текст кнопки');
  FLabel.Caption     := InName;
  FLabel.ZglTextFlags := TEXT_HALIGN_CENTER or TEXT_VALIGN_CENTER;
  FLabel.SetAreaElement(1,1,AreaElement.W-2,AreaElement.H-2);
  FLabel.GetMouse    := false;
  PauseAfterClick    := ClickTimeoutForUnspecial;
  CalkAfterClick     := 0;
  AutoSizeLabel      := true;
  OnProc             := DoInspectClick;
  AutoDivideTexture  := true;
  FTexButton         := nil;
  CountModesButton   := 3;
  OnDraw             := DoDraw;
  //цвета
  with NormalCol do begin
    FoneColor := $66CC99;
    BorderColor := $336633;
    FontColor := $000000;
  end;
  with SelectCol do begin
    FoneColor := $66CCCC;
    BorderColor := $336666;
    FontColor := $000000;
  end;
  with DisableCol do begin
    FoneColor := $99CC99;
    BorderColor := $669933;
    FontColor := $336666;
  end;
end;

destructor avk_TSimpleButton.Destroy;
begin
  inherited Destroy;
end;

