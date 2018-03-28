unit avk_loadmap;

{$mode delphi}
{$codepage UTF8}

interface

uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  {$IFDEF WINDOWS}
    ,Windows
  {$ELSE}
    ,Unix, UnixType
  {$ENDIF}
  {$ifdef DEBUG}
    , SysUtils
  {$endif}
  //avk
  , avk_strings
  //zgl
  , zgl_file
  , zgl_utils
  ;

type
  TMapArray = array of array of Word;

  function LoadMapFromCsv(FileName: String): TMapArray;

implementation

procedure myReadLn(var f, str: ANSIstring);
var n :integer;
begin
  n := Pos(#10, f);
  str := Copy(f, 1, n - 2);
  Delete(f, 1, n);
end;

function NextArg(var f: ANSIstring): ANSIString;
var
  n :integer;
begin
  Result := '';

  n := Pos(#44, f);

  if n = 0 then begin //последняя в строке
     n := Length(f);
     Result := Copy(f, 1, n);
  end else
     Result := Copy(f, 1, n - 1);

  Delete(f, 1, n);
end;

function LoadMapFromCsv(FileName: String): TMapArray;
var
  f: zglTFile;
  str, st: ANSIString;
  sz: integer;
begin
  file_Open( f, FileName, FOM_OPENR );
  sz := file_GetSize(f);
  SetLength(str, sz);
  file_Read( f, str[1], sz);

  repeat
    myReadLn(str, st);

    SetLength(Result, Length(Result) + 1);

    while not (Length(st) = 0) do begin
      SetLength(Result[Length(Result) - 1], Length(Result[Length(Result) - 1]) + 1);
      Result[Length(Result) - 1, Length(Result[Length(Result) - 1]) - 1] := u_StrToInt(NextArg(st));
    end;

  until Length(str) = 0;

  file_close( f );
end;

end.

