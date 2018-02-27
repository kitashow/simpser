unit unit_test_cs;

{$mode delphi}
//{$codepage UTF8}

interface

uses
  Classes, SysUtils
  ,avk_btype
  ,unit_coolsprite
  ,zgl_keyboard
  ,zgl_file
  ;

type

  { TTestSpr }

  TTestSpr = class (avk_TFraim)
  public
    ManSpr  : clPSprite;
    ManFrm  : single;
    //HelmetSpr : clPSprite;
    //SwordSpr  : clPSprite;
    Xmove: Single;
  public
    procedure clSprite_SetParentDrawBefore( Sprite, Before : clPSprite );
    procedure clSprite_Remove( Sprite : clPSprite );
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
  public
    constructor Create (InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

implementation

{ TTestSpr }

procedure TTestSpr.clSprite_SetParentDrawBefore(Sprite, Before: clPSprite);
begin
  if Sprite.PrevDraw <> nil then Sprite.PrevDraw.NextDraw := Sprite.NextDraw;
  if Sprite.NextDraw <> nil then Sprite.NextDraw.PrevDraw := Sprite.PrevDraw;
  if Sprite.ParentDraw <> nil then
  begin
    if Sprite.ParentDraw.FDraw = Sprite then Sprite.ParentDraw.FDraw := Sprite.NextDraw;
    if Sprite.ParentDraw.LDraw = Sprite then Sprite.ParentDraw.LDraw := Sprite.PrevDraw;
  end;

  Sprite.NextDraw := Before;
  if Before <> nil then
  begin
    if Before.ParentDraw.FDraw = Before then Before.ParentDraw.FDraw := Sprite;
    if Before.PrevDraw <> nil then Before.PrevDraw.NextDraw := Sprite;
    Sprite.PrevDraw := Before.PrevDraw;
    Before.PrevDraw := Sprite;
  end else
  begin
    Sprite.PrevDraw := Sprite.ParentDraw.LDraw;
    Sprite.ParentDraw.LDraw.NextDraw := Sprite;
    Sprite.ParentDraw.LDraw := Sprite;
  end;
end;

procedure TTestSpr.clSprite_Remove(Sprite: clPSprite);
begin
  if Sprite.Prev <> nil then Sprite.Prev.Next := Sprite.Next;
  if Sprite.Next <> nil then Sprite.Next.Prev := Sprite.Prev;
  Sprite.Prev := nil;
  Sprite.Next := nil;
  if Sprite.Parent <> nil then
  begin
    if Sprite.Parent.FChild = Sprite then Sprite.Parent.FChild := Sprite.Next;
    if Sprite.Parent.LChild = Sprite then Sprite.Parent.LChild := Sprite.Prev;
    Sprite.Parent := nil;
  end;
  if Sprite.PrevDraw <> nil then Sprite.PrevDraw.NextDraw := Sprite.NextDraw;
  if Sprite.NextDraw <> nil then Sprite.NextDraw.PrevDraw := Sprite.PrevDraw;
  Sprite.PrevDraw := nil;
  Sprite.NextDraw := nil;
  if Sprite.ParentDraw <> nil then
  begin
    if Sprite.ParentDraw.FDraw = Sprite then Sprite.ParentDraw.FDraw := Sprite.NextDraw;
    if Sprite.ParentDraw.LDraw = Sprite then Sprite.ParentDraw.LDraw := Sprite.PrevDraw;
    Sprite.ParentDraw := nil;
  end;
end;

procedure TTestSpr.DoDraw(Sender: TObject);
begin
  clSprite_Calculate( ManSpr, Xmove, 750, 1, 0, ManFrm );
  clSprite_Draw( ManSpr );
end;

procedure TTestSpr.DoProc(Sender: TObject);
var
  HeadSpr : clPSprite;
  ArmSpr  : clPSprite;
begin
  ManFrm := ManFrm + ManSpr.AnimFPS * 4 / 1000;
  if ManFrm > ManSpr.EndFrame then ManFrm := ManSpr.StartFrame;

  //if key_Press( K_SPACE ) then
  //begin
  //  if HelmetSpr.Parent = nil then
  //  begin
  //    HeadSpr := clSprite_GetByID( ManSpr, 8 );
  //    clSprite_SetParent( HelmetSpr, HeadSpr );
  //    clSprite_SetParentDraw( HelmetSpr, HeadSpr );
  //
  //    ArmSpr := clSprite_GetByID( ManSpr, 10 );
  //    clSprite_SetParent( SwordSpr, ArmSpr );
  //    clSprite_SetParentDrawBefore( SwordSpr, ArmSpr );
  //    SwordSpr.Angle := 90;
  //    SwordSpr.X := 5;
  //    SwordSpr.Y := 40;
  //  end else
  //  begin
  //    clSprite_Remove( HelmetSpr );
  //    clSprite_Remove( SwordSpr );
  //  end;
  //end;

  //key_ClearState;
  Xmove :=   Xmove + 2;
  if Xmove > 1074 then Xmove := 0;
end;

constructor TTestSpr.Create(InParent: avk_TFraim);
begin
  inherited Create(InParent);
  file_OpenArchive('A_resources.zip');
  ManSpr  := clSprite_LoadFromFile( 'f.cls' );
  file_CloseArchive();
  Xmove := 0;
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor TTestSpr.Destroy;
begin
  //clSprite_ClearAll;
  inherited Destroy;
end;

end.

