{ avk_TCircleButton }

procedure avk_TCircleButton.CreateGeometric;
var
  TMPRt: zglPRenderTarget;
  InTexture: zglPTexture;
  TmpArea: zglTRect;
  GorizontalStyle: boolean = false;

  procedure SimRect (X,Y:Single;ColW,ColB:LongWord);
  begin
    pr2d_Ellipse( X + AreaElement.W / 2, Y + AreaElement.H / 2, AreaElement.W / 2 - 1 , AreaElement.H / 2 - 1, ColW, 255,32, PR2D_FILL);
    if BorderStyle = BS_LINE then
    pr2d_Ellipse( X + AreaElement.W / 2, Y + AreaElement.H / 2, AreaElement.W / 2 - 1 , AreaElement.H / 2 - 1, ColB, 255,32, PR2D_SMOOTH);
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
    SimRect (AreaElement.W, 0, SelectCol.FoneColor, SelectCol.BorderColor);
    SimRect (AreaElement.W * 2, 0, DisableCol.FoneColor, DisableCol.BorderColor);
  end else begin//вертикально
    SimRect (0, 0, NormalCol.FoneColor, NormalCol.BorderColor);
    SimRect (0, AreaElement.H, SelectCol.FoneColor, SelectCol.BorderColor);
    SimRect (0, AreaElement.H * 2, DisableCol.FoneColor, DisableCol.BorderColor);
  end;
  rtarget_Set( nil );//закончили
  SetTexButton(InTexture);
end;

procedure avk_TCircleButton.DoInspectClick(Sender: TObject);
begin

end;

