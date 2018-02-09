unit Coder;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes;

  procedure Windows1251ToUTF8(var Str: string);
  procedure UTF8ToWindows1251(var Str: string);
  procedure OEM866ToUTF8(var Str: string);
  procedure UTF8ToOEM866(var Str: string);
  procedure OEM866ToWindows1251(var Str: string);
  procedure Windows1251ToOEM866(var Str: string);

implementation

procedure Windows1251ToUTF8(var Str: string);
const
  bRD0: Byte = ($C0 - $90);
  bRD1: Byte = ($F0 - $80);
var
  xCh, GStr, NStr: string;
  xL, iFor: integer;
  xChr: Char;
begin
  GStr := Str;
  NStr := '';
  xL := length(Str);
  for iFor := 1 to xL do
    begin
      xCh := #$20;
      xChr := GStr[iFor];
    if (xChr >= #$00) and (xChr <= #$7F) then {Первая половина без изменений}
      begin
        xCh := xChr;
        case ord(xChr) of   {Некоторые символы}
          $11: xCh := #$E2#$97#$80;
          $10: xCh := #$E2#$96#$B6;
          $1E: xCh := #$E2#$96#$B2;
          $1F: xCh := #$E2#$96#$BC;
        end;
      end
    else
      if (xChr >= #$C0) and (xChr <= #$EF) then {А-п}
        xCh := #$D0 + chr(ord(xChr) - bRD0)
      else
        if (xChr >= #$F0) and (xChr <= #$FF) then {р-я}
          xCh := #$D1 + chr(ord(xChr) - bRD1)
        else
          case ord(xChr) of
            $80: xCh := #$D0#$82;
            $81: xCh := #$D0#$83;
            $82: xCh := #$E2#$80#$9A;
            $83: xCh := #$D1#$93;
            $84: xCh := #$E2#$80#$0E;
            $93: xCh := #$E2#$80#$9C;
            $94: xCh := #$E2#$80#$9D;
            $AB: xCh := #$C2#$AB;
            $BB: xCh := #$C2#$BB;
            $85: xCh := #$E2#$80#$A6;
            $86: xCh := #$E2#$80#$A0;
            $87: xCh := #$E2#$80#$A1;
            $88: xCh := #$E2#$82#$AC;
            $89: xCh := #$E2#$80#$B0;
            $8A: xCh := #$D0#$89;
            $8B: xCh := #$E2#$80#$B9;
            $9B: xCh := #$E2#$80#$BA;
            $8C: xCh := #$D0#$8A;
            $8D: xCh := #$D0#$8C;
            $8E: xCh := #$D0#$8B;
            $8F: xCh := #$D0#$8F;
            $90: xCh := #$D1#$92;
            $91: xCh := #$E2#$80#$98;
            $92: xCh := #$E2#$80#$99;
            $95: xCh := #$E2#$80#$A2;
            $96: xCh := #$E2#$80#$93;
            $97: xCh := #$E2#$80#$92;
            $AD: xCh := #$E2#$80#$94;
            $99: xCh := #$E2#$84#$A2;
            $9A: xCh := #$D1#$99;
            $9C: xCh := #$D1#$9A;
            $9D: xCh := #$D1#$9C;
            $9E: xCh := #$D1#$9B;
            $9F: xCh := #$D1#$9F;
            $A1: xCh := #$D0#$8E;
            $A2: xCh := #$D1#$9E;
            $A3: xCh := #$D0#$88;
            $A4: xCh := #$C2#$A4;
            $A5: xCh := #$D2#$90;
            $A6: xCh := #$C2#$A6;
            $A7: xCh := #$C2#$A7;
            $A8: xCh := #$D0#$81;
            $A9: xCh := #$C2#$A9;
            $AA: xCh := #$D0#$84;
            $AC: xCh := #$C2#$AC;
            $AF: xCh := #$D0#$87;
            $B0: xCh := #$C2#$B0;
            $B1: xCh := #$C2#$B1;
            $B2: xCh := #$D0#$86;
            $B3: xCh := #$D1#$96;
            $B4: xCh := #$D2#$91;
            $B5: xCh := #$C2#$B5;
            $B6: xCh := #$C2#$B6;
            $B7: xCh := #$C2#$B7;
            $B8: xCh := #$D1#$91;
            $B9: xCh := #$E2#$84#$96;
            $BA: xCh := #$D1#$94;
            $BC: xCh := #$D1#$98;
            $BD: xCh := #$D0#$85;
            $BE: xCh := #$D1#$95;
            $BF: xCh := #$D1#$97;
          end;
      NStr := NStr + xCh;
    end;
  Str := NStr;
end;

procedure UTF8ToWindows1251(var Str: string);
const
  bRD0: Byte = ($C0 - $90);
  bRD1: Byte = ($F0 - $80);
var
  GStr, NStr: string;
  xChr, xP: Char;
  xL, iFor: integer;
  xGr1, xGr2: Char;
  bitn: Boolean = true {true - 2 байта, false - 3 байта};
begin
  xL := length(Str);
  GStr := Str;
  NStr := '';
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xP := GStr[iFor];
      if (xP >= #$00) and (xP <= #$7F) then {Первая половина без изменений}
        begin
          xChr := xP;
          xGr1:= #$00;
          xGr2:= #$00;
        end
      else
        if (xP = #$C2) or (xP = #$D0) or (xP = #$D1) then
          begin        {Двухбайтный символ}
            xGr1 := xP;
            xGr2 := #$00;
            bitn := true;
          end
        else
          if xP = #$E2 then
            begin      {Трехбайтный символ}
              xGr1 := xP;
              xGr2 := #$00;
              bitn := false;
            end
          else         {если это второй байт трехбайтного символа}
            if (xP >= #$80) and (xP <= #$BF) then
              if (not bitn) and (xGr2 = #$00) then
                  begin
                    xGr2 := xP;
                    //bitn := true;
                  end
              else
                begin
                  if xGr2 = #$00 then   {если это двухбайтный символ}
                    begin
                    if xGr1 = #$D0 then {и первый байт = $D0}
                      if (xP >= #$90) and (xP <= #$BF) then {второй байт}
                        xChr := chr(ord(xP) + brD0)
                      else
                        case ord(xP) of
                          $81: xChr := #$A8;
                          $82: xChr := #$80;
                          $83: xChr := #$81;
                          $84: xChr := #$AA;
                          $85: xChr := #$BD;
                          $86: xChr := #$B2;
                          $87: xChr := #$AF;
                          $88: xChr := #$A3;
                          $89: xChr := #$8A;
                          $8A: xChr := #$8C;
                          $8B: xChr := #$8E;
                          $8C: xChr := #$8D;
                          $8E: xChr := #$A1;
                          $8F: xChr := #$8F;
                        end
                    else
                      if xGr1 = #$D1 then
                        if (xP >= #$80) and (xP <= #$8F) then
                          xChr := chr(ord(xP) + bRD1)
                        else
                          case ord(xP) of
                            $91: xChr := #$B8;
                            $92: xChr := #$90;
                            $93: xChr := #$83;
                            $94: xChr := #$BA;
                            $95: xChr := #$BE;
                            $96: xChr := #$B3;
                            $97: xChr := #$BF;
                            $98: xChr := #$BC;
                            $99: xChr := #$9A;
                            $9A: xChr := #$9C;
                            $9B: xChr := #$9E;
                            $9C: xChr := #$9D;
                            $9E: xChr := #$A2;
                            $9F: xChr := #$9F;
                          end
                      else
                        if xGr1 = #$C2 then
                          case ord(xP) of
                            $A4: xChr := xP;
                            $A6: xChr := xP;
                            $A7: xChr := xP;
                            $A9: xChr := xP;
                            $AB: xChr := xP;
                            $AC: xChr := xP;
                            $B0: xChr := xP;
                            $B1: xChr := xP;
                            $B5: xChr := xP;
                            $B6: xChr := xP;
                            $B7: xChr := xP;
                            $BB: xChr := xP;
                          end;
                    end
                  else
                    case ord(xGr2) of
                      $82: if xP = #$AC then xChr := #$88;
                      $84: case ord(xP) of
                             $A2: xChr := #$99;
                             $96: xChr := #$B9;
                           end;
                      $80: case ord(xP) of
                             $92: xChr := #$97;
                             $93: xChr := #$96;
                             $94: xChr := #$AD;
                             $98: xChr := #$91;
                             $99: xChr := #$92;
                             $9A: xChr := #$82;
                             $9C: xChr := #$93;
                             $9D: xChr := #$94;
                             $A0: xChr := #$86;
                             $A1: xChr := #$87;
                             $A2: xChr := #$95;
                             $A6: xChr := #$85;
                             $B0: xChr := #$89;
                             $B9: xChr := #$8B;
                             $BA: xChr := #$9B;
                             $0E: xChr := #$84;
                           end;
                      $96: case ord(xP) of
                             $B2: xChr := #$1E;
                             $B6: xChr := #$10;
                             $BC: xChr := #$1F;
                           end;
                      $97: case ord(xP) of
                             $80: xChr := #$11;
                           end;
                    end;
                  xGr1 := #$00;
                end;
      if xGr1 = #$00 then
        NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure OEM866ToUTF8(var Str: string);
const
  bRD0: Byte = ($90 - $80);
  bRD1: Byte = ($E0 - $80);
var
  xCh, GStr, NStr: string;
  xL, iFor: integer;
  xChr: Char;
begin
  GStr := Str;
  NStr := '';
  xL := length(Str);
  for iFor := 1 to xL do
    begin
      xCh := #$20;
      xChr := GStr[iFor];
    if (xChr >= #$00) and (xChr <= #$7F) then {Первая половина без изменений}
      begin
        xCh := xChr;
        case ord(xChr) of
          $11: xCh := #$E2#$97#$80;
          $10: xCh := #$E2#$96#$B6;
          $1E: xCh := #$E2#$96#$B2;
          $1F: xCh := #$E2#$96#$BC;
        end;
      end
    else
      if (xChr >= #$80) and (xChr <= #$AF) then {А-п}
        xCh := #$D0 + chr(ord(xChr) + bRD0)
      else
        if (xChr >= #$E0) and (xChr <= #$EF) then {р-я}
          xCh := #$D1 + chr(ord(xChr) - bRD1)
        else
          case ord(xChr) of
            $B0: xCh := #$E2#$96#$91;
            $B1: xCh := #$E2#$96#$92;
            $B2: xCh := #$E2#$96#$93;
            $B3: xCh := #$E2#$94#$82;
            $B4: xCh := #$E2#$94#$A4;
            $B5: xCh := #$E2#$95#$A1;
            $B6: xCh := #$E2#$95#$A2;
            $B7: xCh := #$E2#$95#$96;
            $B8: xCh := #$E2#$95#$95;
            $B9: xCh := #$E2#$95#$A3;
            $BA: xCh := #$E2#$95#$91;
            $BB: xCh := #$E2#$95#$97;
            $BC: xCh := #$E2#$95#$9D;
            $BD: xCh := #$E2#$95#$9C;
            $BE: xCh := #$E2#$95#$9B;
            $BF: xCh := #$E2#$95#$AE;
            $C0: xCh := #$E2#$95#$B0;
            $C1: xCh := #$E2#$94#$B4;
            $C2: xCh := #$E2#$94#$AC;
            $C3: xCh := #$E2#$94#$9C;
            $C4: xCh := #$E2#$94#$80;
            $C5: xCh := #$E2#$94#$BC;
            $C6: xCh := #$E2#$95#$9E;
            $C7: xCh := #$E2#$95#$9F;
            $C8: xCh := #$E2#$95#$9A;
            $C9: xCh := #$E2#$95#$94;
            $CA: xCh := #$E2#$95#$A9;
            $CB: xCh := #$E2#$95#$A6;
            $CC: xCh := #$E2#$95#$A0;
            $CD: xCh := #$E2#$95#$90;
            $CE: xCh := #$E2#$95#$AC;
            $CF: xCh := #$E2#$95#$A7;
            $D0: xCh := #$E2#$95#$A8;
            $D1: xCh := #$E2#$95#$A4;
            $D2: xCh := #$E2#$95#$A5;
            $D3: xCh := #$E2#$95#$99;
            $D4: xCh := #$E2#$95#$98;
            $D5: xCh := #$E2#$95#$92;
            $D6: xCh := #$E2#$95#$93;
            $D7: xCh := #$E2#$95#$AB;
            $D8: xCh := #$E2#$95#$AA;
            $D9: xCh := #$E2#$95#$AF;
            $DA: xCh := #$E2#$95#$AD;
            $DB: xCh := #$E2#$96#$88;
            $DC: xCh := #$E2#$96#$84;
            $DD: xCh := #$E2#$96#$8C;
            $DE: xCh := #$E2#$96#$90;
            $DF: xCh := #$E2#$95#$80;
            $F0: xCh := #$D0#$81;
            $F1: xCh := #$D1#$91;
            $F2: xCh := #$D0#$84;
            $F3: xCh := #$D1#$94;
            $F4: xCh := #$D0#$87;
            $F5: xCh := #$D1#$97;
            $F6: xCh := #$D0#$8E;
            $F7: xCh := #$D1#$9E;
            $F8: xCh := #$C2#$B0;
            $F9: xCh := #$E2#$80#$A2;
            $FA: xCh := #$C2#$B7;
            $FB: xCh := #$E2#$8E#$B7;
            $FC: xCh := #$E2#$84#$96;
            $FD: xCh := #$C2#$A4;
            $FE: xCh := #$E2#$8E#$B7;    {254}
            // $FF: xCh := #$C2#$A4; //
          end;
      NStr := NStr + xCh;
    end;
  Str := NStr;
end;

procedure UTF8ToOEM866(var Str: string);
const
  bRD0: Byte = ($90 - $80);
  bRD1: Byte = ($E0 - $80);
var
  GStr, NStr: string;
  xChr, xP: Char;
  xL, iFor: integer;
  xGr1, xGr2: Char;
  bitn: Boolean = true {true - 2 байта, false - 3 байта};
begin
  xL := length(Str);           {Длина строки}
  GStr := Str;                 {Сохранили в рабочую переменную}
  NStr := '';
  for iFor := 1 to xL do
    begin
      xChr := #$20;            {По умолчанию}
      xP := GStr[iFor];        {Следующий обрабатываемый символ}
      if (xP >= #$00) and (xP <= #$7F) then {Первая половина без изменений}
        begin
          xChr := xP;          {Возвращаемый символ}
          xGr1:= #$00;         {Обнулим группы}
          xGr2:= #$00;
        end
      else
        {Если это двубайтный символ}
        if (xP = #$C2) or (xP = #$D0) or (xP = #$D1) then
          begin
            xGr1 := xP;        {Запомним первую группу}
            xGr2 := #$00;      {Обнулим вторую}
            bitn := true;      {Поставим флаг двубайтности}
          end
        else
          if xP = #$E2 then    {Если это трехбайтный}
            begin
              xGr1 := xP;      {Запомним первую группу}
              xGr2 := #$00;    {Обнулим вторую}
              bitn := false;   {Поставим флаг требайтности}
            end
          else
            {Если это подгруппа}
            if (xP >= #$80) and (xP <= #$BF) then
              {Если это второй байт трибайта}
              if (not bitn) and (xGr2 = #$00) then
                  begin
                    xGr2 := xP;   {Запомним вторую группу}
                    //bitn := true;
                  end
              else
                begin
                  if xGr2 = #$00 then
                    begin
                    if xGr1 = #$D0 then
                      if (xP >= #$90) and (xP <= #$BF) then
                        xChr := chr(ord(xP) - brD0)
                      else
                        case ord(xP) of
                          $81: xChr := #$F0;
                          $84: xChr := #$F2;
                          $87: xChr := #$F4;
                          $8E: xChr := #$F6;
                        end
                    else
                      if xGr1 = #$D1 then
                        if (xP >= #$80) and (xP <= #$8F) then
                          xChr := chr(ord(xP) + bRD1)
                        else
                          case ord(xP) of
                            $91: xChr := #$F1;
                            $94: xChr := #$F3;
                            $97: xChr := #$F5;
                            $9E: xChr := #$F7;
                          end
                      else
                        if xGr1 = #$C2 then
                          case ord(xP) of
                            $A4: xChr := #$FD;
                            $B0: xChr := #$F8;
                            $B7: xChr := #$FA;
                          end;
                    end
                  else
                    case ord(xGr2) of
                      $8E: if xP = #$B7 then xChr := #$FE;
                      $84: if xP = #$96 then xChr := #$FC;
                      $80: if xP = #$A2 then xChr := #$F9;
                      $94: case ord(xP) of
                             $80: xChr := #$C4;
                             $82: xChr := #$B3;
                             $9C: xChr := #$C3;
                             $A4: xChr := #$B4;
                             $AC: xChr := #$C2;
                             $B4: xChr := #$C1;
                             $BC: xChr := #$C5;
                           end;
                      $95: case ord(xP) of
                             $A1: xChr := #$B5;
                             $A2: xChr := #$B6;
                             $96: xChr := #$B7;
                             $95: xChr := #$B8;
                             $A3: xChr := #$B9;
                             $91: xChr := #$BA;
                             $97: xChr := #$BB;
                             $9D: xChr := #$BC;
                             $9C: xChr := #$BD;
                             $9B: xChr := #$BE;
                             $AE: xChr := #$BF;
                             $B0: xChr := #$C0;
                             $9E: xChr := #$C6;
                             $9F: xChr := #$C7;
                             $9A: xChr := #$C8;
                             $94: xChr := #$C9;
                             $A9: xChr := #$CA;
                             $A6: xChr := #$CB;
                             $A0: xChr := #$CC;
                             $90: xChr := #$CD;
                             $AC: xChr := #$CE;
                             $A7: xChr := #$CF;
                             $A8: xChr := #$D0;
                             $A4: xChr := #$D1;
                             $A5: xChr := #$D2;
                             $99: xChr := #$D3;
                             $98: xChr := #$D4;
                             $92: xChr := #$D5;
                             $93: xChr := #$D6;
                             $AB: xChr := #$D7;
                             $AA: xChr := #$D8;
                             $AF: xChr := #$D9;
                             $AD: xChr := #$DA;
                             $80: xChr := #$DF;
                           end;
                      $96: case ord(xP) of
                             $90: xChr := #$DE;
                             $91: xChr := #$B0;
                             $92: xChr := #$B1;
                             $93: xChr := #$B2;
                             $88: xChr := #$DB;
                             $84: xChr := #$DC;
                             $8C: xChr := #$DD;
                             $B2: xChr := #$1E;
                             $B6: xChr := #$10;
                             $BC: xChr := #$1F;
                           end;
                      $97: case ord(xP) of
                             $80: xChr := #$11;
                           end;
                    end;
                  xGr1 := #$00;
                end;
      if xGr1 = #$00 then
        NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure OEM866ToWindows1251(var Str: string);
const
  Ap: Byte = ($C0 - $80);
  rya: Byte = ($F0 - $E0);
var
  iFor, xL: integer;
  GStr, NStr: string;
  xCh, xChr: Char;
begin
  NStr := '';
  GStr := Str;
  xL := length(GStr);
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xCh := GStr[iFor];
      if (xCh >= #$00) and (xCh <= #$7F) then {Первая часть без изменений}
        xChr := xCh
      else
        if (xCh >= #$80) and (xCh <= #$AF) then
          xChr := chr(ord(xCh) + Ap)
        else
          if (xCh >= #$E0) and (xCh <= #$EF) then
            xChr := chr(ord(xCh) + rya)
          else
            case ord(xCh) of
              {Псевдографика}
              $B0: xChr := #$A9;
              $B1: xChr := #$AE;
              $B2: xChr := #$B5;
              $B3: xChr := #$A6;
              $B4: xChr := #$A6;
              $B5: xChr := #$A6;
              $B6: xChr := #$A6;
              $B9: xChr := #$A6;
              $BA: xChr := #$A6;
              $C3: xChr := #$A6;
              $C6: xChr := #$A6;
              $C7: xChr := #$A6;
              $CC: xChr := #$A6;
              $B7: xChr := #$2B;
              $B8: xChr := #$2B;
              $BB: xChr := #$2B;
              $BC: xChr := #$2B;
              $BD: xChr := #$2B;
              $BE: xChr := #$2B;
              $BF: xChr := #$2B;
              $C0: xChr := #$2B;
              $C5: xChr := #$2B;
              $C8: xChr := #$2B;
              $C9: xChr := #$2B;
              $CE: xChr := #$2B;
              $D3: xChr := #$2B;
              $D4: xChr := #$2B;
              $D5: xChr := #$2B;
              $D6: xChr := #$2B;
              $D7: xChr := #$2B;
              $D8: xChr := #$2B;
              $D9: xChr := #$2B;
              $DA: xChr := #$2B;
              $C1: xChr := #$97;
              $C2: xChr := #$97;
              $C4: xChr := #$97;
              $CA: xChr := #$97;
              $CB: xChr := #$97;
              $CD: xChr := #$97;
              $CF: xChr := #$97;
              $D0: xChr := #$97;
              $D1: xChr := #$97;
              $D2: xChr := #$97;
              {...}
              $F0: xChr := #$A8;
              $F1: xChr := #$B8;
              $F2: xChr := #$AA;
              $F3: xChr := #$BA;
              $F4: xChr := #$AF;
              $F5: xChr := #$BF;
              $F6: xChr := #$A1;
              $F7: xChr := #$A2;
              $F8: xChr := #$B0;
              $F9: xChr := #$95;
              $FA: xChr := #$B7;
              $FB: xChr := #$AC;
              $FC: xChr := #$B9;
              $FD: xChr := #$A4;
            end;
      NStr := NStr + xChr;
    end;
  Str := NStr;
end;

procedure Windows1251ToOEM866(var Str: string);
const
  Ap: Byte = ($C0 - $80);
  rya: Byte = ($F0 - $E0);
var
  iFor, xL: integer;
  GStr, NStr, xChr: string;
  xCh: Char;
begin
  NStr := '';
  GStr := Str;
  xL := length(GStr);
  for iFor := 1 to xL do
    begin
      xChr := #$20;
      xCh := GStr[iFor];
      if (xCh >= #$00) and (xCh <= #$7F) then {Первая часть без изменений}
        xChr := xCh
      else
        if (xCh >= #$C0) and (xCh <= #$EF) then
          xChr := chr(ord(xCh) - Ap)
        else
          if (xCh >= #$F0) and (xCh <= #$FF) then
            xChr := chr(ord(xCh) - rya)
          else
            case ord(xCh) of
              $82: xChr := #$2C;
              $84: xChr := #$22;
              $93: xChr := #$22;
              $94: xChr := #$22;
              $AB: xChr := #$22;
              $BB: xChr := #$22;
              $85: if xL < 254 then xChr := #$2E#$2E#$2E
                   else xChr := #$2E;
              $8B: xChr := #$3C;
              $9B: xChr := #$3E;
              $91: xChr := #$27;
              $92: xChr := #$27;
              $95: xChr := #$F9;
              $96: xChr := #$C4;
              $97: xChr := #$C4;
              $A1: xChr := #$F6;
              $A2: xChr := #$F7;
              $A3: xChr := #$4A;
              $A4: xChr := #$FD;
              $A6: xChr := #$7C;
              $A8: xChr := #$F0;
              $A9: xChr := #$B0;
              $AA: xChr := #$F2;
              $AC: xChr := #$FB;
              $AD: xChr := #$2D;
              $AE: xChr := #$C1;
              $AF: xChr := #$F4;
              $B0: xChr := #$F8;
              $B2: xChr := #$49;
              $B3: xChr := #$69;
              $B5: xChr := #$B2;
              $B7: xChr := #$FA;
              $B8: xChr := #$F1;
              $B9: xChr := #$FC;
              $BA: xChr := #$F3;
              $BC: xChr := #$6A;
              $BD: xChr := #$53;
              $BE: xChr := #$73;
              $BF: xChr := #$F5;
            end;
      NStr := NStr + xChr;
    end;
  Str := NStr;
end;

end.

