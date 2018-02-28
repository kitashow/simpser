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
  public
    Xmove: Single;
    ManFrm  : single;
    ManSpr  : clTSprite;
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    constructor Create(const InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;


implementation

{ csp_TTestSpr }

procedure csp_TTestSpr.DoDraw(Sender: TObject);
begin
  clSprite_Calculate( @ManSpr, Xmove, 120, 0.3, 0.3, ManFrm );
  clSprite_Draw( @ManSpr );
end;

procedure csp_TTestSpr.DoProc(Sender: TObject);
begin
  ManFrm := ManFrm + ManSpr.AnimFPS * 4 / 1000;
  if ManFrm > ManSpr.EndFrame then ManFrm := ManSpr.StartFrame;
  Xmove :=   Xmove + 0.5;
  if Xmove > 1024 then Xmove := 0;
end;


constructor csp_TTestSpr.Create(const InParent: avk_TFraim);
begin
  inherited Create(InParent);
  file_OpenArchive('A_resources.zip');
  ManSpr  := clSprite_LoadFromFile( 'f.cls' )^;
  file_CloseArchive();
  Xmove := 0;
  ManFrm := 0;
  OnDraw := DoDraw;
  OnProc := DoProc;

end;

destructor csp_TTestSpr.Destroy;
begin
  clSprite_ClearAll;
  inherited Destroy;
end;

end.

