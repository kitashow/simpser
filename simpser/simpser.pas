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
  zgl_main, zgl_screen, zgl_window, zgl_timers, mine_unit, avk_emitters;

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

  {$IfDef Debug}
  scr_SetOptions(1280,736, REFRESH_MAXIMUM, false, false );
  {$else}
  scr_SetOptions(1280,720, REFRESH_DEFAULT, false, true );
  {$endif}
  zgl_Init();
End.
