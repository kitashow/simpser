unit avk_emitters;

{$mode delphi}
{$codepage UTF8}

interface

uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  {$IFDEF WINDOWS}
    ,Windows
  {$ELSE}
    ,Unix, UnixType
  {$ENDIF}
  {$ifdef DEBUG}
    , SysUtils
  {$endif}
  //avk
  , avk_btype
  , avk_gui
  , avk_input
  , avk_resmanager
  , avk_vector
  , avk_cls
  //zgl
  {$IFNDEF ANDROID}   //Не андроид
  , zgl_opengl
  , zgl_opengl_all
  {$ELSE}
  , zgl_opengles
  , zgl_opengles_all
  {$ENDIF}
  , zgl_file
  , zgl_render_2d
  , zgl_camera_2d
  , zgl_math_2d
  , zgl_screen
  , zgl_font
  , zgl_primitives_2d
  , zgl_fx
  , zgl_text
  , zgl_textures
  //, zgl_textures_tga
  , zgl_textures_png
  //, zgl_textures_jpg
  , zgl_sprite_2d
  , zgl_render_target
  , zgl_utils
  , zgl_types
  , zgl_keyboard
  , zgl_main
  , zgl_particles_2d
  , avk_sprites
  ;

type

  { avk_TSimplePaticle }

  avk_TSimplePaticle = class (TObject)
    FParticles: zglTPEngine2D;
    FEmitter: zglPEmitter2D;
    FStepTime: Double;
    procedure FSetEmitter(AEmitter: zglPEmitter2D; AValX: Single = 0; AValY: Single = 0);
    procedure Proc;
    procedure Draw;
    constructor Create;
    destructor Destroy; override;
  end;

  { avk_TSimpleEmitter }

  avk_TSimpleEmitter = class (avk_TFraim)
    FSimplePaticle: avk_TSimplePaticle;
    procedure DoDraw(Sender: TObject);
    procedure DoProc(Sender: TObject);
    constructor Create(const InParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

implementation

{ avk_TSimpleEmitter }

procedure avk_TSimpleEmitter.DoDraw(Sender: TObject);
begin
  FSimplePaticle.Draw;
end;

procedure avk_TSimpleEmitter.DoProc(Sender: TObject);
begin
  FSimplePaticle.Proc;
end;

constructor avk_TSimpleEmitter.Create(const InParent: avk_TFraim);
begin
  FSimplePaticle := avk_TSimplePaticle.Create;
  inherited Create(InParent);
  OnDraw := DoDraw;
  OnProc := DoProc;
end;

destructor avk_TSimpleEmitter.Destroy;
begin
  FSimplePaticle.Destroy;
  inherited Destroy;
end;

{ avk_TSimplePaticle }

procedure avk_TSimplePaticle.FSetEmitter(AEmitter: zglPEmitter2D;
  AValX: Single; AValY: Single);
begin
  pengine2d_Set( @Fparticles );
  pengine2d_AddEmitter(AEmitter, @FEmitter, AValX, AValY);
end;

procedure avk_TSimplePaticle.Proc;
begin
  if Assigned(FEmitter) then begin
    pengine2d_Set( @Fparticles );
    pengine2d_Proc(FStepTime);
  end;
end;

procedure avk_TSimplePaticle.Draw;
{$IfDef Debug}
var
  i: Integer;
{$EndIf}
begin
  if Assigned(FEmitter) then begin
    pengine2d_Set( @Fparticles );
    pengine2d_Draw();
    {$IfDef Debug}
    for i := 0 to FParticles.Count.Emitters - 1 do
      with FParticles.List[ i ].BBox do
        pr2d_Rect( MinX, MinY, MaxX - MinX, MaxY - MinY, $FF0000, 255 );
    {$EndIf}
  end;
end;

constructor avk_TSimplePaticle.Create;
begin
  pengine2d_Set( @FParticles );
  FStepTime := 4;
end;

destructor avk_TSimplePaticle.Destroy;
begin
  pengine2d_Set( @FParticles );
  pengine2d_ClearAll();
  inherited Destroy;
end;

end.

