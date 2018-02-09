{
модуль посредник м/у LNet и программой на ZGL
запускает сервер отдельным потоком с 0 ожидания
в рассчете на быстрые ответы
}

unit avk_server;

{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes, lNet;

type

TProcInMess = procedure( const InCommand: String = ''; InMessage: String = ''; InParent: TObject = nil ) of object;
TMessageInput = procedure (InMessage:String; InParent: TObject = nil) of object;
TDataInput = procedure (InData:TMemoryStream; InParent: TObject = nil) of object;

avk_TServer = class; //для связывания

{ TServThread }

TServThread = class(TThread)
private
  FServer: avk_TServer;
protected
  procedure Execute; override;
public
  constructor Create(CreateSuspended : boolean; aServer: avk_TServer);
end;

{ avk_TServer }

avk_TServer = class
private
  FImBusy: boolean;
  FPort: word;
  FServThread: TServThread;
  FCon: TLTCP; // THE server connection
  {  these are all events which happen on our server connection. They are called inside CallAction
   OnEr gets fired when a network error occurs.
   OnAc gets fired when a new connection is accepted on the server socket.
   OnRe gets fired when any of the server sockets receives new data.
   OnDs gets fired when any of the server sockets disconnects gracefully.
  }
  procedure OnEr(const msg: string; aSocket: TLSocket);
  procedure OnAc(aSocket: TLSocket);
  procedure OnRe(aSocket: TLSocket);
  procedure OnDs(aSocket: TLSocket);
public
  constructor Create(aPort: Integer);
  destructor Destroy; override;
  procedure Listen; // main loop with CallAction
private
  FEcho: boolean;
  FMesInput: TMessageInput;
  FError: TMessageInput;
  FDtInput: TDataInput;
  FNewConnect: TMessageInput;
  function FConnected: boolean;
  procedure FSetConnect(aConnect: boolean);
public
  property Echo: boolean read FEcho write FEcho;
  property Connected: boolean read FConnected write FSetConnect;
  property OnMessageInput:TMessageInput read FMesInput write FMesInput;
  property OnDataInput:TDataInput read FDtInput write FDtInput;
  property OnNewConnect:TMessageInput read FNewConnect write FNewConnect;
  property OnError:TMessageInput read FError write FError;
public
end;


implementation

function loc_IntToStr( Value : Integer ) : string;
begin
  Str( Value, Result );
end;

{ TServThread }

procedure TServThread.Execute;
begin
  while (not Terminated) do
    if FServer. FConnected then
      if not FServer.FImBusy then
        FServer.Listen;
end;

constructor TServThread.Create(CreateSuspended: boolean; aServer: avk_TServer);
begin
  inherited Create(CreateSuspended);
  FServer := aServer;
  Priority := tpLowest;
end;

{ avk_TServer }

procedure avk_TServer.OnEr(const msg: string; aSocket: TLSocket);
begin
  if Assigned(OnError) then OnError(msg, aSocket);
end;

procedure avk_TServer.OnAc(aSocket: TLSocket);
begin
  if Assigned(OnNewConnect) then OnNewConnect('Входящее соединение [' + aSocket.PeerAddress + ': ' + loc_IntToStr(aSocket.Handle) + ']', aSocket);
end;

procedure avk_TServer.OnRe(aSocket: TLSocket);
var
  s: string;
  n: Integer;
begin
  if aSocket.GetMessage(s) > 0 then begin
    if Assigned(OnMessageInput) then OnMessageInput(s, aSocket);
  end;
  if FEcho then begin
    FCon.IterReset; // now it points to server socket
    while FCon.IterNext do begin // while we have clients to echo to
      if FCon.Iterator = aSocket then Continue;
      n := FCon.SendMessage(s, FCon.Iterator);
      if n < Length(s) then // try to send to each of them
        OnEr(s, FCon.Iterator);
    end;
  end;
end;

procedure avk_TServer.OnDs(aSocket: TLSocket);
begin
  Writeln('Lost connection'); // write info if connection was lost
end;

function avk_TServer.FConnected: boolean;
begin
  result := FCon.Connected;
end;

procedure avk_TServer.FSetConnect(aConnect: boolean);
begin
  if aConnect = FConnected then Exit;
  if aConnect then
    FCon.Listen(FPort)
  else
    FCon.Disconnect;
end;

constructor avk_TServer.Create(aPort: Integer);
begin
  FPort := word(aPort);
  FImBusy := false;
  FEcho := false;
  FCon := TLTCP.Create(nil); // create new TCP connection
  FCon.OnError := OnEr;     // assign all callbacks
  FCon.OnReceive := OnRe;
  FCon.OnDisconnect := OnDs;
  FCon.OnAccept := OnAc;
  FCon.Timeout := 100; // responsive enough, but won't hog cpu
  FCon.ReuseAddress := True;
  FServThread := TServThread.Create(true, Self);
  if Assigned(FServThread.FatalException) then begin
    raise FServThread.FatalException;
  end;
  FServThread.Resume;
end;

destructor avk_TServer.Destroy;
begin
  FServThread.Destroy;
  FCon.Free; // free the TCP connection
  inherited Destroy;
end;

procedure avk_TServer.Listen;
begin
  FImBusy := true;
  if FConnected then begin // if listen went ok
    FCon.Callaction; // eventize the lNet
  end;
  FImBusy := false;
end;

end.

