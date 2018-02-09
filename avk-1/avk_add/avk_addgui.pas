unit avk_addgui;

{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  {$IfDef WINDOWS}
  , SysUtils
  {$EndIf}
  //avk
  , avk_btype
  , avk_gui
  , avk_strings
  //zgl
  , zgl_primitives_2d
  , zgl_math_2d
  , zgl_render_target
  , zgl_textures
  , zgl_textures_tga
  , zgl_memory
  , zgl_file
  , zgl_main
  , zgl_text
  , zgl_fx
  , zgl_sprite_2d
  //, zgl_types
  ;

type

  avk_TMessageRecord = class
    Message: String;
    Title: String;//err !!! i etc.
    Details: String; //<property>value</property>
    MObject: TObject;
    TitleFrm: Integer;
  end;

  { avk_TMessagePanel }

  avk_TMessagePanel = class (avk_TElement)
  private
    FNameSqColor: LongWord;
    FNameFontColor: LongWord;
    FMarkSqColor: LongWord;
  public
    FMessageList: TStringList;
  private
    FMessageMarkersTex: zglPTexture;
    procedure DoAfterParentResize(Sender: TObject);
    function GetWidthOnScreen: Single;
    procedure SetWidthOnScreen(AValue: Single);
  public
    MessListIcons: zglPTexture;
    CaptionButton: avk_TSimpleButton;
    CloseButton: avk_TCircleButton;
    procedure CreateGeometric; override;
    procedure DoChangeStyle(Sender:TObject); virtual;
    procedure DoClose(Sender:TObject); virtual;
    procedure Report(InMessage:String; InStyle:String = ''; Sender:TObject = nil; InDetails:String = ''); overload; virtual;
    procedure Report(InMessage:String; Sender:TObject); overload; virtual;
  public
    procedure DoDraw(Sender:TObject); virtual;
  public
    property Width: Single read GetWidthOnScreen write SetWidthOnScreen;
    property MessageMarkersTex: zglPTexture read FMessageMarkersTex write FMessageMarkersTex;
  public
    constructor Create(const InParent: avk_TFraim = nil; InName: String = '');
    destructor Destroy; override;
  end;

var
  TMPvers: string = 'не знаю зачем это вообще';
  function GetSimpleTexSquere (InRect:zglTRect;Color : LongWord; InTexture: zglPTexture = nil; Alpha : Byte = 255; FX : LongWord = PR2D_FILL):zglPTexture;

implementation

function GetSimpleTexSquere(InRect: zglTRect; Color: LongWord; InTexture: zglPTexture = nil; Alpha : Byte = 255; FX : LongWord = PR2D_FILL): zglPTexture;
var
  TMPRt: zglPRenderTarget;
begin
  Result := nil;
  if InTexture = nil then begin
    InTexture := tex_CreateZero(Round(InRect.W), Round(InRect.H), Color, TEX_DEFAULT_2D);
    InTexture := ReloadAsTGA( InTexture );
    TMPRt := rtarget_Add( InTexture, RT_CLEAR_COLOR )
  end else begin
    tex_Del(InTexture);
    InTexture := nil;
    Result := GetSimpleTexSquere(InRect, Color, InTexture, Alpha, FX);
    Exit;
  end;
  rtarget_Set( TMPRt );//начали
  pr2d_Rect( 0, 0, InRect.W, InRect.H, Color, Alpha, FX );
  rtarget_Set( nil );//закончили
  Result := InTexture;
end;

{ avk_TMessagePanel }

procedure avk_TMessagePanel.DoAfterParentResize(Sender: TObject);
var
  TmpAr: zglTRect;
  TmpWalp: zglPTexture;
begin
  if not (Parent is avk_TElement) then begin
    if Assigned(OnError) then OnError(Self);
    {$IfDef WINDOWS}
    Raise Exception.Create('Проблема с предком, предок не верного класса, должен быть avk_TElement.');
    Exit;
    {$Else}
    u_Warning('Проблема с предком, предок не верного класса, должен быть avk_TElement.');
    Exit;
    {$EndIf}
  end;
  TmpAr := ParentAsElement.AreaElement;
  case Position of
    POS_BOTTOM: SetAreaElement(0,TmpAr.H - AreaElement.H,TmpAr.W,AreaElement.H);
    POS_LEFT:   SetAreaElement(0,0,AreaElement.W,TmpAr.H);
    POS_RIGHT:  SetAreaElement(TmpAr.W - AreaElement.W,0,AreaElement.W,TmpAr.H);
    POS_TOP: SetAreaElement(0,0,TmpAr.W,AreaElement.H);
  end;
  if StyleElement = STYLE_GEOMETRIC then CreateGeometric
    else Wallpaper := GetSimpleTexSquere(AreaElement, WallpaperColor);
end;

function avk_TMessagePanel.GetWidthOnScreen: Single;
begin
  Result:= AreaElement.W;
  case Position of
    POS_BOTTOM, POS_TOP: Result:= AreaElement.H;
    POS_LEFT, POS_RIGHT: Result:= AreaElement.W;
  end;
end;

procedure avk_TMessagePanel.SetWidthOnScreen(AValue: Single);
var
  PrevPar: Single;
begin
  case Position of
    POS_BOTTOM, POS_TOP: PrevPar:= AreaElement.H;
    POS_LEFT, POS_RIGHT: PrevPar:= AreaElement.W;
  end;
  if AValue = PrevPar then Exit;
  SetAreaElement(0,0,AValue,AValue);
  DoAfterParentResize(Self);
end;

procedure avk_TMessagePanel.CreateGeometric;
var
  TMPRt: zglPRenderTarget;
  InTexture: zglPTexture;
  TmpArea: zglTRect;
  TmpPlW, TmpPlH, TmpPlWM, TmpCalc: Integer;
  CKL: Integer;
  TmpMes: UTF8String;
  TmpColour: Integer;
begin
  TmpPlW := Round(text_GetWidth(Font, 'ОШИБКА') + 4);
  InTexture := tex_CreateZero(Round(AreaElement.W), Round(AreaElement.H), WallpaperColor, TEX_DEFAULT_2D);
  InTexture := ReloadAsTGA( InTexture );
  TMPRt := rtarget_Add( InTexture, RT_CLEAR_COLOR );
  rtarget_Set( TMPRt );//начали
  pr2d_Rect( 0, 5, AreaElement.W , AreaElement.H - 5, WallpaperColor, 255, PR2D_FILL);
  //Полоса с метками
  pr2d_Rect( 0, 5, TmpPlW , AreaElement.H - 5, FMarkSqColor, 255, PR2D_FILL);
  //Заголовок
  if BorderStyle = BS_LINE then
    pr2d_Rect( 0, 5, AreaElement.W , AreaElement.H - 5, BorderColor, 255, PR2D_SMOOTH);
  rtarget_Set( nil );//закончили
  Wallpaper := InTexture;
  //полоса с метками
  if FMessageMarkersTex = nil then begin
    //создаем ОШИБКА, !!!, !!, !, i, >
    TmpCalc := avk_CalcNumOfStr(avk_MessageInTex,',');
    TmpPlH := Round(text_GetHeight(Font, TmpPlW, 'ОШИБКА'));
    InTexture := tex_CreateZero(TmpPlW, TmpPlH * TmpCalc, WallpaperColor, TEX_DEFAULT_2D);
    InTexture := ReloadAsTGA( InTexture );
    TMPRt := rtarget_Add( InTexture, RT_CLEAR_COLOR );
    rtarget_Set( TMPRt );//начали
    for CKL := 0 to TmpCalc do begin
        TmpMes := avk_GetNumOfStr(avk_MessageInTex,',',CKL +1);
        TmpPlWM := Round(text_GetWidth(Font, TmpMes) + 4);
        if CKL < 4 then
          TmpColour := $FF0000//красный
        else if CKL < 5 then
          TmpColour := $00FF00//синий
        else
          TmpColour := $0000FF;
        //Round((TmpPlW / 2) - (TmpPlWM / 2))
        pr2d_Rect( 0, TmpPlH * CKL, TmpPlW , TmpPlH, FMarkSqColor, 255, PR2D_FILL);
        with TmpArea do begin
          X:= 0;
          Y:= TmpPlH * CKL;
          W:= TmpPlW;
          H:= TmpPlH;
        end;
        text_DrawInRectEx (Font,TmpArea,1.0,0,TmpMes, 255, TmpColour, TEXT_HALIGN_CENTER or TEXT_VALIGN_CENTER);
    end;
    rtarget_Set( nil );//закончили
    FMessageMarkersTex := InTexture;
    tex_SetFrameSize(FMessageMarkersTex,TmpPlW,TmpPlH);
  end;
end;

procedure avk_TMessagePanel.DoChangeStyle(Sender: TObject);
var
  TmX,TmY: Single;
  TmW,TmH: Single;
begin
  //TODO: надо стиль авторазмер сделать минимал
  CaptionButton.BorderStyle := BS_LINE;
  with CaptionButton.LabelCaption do begin
    TmW :=  text_GetWidth(Font,Caption,Step);
    TmW := TmW + 10;
    TmH :=  text_GetHeight(Font,TmW,Caption);
    TmH := TmH + 4;
  end;
  TmX:=0;
  TmY:=0;
  case Position of
    POS_TOP: begin
      //if ParentAsElement<>nil then
        TmY := AreaElement.H - TmH;
    end;
  end;
  //WhatS := CaptionButton.StyleElement;
  CaptionButton.SetAreaElement(TmX,TmY,TmW,TmH);
  CaptionButton.CreateGeometric;
  CaptionButton.LabelCaption.FontColor := $000000;
  CloseButton.BorderStyle := BS_LINE;
  CloseButton.SetAreaElement(AreaElement.W - TmH - 3,TmY,TmH,TmH);
  CloseButton.CreateGeometric;
  DoAfterParentResize(Self);
end;

procedure avk_TMessagePanel.DoClose(Sender: TObject);
begin
  DeleteMe:=true;
end;

procedure avk_TMessagePanel.Report(InMessage: String; InStyle: String;
  Sender: TObject; InDetails: String);
var
  TmpRec: avk_TMessageRecord;
  TmpCount: Integer;
  CKL: Integer;
  TmpSubstr: UTF8String;
begin
  if not Assigned(FMessageList) then FMessageList := TStringList.Create;
  TmpRec := avk_TMessageRecord.Create;
  with TmpRec do begin
    Message := InMessage;
    Title   := InStyle;
    MObject := Sender;
    Details := InDetails;
    //if avk_find(Title,);
    TitleFrm := 5;
    TmpCount := avk_CalcNumOfStr(avk_MessageInTex, ',');
    For CKL:=0 to TmpCount do begin
      TmpSubstr := avk_GetNumOfStr ( avk_MessageInTex, ',', CKL );
      if TmpSubstr = InStyle then begin
        TitleFrm := CKL;
        Break;
      end;
    end;
  end;
  FMessageList.AddObject(InMessage,TmpRec);
end;

procedure avk_TMessagePanel.Report(InMessage: String; Sender: TObject);
begin
  Report(InMessage, 'i', Sender);
end;

procedure avk_TMessagePanel.DoDraw(Sender: TObject);
var
  CanDraw: Boolean;
  NowDraw: Integer;
  NowPrint: String;
  TmpHeight: Single;
  NowPntY: Single;
begin
  if not Assigned(FMessageList) then Exit;
  //рисуем снизу
  CanDraw := true;
  NowDraw := FMessageList.Count - 1;
  NowPrint:= FMessageList.Strings[NowDraw];
  TmpHeight := text_GetHeight(Font,text_GetWidth(Font,'Проверка высоты'),'Проверка');
  NowPntY := 0.0;
  while CanDraw do begin
    NowPrint:= FMessageList.Strings[NowDraw];
    NowPntY := AreaElement.H - ((FMessageList.Count - NowDraw) * TmpHeight);
    text_DrawEx(Font, text_GetWidth(Font, 'ОШИБКА') + 4, GetAbsolyteArea.Y + NowPntY, 1.0, 0.0, NowPrint, 255, FontColor);
    //теперь маркер
    if FMessageMarkersTex <> nil then begin
      asprite2d_Draw( FMessageMarkersTex, GetAbsolyteArea.X+1, GetAbsolyteArea.Y + NowPntY, text_GetWidth(Font, 'ОШИБКА') + 2, TmpHeight, 0.0,  avk_TMessageRecord( FMessageList.Objects[NowDraw] ).TitleFrm, Transparence);
    end;
    INC(NowDraw,-1);
    CanDraw := not((NowDraw < 0) or (NowPntY < 10));
  end;
end;

constructor avk_TMessagePanel.Create(const InParent: avk_TFraim; InName: String);
begin
  inherited Create(InParent,InName);
  OnAfterParentResize := DoAfterParentResize;
  CaptionButton := avk_TSimpleButton.Create(Self,InName);
  CloseButton := avk_TCircleButton.Create(Self,'X');
  CloseButton.OnClick:=DoClose;
  StyleElement := STYLE_GEOMETRIC;
  Position := POS_BOTTOM;//низ
  WallpaperColor := $CFE6DC;
  BorderColor := $648F7D;
  FNameSqColor := $E1E6CF;
  FNameFontColor := $788059;
  FMarkSqColor := $E6D3CF;
  SetAreaElement(0,0,150,150);
  OnChangeStyle := DoChangeStyle;
  OnDraw := DoDraw;
  FMessageMarkersTex := nil;
end;

destructor avk_TMessagePanel.Destroy;
var
  ckl: Integer;
begin
  if Assigned(FMessageList) then begin
    for ckl:= 0 to FMessageList.Count - 1 do FMessageList.Objects[ckl].Destroy;
    FMessageList.Destroy;
  end;
  inherited Destroy;
end;

end.

