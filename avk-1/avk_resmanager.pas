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
  //, zgl_file
  //avk
  , avk_btype
  //coolsprite
  , avk_cls
  ;

type

  avk_TTexSimple = class
    Texture: zglPTexture;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
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
    CoolSprite: clPSprite;
    {$IFDEF ANDROID}
    FileName: String;
    {$ENDIF}
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
    procedure AddCoolSprite(InName: String; InCoolSprite: clPSprite; InFName: String
      );
  public
    property Parent: avk_TFraim read FParent;
    property CoolSpriteList[InID :Integer]: clPSprite read GetCSById;
    property CoolSpriteName[InID :String]: clPSprite read GetCSByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TCoolSpriteSimple read GetCSSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
    destructor Destroy; override;
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
  public
    procedure AddTexture(InName: String; InTex: zglPTexture; InFName: String = '');
  public
    property Parent: avk_TFraim read FParent;
    property TexList[InID :Integer]: zglPTexture read GetTexById;
    property TexName[InID :String]: zglPTexture read GetTexByName;
    property Count: Integer read FGetCount;
    property ResList[InID :Integer]: avk_TTexSimple read GetTexSimple;
  public
    constructor Create(inParent: avk_TFraim = nil);
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
    procedure AddSound(InName: String; InSound: zglPSound; InFName: String='');
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

implementation

{ avk_TCoolSpriteManager }

function avk_TCoolSpriteManager.GetCSById(InID: Integer): clPSprite;
begin
  Result := nil;
  if InID >= Count then Exit;
  if InID < 0 then Exit;
  Result := avk_TCoolSpriteSimple(FCSList.Objects[InId]).CoolSprite;
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

procedure avk_TCoolSpriteManager.AddCoolSprite(InName: String;
  InCoolSprite: clPSprite; InFName: String);
var
  tmp_CS: avk_TCoolSpriteSimple;
begin
  tmp_CS:= avk_TCoolSpriteSimple.Create;
  tmp_CS.CoolSprite := InCoolSprite;
  {$IFDEF ANDROID}
  tmp_CS.FileName := InFName;
  {$EndIf}
  FCSList.AddObject(InName, tmp_CS);
end;

constructor avk_TCoolSpriteManager.Create(inParent: avk_TFraim);
begin
  FCSList := TStringList.Create;
  FCSList.Sorted :=true;
  FParent := inParent;
end;

destructor avk_TCoolSpriteManager.Destroy;
var
  i: Integer;
begin
  for i:= 0 to FCSList.Count - 1 do avk_TCoolSpriteSimple(FCSList.Objects[i]).Destroy;
  FCSList.Destroy;
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
  {$IFDEF ANDROID}
  tmp_Tex.FileName := InFName;
  {$EndIf}
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

