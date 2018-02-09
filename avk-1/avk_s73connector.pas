unit avk_s73connector;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
  avk_clientsocket, Classes;
type
  {Если есть необходимость использовать процедуры из класса то нужно раскомментировать определение}
  //{$D ObjectMode}
  {или задать директиву при компиляции -dObjectMode}
  {$IfDef ObjectMode}
    TMessageInput = procedure (InMessage:String) of object;
  {$Else}
    TMessageInput = procedure (InMessage:String);
  {$EndIf}
  { TMyThread }

  { TSimpleThread }

  TSimpleThread = class(TThread)
  private
    FListSocket: avk_TClSocket;
    FLastResListen: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended : boolean; inListSocket: avk_TClSocket);
    destructor Destroy; override;
  end;

  { TConS73 }

  TConS73 = class (avk_TClSocket)
  private
    FMesInput: TMessageInput;
    FListenThread: TSimpleThread;
  public
    procedure GetSomeCome ( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
    constructor Create;
    destructor Destroy; override;
  public
    property MessageInput:TMessageInput read FMesInput write FMesInput;
  public

  end;

implementation

{ TSimpleThread }

procedure TSimpleThread.Execute;
var
  TmpRes: Integer;
  SortOfError: Integer;
  WhatRet: Longint;
  TmpPnt: Byte = 0;
  PreviousDelAfterRead: boolean;
begin
  while (not Terminated) do begin
  if (Assigned(FListSocket)) then
    if FListSocket.Connected then begin
      with FListSocket do begin
        PreviousDelAfterRead := DelBufferAfterRead;
        DelBufferAfterRead := false;
        TmpPnt := 0;
        TmpRes := Get( TmpPnt, SizeOf(TmpPnt));
        DelBufferAfterRead := PreviousDelAfterRead;
        if TmpRes < 0 then begin
          SortOfError := SecSocketError;
          if SortOfError = $274C then begin
            //Это таймаут и надо бы проверить жив ли коннект
            //но "Помните, что TCP не выполняет опрос соединения."
            //Йон Снайдер. Эффективное программирование TCP-IP. стр 96
            Exit;
          end;
          Disconnect;
          if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при прослушивании порта.',Self);
        end;
        if TmpRes > 0 then begin
          if Assigned(OnSomeCome) then
           if TmpPnt > 1 then
            OnSomeCome('Входящий пакет','По сети приплыла скорее всего строка',Self)
           else OnSomeCome('Входящий пакет','По сети приплыли данные',Self);
           if Assigned(OnSomeCome) then
            if TmpPnt > 1 then
             OnSomeCome('Входящий пакет','По сети приплыла скорее всего строка',Self)
            else OnSomeCome('Входящий пакет','По сети приплыли данные',Self);
        end;
      end;
    end;
  end;
end;

constructor TSimpleThread.Create(CreateSuspended: boolean;
  inListSocket: avk_TClSocket);
begin
  inherited Create(CreateSuspended);
  FLastResListen:=0;
  FListSocket := inListSocket;
end;

destructor TSimpleThread.Destroy;
begin
  inherited Destroy;
end;

{ TConS73 }

procedure TConS73.GetSomeCome(const InCommand: String; InMessage: String;
  InParent: TObject);
var
  TmpStr: String;
  HowMany: Integer;
begin
  if InMessage = 'По сети приплыла скорее всего строка' then begin
     if Assigned(MessageInput) then begin
       HowMany:=GetMessage(TmpStr);
       if HowMany > 0 then MessageInput(TmpStr);
     end;
  end else begin

  end;
end;

constructor TConS73.Create;
begin
 inherited Create;
 OnSomeCome:=@GetSomeCome;
 FListenThread:= TSimpleThread.Create(true,Self);
  if Assigned(FListenThread.FatalException) then begin
    raise FListenThread.FatalException;
  end;
  FListenThread.Resume;
end;

destructor TConS73.Destroy;
begin
  FListenThread.Destroy;
  inherited Destroy;
end;

end.

