type
  zglTTGAHeader = packed record
    IDLength  : Byte;
    CPalType  : Byte;
    ImageType : Byte;
    CPalSpec  : packed record
      FirstEntry : Word;
      Length     : Word;
      EntrySize  : Byte;
                end;
    ImgSpec   : packed record
      X      : Word;
      Y      : Word;
      Width  : Word;
      Height : Word;
      Depth  : Byte;
      Desc   : Byte;
                end;
end;

function ReloadAsTGA( Texture : zglPTexture): zglPTexture;
var
    tga  : zglTTGAHeader; //zglTTGAHeader;
    f    : zglTFile;
    data : Pointer;
    StreamMem: TMemoryStream;
    memory : zglTMemory;
begin
  FillChar( tga, SizeOf( zglTTGAHeader ), 0 );
  tga.ImageType      := 2;
  tga.ImgSpec.Width  := Texture.Width;
  tga.ImgSpec.Height := Texture.Height;
  tga.ImgSpec.Depth  := 32;
  tga.ImgSpec.Desc   := 8;

  tex_GetData( Texture, data );
  StreamMem := TMemoryStream.Create;
  StreamMem.SetSize(SizeOf( zglTTGAHeader ) + Texture.Width * Texture.Height * 4);
  StreamMem.WriteBuffer(tga, SizeOf( zglTTGAHeader ));
  StreamMem.WriteBuffer(data^,Texture.Width * Texture.Height * 4);
  memory.Position := 0;
  memory.Memory   := StreamMem.Memory;
  memory.Size     := StreamMem.Size;
  Result := tex_LoadFromMemory( memory, 'TGA' );
  StreamMem.Free();
  zgl_FreeMem( data );
end;

function avk_Trim( Value : UTF8String ) : UTF8String;
var
   TmpStep: Integer;
   SubStr: UTF8String;
begin
  Result := Value;
  SubStr := ' ';
  for TmpStep:= 1 to (utf8_Length(Result) - utf8_Length(SubStr)) do begin
    if SubStr = utf8_Copy(Result, TmpStep, utf8_Length(SubStr)) then begin
      utf8_Delete(Result,TmpStep,1);
      Continue;
    end else Break;
  end;
  for TmpStep:= (utf8_Length(Result) - utf8_Length(SubStr)) downto 1 do begin
    if SubStr = utf8_Copy(Result, TmpStep, utf8_Length(SubStr)) then begin
      utf8_Delete(Result,TmpStep,1);
      Continue;
    end else Break;
  end;
end;

function GetMilliseconds: Double;
{$IFDEF WINDOWS}
var
  t : int64;
  m : LongWord;
  timerFrequency : Int64 = 1;
  timerFreq      : Single;
{$ENDIF}
{$IFDEF LINUX}
var
timerTimeVal : TimeVal;
{$ENDIF}

begin
  {$IFDEF LINUX}
  fpGetTimeOfDay( @timerTimeVal, nil );
  {$Q-}
  // FIXME: почему-то overflow вылетает с флагом -Co
  Result := timerTimeVal.tv_sec * 1000 + timerTimeVal.tv_usec / 1000;
  {$Q+}
  {$ENDIF}
  {$IFDEF WINDOWS}
  m := SetThreadAffinityMask( GetCurrentThread(), 1 );
  QueryPerformanceFrequency( timerFrequency );
  timerFreq := 1 / timerFrequency;
  QueryPerformanceCounter( t );
  Result := 1000 * t * timerFreq;
  SetThreadAffinityMask( GetCurrentThread(), m );
  {$ENDIF}
  {$IFDEF DARWIN}
  Result := mach_absolute_time() * timerTimebaseInfo.numer / timerTimebaseInfo.denom / 1000000;
  {$ENDIF}
end;

function IdentRect(const FrRect, ScRect: zglTRect): boolean;
begin
  Result := (FrRect.X = ScRect.X) and (FrRect.Y = ScRect.Y)
            and (FrRect.W = ScRect.W) and (FrRect.H = ScRect.H);
end;




//procedure GenerateErrorWindows(InCaption, InMessage: String;
//  InParent: avk_TFraim = nil; inImgError: zglPTexture = nil);
//var
//  TmpErrorW: TErrorWind;
//begin
//  TmpErrorW := TErrorWind.Create(avk_TElement(InParent),InCaption,inImgError);
//  TmpErrorW.Message:=InMessage;
//end;

//procedure GeneratePopUpWnd(const InLbl, InTxt, NmInList: String;
//                                 InMother:avk_TElement; InWndW: Single = 200;
//                                 InWndH: Single = 100; InWndScale: byte = 200);
//var
//   TempPopUp:THelpPopUpWnd;
//   TmpMother: avk_TElement;
//begin
//  if not Assigned(InMother) then Exit;
//  TmpMother := InMother;
//  while TmpMother.ParentAsElement<>nil do
//    TmpMother := avk_TElement(TmpMother).ParentAsElement;
//  if TmpMother.GetIdByName(NmInList) > -1 then Exit;
//  TempPopUp := THelpPopUpWnd.Create(TmpMother);
//  TempPopUp.Name := NmInList;
//  TempPopUp.HPWLabel := InLbl;
//  TempPopUp.HPWText  := InTxt;
//  TempPopUp.SetAreaControl(avk_MouseIsX - 3, avk_MouseIsY - 3, 6, 6);
//  TempPopUp.SetAreaForm(0,0,InWndW,InWndH);
//  TempPopUp.HPWScale := InWndScale;
//end;

procedure DrawRect(const InArea: zglTRect; Color: LongWord; Alpha: Byte;
  FX: LongWord);
begin
  pr2d_Rect( InArea.X , InArea.Y , InArea.W, InArea.H , Color, Alpha, FX);
end;






