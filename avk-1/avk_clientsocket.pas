{
 *  Copyright (c) 2013 Alexey Kitashov
 *
 *  This software is provided 'as-is', without any express or
 *  implied warranty. In no event will the authors be held
 *  liable for any damages arising from the use of this software.
 *
 *  Permission is granted to anyone to use this software for any purpose,
 *  including commercial applications, and to alter it and redistribute
 *  it freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented;
 *     you must not claim that you wrote the original software.
 *     If you use this software in a product, an acknowledgment
 *     in the product documentation would be appreciated but
 *     is not required.
 *
 *  2. Altered source versions must be plainly marked as such,
 *     and must not be misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any
 *     source distribution.
}

unit avk_clientsocket;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
   Sockets, Classes
   //,avk_gui
   ;

const
  BUFFER_SIZE = 262144;//1024;//Возможный размер входящих данных, чем ближе к килобайту тем лучше

type
// RU: Если есть необходимость использовать процедуры из класса то нужно раскомментировать определение
// EN: If there is need to use procedure of object you have to uncomment directive below
//{$D ObjectMode}
// RU:или задать директиву при компиляции -dObjectMode
// EN:or to use define during compilation -dObjectMode
// {$IfDef ObjectMode}
   TProcInMess = procedure( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil ) of object;
   TMessageInput = procedure (InMessage:String) of object;
   TDataInput = procedure (InData:TMemoryStream) of object;
 //{$Else}
 //  TProcInMess = procedure( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
 //  TMessageInput = procedure (InMessage:String);
 //  TDataInput = procedure (InData:TMemoryStream);
 //{$EndIf}

 { avk_TClSocket }

 avk_TClSocket = class
  private
    FHandle: Integer;
    FConnected: boolean;
    FPort: Integer;
    FHost: String;
    FSomeError: TProcInMess;
    FSomeCome: TProcInMess;
    FTimeOut: Integer;
    FLastMessWasRead: boolean;
    function GetMyIp: String;
    procedure SetTimeOut(InTimeOut:Integer);
    function GetSocketError: Integer;
  public
    DelBufferAfterRead: boolean;
    SocketCurrentSit: String;
    procedure Connect (const InHost:String = '127.0.0.1';const InPort: Word = 6638);
    procedure Disconnect;
    function ClientListen: boolean;
    function Get(out aData; const aSize: Integer): Integer;
    function GetMessage(out msg: string): Integer;
    function Send(const aData; const aSize: Integer): Integer;
    function SendMessage(const msg: string): Integer;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property SecSocketError: Integer read GetSocketError;
    property OnSomeError: TProcInMess read FSomeError write FSomeError;
    property OnSomeCome: TProcInMess read FSomeCome write FSomeCome;
    property Connected : boolean read FConnected;
    property Port: Integer read FPort;
    property Host: String read FHost;
    property MyIP: String read GetMyIp;
    property Timeout: Integer read FTimeOut write SetTimeOut;
  end;

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

 { avk_TClientSocket }

 avk_TClientSocket = class (avk_TClSocket)
 private
   FMesInput: TMessageInput;
   FDtInput: TDataInput;
   FListenThread: TSimpleThread;
 public
   procedure GetSomeCome ( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
   constructor Create;
   destructor Destroy; override;
 public
   property MessageInput:TMessageInput read FMesInput write FMesInput;
   property DataInput:TDataInput read FDtInput write FDtInput;
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
            //Exit;
          end else begin
            Disconnect;
            if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при прослушивании порта.',Self);
          end;
        end;
        if TmpRes > 0 then begin
          if Assigned(OnSomeCome) then
           if TmpPnt > 1 then
            OnSomeCome('Входящий пакет','По сети приплыла скорее всего строка',Self)
           else OnSomeCome('Входящий пакет','По сети приплыли данные',Self);
        end;
      end;
    end;
  end;
  FListSocket.SocketCurrentSit:='ЧТО ТО ХНЯ КАКАЯТО';
end;

constructor TSimpleThread.Create(CreateSuspended: boolean;
  inListSocket: avk_TClSocket);
begin
  inherited Create(CreateSuspended);
  FLastResListen:=0;
  FListSocket := inListSocket;
  Priority := tpLowest;
end;

destructor TSimpleThread.Destroy;
begin
  inherited Destroy;
end;

{ TConS73 }

procedure avk_TClientSocket.GetSomeCome(const InCommand: String; InMessage: String;
  InParent: TObject);
var
  TmpStr: String;
  HowMany: Integer;
  PbtAr: array of Byte;
  OutData: TMemoryStream;
begin
  if InMessage = 'По сети приплыла скорее всего строка' then begin
     if Assigned(MessageInput) then begin
       HowMany:=GetMessage(TmpStr);
       if HowMany > 0 then MessageInput(TmpStr);
     end;
  end else begin
    if Assigned(DataInput) then begin
      SetLength(PbtAr,BUFFER_SIZE);
      HowMany := Get(PbtAr[0],BUFFER_SIZE);
      OutData := TMemoryStream.Create;
      OutData.Write(PbtAr[0],HowMany);
      if HowMany > 0 then DataInput(OutData);
      SetLength(PbtAr,0);
      OutData.Destroy;
    end;
  end;
end;

constructor avk_TClientSocket.Create;
begin
 inherited Create;
 OnSomeCome:=@GetSomeCome;
 FListenThread:= TSimpleThread.Create(true,Self);
  if Assigned(FListenThread.FatalException) then begin
    raise FListenThread.FatalException;
  end;
  FListenThread.Resume;
end;

destructor avk_TClientSocket.Destroy;
begin
  Disconnect;
  while (not FListenThread.Terminated) do FListenThread.Terminate;
  FListenThread.Destroy;
  inherited Destroy;
end;

{ avk_TClSocket }

function avk_TClSocket.GetMyIp: String;
var
  Selfsocket: Integer;
  saddr:TInetSockAddr;
  WhatReturn: Integer;
  mysaddr:TInetSockAddr;
  MyWhatReturn: tsocklen;
begin
  if FHandle = -1 then begin
    selfsocket := fpSocket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    saddr.sin_family := AF_INET;
    saddr.sin_port := htons(Word(53));
    saddr.sin_addr.s_addr := Longword(StrToNetAddr('8.8.8.8'));//сервис google
    WhatReturn:= fpConnect(selfSocket,@saddr,SizeOf(TSockAddr));
  end else
    selfsocket := FHandle;
  MyWhatReturn:= SizeOf(TSockAddr);
  WhatReturn := fpgetsockname (selfsocket, @mysaddr, @MyWhatReturn);
  if WhatReturn <> 0 then
    Result := '127.0.0.1'
  else
    Result := NetAddrToStr(mysaddr.sin_addr);
end;

procedure avk_TClSocket.SetTimeOut(InTimeOut: Integer);
var
  kip: byte = 1;
begin
  FTimeOut := InTimeOut;
  if not FConnected then Exit;
  if fpsetsockopt(FHandle,SOL_SOCKET, SO_RCVTIMEO, @FTimeOut, sizeof(FTimeOut)) < 0 then
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при попытке назначения таймаута получения socket. ',Self);
  if fpsetsockopt(FHandle,SOL_SOCKET, SO_SNDTIMEO, @FTimeOut, sizeof(FTimeOut))<0  then
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при попытке назначения таймаута отправки socket. ',Self);
  if fpsetsockopt(FHandle,SOL_SOCKET, SO_KEEPALIVE, @kip, sizeof(kip))<0  then
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при попытке установки флага поддержания жизни socket. ',Self);
end;

function avk_TClSocket.GetSocketError: Integer;
begin
  Result := -1;
  Result := socketerror;
end;

procedure avk_TClSocket.Connect(const InHost: String; const InPort: Word);
var
  Selfsocket: Integer;
  saddr:TInetSockAddr;
  WhatReturn: Integer;
begin
  if FConnected then Disconnect;
  selfsocket := fpSocket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if selfsocket = -1 then
   begin
     if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при попытке создания socket. ',Self);
   end else
   begin
    saddr.sin_family := AF_INET;
    saddr.sin_port := htons(Word(InPort));
    saddr.sin_addr.s_addr := longword(StrToNetAddr(InHost));
    //if fpbind(selfSocket,@saddr,SizeOf(TSockAddr)) = 0 then begin
      WhatReturn:= fpConnect(selfSocket,@saddr,SizeOf(TSockAddr));
    //end else begin
      //WhatReturn:= -1;
    //end;
    //ioctlsocket
    if WhatReturn <> 0 then
     begin
       fpShutDown(selfSocket,2);
       if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при соединении socket. ',Self);
     end else
     begin
       FHandle := selfsocket;
       FConnected := true;
       FPort := InPort;
       FHost := InHost;
       SetTimeOut(FTimeOut);
     end;
   end;
end;

procedure avk_TClSocket.Disconnect;
begin
  FConnected := false;
  fpShutDown(FHandle,2);
  FHandle := -1;
end;

function avk_TClSocket.ClientListen: boolean;
var
  TmpRes: Integer;
  SortOfError: Integer;
  WhatRet: Longint;
  TmpPnt: Byte;
begin
  if not FLastMessWasRead then Exit;
  Result:=false;
  if not Connected then Exit;
  TmpRes := fprecv(FHandle, @TmpPnt, SizeOf(TmpPnt), MSG_PEEK);
  if TmpRes < 0 then begin
    SortOfError := socketerror;
    if SortOfError = $274C then begin
      //Это таймаут и надо бы проверить жив ли коннект
      //но "Помните, что TCP не выполняет опрос соединения."
      //Йон Снайдер. Эффективное программирование TCP-IP. стр 96
      Result := true;
      Exit;
    end;
    FHandle := -1;
    FConnected := false;
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Ошибка при прослушивании порта.',Self);
  end;
  if TmpRes = 0 then Result := true;
  if TmpRes > 0 then begin
    FLastMessWasRead := false;
    Result := true;
    if Assigned(OnSomeCome) then
     if TmpPnt > 1 then
      OnSomeCome('Входящий пакет','По сети приплыла скорее всего строка',Self)
     else OnSomeCome('Входящий пакет','По сети приплыли данные',Self)
  end;
end;

function avk_TClSocket.Get(out aData; const aSize: Integer): Integer;
var
  TmpFlag: Integer;
begin
  Result := 0;
  TmpFlag := MSG_PEEK;
  if DelBufferAfterRead then TmpFlag := 0;
  if aSize <= 0 then begin
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Кривой размер буфера входящего сообщения.',Self);
  end;
  FLastMessWasRead := true;
  Result := fprecv(FHandle, @aData, aSize, TmpFlag);
end;

function avk_TClSocket.GetMessage(out msg: string): Integer;
begin
  Result := 0;
  SetLength(msg, BUFFER_SIZE);
  SetLength(msg, Get(PChar(msg)^, Length(msg)));
  Result := Length(msg);
end;

function avk_TClSocket.Send(const aData; const aSize: Integer): Integer;
var
  TmpFlag: Integer;
begin
  Result := 0;
  if not Connected then Exit;
  //TmpFlag := MSG_PEEK;
  //if DelBufferAfterRead then TmpFlag := 0;
  TmpFlag := 0;
  if aSize <= 0 then
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Кривой размер буфера входящего сообщения.',Self);
  FLastMessWasRead := true;
  Result := fpsend(FHandle, @aData, aSize, TmpFlag);
  if Result < aSize then
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Исходящее сообщение отправлено не полностью.',Self);
  if Result < 0 then begin
    Disconnect;
    if Assigned(OnSomeError) then OnSomeError('Ошибка','Сервер не отозвался.',Self);
  end;
end;

function avk_TClSocket.SendMessage(const msg: string): Integer;
begin
  Result := Send(PChar(msg)^, Length(msg));
end;

constructor avk_TClSocket.Create;
begin
  FHandle := -1;
  FConnected := false;
  FPort := 0;
  FHost := '';
  FSomeError := nil;
  FSomeCome := nil;
  DelBufferAfterRead := true;
  FLastMessWasRead := true;
  FTimeOut:=1;
  SocketCurrentSit:='';
end;

destructor avk_TClSocket.Destroy;
begin
  if FConnected then Disconnect;
  inherited Destroy;
end;

end.

