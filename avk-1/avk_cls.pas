{Взято из
http://zengl.org/forum/index.php/topic,297.0.html}

unit avk_cls;

{$mode delphi}
{$codepage UTF8}

interface

uses
  SysUtils
  ,Classes
  {блок зенгл}
  ,zgl_main
  ,zgl_render_2d
  ,zgl_types
  ,zgl_math_2d
  ,zgl_textures
  ,zgl_textures_png
  ,zgl_textures_jpg
  ,zgl_textures_tga
  ,zgl_font, zgl_utils,
  zgl_primitives_2d, zgl_fx, zgl_text,
  zgl_resources, zgl_file
  ;

type
  clPTexture = ^clTTexture;
  clTTexture = record
    FileName  : string;
    Tex       : zglPTexture;
    Next      : clPTexture;
  end;

type
  clMatrix = record
    a11, a12, a13 : single;
    a21, a22, a23 : single;
    a31, a32, a33 : single;
  end;

var
  M_Identity : clMatrix = ( a11 : 1; a12 : 0; a13 : 0;
                            a21 : 0; a22 : 1; a23 : 0;
                            a31 : 0; a32 : 0; a33 : 1 );

type
  clPFrame = ^clTFrame;
  clTFrame = record
    v        : array of zglTPoint2D;
    vCnt     : byte;
    TriList  : array of zglTPoint2D;
    TexCrds  : array of zglTPoint2D;
    TriPos   : array of zglTPoint2D;
    tvCnt    : byte;
    CenterX  : single;
    CenterY  : single;
    Next     : clPFrame;
  end;

type
  kfTCurveType = ( kfcInstant, kfcLinear, kfcSmooth );

type
  clPKeyFrame = ^clTKeyFrame;
  clTKeyFrame = record
    N     : integer;
    cType : kfTCurveType;
    S1    : single;
    S2    : single;
    Next  : clPKeyFrame;
  end;

type
  clPSprite = ^clTSprite;
  clTSprite = record
    ID         : word;
    Name       : string;
    Texture    : clPTexture;
    X, Y       : single;
    Angle      : single;
    ScaleX     : single;
    ScaleY     : single;
    FlipX      : boolean;
    FlipY      : boolean;
    SMatrix    : clMatrix;
    Matrix     : clMatrix;
    Visible    : boolean;
    InheritVis : boolean;

    Frames     : clPFrame;
    CurFrame   : clPFrame;

    Frame      : single;
    StartFrame : integer;
    EndFrame   : integer;
    Animated   : boolean;
    AnimFPS    : integer;
    AnimSpeed  : single;

    PosKF      : clPKeyFrame;
    AngKF      : clPKeyFrame;
    SclKF      : clPKeyFrame;
    FlXKF      : clPKeyFrame;
    FlYKF      : clPKeyFrame;
    VisKF      : clPKeyFrame;
    FrmKF      : clPKeyFrame;
    AnmKF      : clPKeyFrame;

    Parent     : clPSprite;
    FChild     : clPSprite;
    LChild     : clPSprite;
    Next       : clPSprite;
    Prev       : clPSprite;

    ParentDraw : clPSprite;
    FDraw      : clPSprite;
    LDraw      : clPSprite;
    NextDraw   : clPSprite;
    PrevDraw   : clPSprite;

    ListNext   : clPSprite;
    ListPrev   : clPSprite;
  end;

function clTexture_Load( FileName : string ) : clPTexture;
function clTexture_Get( FileName : string ) : clPTexture;
function clFrame_Create : clPFrame;
procedure clFrame_Del( frm : clPFrame );
procedure clFrame_AddVertex( Frame : clPFrame; X, Y : single );
procedure clFrame_Triangulate( Frame : clPFrame; Tex : zglPTexture );
function clSprite_Create : clPSprite;
procedure clSprite_Del( Sprite : clPSprite; DelChild : boolean = true );
procedure clSprite_SetParent( Sprite, Parent : clPSprite );
procedure clSprite_SetParentDraw( Sprite, ParentDraw : clPSprite );
function clSprite_GetByID( Sprite : clPSprite; id : word ) : clPSprite;
function clM_FromAngle( Angle : single ) : clMatrix;
function clM_Mul( M1, M2 : clMatrix ) : clMatrix;
function clM_Inverse( M : clMatrix ) : clMatrix;
function clM_VMul( v : zglTPoint2D; M : clMatrix ) : zglTPoint2D;
procedure clSprite_Calculate( Sprite : clPSprite; X, Y, Scale, Angle, Frame : Single; FlipX : boolean = false ); overload;
procedure clSprite_Calculate( Sprite : clPSprite ); overload;
procedure clSprite_Draw( Sprite : clPSprite );
function clSprite_LoadFromFile( FileName : string ) : clPSprite;
procedure clSprite_ClearAll;

procedure SetBufferCoolSprite(const AFileName: String; var AValue: String; var AValSize: Integer);
function clSprite_LoadFromBuffer( AValue: string; AValSize: Integer; ATexManager: TObject) : clPSprite;

var
  clTexList : clPTexture;
  clSprList : clPSprite;

implementation

uses
  avk_resmanager;


function clTexture_Load( FileName : string ) : clPTexture;
var
  ct : clPTexture;
begin
  New( ct );
  ct.FileName := FileName;
  ct.Tex      := tex_LoadFromFile( FileName );
  ct.Next     := clTexList;
  clTexList   := ct;
  Result      := ct;

end;

function clTexture_Get( FileName : string ) : clPTexture;
begin
  Result := nil;
  Result := clTexList;
  while Result <> nil do
  begin
    if Result.FileName = FileName then Exit;
    Result := Result.Next;
  end;

end;

function clFrame_Create : clPFrame;
var
  frm : clPFrame;
begin
  New( frm );
  frm.vCnt    := 0;
  frm.tvCnt   := 0;
  frm.CenterX := 0;
  frm.CenterY := 0;
  frm.Next    := nil;
  Result      := frm;
end;

procedure clFrame_Del( frm : clPFrame );
begin
  SetLength( frm.v, 0 );
  SetLength( frm.TriList, 0 );
  SetLength( frm.TexCrds, 0 );
  SetLength( frm.TriPos, 0 );
  frm.Next := nil;
  Dispose( frm );
end;

procedure clFrame_AddVertex( Frame : clPFrame; X, Y : single );
begin
  SetLength( Frame.v, Frame.vCnt + 1 );
  Frame.v[ Frame.vCnt ].X := X;
  Frame.v[ Frame.vCnt ].Y := Y;
  INC( Frame.vCnt );
end;

procedure clFrame_Triangulate( Frame : clPFrame; Tex : zglPTexture );
var
  vertices : zglPPoints2D;
  i        : integer;
  w, h     : single;
begin
  vertices := nil;

  if Tex = nil then Exit;

  tess_Triangulate( @Frame.v[ 0 ], 0, Frame.vCnt - 1 );
  //tess_Triangulate( Frame.v[ 0 ], 0, Frame.vCnt - 1 );
  Frame.tvCnt := tess_GetData( vertices );

  SetLength( Frame.TriList, Frame.tvCnt );
  SetLength( Frame.TriPos, Frame.tvCnt );
  for i := 0 to Frame.tvCnt - 1 do
  begin
    Frame.TriList[ i ] := vertices[ i ];
    Frame.TriPos[ i ]  := vertices[ i ];
  end;

  SetLength( Frame.TexCrds, Frame.tvCnt );
  w := 1 / ( Tex.Width / Tex.U );
  h := 1 / ( Tex.Height / Tex.V );
  for i := 0 to Frame.tvCnt - 1 do
  begin
    Frame.TexCrds[ i ].X := vertices[ i ].X * w;
    Frame.TexCrds[ i ].Y := Tex.V - vertices[ i ].Y * h;
  end;

  {$IFDEF FPC}
  {http://zengl.org/forum/index.php/topic,297.msg4060.html#msg4060}
  //очитка памяти
  zgl_FreeMem(vertices);
  {$EndIf}

end;

function clSprite_Create : clPSprite;
var
  cs : clPSprite;
begin
  New( cs );
  cs.Name       := '';
  cs.ID         := 0;
  cs.Texture    := nil;
  cs.X          := 0;
  cs.Y          := 0;
  cs.Angle      := 0;
  cs.ScaleX     := 1;
  cs.ScaleY     := 1;
  cs.FlipX      := false;
  cs.FlipY      := false;
  cs.Matrix     := M_Identity;
  cs.SMatrix    := M_Identity;
  cs.Visible    := true;
  cs.InheritVis := true;

  cs.Frames     := nil;
  cs.CurFrame   := nil;

  cs.Frame      := 1;
  cs.StartFrame := 0;
  cs.EndFrame   := 0;
  cs.Animated   := false;
  cs.AnimFPS    := 24;
  cs.AnimSpeed  := 1;

  cs.PosKF      := nil;
  cs.AngKF      := nil;
  cs.SclKF      := nil;
  cs.FlXKF      := nil;
  cs.FlYKF      := nil;
  cs.VisKF      := nil;
  cs.FrmKF      := nil;
  cs.AnmKF      := nil;

  cs.Parent     := nil;
  cs.FChild     := nil;
  cs.LChild     := nil;
  cs.Prev       := nil;
  cs.Next       := nil;

  cs.ParentDraw := nil;
  cs.FDraw      := nil;
  cs.LDraw      := nil;
  cs.NextDraw   := nil;
  cs.PrevDraw   := nil;

  cs.ListNext   := clSprList;
  cs.ListPrev   := nil;
  if clSprList <> nil then clSprList.ListPrev := cs;
  clSprList     := cs;

  Result        := cs;
end;

procedure kf_Del( fkf : clPKeyFrame );
var
  kf, kfn : clPKeyFrame;
begin
  kf := fkf;
  while kf <> nil do
  begin
    kfn := kf.Next;
    Dispose( kf );
    kf := kfn;
  end;
end;

procedure cls_Del( Sprite : clPSprite; DelChild : boolean );
var
  cs, csn, csp : clPSprite;
  frm, frmn    : clPFrame;
begin
  if clSprList = Sprite then clSprList := Sprite.ListNext;
  if Sprite.ListPrev <> nil then Sprite.ListPrev.ListNext := Sprite.ListNext;
  if Sprite.ListNext <> nil then Sprite.ListNext.ListPrev := Sprite.ListPrev;

  if Sprite.Prev <> nil then Sprite.Prev.Next := Sprite.Next;
  if Sprite.Next <> nil then Sprite.Next.Prev := Sprite.Prev;
  if Sprite.Parent <> nil then
  begin
    if Sprite.Parent.FChild = Sprite then Sprite.Parent.FChild := Sprite.Next;
    if Sprite.Parent.LChild = Sprite then Sprite.Parent.LChild := Sprite.Prev;
  end;
  if Sprite.PrevDraw <> nil then Sprite.PrevDraw.NextDraw := Sprite.NextDraw;
  if Sprite.NextDraw <> nil then Sprite.NextDraw.PrevDraw := Sprite.PrevDraw;
  if Sprite.ParentDraw <> nil then
  begin
    if Sprite.ParentDraw.FDraw = Sprite then Sprite.ParentDraw.FDraw := Sprite.NextDraw;
    if Sprite.ParentDraw.LDraw = Sprite then Sprite.ParentDraw.LDraw := Sprite.PrevDraw;
  end;

  if DelChild then
  begin
    cs := Sprite.FChild;
    while cs <> nil do
    begin
      csn := cs.Next;
      cls_Del( cs, true );
      cs := csn;
    end;
  end else
  begin
    csp := Sprite;
    while csp.Parent <> nil do
      csp := csp.Parent;
    cs := Sprite.FChild;
    while cs <> nil do
    begin
      csn := cs.Next;
      clSprite_SetParent( cs, csp );
      cs := csn;
    end;
  end;

  Sprite.Name := '';

  frm := Sprite.Frames;
  while frm <> nil do
  begin
    frmn := frm.Next;
    clFrame_Del( frm );
    frm := frmn;
  end;

  kf_Del( Sprite.PosKF );
  kf_Del( Sprite.AngKF );
  kf_Del( Sprite.SclKF );
  kf_Del( Sprite.FlXKF );
  kf_Del( Sprite.FlYKF );
  kf_Del( Sprite.VisKF );
  kf_Del( Sprite.FrmKF );
  kf_Del( Sprite.AnmKF );
  Dispose( Sprite );
end;

procedure clSprite_Del( Sprite : clPSprite; DelChild : boolean = true );
begin
  if Sprite.Parent = nil then DelChild := true;
  cls_Del( Sprite, DelChild )
end;

procedure clSprite_SetParent( Sprite, Parent : clPSprite );
var
  csp : clPSprite;
begin
  csp := Parent;
  while csp <> nil do
  begin
    if csp = Sprite then Exit;
    csp := csp.Parent;
  end;

  if Sprite.Prev <> nil then Sprite.Prev.Next := Sprite.Next;
  if Sprite.Next <> nil then Sprite.Next.Prev := Sprite.Prev;
  if Sprite.Parent <> nil then
  begin
    if Sprite.Parent.FChild = Sprite then Sprite.Parent.FChild := Sprite.Next;
    if Sprite.Parent.LChild = Sprite then Sprite.Parent.LChild := Sprite.Prev;
  end;
  Sprite.Parent := Parent;
  Sprite.Prev   := Parent.LChild;
  Sprite.Next   := nil;
  if Parent.LChild <> nil then Parent.LChild.Next := Sprite;
  Parent.LChild := Sprite;
  if Parent.FChild = nil then Parent.FChild := Sprite;
end;

procedure clSprite_SetParentDraw( Sprite, ParentDraw : clPSprite );
begin
  if Sprite.PrevDraw <> nil then Sprite.PrevDraw.NextDraw := Sprite.NextDraw;
  if Sprite.NextDraw <> nil then Sprite.NextDraw.PrevDraw := Sprite.PrevDraw;
  if Sprite.ParentDraw <> nil then
  begin
    if Sprite.ParentDraw.FDraw = Sprite then Sprite.ParentDraw.FDraw := Sprite.NextDraw;
    if Sprite.ParentDraw.LDraw = Sprite then Sprite.ParentDraw.LDraw := Sprite.PrevDraw;
  end;
  Sprite.ParentDraw := ParentDraw;
  Sprite.PrevDraw   := ParentDraw.LDraw;
  Sprite.NextDraw   := nil;
  if ParentDraw.LDraw <> nil then ParentDraw.LDraw.NextDraw := Sprite;
  ParentDraw.LDraw      := Sprite;
  if ParentDraw.FDraw = nil then ParentDraw.FDraw := Sprite;
end;


function clSprite_GetByID( Sprite : clPSprite; id : word ) : clPSprite;
var
  cs : clPSprite;
begin
  Result := nil;
  if Sprite.ID = id then
  begin
    Result := Sprite;
    Exit;
  end;
  cs := Sprite.FChild;
  while cs <> nil do
  begin
    Result := clSprite_GetByID( cs, id );
    if Result <> nil then Exit;
    cs := cs.Next;
  end;
end;

procedure clM_SetPos( var M : clMatrix; X, Y : single );
begin
  M.a13 := X;
  M.a23 := Y;
end;

procedure clM_Translate( var M : clMatrix; X, Y : single );
begin
  M.a13 := M.a13 + X;
  M.a23 := M.a23 + Y;
end;

procedure clM_Scale( var M : clMatrix; sX, sY : single );
begin
  M.a11 := M.a11 * sX;
  M.a22 := M.a22 * sY;
end;

function clM_FromAngle( Angle : single ) : clMatrix;
var
  s, c : Single;
begin
  s := sin( Angle );
  c := cos( Angle );
  with Result do
  begin
    a11 := c;
    a12 := -s;
    a13 := 0;
    a21 := s;
    a22 := c;
    a23 := 0;
    a31 := 0;
    a32 := 0;
    a33 := 1;
  end;
end;

function clM_Mul( M1, M2 : clMatrix ) : clMatrix;
begin
  with Result do
  begin
    a11 := M1.a11 * M2.a11 + M1.a12 * M2.a21 + M1.a13 * M2.a31;
    a12 := M1.a11 * M2.a12 + M1.a12 * M2.a22 + M1.a13 * M2.a32;
    a13 := M1.a11 * M2.a13 + M1.a12 * M2.a23 + M1.a13 * M2.a33;
    a21 := M1.a21 * M2.a11 + M1.a22 * M2.a21 + M1.a23 * M2.a31;
    a22 := M1.a21 * M2.a12 + M1.a22 * M2.a22 + M1.a23 * M2.a32;
    a23 := M1.a21 * M2.a13 + M1.a22 * M2.a23 + M1.a23 * M2.a33;
    a31 := M1.a31 * M2.a11 + M1.a32 * M2.a21 + M1.a33 * M2.a31;
    a32 := M1.a31 * M2.a12 + M1.a32 * M2.a22 + M1.a33 * M2.a32;
    a33 := M1.a31 * M2.a13 + M1.a32 * M2.a23 + M1.a33 * M2.a33;
  end;
end;

function clM_Inverse( M : clMatrix ) : clMatrix;
var
  det : Single;
begin
  with M do
  begin
    det := a11 * a22 * a33 - a11 * a23 * a32 - a12 * a21 * a33 + a12 * a23 * a31 + a13 * a21 * a32 - a13 * a22 * a31;
    det := 1 / det;
    Result.a11 :=   ( a22 * a33 - a23 * a32 ) * det;
    Result.a12 :=  -( a12 * a33 - a13 * a32 ) * det;
    Result.a13 :=   ( a12 * a23 - a13 * a22 ) * det;
    Result.a21 :=  -( a21 * a33 - a23 * a31 ) * det;
    Result.a22 :=   ( a11 * a33 - a13 * a31 ) * det;
    Result.a23 :=  -( a11 * a23 - a13 * a21 ) * det;
    Result.a31 :=   ( a21 * a32 - a22 * a31 ) * det;
    Result.a32 :=  -( a11 * a32 - a12 * a31 ) * det;
    Result.a33 :=   ( a11 * a22 - a12 * a21 ) * det;
  end;
end;

function clM_VMul( v : zglTPoint2D; M : clMatrix ) : zglTPoint2D;
begin
  Result.X := M.a11 * v.X + M.a12 * v.Y + M.a13;
  Result.Y := M.a21 * v.X + M.a22 * v.Y + M.a23;
end;

function cls_Lineal( p1, p2, tc, t : single ) : single;
begin
  Result := p1 + ( p2 - p1 ) * tc / t;
end;

function cls_Smooth( p0, p1, p2, p3, tc, t : single ) : single;
var
  mu, mu2, mu3, m0, m1, a0, a1, a2, a3: single;
begin
  mu  := tc / t;
  mu2 := mu * mu;
  mu3 := mu2 * mu;

  m0 := ( p1 - p0 ) * 0.5;
  m0 := m0 + ( p2 - p1 ) * 0.5;
  m1 := ( p2 - p1 ) * 0.5;
  m1 := m1 + ( p3 - p2 ) * 0.5;

  a0 := 2 * mu3 - 3 * mu2 + 1;
  a1 := mu3 - 2 * mu2 + mu;
  a2 := mu3 - mu2;
  a3 := -2 * mu3 + 3 * mu2;

  Result := a0 * p1 + a1 * m0 + a2 * m1 + a3 * p2;
end;

procedure cls_CalcKF( fkf : clPKeyFrame; Frame : single; var S1, S2 : single; two : boolean = false );
var
  kf, kfp, kfpp, kfn : clPKeyFrame;
begin
  kfpp := nil;
  kfp  := nil;
  kf   := fkf;
  while kf <> nil do
  begin
    if kf.N = Frame then
    begin
      S1 := kf.S1;
      S2 := kf.S2;
      Exit;
    end;
    if kf.N > Frame then
    begin
      if kfp = nil then
      begin
        S1 := kf.S1;
        S2 := kf.S2;
        Exit;
      end else
      begin
        if kfp.cType = kfcInstant then
        begin
          S1 := kfp.S1;
          S2 := kfp.S2;
          Exit;
        end;
        if ( kfp.cType = kfcLinear ) or ( kf.N - kfp.N = 1 ) then
        begin
          S1 := cls_Lineal( kfp.S1, kf.S1, Frame - kfp.N, kf.N - kfp.N );
          if two = true then S2 := cls_Lineal( kfp.S2, kf.S2, Frame - kfp.N, kf.N - kfp.N );
          Exit;
        end;
        if kfpp = nil then kfpp := kfp;
        kfn := kf.Next;
        if kfn = nil then kfn := kf;
        S1 := cls_Smooth( kfpp.S1, kfp.S1, kf.S1, kfn.S1, Frame - kfp.N, kf.N - kfp.N );
        if two = true then S2 := cls_Smooth( kfpp.S2, kfp.S2, kf.S2, kfn.S2, Frame - kfp.N, kf.N - kfp.N );
        Exit;
      end;
    end;
    if kf.Next = nil then
    begin
      S1 := kf.S1;
      S2 := kf.S2;
      Exit;
    end;
    kfpp := kfp;
    kfp  := kf;
    kf   := kf.Next;
  end;
end;

procedure cls_Calculate( Sprite : clPSprite; Matrix : clMatrix; Frame : single );
var
  cs      : clPSprite;
  M       : clMatrix;
  sx, sy  : single;
  frm     : clPFrame;
  i, n    : integer;
  kf, kfp : clPKeyFrame;
begin
  cls_CalcKF( Sprite.PosKF, Frame, Sprite.X, Sprite.Y, true );
  cls_CalcKF( Sprite.AngKF, Frame, Sprite.Angle, sy );
  cls_CalcKF( Sprite.SclKF, Frame, Sprite.ScaleX, Sprite.ScaleY, true );
  cls_CalcKF( Sprite.FlXKF, Frame, sx, sy );
  if Sprite.FlXKF <> nil then Sprite.FlipX := ( Round( sx ) <> 0 );
  cls_CalcKF( Sprite.FlYKF, Frame, sx, sy );
  if Sprite.FlYKF <> nil then Sprite.FlipY := ( Round( sx ) <> 0 );
  cls_CalcKF( Sprite.VisKF, Frame, sx, sy );
  if Sprite.VisKF <> nil then Sprite.Visible := ( Round( sx ) <> 0 );
  cls_CalcKF( Sprite.AnmKF, Frame, sx, sy );
  if Sprite.AnmKF <> nil then Sprite.Animated := ( Round( sx ) <> 0 );

  sx := 1;
  cls_CalcKF( Sprite.FrmKF, Frame, sx, sy );
  if Sprite.FrmKF <> nil then Sprite.Frame := sx;

  if Sprite.Animated then
  begin
    n   := 0;
    kf  := Sprite.FrmKF;
    kfp := nil;
    while kf <> nil do
    begin
      if kf.N > Frame then Break;
      kfp := kf;
      kf  := kf.Next;
    end;
    if kfp <> nil then n := kfp.N;

    Sprite.Frame := ( Frame - n ) * Sprite.AnimSpeed + sx;
    if Sprite.Frame > Sprite.EndFrame then
      Sprite.Frame := Sprite.Frame - ( ( Trunc( Sprite.Frame ) - 1 ) div Sprite.EndFrame ) * Sprite.EndFrame;
  end;

  Sprite.CurFrame := Sprite.Frames;
  i   := 0;
  n   := Trunc( Sprite.Frame );
  frm := Sprite.Frames;
  while frm <> nil do
  begin
    INC( i );
    if i = n then
    begin
      Sprite.CurFrame := frm;
      Break;
    end;
    frm := frm.Next;
  end;

  frm := Sprite.CurFrame;
  if frm <> nil then
  begin
    M := M_Identity;
    sx := Sprite.ScaleX;
    sy := Sprite.ScaleY;
    if Sprite.FlipX then sx := -sx;
    if Sprite.FlipY then sy := -sy;
    clM_SetPos( M, -frm.CenterX * sx, -frm.CenterY * sy );
    clM_Scale( M, sx, sy );
    M := clM_Mul( clM_FromAngle( Sprite.Angle * deg2rad ), M );
    clM_Translate( M, Sprite.X, Sprite.Y );
    M := clM_Mul( Matrix, M );
    Sprite.SMatrix := M;

    for i := 0 to Frm.tvCnt - 1 do
      Frm.TriPos[ i ] := clM_VMul( Frm.TriList[ i ], M );
  end;

  M := M_Identity;
  sx := Sprite.ScaleX;
  sy := Sprite.ScaleY;
  if Sprite.FlipX then sx := -sx;
  if Sprite.FlipY then sy := -sy;
  clM_Scale( M, sx, sy );
  M := clM_Mul( clM_FromAngle( Sprite.Angle * deg2rad ), M );
  clM_Translate( M, Sprite.X, Sprite.Y );
  M := clM_Mul( Matrix, M );
  Sprite.Matrix := M;

  cs := Sprite.FChild;
  while cs <> nil do
  begin
    cls_Calculate( cs, M, Frame );
    cs := cs.Next;
  end;
end;

procedure clSprite_Calculate( Sprite : clPSprite; X, Y, Scale, Angle, Frame : Single; FlipX : boolean = false );
begin
  Sprite.X := X;
  Sprite.Y := Y;
  Sprite.ScaleX := Scale;
  Sprite.ScaleY := Scale;
  Sprite.Angle  := Angle;
  Sprite.FlipX  := FlipX;

  cls_Calculate( Sprite, M_Identity, Frame );
end;

procedure clSprite_Calculate( Sprite : clPSprite );
begin
  cls_Calculate( Sprite, M_Identity, Sprite.Frame );
end;

procedure cls_Draw( Sprite : clPSprite );
var
  cs, par : clPSprite;
  frm     : clPFrame;
  vis     : boolean;
begin
  cs  := Sprite;

  vis := cs.Visible;
  if cs.InheritVis = true then
  begin
    par := cs.Parent;
    while par <> nil do
    begin
      if par.Visible = false then
      begin
        vis := false;
        Break;
      end;
      if Par.InheritVis = false then Break;
      par := par.Parent;
    end;
  end;

  if vis = true then
  begin
    frm := cs.CurFrame;
    if ( cs.Texture <> nil ) and ( frm <> nil ) then
      if frm.tvCnt > 0 then
        pr2d_TriList( cs.Texture.Tex, @frm.TriPos[ 0 ], @frm.TexCrds[ 0 ], 0, frm.tvCnt - 1, $FFFFFF, 255, PR2D_FILL or FX_BLEND );
  end;

  cs := Sprite.FDraw;
  while cs <> nil do
  begin
    cls_Draw( cs );
    cs := cs.NextDraw;
  end;
end;

procedure clSprite_Draw( Sprite : clPSprite );
begin
  cls_Draw( Sprite );
end;

procedure myReadLn(var f, str :string);
var n :integer;
begin
  n := Pos(#10, f);
  str := Copy(f, 1, n - 2);
  Delete(f, 1, n);
end;

function cls_LoadKF( var f : string; KFcnt: integer ) : clPKeyFrame;
var
  kf, kfp   : clPKeyFrame;
  str, str2 : string;
  i, p, len : integer;
begin
  Result := nil;
  kfp := nil;
  while KFcnt > 0 do
  begin
    DEC( KFcnt );
    New( kf );
    kf.Next := nil;
    if kfp = nil then Result := kf;
    if kfp <> nil then kfp.Next := kf;
    kfp := kf;

    myReadLn( f, str);
    len  := Length( str );
    str2 := '';
    p    := 1;
    for i := 1 to len do
    begin
      if ( str[ i ] = ' ' ) and ( p = 1 ) then
      begin
        kf.N  := u_StrToInt( str2 );
        str2  := '';
        p     := 2;
        Continue;
      end;
      if ( str[ i ] = ' ' ) and ( p = 2 ) then
      begin
        if str2 = '0' then kf.cType := kfcInstant;
        if str2 = '1' then kf.cType := kfcLinear;
        if str2 = '2' then kf.cType := kfcSmooth;
        str2  := '';
        p     := 3;
        Continue;
      end;
      if ( str[ i ] = ' ' ) and ( p = 3 ) then
      begin
        kf.S1 := u_StrToFloat( str2 );
        str2  := '';
        p     := 4;
        Continue;
      end;
      str2 := str2 + str[ i ];
    end;
    if p = 3 then kf.S1 := u_StrToFloat( str2 );
    if p = 4 then kf.S2 := u_StrToFloat( str2 );
  end;
end;

function clSprite_LoadFromFile( FileName : string ) : clPSprite;
var
  f            : zglTFile;
  cs, csp      : clPSprite;
  str, str2, st: string;
  Param, Value : string;
  i, k, p, len : integer;
  prm          : boolean;
  id1, id2     : array of word;
  idc,sz       : integer;
  frm, lfrm    : clPFrame;
begin

  Result := clSprite_Create;



  file_Open( f, FileName, FOM_OPENR );

  sz := file_GetSize(f);
  SetLength(str, sz);

  file_Read( f, str[1], sz);

  myReadLn(str, st);


  if st <> 'CoolSprite' then
  begin
    file_close( f );
    Exit;
  end;

  cs  := nil;
  idc := 0;

  while not (Length(str) = 0) do
  begin

    myReadLn(str, st);
    len := Length( st );
    prm := true;
    Param := '';
    Value := '';
    for i := 1 to len do
    begin
      if st[ i ] = '=' then
      begin
        prm := false;
        Continue;
      end;
      if prm = true then Param := Param + st[ i ]
        else Value := Value + st[ i ];
    end;

    if cs = nil then
    begin
      if Param = 'Frame'      then Result.Frame := u_StrToFloat( Value );
      if Param = 'StartFrame' then Result.StartFrame := u_StrToINt( Value );
      if Param = 'EndFrame'   then Result.EndFrame := u_StrToINt( Value );
      if Param = 'FPS'        then Result.AnimFPS := u_StrToINt( Value );
    end;

    if Param = 'Sprite' then
    begin
      cs := clSprite_Create;
      clSprite_SetParent( cs, Result );
      clSprite_SetParentDraw( cs, Result );
    end;

    if cs <> nil then
    begin
      if Param = 'Name'    then cs.Name    := Value;
      if Param = 'ID'      then cs.ID      := u_StrToINt( Value );
      if Param = 'Texture' then
      begin
        cs.Texture := clTexture_Get( file_getDirectory( FileName )  + Value );

        if cs.Texture = nil then
         cs.Texture := clTexture_Load(file_getDirectory( FileName )  + Value );
      end;

      if Param = 'X'       then cs.X       := u_StrToFloat( Value );
      if Param = 'Y'       then cs.Y       := u_StrToFloat( Value );
      if Param = 'Angle'   then cs.Angle   := u_StrToFloat( Value );
      if Param = 'ScaleX'  then cs.ScaleX  := u_StrToFloat( Value );
      if Param = 'ScaleY'  then cs.ScaleY  := u_StrToFloat( Value );
      if Param = 'FlipX'   then cs.FlipX   := u_StrToBool( Value );
      if Param = 'FlipY'   then cs.FlipY   := u_StrToBool( Value );
      if Param = 'Visible' then cs.Visible := u_StrToBool( Value );
      if Param = 'InheritVis' then cs.InheritVis := u_StrToBool( Value );
      if Param = 'ParentID' then
      begin
        SetLength( id1, idc + 1 );
        SetLength( id2, idc + 1 );
        id1[ idc ] := cs.ID;
        id2[ idc ] := u_StrToINt( Value );
        INC( idc );
      end;

      if Param = 'Frame'    then cs.Frame     := u_StrToFloat( Value );
      if Param = 'FPS'      then cs.AnimFPS   := u_StrToINt( Value );
      if Param = 'Animated' then cs.Animated  := u_StrToBool( Value );
      if Param = 'Speed'    then cs.AnimSpeed := u_StrToFloat( Value );
      if Param = 'Frames' then
      begin
        cs.EndFrame := u_StrToINt( Value );
        frm := nil;
        for i := 0 to cs.EndFrame - 1 do
        begin
          lfrm := frm;
          frm := clFrame_Create;
          if lfrm = nil then cs.Frames := frm
            else lfrm.Next := frm;
          myReadLn(str, st);
          frm.CenterX := u_StrToFloat( st );
          myReadLn(str, st);
          frm.CenterY := u_StrToFloat( st );
          myReadLn(str, st);
          frm.vCnt := u_StrToINt( st );
          SetLength( frm.v, frm.vCnt );
          for k := 0 to frm.vCnt - 1 do
          begin
            myReadLn(str, st);
            p := Pos( ' ', st );
            str2 := st;
            Delete( st, p, Length( st ) - p + 1 );
            Delete( str2, 1, p );
            frm.v[ k ].X := u_StrToFloat( st );
            frm.v[ k ].Y := u_StrToFloat( str2 );
          end;
          clFrame_Triangulate( frm, cs.Texture.Tex );
        end;
      end;

      if Param = 'PosKeys' then cs.PosKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'AngKeys' then cs.AngKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'SclKeys' then cs.SclKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FlXKeys' then cs.FlXKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FlYKeys' then cs.FlYKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'VisKeys' then cs.VisKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FrmKeys' then cs.FrmKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'AnmKeys' then cs.AnmKF := cls_LoadKF( str, u_StrToINt( Value ) );
    end;
  end;

  file_close( f );

  for i := 0 to idc - 1 do
  begin
    cs  := clSprite_GetByID( Result, id1[ i ] );
    csp := clSprite_GetByID( Result, id2[ i ] );
    clSprite_SetParent( cs, csp );
  end;

  cls_Calculate( Result, M_Identity, Result.Frame );

end;

procedure clSprite_ClearAll;
var
  t, tn : clPTexture;
begin
  while clSprList <> nil do
    cls_Del( clSprList, false );
  t := clTexList;
  while t <> nil do
  begin
    tn := t.Next;
    t.FileName := '';
    Dispose( t );
    t := tn;
  end;
end;

procedure SetBufferCoolSprite(const AFileName: String; var AValue: String; var AValSize: Integer);
var
  FNm: zglTFile;
  str: String;
begin
  file_Open(FNm, AFileName, FOM_OPENR );
  AValSize := file_GetSize(FNm);
  SetLength(str, AValSize);
  SetLength(AValue, AValSize);
  file_Read(FNm, str[1], AValSize);
  Move(str[1], AValue[1], AValSize );
  file_close(FNm);
end;

function clTexture_fromTexMan( FileName : string;  TexManager: avk_TTextureManager) : clPTexture;
var
  ct : clPTexture;
begin
  New( ct );
  ct.FileName := FileName;
  ct.Tex      := TexManager.TexFileName[FileName];
  ct.Next     := clTexList;
  clTexList   := ct;
  Result      := ct;
end;


function clSprite_LoadFromBuffer(AValue: string; AValSize: Integer;
  ATexManager: TObject): clPSprite;
var
  TexManager: avk_TTextureManager;
  cs, csp      : clPSprite;
  str, str2, st: string;
  Param, Value : string;
  i, k, p, len : integer;
  prm          : boolean;
  id1, id2     : array of word;
  idc          : integer;
  frm, lfrm    : clPFrame;
begin

  Result := clSprite_Create;

  SetLength(str, AValSize);
  Move(AValue[1], str[1], AValSize );

  myReadLn(str, st);

  if st <> 'CoolSprite' then
  begin
    Exit;
  end;

  TexManager := avk_TTextureManager(ATexManager);

  cs  := nil;
  idc := 0;

  while not (Length(str) = 0) do
  begin

    myReadLn(str, st);
    len := Length( st );
    prm := true;
    Param := '';
    Value := '';
    for i := 1 to len do
    begin
      if st[ i ] = '=' then
      begin
        prm := false;
        Continue;
      end;
      if prm = true then Param := Param + st[ i ]
        else Value := Value + st[ i ];
    end;

    if cs = nil then
    begin
      if Param = 'Frame'      then Result.Frame := u_StrToFloat( Value );
      if Param = 'StartFrame' then Result.StartFrame := u_StrToINt( Value );
      if Param = 'EndFrame'   then Result.EndFrame := u_StrToINt( Value );
      if Param = 'FPS'        then Result.AnimFPS := u_StrToINt( Value );
    end;

    if Param = 'Sprite' then
    begin
      cs := clSprite_Create;
      clSprite_SetParent( cs, Result );
      clSprite_SetParentDraw( cs, Result );
    end;

    if cs <> nil then
    begin
      if Param = 'Name'    then cs.Name    := Value;
      if Param = 'ID'      then cs.ID      := u_StrToINt( Value );
      if Param = 'Texture' then
      begin
        cs.Texture :=  clTexture_fromTexMan(Value, TexManager);

        //if cs.Texture = nil then
        // cs.Texture := clTexture_Load(Value);
      end;

      if Param = 'X'       then cs.X       := u_StrToFloat( Value );
      if Param = 'Y'       then cs.Y       := u_StrToFloat( Value );
      if Param = 'Angle'   then cs.Angle   := u_StrToFloat( Value );
      if Param = 'ScaleX'  then cs.ScaleX  := u_StrToFloat( Value );
      if Param = 'ScaleY'  then cs.ScaleY  := u_StrToFloat( Value );
      if Param = 'FlipX'   then cs.FlipX   := u_StrToBool( Value );
      if Param = 'FlipY'   then cs.FlipY   := u_StrToBool( Value );
      if Param = 'Visible' then cs.Visible := u_StrToBool( Value );
      if Param = 'InheritVis' then cs.InheritVis := u_StrToBool( Value );
      if Param = 'ParentID' then
      begin
        SetLength( id1, idc + 1 );
        SetLength( id2, idc + 1 );
        id1[ idc ] := cs.ID;
        id2[ idc ] := u_StrToINt( Value );
        INC( idc );
      end;

      if Param = 'Frame'    then cs.Frame     := u_StrToFloat( Value );
      if Param = 'FPS'      then cs.AnimFPS   := u_StrToINt( Value );
      if Param = 'Animated' then cs.Animated  := u_StrToBool( Value );
      if Param = 'Speed'    then cs.AnimSpeed := u_StrToFloat( Value );
      if Param = 'Frames' then
      begin
        cs.EndFrame := u_StrToINt( Value );
        frm := nil;
        for i := 0 to cs.EndFrame - 1 do
        begin
          lfrm := frm;
          frm := clFrame_Create;
          if lfrm = nil then cs.Frames := frm
            else lfrm.Next := frm;
          myReadLn(str, st);
          frm.CenterX := u_StrToFloat( st );
          myReadLn(str, st);
          frm.CenterY := u_StrToFloat( st );
          myReadLn(str, st);
          frm.vCnt := u_StrToINt( st );
          SetLength( frm.v, frm.vCnt );
          for k := 0 to frm.vCnt - 1 do
          begin
            myReadLn(str, st);
            p := Pos( ' ', st );
            str2 := st;
            Delete( st, p, Length( st ) - p + 1 );
            Delete( str2, 1, p );
            frm.v[ k ].X := u_StrToFloat( st );
            frm.v[ k ].Y := u_StrToFloat( str2 );
          end;
          clFrame_Triangulate( frm, cs.Texture.Tex );
        end;
      end;

      if Param = 'PosKeys' then cs.PosKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'AngKeys' then cs.AngKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'SclKeys' then cs.SclKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FlXKeys' then cs.FlXKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FlYKeys' then cs.FlYKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'VisKeys' then cs.VisKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'FrmKeys' then cs.FrmKF := cls_LoadKF( str, u_StrToINt( Value ) );
      if Param = 'AnmKeys' then cs.AnmKF := cls_LoadKF( str, u_StrToINt( Value ) );
    end;
  end;

  for i := 0 to idc - 1 do
  begin
    cs  := clSprite_GetByID( Result, id1[ i ] );
    csp := clSprite_GetByID( Result, id2[ i ] );
    clSprite_SetParent( cs, csp );
  end;

  cls_Calculate( Result, M_Identity, Result.Frame );
end;


end.

