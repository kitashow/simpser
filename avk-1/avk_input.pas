unit avk_input;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
 {$ifdef TOUCHSCREEN}
  zgl_touch,
 {$endif}
 {$ifdef MOUSE3KEY}
  zgl_mouse,
 {$endif}
  zgl_keyboard,
  zgl_primitives_2d,
  zgl_math_2d,
  zgl_collision_2d;

const
  M_BLEFT   = 0;
  M_BMIDDLE = 1;
  M_BRIGHT  = 2;

var
  FingerAnalyses: byte = 2;

  function avk_MouseIsX (inFinger: Byte = 0): Integer;
  function avk_MouseIsY (inFinger: Byte = 0): Integer;

  function avk_MouseIsDown( Button : Byte; inFinger: Byte = 0 ) : Boolean;
  function avk_MouseIsUp( Button : Byte; inFinger: Byte = 0 ) : Boolean;
  function avk_MouseIsClick( Button : Byte; inFinger: Byte = 0 ) : Boolean;
  function avk_MouseIsDblClick( Button : Byte = 0) : Boolean;

  function avk_MouseInRect( InRect:zglTRect; inFinger: Byte = 0 ) : Boolean; overload;
  function avk_MouseInRect( InX,InY,InW,InH: Single; inFinger: Byte = 0 ) : Boolean; overload;

  procedure avk_ClearAllStates;

implementation

function loc_UserTap( inFinger: Byte = 0): boolean;
var
  TmpFor: byte;
begin
  Result := false;
  {$ifdef TOUCHSCREEN}
    for TmpFor:=0 to FingerAnalyses do Result:= Result or touch_Tap( TmpFor );
  {$endif}
end;

function loc_TouchDown( inFinger: Byte = 0): boolean;
var
  TmpFor: byte;
begin
  Result := false;
  {$ifdef TOUCHSCREEN}
    for TmpFor:=0 to FingerAnalyses do Result:= Result or touch_Down( TmpFor );
  {$endif}
end;

function loc_TouchUp( inFinger: Byte = 0): boolean;
var
  TmpFor: byte;
begin
  Result := false;
  {$ifdef TOUCHSCREEN}
    for TmpFor:=0 to FingerAnalyses do Result:= Result or touch_Up( TmpFor );
  {$endif}
end;

function avk_MouseIsX(inFinger: Byte = 0): Integer;
begin
  Result:= 0;
  {$ifdef TOUCHSCREEN}
  Result:=touch_X(inFinger);
  {$endif}
  {$ifdef MOUSE3KEY}
  if Result = 0 then Result:= mouse_X;
  {$endif}
end;

function avk_MouseIsY(inFinger: Byte = 0): Integer;
begin
  Result:= 0;
  {$ifdef TOUCHSCREEN}
  Result:=touch_Y(inFinger);
  {$endif}
  {$ifdef MOUSE3KEY}
  if Result = 0 then Result:=mouse_Y;
  {$endif}
end;

function avk_MouseIsDown(Button: Byte; inFinger: Byte = 0): Boolean;
begin
  Result:=false;
  {$ifdef TOUCHSCREEN}
  Result:=loc_TouchDown(inFinger);
  {$endif}
  {$ifdef MOUSE3KEY}
  Result:=Result or mouse_Down ( Button );
  {$endif}
end;

function avk_MouseIsUp(Button: Byte; inFinger: Byte = 0): Boolean;
begin
  Result:=false;
  {$ifdef TOUCHSCREEN}
  Result:=loc_TouchUp(inFinger);
  {$endif}
  {$ifdef MOUSE3KEY}
  Result:=Result or mouse_Up ( Button );
  {$endif}
end;

function avk_MouseIsClick(Button: Byte; inFinger: Byte = 0): Boolean;
begin
  {$ifdef TOUCHSCREEN}
  Result:=loc_UserTap(inFinger);
  {$endif}
  {$ifdef MOUSE3KEY}
  Result:= mouse_Click( Button );
  {$endif}
end;

function avk_MouseIsDblClick(Button: Byte = 0): Boolean;
begin
  {$ifdef TOUCHSCREEN}
  Result:=false;
  {$endif}
  {$ifdef MOUSE3KEY}
  Result:= mouse_DblClick( Button );
  {$endif}
end;

function avk_MouseInRect(InRect: zglTRect; inFinger: Byte = 0): Boolean;
var
  TmpFor: byte;
begin
  Result:=false;
  for TmpFor:=0 to FingerAnalyses do Result:= Result or col2d_PointInRect(avk_MouseIsX( TmpFor ),avk_MouseIsY( TmpFor ),InRect);
end;

function avk_MouseInRect(InX, InY, InW, InH: Single; inFinger: Byte = 0): Boolean;
var
  TmpZTRect:zglTRect;
begin
  with TmpZTRect do begin
    X:=InX;Y:=InY;W:=InW;H:=InH;
  end;
  Result:=avk_MouseInRect(TmpZTRect);
end;

procedure avk_ClearAllStates;
begin
  {$ifdef TOUCHSCREEN}
  touch_ClearState();
  {$endif}
  {$ifdef MOUSE3KEY}
  mouse_ClearState();
  {$endif}
  key_ClearState;
end;

end.

