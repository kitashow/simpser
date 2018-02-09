{сортировки по порядку и слою}

function avk_TFraim.GetMaxFID: Integer;
var
  IndMid: Integer;
begin
  Result := 0;
  if (not Assigned(FList)) or (FList = nil) then Exit;
  if Count = 0 then Exit;
  Result := avk_TFraim(FList.Objects[0]).Id;
  for IndMid := 0 to FList.Count - 1 do begin
    if avk_TFraim(FList.Objects[IndMid]).Id > Result then Result := avk_TFraim(FList.Objects[IndMid]).Id;
  end;
end;

function avk_TFraim.GetMinFID: Integer;
var
  IndMid: Integer;
begin
  Result := 0;
  if (not Assigned(FList)) or (FList = nil) then Exit;
  if Count = 0 then Exit;
  Result := avk_TFraim(FList.Objects[0]).Id;
  for IndMid := 0 to FList.Count - 1 do begin
    if avk_TFraim(FList.Objects[IndMid]).Id < Result then Result := avk_TFraim(FList.Objects[IndMid]).Id;
  end;
end;

function avk_TFraim.GetMinLayer: Integer;
var
  IndMid: Integer;
begin
  Result := 0;
  if (not Assigned(FList)) or (FList = nil) then Exit;
  if Count = 0 then Exit;
  Result := avk_TFraim(FList.Objects[0]).Layer;
  for IndMid := 0 to FList.Count - 1 do begin
    if avk_TFraim(FList.Objects[IndMid]).Layer < Result then Result := avk_TFraim(FList.Objects[IndMid]).Layer;
  end;
end;

function avk_TFraim.GetMaxLayer: Integer;
var
  IndMid: Integer;
begin
  Result := 0;
  if (not Assigned(FList)) or (FList = nil) then Exit;
  if Count = 0 then Exit;
  Result := avk_TFraim(FList.Objects[0]).Layer;
  for IndMid := 0 to FList.Count - 1 do begin
    if avk_TFraim(FList.Objects[IndMid]).Layer > Result then Result := avk_TFraim(FList.Objects[IndMid]).Layer;
  end;
end;

procedure avk_TFraim.SortByID(ForLoToHi: boolean = true);
var
  loHren, hiHren: Real;
  ShouldSort, ShouldChange: Boolean;
  AtCur: Integer;
begin
  if (not Assigned(FList)) or (FList = nil) then Exit;//нет подчиненных
  if FList.Count <= 1 then Exit; //нет подчиненных
  loHren := 0; hiHren := 0;
  ShouldSort := true;
  while ShouldSort do begin
    ShouldSort := false;
    for AtCur := 0 to FList.Count - 2 do begin
      ShouldChange := false;
      if (not Assigned(FList.Objects[AtCur])) or (FList.Objects[AtCur] = nil) then begin
        loHren := 0;
      end else begin
        loHren := avk_TFraim(FList.Objects[AtCur]).ID;
      end;
      if (not Assigned(FList.Objects[AtCur+1])) or (FList.Objects[AtCur+1] = nil) then begin
        hiHren := 0;
      end else begin
        hiHren := avk_TFraim(FList.Objects[AtCur+1]).ID;
      end;
      if ForLoToHi then begin
        if loHren > hiHren then ShouldChange := true;
      end else begin
        if loHren < hiHren then ShouldChange := true;
      end;
      if ShouldChange then begin
        FList.Exchange(AtCur,AtCur+1);
        ShouldSort:=true;
      end;
    end;
  end;
end;

procedure avk_TFraim.SortByLayer(ForLoToHi: boolean = true);
var
  lo, hi: Real;
  ShouldSort, ShouldChange: Boolean;
  AtCur: Integer;
begin
  if (not Assigned(FList)) or (FList = nil) then Exit;//нет подчиненных
  if FList.Count <= 1 then Exit; //нет подчиненных ИЛИ НЕ НАДО СОРТИРОВАТЬ
  ShouldSort := true;
  while ShouldSort do begin
    ShouldSort := false;
    for AtCur := 0 to FList.Count - 2 do begin
      ShouldChange := false;
      if (not Assigned(FList.Objects[AtCur])) or (FList.Objects[AtCur] = nil) then begin
        lo := 0;
      end else begin
        lo := avk_TFraim(FList.Objects[AtCur]).Layer;
      end;
      if (not Assigned(FList.Objects[AtCur+1])) or (FList.Objects[AtCur+1] = nil) then begin
        hi := 0
      end else begin
        hi := avk_TFraim(FList.Objects[AtCur+1]).Layer;
      end;
      if ForLoToHi then begin
        if lo < hi then ShouldChange := true;
      end else begin
        if lo > hi then ShouldChange := true;
      end;
      if ShouldChange then begin
        FList.Exchange(AtCur,AtCur+1);
        ShouldSort:=true;
      end;
    end;
  end;
end;
