{
 *  Copyright (c) 2017 Alexey Kitashov
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

unit avk_sockets;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
   {$ifdef WINDOWS}
     Winsock2,
   {$else} //android is unix
     BaseUnix, NetDB,
   {$endif}

   Sockets, Classes;

const
  BUFFER_SIZE = 262144;//Возможный размер входящих данных, чем ближе к килобайту тем лучше

type

TProcInMess = procedure( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil ) of object;
TMessageInput = procedure (InMessage:String; InParent: TObject = nil) of object;
TDataInput = procedure (InData:TMemoryStream; InParent: TObject = nil) of object;

 { avk_TSocket }

avk_TSocket = class
private
  FHandle: Integer;
  FConnected: boolean;
  FPort: Integer;
  FHost: String;
  FSomeError: TProcInMess;
  FSomeCome: TProcInMess;
  FTimeOut: Integer;
  FLastMessWasRead: boolean;
  FAddress: String;
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
private
  FMesInput: TMessageInput;
  FDtInput: TDataInput;
public
  procedure GetSomeCome ( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
public
  constructor Create;
  destructor Destroy; override;
public
  property Socket: Integer read FHandle;
  property SecSocketError: Integer read GetSocketError;
  property OnSomeError: TProcInMess read FSomeError write FSomeError;
  property OnSomeCome: TProcInMess read FSomeCome write FSomeCome;
  property Connected : boolean read FConnected;
  property Port: Integer read FPort;
  property Host: String read FHost;
  property MyIP: String read GetMyIp;
  property Timeout: Integer read FTimeOut write SetTimeOut;
public
  property OnMessageInput:TMessageInput read FMesInput write FMesInput;
  property OnDataInput:TDataInput read FDtInput write FDtInput;
end;

 { TSimpleThread }

TSimpleThread = class(TThread)
private
  FListSocket: avk_TSocket;
  FLastResListen: Integer;
protected
  procedure Execute; override;
public
  constructor Create(CreateSuspended : boolean; inListSocket: avk_TSocket);
end;

 { avk_TClientSocket }

avk_TClientSocket = class (avk_TSocket)
private
  FListenThread: TSimpleThread;
public
  constructor Create;
  destructor Destroy; override;
end;

{ avk_TSrvSocket }

avk_TSrvSocket = class
private
  FHandle: Integer;
  FConnected: boolean;
  FPort: Integer;
  FSomeError: TProcInMess;
  FSomeCome: TProcInMess;
  FNewConnect: TMessageInput;
  FListSocket: TStringList;
  function GetSocket(InID: Integer): avk_TSocket;
  function GetSocketError: Integer;
protected //NoBlockingSocket
  FReadFDSet: TFDSet;
  FWriteFDSet: TFDSet;
  FErrorFDSet: TFDSet;
private
  function ClSocketCreate(aSocket: Integer; aSAddr: TInetSockAddr): avk_TSocket;
  procedure FReError(const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil );
  procedure FError(aMessage: String);
public
  function Connect(aPort: Integer): boolean;
  function ServerAccept: boolean;
  function ServerListen: boolean;
  procedure Disconnect;
public
  constructor Create(aPort:Integer = 6638);
  destructor Destroy; override;
protected
  property ListSockets: TStringList read FListSocket;
public
  property ClSocket[InID :Integer]: avk_TSocket read GetSocket;
  property OnSomeError: TProcInMess read FSomeError write FSomeError;
  property OnSomeCome: TProcInMess read FSomeCome write FSomeCome;
  property Connected : boolean read FConnected;
  property Port: Integer read FPort;
  procedure EchoMessage(aExeptSocketID: Integer; aMessage: String);
  //procedure EchoMessage(aExeptSocketID :Integer);
private
  FMesInput: TMessageInput;
  FDtInput: TDataInput;
public
  property OnMessageInput:TMessageInput read FMesInput write FMesInput;
  property OnDataInput:TDataInput read FDtInput write FDtInput;
  property OnNewConnect:TMessageInput read FNewConnect write FNewConnect;
end;

{ TServThread }

TServThread = class(TThread)
private
  FAssepter: boolean;
  FListSocket: avk_TSrvSocket;
protected
  procedure Execute; override;
public
  constructor Create(CreateSuspended : boolean; inAccSocket: avk_TSrvSocket; IsAccept: boolean);
end;

{ avk_TServerSocket }

avk_TServerSocket = class (avk_TSrvSocket)
private
  FAcceptThread: TServThread;
  FListenThread: TServThread;
public
  constructor Create;
  destructor Destroy; override;
end;

{$IFDEF WINDOWS}
function fpSelect(const nfds: Integer; const readfds, writefds, exceptfds: PFDSet;
                  const timeout: PTimeVal): Integer; inline;
function fpFD_ISSET(const Socket: Integer; var FDSet: TFDSet): Integer; inline;
procedure fpFD_SET(const Socket: Integer; var FDSet: TFDSet); inline;
procedure fpFD_ZERO(var FDSet: TFDSet); inline;
{$ENDIF}


implementation

{$ifdef WINDOWS}

function SetBlocking(const aHandle: Integer; const aValue: Boolean): Boolean;
const
  BlockAr: array[Boolean] of DWord = (1, 0);
var
  opt: DWord;
begin
  opt := BlockAr[aValue];
  if ioctlsocket(aHandle, Longint(FIONBIO), opt) = SOCKET_ERROR then
    Exit(False);
  Result := True;
end;

function fpSelect(const nfds: Integer; const readfds, writefds, exceptfds: PFDSet;
                  const timeout: PTimeVal): Longint; inline;
begin
  Result := Select(nfds, readfds, writefds, exceptfds, timeout);
end;

function fpFD_ISSET(const Socket: Longint; var FDSet: TFDSet): Integer; inline;
begin
  Result := 0;
  if FD_ISSET(Socket, FDSet) then
    Result := 1;
end;

procedure fpFD_SET(const Socket: Longint; var FDSet: TFDSet); inline;
begin
  FD_SET(Socket, FDSet);
end;

procedure fpFD_ZERO(var FDSet: TFDSet); inline;
begin
  FD_ZERO(FDSet);
end;

{$else}

function SetBlocking(const aHandle: Integer; const aValue: Boolean): Boolean;
var
  opt: cInt;
begin
  opt := fpfcntl(aHandle, F_GETFL);
  if opt = SOCKET_ERROR then
    Exit(False);

  if aValue then
    opt := opt and not O_NONBLOCK
  else
    opt := opt or O_NONBLOCK;

  if fpfcntl(aHandle, F_SETFL, opt) = SOCKET_ERROR then
    Exit(False);
  Result := True;
end;

{$endif}


{ avk_TSocket }

function avk_TSocket.GetMyIp: String;
var
  Selfsocket: Integer;
  saddr:TInetSockAddr;
  WhatReturn: Integer;
  mysaddr:TInetSockAddr;
  MyWhatReturn: tsocklen;
begin
  if not (FAddress = '') then begin
    Result := FAddress;
    Exit;
  end;
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
  else begin
    Result := NetAddrToStr(mysaddr.sin_addr);
    FAddress := Result;
  end;
end;

procedure avk_TSocket.SetTimeOut(InTimeOut: Integer);
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

function avk_TSocket.GetSocketError: Integer;
begin
  Result := -1;
  Result := socketerror;
end;

procedure avk_TSocket.Connect(const InHost: String; const InPort: Word);
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
    {$ifdef BlockingSocket}
    SetBlocking(Selfsocket, false);
    {$else}//NoBlockingSocket
    SetBlocking(Selfsocket, true);
    {$endif}
    saddr.sin_family := AF_INET;
    saddr.sin_port := htons(Word(InPort));
    saddr.sin_addr.s_addr := longword(StrToNetAddr(InHost));
    WhatReturn:= fpConnect(selfSocket,@saddr,SizeOf(TSockAddr));
    if WhatReturn <> 0 then
     begin
       CloseSocket(Selfsocket);
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

procedure avk_TSocket.Disconnect;
begin
  FConnected := false;
  CloseSocket(FHandle);
  FHandle := -1;
end;

function avk_TSocket.ClientListen: boolean;
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
    CloseSocket(FHandle);
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

function avk_TSocket.Get(out aData; const aSize: Integer): Integer;
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

function avk_TSocket.GetMessage(out msg: string): Integer;
begin
  Result := 0;
  SetLength(msg, BUFFER_SIZE);
  SetLength(msg, Get(PChar(msg)^, Length(msg)));
  Result := Length(msg);
end;

function avk_TSocket.Send(const aData; const aSize: Integer): Integer;
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

function avk_TSocket.SendMessage(const msg: string): Integer;
begin
  Result := Send(PChar(msg)^, Length(msg));
end;

procedure avk_TSocket.GetSomeCome(const InCommand: String; InMessage: String;
  InParent: TObject);
var
  TmpStr: String;
  HowMany: Integer;
  PbtAr: array of Byte;
  OutData: TMemoryStream;
begin
  if InMessage = 'По сети приплыла скорее всего строка' then begin
     if Assigned(OnMessageInput) then begin
       HowMany:=GetMessage(TmpStr);
       if HowMany > 0 then OnMessageInput(TmpStr, Self);
     end;
  end else begin
    if Assigned(OnDataInput) then begin
      SetLength(PbtAr,BUFFER_SIZE);
      HowMany := Get(PbtAr[0],BUFFER_SIZE);
      OutData := TMemoryStream.Create;
      OutData.Write(PbtAr[0],HowMany);
      if HowMany > 0 then OnDataInput(OutData, Self);
      SetLength(PbtAr,0);
      OutData.Destroy;
    end;
  end;
end;

constructor avk_TSocket.Create;
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
  FAddress := '';
  OnSomeCome := @GetSomeCome;
end;

destructor avk_TSocket.Destroy;
begin
  if FConnected then Disconnect;
  inherited Destroy;
end;

{ avk_TSrvSocket }

function avk_TSrvSocket.GetSocket(InID: Integer): avk_TSocket;
var
  Header: String;
  OutId: Integer;
begin
  Result := nil;
  if InID < 1 then Exit; //сокета 0 вроде нет
  Header := '';
  Str(InID, Header);
  OutId := -1;
  if FListSocket.Find(Header, OutId) then
    Result := avk_TSocket(FListSocket.Objects[OutId]);
end;

function avk_TSrvSocket.GetSocketError: Integer;
begin
  Result := -1;
  Result := socketerror;
end;

function avk_TSrvSocket.ClSocketCreate(aSocket: Integer; aSAddr: TInetSockAddr): avk_TSocket;
var
  TempStr: String;
begin
  Result := avk_TSocket.Create;
  //в теле можно регулировать скрытые
  Result.FConnected := true;
  Result.FHandle := aSocket;
  Result.FLastMessWasRead := true;
  TempStr := NetAddrToStr(aSAddr.sin_addr);
  Result.FAddress := TempStr;
  Result.OnSomeError := @FReError;
  Result.OnMessageInput := OnMessageInput;
  Result.OnDataInput := OnDataInput;
end;

procedure avk_TSrvSocket.FReError(const InCommand: String;
  InMessage: String; InParent: TObject);
var
  Header: String;
  Message: String;
begin
  Header := '';
  Str(GetSocketError, Header);
  Header:= InCommand + ': ' + Header;
  Message := '';
  Str(avk_TSocket(InParent).Socket, Message);
  Message := 'Socket: ' + Message + ',с адреса: ' + avk_TSocket(InParent).GetMyIp + '. ' + InMessage;
  if Assigned(OnSomeError) then OnSomeError(Header, Message, InParent)
  {$IfDef Debug}
  else raise EComponentError.Create(Message);
  {$Else}
  ;
  {$EndIf}
end;

procedure avk_TSrvSocket.FError(aMessage: String);
var
  Header: String;
begin
  Header := '';
  Str(GetSocketError, Header);
  Header:= 'Ошибка: ' + Header;
  if Assigned(OnSomeError) then OnSomeError(Header, aMessage, Self)
  {$IfDef Debug}
  else raise EComponentError.Create(aMessage);
  {$Else}
  ;
  {$EndIf}
end;

function avk_TSrvSocket.Connect(aPort: Integer): boolean;
var
  Selfsocket: Integer;
   saddr:TInetSockAddr;
  WhatReturn: Integer;
  opt: longint;
begin
  if FConnected then Disconnect;
  selfsocket := fpSocket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  if selfsocket = -1 then begin
    FError('Ошибка при попытке создания server socket.');
  end else begin
    {$ifdef BlockingSocket}
    SetBlocking(Selfsocket, false);
    {$else}//NoBlockingSocket
    SetBlocking(Selfsocket, true);
    {$endif}
    opt := 1;
    if fpsetsockopt(selfsocket, SOL_SOCKET, SO_REUSEADDR, @opt, sizeof(opt))<0 then
       FError('Ошибка при попытке установки флага повторного использования адреса серверного socket. ');
  end;
  saddr.sin_family := AF_INET;
  saddr.sin_port := htons(Word(aPort));
  saddr.sin_addr.s_addr := HostToNet((127 shl 24) or 1);//это ж сервер, 127.0.0.1
  if fpBind(selfSocket,@saddr,SizeOf(TSockAddr)) = -1 then
    FError('Ошибка bind.');
  WhatReturn := fpListen(selfSocket, 1);
  Result := not WhatReturn = -1;
  if not Result then begin
    CloseSocket(selfSocket);
    Disconnect;
    FError('Ошибка Listen.');
  end else begin
    FHandle := selfsocket;
    FPort := aPort;
    FConnected := true;
  end;
end;

function avk_TSrvSocket.ServerAccept: boolean;
var
  saddr:TInetSockAddr;
  sizeofSockAdr: Integer;
  Client: Integer;
  Header: String;
begin
  Result := true;
  saddr.sin_family := AF_INET;
  saddr.sin_port := htons(Word(FPort));
  saddr.sin_addr.s_addr := HostToNet((127 shl 24) or 1);//просто инициализация
  sizeofSockAdr := sizeof(saddr);
  Client:=fpaccept(FHandle, @saddr, @sizeofSockAdr);
  if Client < 0 then begin
    //Пробуем переоткрыть ???
    CloseSocket(Client);
    Exit;
  end else
    if ClSocket[Client] = nil then begin
      Header := '';
      Str(Client, Header);
      FListSocket.AddObject(Header, ClSocketCreate(Client, saddr));
      if Assigned(OnNewConnect) then OnNewConnect(ClSocket[Client].GetMyIp + ': '+ Header, ClSocket[Client]);
    end;
end;

function avk_TSrvSocket.ServerListen: boolean;
var
  CKL: Integer;
  TMPSocket: Integer;
  MaxSocket: Integer;

  procedure inFD_Set(aSocket: Integer);
  begin
    //устанавливаем
    fpFD_SET(aSocket, FWriteFDSet);
    fpFD_SET(aSocket, FReadFDSet);
    fpFD_SET(aSocket, FErrorFDSet);
    if TMPSocket > MaxSocket then MaxSocket := TMPSocket;
  end;

  procedure inListIvent(aSocket: Integer);
  begin
    if fpFD_ISSET(aSocket, FWriteFDSet) <> 0 then begin
       //нужно вызвать событие запись... что это вообще
    end;
    if fpFD_ISSET(aSocket, FReadFDSet) <> 0 then
      if Assigned(FSomeCome) then
        FSomeCome(Temp);
    if fpFD_ISSET(aSocket, FErrorFDSet) <> 0 then
      if Assigned(FSomeError) then
        FSomeError(aSocket, 'Handle error' + LStrError(LSocketError));
  end;

begin
  Result := true;
  {$ifndef BlockingSocket} //обнуляем
  fpFD_ZERO(FReadFDSet);
  fpFD_ZERO(FWriteFDSet);
  fpFD_ZERO(FErrorFDSet);
  TMPSocket := FHandle;
  MaxSocket := 0;
  inFD_Set(TMPSocket);
  {$endif}
  for CKL := 0 to FListSocket.Count - 1 do begin
    {$ifdef BlockingSocket}
    if Assigned(avk_TSocket(FListSocket.Objects[CKL])) then
       Result := avk_TSocket(FListSocket.Objects[CKL]).ClientListen and Result;
    {$else}//NoBlockingSocket
    TMPSocket := avk_TSocket(FListSocket.Objects[CKL]).Socket;
    inFD_Set(TMPSocket);
    {$endif}
  end;
  {$ifndef BlockingSocket}
  n := fpSelect(MaxSocket + 1, @FReadFDSet, @FWriteFDSet, @FErrorFDSet, nil);

  if n < 0 then
    FError('Ошибка при select.');

  Result := n > 0;
  if Result then begin
    Temp := FHandle;
    for CKL := 0 to FListSocket.Count - 1 do begin
      TMPSocket := avk_TSocket(FListSocket.Objects[CKL]).Socket;
      inListIvent(TMPSocket);
    end;
  end;
  {$endif}
end;

procedure avk_TSrvSocket.Disconnect;
var
  CKL: Integer;
begin
  FConnected := false;
  for CKL := 0 to FListSocket.Count -1 do begin
    avk_TSocket(FListSocket.Objects[CKL]).FConnected := false;
    CloseSocket(avk_TSocket(FListSocket.Objects[CKL]).Socket);
  end;
  FListSocket.Clear;
  CloseSocket(FHandle);
  FHandle := -1;
end;

constructor avk_TSrvSocket.Create(aPort: Integer);
begin
  FHandle := -1;
  FConnected := false;
  FPort := 0;
  FSomeError := nil;
  FSomeCome := nil;
  FListSocket := TStringList.Create;
  FListSocket.Sorted := true;
end;

destructor avk_TSrvSocket.Destroy;
begin
  Disconnect;
  FListSocket.Destroy;
  inherited Destroy;
end;

procedure avk_TSrvSocket.EchoMessage(aExeptSocketID: Integer; aMessage: String);
var
  CKL: Integer;
begin
  for CKL := 0 to (FListSocket.Count - 1) do
    if not avk_TSocket(FListSocket.Objects[CKL]).Socket = aExeptSocketID then
      avk_TSocket(FListSocket.Objects[CKL]).SendMessage(aMessage);
end;

{ TSimpleThread }

procedure TSimpleThread.Execute;
var
  TmpRes: Integer;
  SortOfError: Integer;
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
  inListSocket: avk_TSocket);
begin
  inherited Create(CreateSuspended);
  FLastResListen:=0;
  FListSocket := inListSocket;
  Priority := tpLowest;
end;

{ TServThread }

procedure TServThread.Execute;
begin
  while (not Terminated) do
    if FListSocket.Connected then
      Case FAssepter of
        true: FListSocket.ServerAccept;
        false: if FListSocket.ListSockets.Count > 0 then FListSocket.ServerListen;
      end;
end;

constructor TServThread.Create(CreateSuspended: boolean;
  inAccSocket: avk_TSrvSocket; IsAccept: boolean);
begin
  inherited Create(CreateSuspended);
  FListSocket := inAccSocket;
  FAssepter := IsAccept;
  Priority := tpLowest;
end;

{ avk_TClientSocket }

constructor avk_TClientSocket.Create;
begin
 inherited Create;
 FListenThread:= TSimpleThread.Create(true,Self);
 if Assigned(FListenThread.FatalException) then begin
   raise FListenThread.FatalException;
 end;
 FListenThread.Resume;
end;

destructor avk_TClientSocket.Destroy;
begin
  Disconnect;
  //while (not FListenThread.Terminated) do FListenThread.Terminate;
  FListenThread.Destroy;
  inherited Destroy;
end;

{ avk_TServerSocket }

constructor avk_TServerSocket.Create;
begin
  inherited Create;
  //подключения
  FAcceptThread := TServThread.Create(true, Self, true);
   if Assigned(FAcceptThread.FatalException) then begin
     raise FAcceptThread.FatalException;
   end;
  FAcceptThread.Resume;
  //обмены
  FListenThread:= TServThread.Create(true, Self, false);
   if Assigned(FListenThread.FatalException) then begin
     raise FListenThread.FatalException;
   end;
  FListenThread.Resume;
end;

destructor avk_TServerSocket.Destroy;
begin
  Disconnect;
  FListenThread.Destroy;
  FAcceptThread.Destroy;
  inherited Destroy;
end;

end.

