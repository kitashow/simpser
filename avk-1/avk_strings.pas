unit avk_strings;

{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  , zgl_utils
  ;

var
  avk_ModuleExtension:string = '.txt';
  avk_TupicalModuleName1:string = 'Программа';
  avk_TupicalModuleName2:string = 'Глобальный модуль';

  avk_SymbolStr: string = '_АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЬЪЭЮЯабвгдеёжзийклмнопрстуфхцчшщыьъэюя';
  avk_NumberStr: string = '0123456789.';//дробная часть точкой
  avk_Upper: UTF8String = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЬЪЭЮЯ';
  avk_Down: UTF8String = 'абвгдеёжзийклмнопрстуфхцчшщыьъэюя';
  avk_SymbolMath : string = '/*+-^';
  avk_SymbolSepar: string = '/|\*-+(';

  avk_ParametrHeader:string = '%пар';
  avk_MessageInTex:string = 'ОШИБКА,!!!,!!,!,i,>,>>,';

  function avk_find (const InStr,SubStr: UTF8String): Integer;
  function avk_GetNumOfStr ( const InStr,SubStr: UTF8String;
                              const InNumOf:Integer): UTF8String;
  function avk_CalcNumOfStr(const InStr, SubStr: UTF8String):Integer;

  function avk_Case(InStr:UTF8String; InUp:boolean = true): UTF8String;
  function avk_UpCase(InStr:UTF8String): UTF8String;
  function avk_DownCase(InStr:UTF8String): UTF8String;

  function avk_TrimLeft(InStr:UTF8String):UTF8String;
  function avk_TrimRight(InStr:UTF8String):UTF8String;
  function avk_Trim(InStr:UTF8String):UTF8String;

  function avk_Char(InStr:UTF8String; NumChar: Integer): UTF8String;

  function avk_Construct(InStr:UTF8String; Params: Array of UTF8String):UTF8String;

implementation

function avk_Case(InStr: UTF8String; InUp:boolean = true): UTF8String;
var
  CKL: Integer;
  FromS: UTF8String;
  ToS: UTF8String;
  ResStr: UTF8String;
  SymbU: UTF8String;
  WhereU: SizeInt;
begin
  ResStr := '';
  if InUp then begin
    FromS  := avk_Down;
    ToS    := avk_Upper;
  end else begin
    FromS  := avk_Upper;
    ToS    := avk_Down;
  end;
  for CKL:= 1 to utf8_Length(InStr) do begin
    SymbU := utf8_Copy(InStr,CKL,1);
    //WhereU := Pos(SymbU,FromS);
    WhereU := avk_find (FromS,SymbU);
    if WhereU > 0 then
      ResStr := ResStr + utf8_Copy(ToS,WhereU,1)
    else
      ResStr := ResStr + SymbU;
  end;
  Result := ResStr;
end;

function avk_UpCase(InStr: UTF8String): UTF8String;
begin
  Result := avk_Case(InStr);
end;

function avk_DownCase(InStr: UTF8String): UTF8String;
begin
  Result := avk_Case(InStr,false);
end;

function avk_find(const InStr, SubStr: UTF8String): Integer;
var
   TmpStep: Integer;
   TmpStp1: UTF8String;
   Len1, Len2 : integer;
begin
  Result := 0;
  TmpStp1:= '';
  TmpStep:= 1;
  Len1 := utf8_Length(InStr);
  Len2 := utf8_Length(SubStr);
  while TmpStep < (utf8_Length(InStr) - utf8_Length(SubStr)) do begin
    TmpStp1:= utf8_Copy(InStr, TmpStep, utf8_Length(SubStr));
    if SubStr = utf8_Copy(InStr, TmpStep, utf8_Length(SubStr)) then begin
      Result := TmpStep;
      Break;
    end;
    inc(TmpStep);
  end;
end;


function avk_GetNumOfStr(const InStr, SubStr: UTF8String;
  const InNumOf: Integer): UTF8String;
var
   TmpStep: Integer;
   TmpStr: UTF8String;
begin
  result:='';
  TmpStr:=InStr;
  for TmpStep:= 1 to InNumOf do begin
    if TmpStep = InNumOf then begin
      if avk_find(TmpStr, SubStr) > 0 then
        result := utf8_Copy(TmpStr,1,avk_find(TmpStr, SubStr))
      else result := TmpStr;
       if utf8_Length(result) >= utf8_Length(SubStr) then
         result := utf8_Copy(result,1,utf8_Length(result)-utf8_Length(SubStr));
       Break;
    end;
    TmpStr := utf8_Copy(TmpStr,avk_find(TmpStr, SubStr)+utf8_Length(SubStr),
              utf8_Length(TmpStr)- avk_find(TmpStr, SubStr));
  end;
end;

function avk_CalcNumOfStr(const InStr, SubStr: UTF8String):Integer;
var
   TmpStep: Integer;
   TmpStr: UTF8String;
begin
  TmpStr:=InStr;
  TmpStep := avk_find(TmpStr, SubStr);
  if TmpStep > 0 then
    Result := 1
  else
    Result := 0;
  while utf8_Length(TmpStr) > 0 do begin
    TmpStep := avk_find(TmpStr, SubStr);
    if TmpStep > 0 then begin
      Inc(result,1);
      utf8_Delete(TmpStr, TmpStep, utf8_Length(SubStr));
    end else Break;
  end;
end;

function avk_TrimLeft(InStr:UTF8String):UTF8String;
var
  RStr: AnsiString;
begin
  RStr := Utf8ToAnsi(InStr);
  while Length(RStr) > 0 do
    case RStr[1] of
      #00..#32: Delete(RStr,1,1);
    else
      Break;
    end;
  Result := AnsiToUtf8(RStr);
end;

function avk_TrimRight(InStr:UTF8String):UTF8String;
var
  RStr: AnsiString;
  TmLen: Integer;
begin
  RStr := Utf8ToAnsi(InStr);
  while Length(RStr) > 0 do begin
    TmLen := Length(RStr);
    if TmLen = 0 then Break;
    case RStr[TmLen] of
      #00..#32: Delete(RStr,TmLen,1);
    else
      Break;
    end;
  end;
  Result := AnsiToUtf8(RStr);
end;

function avk_Trim(InStr: UTF8String): UTF8String;
begin
  Result := avk_TrimLeft(avk_TrimRight(InStr));
end;

function avk_Char(InStr: UTF8String; NumChar: Integer): UTF8String;
begin
  Result := utf8_Copy(InStr,NumChar,1);
end;

function avk_Construct(InStr: UTF8String; Params: array of UTF8String): UTF8String;
var
  CKL: Integer;
  ResStr: UTF8String;
  PlacePar: Integer;
  ResStr_len: Integer;
  avk_ParametrHeader_Len: Integer;
begin
  ResStr := InStr;
  avk_ParametrHeader_Len := utf8_Length(avk_ParametrHeader);
  for CKL := 0 to (Length(Params) - 1) do begin
    PlacePar := avk_find(ResStr,avk_ParametrHeader);
    ResStr_len := utf8_Length(ResStr);
    if PlacePar = 0 then break;
    ResStr := utf8_Copy(ResStr, 1, PlacePar - 1) + Params[CKL] + utf8_Copy(ResStr, PlacePar+avk_ParametrHeader_Len, ResStr_len - (PlacePar+avk_ParametrHeader_Len));
  end;
  Result := ResStr;
end;

end.

