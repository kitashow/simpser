program simpser;

{$mode DELPHI}{$H+}
{$codepage UTF8}

uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  {$ifdef unix}
    cthreads,
    cmem, // the c memory manager is on some systems much faster for multi-threading
  {$endif}
  zgl_main, zgl_screen, zgl_window, zgl_timers, mine_unit;

const
{$IfDef Debug}
  Debug = ' дебаг режим';
{$else}
  Debug = '';
{$endif}

{$R *.res}

Begin
  zgl_Reg( SYS_LOAD, @Init );
  zgl_Reg( SYS_DRAW, @Draw );
  zgl_Reg( SYS_UPDATE, @Update );
  zgl_Reg( SYS_EXIT, @Quit );
  //zgl_Enable(APP_USE_UTF8);
  randomize();
  timer_Add( @Proc, 4 );
  wnd_SetCaption( 'Набор тестов' + Debug);
  {$IfDef ShowCursor}
  wnd_ShowCursor( TRUE );
  {$else}
  wnd_ShowCursor( False );
  {$endif}

  scr_SetOptions(1280,720, REFRESH_MAXIMUM, false, false );
  zgl_Init();
End.
