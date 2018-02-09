unit gm_inet;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  {$IFDEF IT_IS_SERVER}
  Dialogs,
  {$ELSE}
  //globalmodule,
  {$ENDIF}
  Classes, SysUtils;

type
  TPacPlaer = record
    TypeOfData: Byte;
    InNumPaket, OutNumPaket: LongWord;
    Command: Word;
    DateLenght: LongWord;
    //Все как бы, остальное будет читать стрим
  end;
  PPacPlaer = ^TPacPlaer;

  TRecAboutSrv = record
    SrvName: array [0..15] of Char;
    SrvPort: Word;
    Endbyte: Byte;//Обязательная хня!
  end;

  TRecAutorize = record
    Name1c: array [0..25] of Char;
    Pincode: array [0..5] of Char;
  end;

  TRecAbTime = record
    Year: Integer;
    Month: byte;
    Day: Byte;
    Hour: byte;
    Minute: byte;
    Secund: byte;
    Milisecund: Integer;
  end;

  TRecAbMouse = record
    //принимает состояние мыши
    //кнопка которой кликнули
    BLIsClick: boolean;//левая
    MLIsClick: boolean;//средняя
    RLIsClick: boolean;//правая
    //кнопка которой дважды кликнули
    BLIsDblClick: boolean;//левая
    MLIsDblClick: boolean;//средняя
    RLIsDblClick: boolean;//правая
    //кнопка прижата
    BLIsDown: boolean;//левая
    MLIsDown: boolean;//средняя
    RLIsDown: boolean;//правая
    //кнопка отпущена
    BLIsUp: boolean;//левая
    MLIsUp: boolean;//средняя
    RLIsUp: boolean;//правая
    //координаты сдвига курсора от центра
    //центр будет 0,0 и от него и вектор (куда мышь) и длина (скорость)
    MPosX, MPosY: Single;
  end;
  {Для передачи строк}
  TArrayOfByte = Array of byte;
  PArrayOfByte = ^TArrayOfByte;

  { TODO : Процедурки связанные с клиент/сервером }
  function MidStr(const Source:String; inS, inF:Integer): String;
  function GetHeaderFromMS(const InMemStr:TMemoryStream): TPacPlaer;
  function PosInStartMS(const InMemStr:TMemoryStream): boolean;
  function GetNextRecordMS(out OutValue: TRecAboutSrv; const InMemStr:TMemoryStream): boolean; overload;
  procedure MakeClearRecAbMouse (var inRecAbMouse: TRecAbMouse);
  {$IFDEF IT_IS_SERVER}
  { TODO : Процедурки связанные только с сервером }
  {$Else}
  { TODO : Процедурки связанные только с клиентом }
  {$ENDIF}
const
  ComiTimeSignal = 1;//Прислать(сервер),пришли(к клиенту) сигналы точного времени
  ComiRecconectS = 2;//Прислать(сервер),пришли(к клиенту) коннект к серверу
  ComiPincode    = 3;//Показать пинкод
  ComiTestServer = 4;//Протестировать функционал сервера
  ComiTouchPad = 5;//Пришла команда с тачпада или телефона в качестве тачпада
  ComiRandomText = 6;//Пришел кусок текста с тачпада или телефона в качестве тачпада
  ComiAutorized = 7;//Пришел запрос на авторизацию

implementation

function MidStr(const Source: String; inS, inF: Integer): String;
begin
  Result := LeftStr(RightStr(Source,Length(Source) - inS) ,inF);
end;

function GetHeaderFromMS(const InMemStr:TMemoryStream): TPacPlaer;
var
  TmpSeek: Int64;//ого
begin
  with Result do begin
    TypeOfData  := 0;
    InNumPaket  := 0;
    OutNumPaket := 0;
    Command     := 0;
    DateLenght  := 0;
  end;
  if InMemStr = nil then begin
    {$IFDEF IT_IS_SERVER}
    Raise Exception.Create('Проблемы с потоком, потока нет!');
    {$Else}
    {$ENDIF}
    Exit;
  end;
  if InMemStr.Size < SizeOf(TPacPlaer) then begin
    {$IFDEF IT_IS_SERVER}
    Raise Exception.Create('Проблемы с потоком, получили не то!');
    {$Else}
    {$ENDIF}
    Exit;
  end;
  TmpSeek := InMemStr.Position;
  InMemStr.Seek(0,soFromBeginning);
  InMemStr.ReadBuffer(Result,SizeOf(TPacPlaer));
  InMemStr.Seek(TmpSeek,soFromBeginning);
end;

function PosInStartMS(const InMemStr: TMemoryStream): boolean;
begin
  Result := false;
  if InMemStr.Size < SizeOf(TPacPlaer) then Exit;
  Result := InMemStr.Seek(SizeOf(TPacPlaer),soFromBeginning) = (SizeOf(TPacPlaer));
end;

function GetNextRecordMS(out OutValue: TRecAboutSrv;
  const InMemStr: TMemoryStream): boolean;
var
  TmpOutValue: TRecAboutSrv;
begin
  Result := false;
  if InMemStr.Size < SizeOf(TPacPlaer) then Exit;
  if GetHeaderFromMS(InMemStr).Command <> $0100 then Exit;//вообще, избыточная проверка
  Result := InMemStr.Read(OutValue,SizeOf(TRecAboutSrv)) = SizeOf(TRecAboutSrv);
end;

procedure MakeClearRecAbMouse(var inRecAbMouse: TRecAbMouse);
begin
  with inRecAbMouse do begin
    BLIsClick    :=false;//левая
    MLIsClick    :=false;//средняя
    RLIsClick    :=false;//правая
    BLIsDblClick :=false;//левая
    MLIsDblClick :=false;//средняя
    RLIsDblClick :=false;//правая
    BLIsDown     :=false;//левая
    MLIsDown     :=false;//средняя
    RLIsDown     :=false;//правая
    BLIsUp       :=false;//левая
    MLIsUp       :=false;//средняя
    RLIsUp       :=false;//правая
    MPosX        := 0;
    MPosY        := 0;
  end;
end;

end.

