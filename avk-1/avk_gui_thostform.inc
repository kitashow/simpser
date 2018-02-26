
{ avk_THostForm }

procedure avk_THostForm.FSetFileResourses(inNameFile: String);
begin
  if inNameFile = FFileResourses then Exit;
  if not Assigned(FFontManager) then FFontManager := avk_TFontManager.Create(Self);
  if not Assigned(FTextureManager) then FTextureManager := avk_TTextureManager.Create(Self);
  if not Assigned(FSoundManager) then FSoundManager := avk_TSoundManager.Create(Self);
  FFileResourses := inNameFile;
end;

procedure avk_THostForm.FSetModeArhive(inOpen: boolean);
begin
  if inOpen = FArhiveNowOpen then Exit;
  if FileResourses = '' then begin
    {$ifdef DEBUG}
    Raise Exception.Create('Не указано имя файла ресурсов!');
    {$endif}
    Exit;
  end;
  if inOpen then begin
    file_OpenArchive(FileResourses);
  end else begin
    file_CloseArchive();
  end;
  FArhiveNowOpen := inOpen;
end;

{$ifdef ANDROID}
procedure avk_THostForm.Restore;
var
  TmpCkl: integer;
begin
  ArhResNowOpen  := true;
    if Assigned(Texmanager) then
      for TmpCkl:= 0 to Texmanager.Count do begin
        tex_RestoreFromFile( Texmanager.ResList[TmpCkl].Texture, Texmanager.ResList[TmpCkl].FileName );
      end;
    if Assigned(FontManager) then
      for TmpCkl:= 0 to FontManager.Count do begin
        font_RestoreFromFile( FontManager.ResList[TmpCkl].Font, FontManager.ResList[TmpCkl].FileName );
      end;
    //if Assigned(MineForm.SoundManager) then
    //  for TmpCkl:= 0 to MineForm.SoundManager.Count do begin
    //    snd_RestoreFromFile( MineForm.SoundManager.ResList[TmpCkl].Font, MineForm.SoundManager.ResList[TmpCkl].FileName );
    //  end;
  ArhResNowOpen  := false;
end;
{$endif}


procedure avk_THostForm.Draw;
{$IfDef Debug}
var
  Nazata: UTF8String;
  SubNazata: UTF8String;
  NowMouseOnForm: avk_TFraim;
{$EndIf}
begin
  if FGoDraw then
    inherited Draw;
  {$IfDef Debug}
   fx2d_SetVCA( $000000, $000000, $000000, $0000000, 255, 255, 255, 255 );
   Nazata := '';

   Nazata := Nazata + 'Форма: ' + (Self.Name)+', окон: '+u_IntToStr(Count);
   if MouseHost = nil then Nazata := Nazata + ' ' else begin
     NowMouseOnForm := MouseHost;
     SubNazata := '';
     while NowMouseOnForm.Parent <> nil do begin
       SubNazata := '.' + NowMouseOnForm.Name + '[' +  u_IntToStr(NowMouseOnForm.Layer) +  ']' + SubNazata;
       NowMouseOnForm := NowMouseOnForm.Parent;
     end;
     if SubNazata = '' then SubNazata := Self.Name;
     Nazata := 'Форма: ' +  (Self.Name) + SubNazata + ', окон: '+u_IntToStr(MouseHost.Count);
   end;
   Nazata := Nazata + '. FPS: ' + u_IntToStr( zgl_Get( RENDER_FPS )) + ', мыш: '+u_IntToStr(avk_MouseIsX)+':'+ u_IntToStr(avk_MouseIsY);
   if NowPause then begin
     Nazata := Nazata + '. Пауза!';
   end;

   pr2d_Rect( 3, AreaElement.H - 20, AreaElement.W - 6, 16, $FFFFFF, 255, PR2D_FILL );
   pr2d_Rect( 2, AreaElement.H - 21, AreaElement.W - 4, 18, $000000, 255);

   pr2d_Circle( avk_MouseIsX, avk_MouseIsY, 20, $ffcfdb, 130, 32, PR2D_FILL);

   fx2d_SetVCA( $000000, $000000, $000000, $0000000, 255, 255, 255, 255 );
   text_Draw( Font, 9, AreaElement.H - 17, Nazata, TEXT_FX_VCA);
   if MouseHost <> nil then begin
     fx2d_SetVCA( $4c5866, $4c5866, $4c5866, $4c5866, 255, 255, 255, 255 );
     text_DrawInRect( Font, avk_TElement(MouseHost).GetAbsolyteArea, 'Id:'+avk_IntToStr(MouseHost.Id)+', L:'+avk_IntToStr(MouseHost.Layer), TEXT_FX_VCA or TEXT_HALIGN_RIGHT or TEXT_VALIGN_TOP);
   end;
  {$EndIf}
  if TextureCursor <> nil then
    ssprite2d_Draw( TextureCursor, avk_MouseIsX - 16, avk_MouseIsY - 16, 32, 32, 0);

end;

procedure avk_THostForm.intProc;
begin
  inherited intProc;
  FGoDraw := True;
end;

// RU: Т.к. звуковая подсистема нацелена на 3D, для позиционирования звуков в 2D нужны некоторые ухищрения.
function avk_THostForm.CalcX2D( const X : Single ) : Single;
begin
  Result := ( X - AreaElement.W / 2 ) * ( 1 / AreaElement.W / 2 );
end;

function avk_THostForm.CalcY2D( const Y : Single ) : Single;
begin
  Result := ( Y - AreaElement.H / 2 ) * ( 1 / AreaElement.H / 2 );
end;

procedure avk_THostForm.LoadResource(inNameFile, inNameRes: UTF8String);
var
  tmpTex: zglPTexture;
  tmpFont: zglPFont;
  ArhOpenBefore: boolean;
  tmpSnd: zglPSound;
  //TmpHjc: String;
begin
  //TmpHjc := '';
  ArhOpenBefore := ArhResNowOpen;
  if not ArhResNowOpen then ArhResNowOpen := true;
  //TmpHjc := avk_IntToStr(utf8_find(inNameFile,'pt.zfi'));
  //TmpHjc := avk_IntToStr(Pos('pt.zfi',inNameFile));
  if Pos('pt.zfi',inNameFile) > 0 then begin
    tmpFont := font_LoadFromFile(inNameFile);
    FFontManager.AddFont(inNameRes,tmpFont,inNameFile);
  end else begin
    if Pos('.ogg',inNameFile) > 0 then begin
      tmpSnd := snd_LoadFromFile(  inNameFile, 2 );
      FSoundManager.AddSound(inNameRes,tmpSnd,inNameFile);
    end else begin
      tmpTex := tex_LoadFromFile(inNameFile, $FF000000, TEX_DEFAULT_2D);
      FTextureManager.AddTexture(inNameRes,tmpTex,inNameFile);
    end;
  end;
  ArhResNowOpen := ArhOpenBefore;
end;

constructor avk_THostForm.Create(const InParent: avk_TFraim; InName: String);
begin
  FGoDraw := False;
  FFontManager := nil;
  FTextureManager := nil;
  FSoundManager := nil;
  FileResourses := '';
  FArhiveNowOpen:=false;
  TextureCursor := nil;
  inherited Create(InParent,InName);
  BorderStyle := BS_NONE;
end;

destructor avk_THostForm.Destroy;
begin
  if Assigned(FFontManager) then FFontManager.Destroy;
  if Assigned(FTextureManager) then FTextureManager.Destroy;
  if Assigned(FSoundManager) then FSoundManager.Destroy;
  inherited Destroy;
end;

