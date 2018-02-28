unit avk_coolspritetest;

{$mode delphi}
{$codepage UTF8}

interface

uses
  Classes, SysUtils
  ,avk_btype
  ,avk_cls
  ,zgl_keyboard
  ,zgl_file
  ;

type

  { csp_TTestSpr }

  csp_TTestSpr = class (avk_TFraim)
  private
    FDoBeforeProc: TNotifyEvent;
  public
    Xmove: Single;
    Ymove: Single;
    CSAngle: Single;
    Animate: boolean;
    ManFrm  : single;
    ManSpr  : clPSprite;
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
    property DoBeforeProc: TNotifyEvent read FDoBeforeProc write FDoBeforeProc;
  public
    constructor Create(const InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;


implementation

{ csp_TTestSpr }

procedure csp_TTestSpr.DoDraw(Sender: TObject);
begin
  clSprite_Draw( ManSpr );
end;

procedure csp_TTestSpr.DoProc(Sender: TObject);
begin
  if Assigned(FDoBeforeProc) then FDoBeforeProc(Self);
  if Animate then begin
    ManFrm := ManFrm + ManSpr^.AnimFPS * 4 / 1000;
    if ManFrm > ManSpr^.EndFrame then ManFrm := ManSpr^.StartFrame;
    clSprite_Calculate( ManSpr, Xmove, Ymove, 0.4, CSAngle, ManFrm );
  end else ManFrm := ManSpr^.EndFrame;
end;


constructor csp_TTestSpr.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  ManSpr  := nil;
  Xmove := 0;
  Ymove := 0;
  ManFrm := 0;
  OnDraw := DoDraw;
  OnProc := DoProc;
  Animate := false;
  CSAngle := 0;
  DoBeforeProc := nil;
end;

destructor csp_TTestSpr.Destroy;
begin
  inherited Destroy;
end;

end.

