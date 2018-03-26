unit avk_resmanager;
{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes

  //zgl
  , zgl_textures
  , zgl_font
  , zgl_sound
  , zgl_particles_2d
  //, zgl_file
  //avk
  , avk_btype
  , avk_loadmap
  //coolsprite
  , avk_cls
  ;

type

  avk_TTexSimple = class
    Texture: zglPTexture;
    FileName: String;
  end;

  avk_TFontSimple = class
    Font: zglPFont;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
  end;

  avk_TSoundSimple = class
    Sound: zglPSound;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
  end;

  avk_TCoolSpriteSimple = class
    FileName: String;
    Buffer: String;
    BufferSize: Integer;
  end;

  avk_TEmitterSimple = class
    Emitter: zglPEmitter2D;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
  end;

  avk_TMapArraySimple = class
    MapArray: TMapArray;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
  end;

  { avk_TTextureManager }

  avk_TTextureManager = class (TObject)
  private
    FParent: avk_TFraim;
    FTexList: TStringList;
    function GetTexById(InID : Integer): zglPTexture;
    function GetTexByName(InID : String): zglPTexture;
    function FGetCount: Integer;
    function GetTexSimple(InID : Integer): avk_TTexSimple;
    function GetTexByFileName(InID : String): zglPTexture;
  public
    procedure AddTexture(InName: String; InTex: zglPTexture; InFName: String = '');
  public
    property Parent: avk_TFraim read FParent;
    property TexList[InID :Integer]: zglPTexture read GetTexById;
    property TexName[InID :String]: zglPTexture read GetTexByName;
    property TexFileName[InID :String]: zglPTexture read GetTexByFileName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TTexSimple read GetTexSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

  { avk_TCoolSpriteManager }

  avk_TCoolSpriteManager = class (TObject)
  private
    FParent: avk_TFraim;
    FCSList: TStringList;
    function GetCSById(InID: Integer): clPSprite;
    function GetCSByName(InID: String): clPSprite;
    function FGetCount: Integer;
    function GetCSSimple(InID : Integer): avk_TCoolSpriteSimple;
  public
    procedure AddCoolSprite(InName: String; InFName: String);
  public
    TexManager: avk_TTextureManager;
    property Parent: avk_TFraim read FParent;
    property CoolSpriteList[InID :Integer]: clPSprite read GetCSById;
    property CoolSpriteName[InID :String]: clPSprite read GetCSByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TCoolSpriteSimple read GetCSSimple;
  public
    constructor Create(inParent: avk_TFraim = nil; ATexManager: avk_TTextureManager = nil);
    destructor Destroy; override;
  end;

  { avk_TFontManager }

  avk_TFontManager = class (TObject)
  private
    FParent: avk_TFraim;
    FFontList: TStringList;
    function GetFontById(InID : Integer): zglPFont;
    function GetFontByName(InID : String): zglPFont;
    function FGetCount: Integer;
    function GetTexSimple(InID : Integer): avk_TFontSimple;
  public
    procedure AddFont(InName: String; InFont: zglPFont; InFName: String='');
  public
    property Parent: avk_TFraim read FParent;
    property FontList[InID :Integer]: zglPFont read GetFontById;
    property FontName[InID :String]: zglPFont read GetFontByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TFontSimple read GetTexSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;


  { avk_TSoundManager }

  avk_TSoundManager = class (TObject)
  private
    FParent: avk_TFraim;
    FSoundList: TStringList;
    function GetSoundById(InID : Integer): zglPSound;
    function GetSoundByName(InID : String): zglPSound;
    function FGetCount: Integer;
    function GetTexSimple(InID : Integer): avk_TSoundSimple;
  public
    procedure AddSound(InName: String; InSound: zglPSound; InFName: String = '');
  public
    property Parent: avk_TFraim read FParent;
    property SoundList[InID :Integer]: zglPSound read GetSoundById;
    property SoundName[InID :String]: zglPSound read GetSoundByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TSoundSimple read GetTexSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

  { avk_TEmitterManager }

  avk_TEmitterManager = class (TObject)
  private
    FParent: avk_TFraim;
    FEmitterList: TStringList;
    function GetEmitterById(InID : Integer): zglPEmitter2D;
    function GetEmitterByName(InID : String): zglPEmitter2D;
    function FGetCount: Integer;
    function GetEmitterSimple(InID : Integer): avk_TEmitterSimple;
  public
    procedure AddEmitter(InName: String; InEmitter: zglPEmitter2D; InFName: String = '');
  public
    property Parent: avk_TFraim read FParent;
    property EmitterList[InID :Integer]: zglPEmitter2D read GetEmitterById;
    property EmitterName[InID :String]: zglPEmitter2D read GetEmitterByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TEmitterSimple read GetEmitterSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

  { avk_TMapArrayManager }

  avk_TMapArrayManager = class (TObject)
  private
    FParent: avk_TFraim;
    FMapArrayList: TStringList;
    function GetMapArrayById(InID : Integer): TMapArray;
    function GetMapArrayByName(InID : String): TMapArray;
    function FGetCount: Integer;
    function GetMapArraySimple(InID : Integer): avk_TMapArraySimple;
  public
    procedure AddMapArray(InName: String; AMapArray: TMapArray; InFName: String);
  public
    property Parent: avk_TFraim read FParent;
    property MapArrayList[InID :Integer]: TMapArray read GetMapArrayById;
    property MapArrayName[InID :String]: TMapArray read GetMapArrayByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TMapArraySimple read GetMapArraySimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
  end;

implementation

{ avk_TMapArrayManager }

function avk_TMapArrayManager.GetMapArrayById(InID: Integer): TMapArray;
begin
  Result := avk_TMapArraySimple(FMapArrayList.Objects[InId]).MapArray;
end;

function avk_TMapArrayManager.GetMapArrayByName(InID: String): TMapArray;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FMapArrayList.Find(InID, OutId);
  Result := GetMapArrayById(OutId);
end;

function avk_TMapArrayManager.FGetCount: Integer;
begin
  Result := FMapArrayList.Count;
end;

function avk_TMapArrayManager.GetMapArraySimple(InID: Integer
  ): avk_TMapArraySimple;
begin
  Result := avk_TMapArraySimple(FMapArrayList.Objects[InId]);
end;

procedure avk_TMapArrayManager.AddMapArray(InName: String; AMapArray: TMapArray;
  InFName: String);
var
  tmp_MA: avk_TMapArraySimple;
begin
  tmp_MA := avk_TMapArraySimple.Create;
  tmp_MA.MapArray := AMapArray;
  {$IFDEF ANDROID}
  tmp_MA.FileName := InFName;
  {$EndIf}
  FMapArrayList.AddObject(InName, tmp_MA);
end;

constructor avk_TMapArrayManager.Create(inParent: avk_TFraim);
begin
  FMapArrayList := TStringList.Create;
  FMapArrayList.Sorted := true;
  FParent := inParent;
end;

destructor avk_TMapArrayManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FMapArrayList.Count - 1 do
    avk_TMapArraySimple(FMapArrayList.Objects[i]).Destroy;
  FMapArrayList.Destroy;
  inherited Destroy;
end;

{ avk_TEmitterManager }

function avk_TEmitterManager.GetEmitterById(InID: Integer): zglPEmitter2D;
begin
  Result := avk_TEmitterSimple(FEmitterList.Objects[InId]).Emitter;
end;

function avk_TEmitterManager.GetEmitterByName(InID: String): zglPEmitter2D;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FEmitterList.Find(InID, OutId);
  Result := GetEmitterById(OutId);
end;

function avk_TEmitterManager.FGetCount: Integer;
begin
  Result := FEmitterList.Count;
end;

function avk_TEmitterManager.GetEmitterSimple(InID: Integer
  ): avk_TEmitterSimple;
begin
  Result := avk_TEmitterSimple(FEmitterList.Objects[InId]);
end;

procedure avk_TEmitterManager.AddEmitter(InName: String;
  InEmitter: zglPEmitter2D; InFName: String);
var
  tmp_Emtr: avk_TEmitterSimple;
begin
  tmp_Emtr:= avk_TEmitterSimple.Create;
  tmp_Emtr.Emitter := InEmitter;
  {$IFDEF ANDROID}
  tmp_Emtr.FileName := InFName;
  {$EndIf}
  FEmitterList.AddObject(InName, tmp_Emtr);
end;

constructor avk_TEmitterManager.Create(inParent: avk_TFraim);
begin
  FEmitterList         := TStringList.Create;
  FEmitterList.Sorted  := true;
  FParent              := inParent;
end;

destructor avk_TEmitterManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FEmitterList.Count - 1 do
    //emitter2d_Del(avk_TEmitterSimple(FEmitterList.Objects[i]).Emitter);
    avk_TEmitterSimple(FEmitterList.Objects[i]).Destroy;
  FEmitterList.Destroy;
  inherited Destroy;
end;


{ avk_TCoolSpriteManager }

function avk_TCoolSpriteManager.GetCSById(InID: Integer): clPSprite;
begin
  Result := nil;
  if InID >= Count then Exit;
  if InID < 0 then Exit;
  Result := clSprite_LoadFromBuffer(avk_TCoolSpriteSimple(FCSList.Objects[InId]).Buffer, avk_TCoolSpriteSimple(FCSList.Objects[InId]).BufferSize, TexManager);
end;

function avk_TCoolSpriteManager.GetCSByName(InID: String): clPSprite;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FCSList.Find(InID,OutId);
  Result := GetCSById(OutId);
end;

function avk_TCoolSpriteManager.FGetCount: Integer;
begin
  Result := FCSList.Count;
end;

function avk_TCoolSpriteManager.GetCSSimple(InID: Integer
  ): avk_TCoolSpriteSimple;
begin
  Result := avk_TCoolSpriteSimple(FCSList.Objects[InId]);
end;

procedure avk_TCoolSpriteManager.AddCoolSprite(InName: String; InFName: String);
var
  tmp_CS: avk_TCoolSpriteSimple;
begin
  tmp_CS:= avk_TCoolSpriteSimple.Create;
  SetBufferCoolSprite(InFName, tmp_CS.Buffer, tmp_CS.BufferSize);
  tmp_CS.FileName := InFName;
  FCSList.AddObject(InName, tmp_CS);
end;

constructor avk_TCoolSpriteManager.Create(inParent: avk_TFraim;
  ATexManager: avk_TTextureManager);
begin
  FCSList := TStringList.Create;
  FCSList.Sorted :=true;
  FParent := inParent;
  TexManager := ATexManager;
end;

destructor avk_TCoolSpriteManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FCSList.Count - 1 do avk_TCoolSpriteSimple(FCSList.Objects[i]).Destroy;
  FCSList.Destroy;
  clSprite_ClearAll;
  inherited Destroy;
end;

{ avk_TSoundManager }
function avk_TSoundManager.FGetCount: Integer;
begin
  Result := FSoundList.Count;
end;

function avk_TSoundManager.GetTexSimple(InID : Integer): avk_TSoundSimple;
begin
  Result := avk_TSoundSimple(FSoundList.Objects[InId]);
end;

procedure avk_TSoundManager.AddSound(InName: String; InSound: zglPSound; InFName:String = '');
var
  tmp_Sound: avk_TSoundSimple;
begin
  tmp_Sound:= avk_TSoundSimple.Create;
  tmp_Sound.Sound := InSound;
  {$IFDEF ANDROID}
  tmp_Sound.FileName := InFName;
  {$EndIf}
  FSoundList.AddObject(InName,tmp_Sound);
end;

function avk_TSoundManager.GetSoundById(InID : Integer): zglPSound;
begin
  Result := nil;
  if InID >= Count then Exit;
  if InID < 0 then Exit;
  Result := avk_TSoundSimple(FSoundList.Objects[InId]).Sound;
end;

function avk_TSoundManager.GetSoundByName(InID : String): zglPSound;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FSoundList.Find(InID,OutId);
  Result := GetSoundById(OutId);
end;

constructor avk_TSoundManager.Create(inParent: avk_TFraim);
begin
  FSoundList         := TStringList.Create;
  FSoundList.Sorted  :=true;
  FParent           := inParent;
end;

destructor avk_TSoundManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FSoundList.Count - 1 do avk_TSoundSimple(FSoundList.Objects[i]).Destroy;
  FSoundList.Destroy;
  inherited Destroy;
end;

{ avk_TFontManager }

function avk_TFontManager.FGetCount: Integer;
begin
  Result := FFontList.Count;
end;

function avk_TFontManager.GetTexSimple(InID : Integer): avk_TFontSimple;
begin
  Result := avk_TFontSimple(FFontList.Objects[InId]);
end;

procedure avk_TFontManager.AddFont(InName: String; InFont: zglPFont; InFName:String = '');
var
  tmp_Font: avk_TFontSimple;
begin
  tmp_Font:= avk_TFontSimple.Create;
  tmp_Font.Font := InFont;
  {$IFDEF ANDROID}
  tmp_Font.FileName := InFName;
  {$EndIf}
  FFontList.AddObject(InName,tmp_Font);
end;

function avk_TFontManager.GetFontById(InID : Integer): zglPFont;
begin
  Result := nil;
  if InID >= Count then Exit;
  if InID < 0 then Exit;
  Result := avk_TFontSimple(FFontList.Objects[InId]).Font;
end;

function avk_TFontManager.GetFontByName(InID : String): zglPFont;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FFontList.Find(InID,OutId);
  Result := GetFontById(OutId);
end;

constructor avk_TFontManager.Create(inParent: avk_TFraim);
begin
  FFontList         := TStringList.Create;
  FFontList.Sorted  :=true;
  FParent           := inParent;
end;

destructor avk_TFontManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FFontList.Count - 1 do avk_TFontSimple(FFontList.Objects[i]).Destroy;
  FFontList.Destroy;
  inherited Destroy;
end;

{ avk_TTextureManager }

function avk_TTextureManager.FGetCount: Integer;
begin
  Result := FTexList.Count;
end;

function avk_TTextureManager.GetTexSimple(InID : Integer): avk_TTexSimple;
begin
  Result :=  avk_TTexSimple(FTexList.Objects[InId]);
end;

procedure avk_TTextureManager.AddTexture(InName: String; InTex: zglPTexture; InFName: String = '');
var
  tmp_Tex: avk_TTexSimple;
begin
  tmp_Tex:= avk_TTexSimple.Create;
  tmp_Tex.Texture := InTex;
  tmp_Tex.FileName := InFName;
  FTexList.AddObject(InName,tmp_Tex);
end;

function avk_TTextureManager.GetTexById(InID : Integer): zglPTexture;
begin
  Result := nil;
  if InID >= Count then Exit;
  if InID < 0 then Exit;
  Result := avk_TTexSimple(FTexList.Objects[InId]).Texture;
end;

function avk_TTextureManager.GetTexByName(InID : String): zglPTexture;
var
  OutId: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  FTexList.Find(InID,OutId);
  Result := GetTexById(OutId);
end;

function avk_TTextureManager.GetTexByFileName(InID : String): zglPTexture;
var
  OutId, CKL: Integer;
begin
  Result := nil;
  if InID = '' then Exit;
  OutId := -1;
  for CKL := 0 to FTexList.Count - 1 do begin
    if avk_TTexSimple(FTexList.Objects[CKL]).FileName = InID then
      Result := avk_TTexSimple(FTexList.Objects[CKL]).Texture;
  end;
end;

constructor avk_TTextureManager.Create(inParent: avk_TFraim);
begin
  FTexList := TStringList.Create;
  FTexList.Sorted:=true;
  FParent := inParent;
end;

destructor avk_TTextureManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FTexList.Count - 1 do avk_TTexSimple(FTexList.Objects[i]).Destroy;
  //FTexList.Clear;
  FTexList.Destroy;
  inherited Destroy;
end;

end.

