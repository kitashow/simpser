{ avk_TPanel }

procedure avk_TPanel.SetTexPanel(AValue: zglPTexture);
begin
  if FTexPanel=AValue then Exit;
  FTexPanel:=AValue;
  if FTexPanel = nil then Exit;
  if FAutoDivideTexture then begin
    if FTexPanel.Height > FTexPanel.Width then begin
        tex_SetFrameSize( FTexPanel, FTexPanel.Width div 3, (FTexPanel.Height div FCountModesButton) div 3 );
        FSizeOfBlock.H := FTexPanel.Height div FCountModesButton div 3;
        FSizeOfBlock.W := FTexPanel.Width div 3;
      end else begin
        tex_SetFrameSize( FTexPanel, (FTexPanel.Width  div FCountModesButton) div 3, FTexPanel.Height div 3 );
        FSizeOfBlock.H := FTexPanel.Height div 3;
        FSizeOfBlock.W := FTexPanel.Width  div FCountModesButton div 3;
      end;
    end;
  FTexPanel:=AValue;
end;

procedure avk_TPanel.SetEmpityCentre(AValue: boolean);
begin
  if FEmpityCentre=AValue then Exit;
  FEmpityCentre:=AValue;
end;

procedure avk_TPanel.DoDraw(Sender: TObject);
var
  tmpFraimTexture: Word;
  StepW, StepH: Single;
  HowManyStepW: Single;
  HowManyStepH: Single;
  CKL1,StCKL1: Integer;
  CKL2,StCKL2: Integer;
begin
  tmpFraimTexture := 1;
  if FTexPanel <> nil then begin
    if Disable then tmpFraimTexture := tmpFraimTexture + 18
    else if MouseHost = Self then tmpFraimTexture := tmpFraimTexture + 9;
    //Это только стартовая, теперь обсчитываем по размеру
    HowManyStepW := AreaElement.W / FSizeOfBlock.W;
    if HowManyStepW < 3 then HowManyStepW := 3;
    HowManyStepH := AreaElement.H / FSizeOfBlock.H;
    if HowManyStepH < 3 then HowManyStepH := 3;
    StCKL1 := trunc(HowManyStepH) - 2;
    StCKL2 := trunc(HowManyStepW) - 2;
    //Если размер менее 3 блоков, то 3 и выводим
    StepW := AreaElement.W / trunc(HowManyStepW);
    StepH := AreaElement.H / trunc(HowManyStepH);
    //Верх, низ, лево, право
    asprite2d_Draw( FTexPanel, GetAbsolyteArea.X, GetAbsolyteArea.Y, StepW, StepH, 0.0, tmpFraimTexture, Transparence);//лево верх
    asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + AreaElement.W - StepW, GetAbsolyteArea.Y, StepW, StepH, 0.0, tmpFraimTexture+2, Transparence);//право верх
    asprite2d_Draw( FTexPanel, GetAbsolyteArea.X, GetAbsolyteArea.Y + AreaElement.H - StepH, StepW, StepH, 0.0, tmpFraimTexture+6, Transparence);//лево низ
    asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + AreaElement.W - StepW, GetAbsolyteArea.Y + AreaElement.H - StepH, StepW, StepH, 0.0, tmpFraimTexture+8, Transparence);//право низ
    for CKL2 := 1 to StCKL2 do begin
      asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + StepW * CKL2, GetAbsolyteArea.Y, StepW, StepH, 0.0, tmpFraimTexture+1, Transparence);
      asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + StepW * CKL2, GetAbsolyteArea.Y + AreaElement.H - StepH, StepW, StepH, 0.0, tmpFraimTexture+7, Transparence);
    end;
    for CKL1 := 2 to StCKL1 + 1 do begin
      asprite2d_Draw( FTexPanel, GetAbsolyteArea.X, GetAbsolyteArea.Y + AreaElement.H - StepH * CKL1, StepW, StepH, 0.0, tmpFraimTexture+3, Transparence);
      asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + AreaElement.W - StepW, GetAbsolyteArea.Y + AreaElement.H - StepH * CKL1, StepW, StepH, 0.0, tmpFraimTexture+5, Transparence);
    end;
    if not FEmpityCentre then
      for CKL1 := 1 to StCKL1 do
        for CKL2 := 1 to StCKL2 do begin
          asprite2d_Draw( FTexPanel, GetAbsolyteArea.X + StepW * CKL2, GetAbsolyteArea.Y + StepH * CKL1, StepW, StepH, 0.0, tmpFraimTexture+4, Transparence);
        end;
  end;
end;

constructor avk_TPanel.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  FAutoDivideTexture  := true;
  FTexPanel         := nil;
  with FSizeOfBlock do begin
    X    := 0; Y    := 0;
    H    := 0; W    := 0;
  end;
  OnDraw             := DoDraw;
  FCountModesButton  := 3;
  FEmpityCentre      := false;
end;

destructor avk_TPanel.Destroy;
begin
  inherited Destroy;
end;

