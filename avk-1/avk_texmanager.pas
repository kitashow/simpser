unit avk_texmanager;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  zgl_textures;
type

  avk_TTex = class
    FID:Integer;
    Name:String;
    FileName: String;
    Texture: zglPTexture;
  end;

  { avk_TTexmanager }

  avk_TTexmanager = class
  private
    FID: Integer;
    FCount : Integer;
    FList  : array of avk_TTex;
  public
    function  GetTexById( inID : Integer ) : avk_TTex;
    function  GetTexNames( inName : String ) : avk_TTex;
    function  GetTextureNames( inName : String ) : zglPTexture;
    function  GetIdByName( inName : String ) : Integer;
    procedure SetTexById( inID : Integer; inTexture: avk_TTex);
    function AddTex (inTexture: avk_TTex): boolean;
    procedure DelById (inId: Integer);
    procedure ClearAll;
  public
    constructor Create;
    destructor Destroy; override;
  public
    property Count: Integer read FCount;
    property List[InID :Integer]: avk_TTex read GetTexById write SetTexById;
  end;


implementation

{ avk_TTexmanager }


function avk_TTexmanager.GetTexById(inID: Integer): avk_TTex;
begin
  if (inID >= 0) and (inID < FCount) then
    Result := FList[ inID ]
  else Result := nil;
end;

function avk_TTexmanager.GetTexNames(inName: String): avk_TTex;
begin
  Result := GetTexById(GetIdByName(inName));
end;

function avk_TTexmanager.GetTextureNames(inName: String): zglPTexture;
var
  LocTex: avk_TTex;
begin
  LocTex := GetTexNames(inName);
  if LocTex = nil then Result := nil
    else Result := LocTex.Texture;
end;

function avk_TTexmanager.GetIdByName(inName: String): Integer;
var
  TmpNxt: integer;
  TmpName: String;
begin
  Result := -1;
  for TmpNxt := 0 to (FCount-1) do begin
    TmpName := GetTexById(TmpNxt).Name;
    if inName = GetTexById(TmpNxt).Name then begin
      Result := TmpNxt;
      Break;
    end;
  end;
end;

procedure avk_TTexmanager.SetTexById(inID: Integer; inTexture: avk_TTex);
begin
  if (inId < 0) or (inId > Count) then begin
    Exit;
  end;
  if inID = Count then AddTex(inTexture)
  else FList[inID] := inTexture;
end;

function avk_TTexmanager.AddTex(inTexture: avk_TTex): boolean;
begin
  Result := true;
  if GetIdByName(inTexture.Name) >= 0 then begin
    Result := false;
    Exit;
  end;
  INC( FCount );
  SetLength( FList, FCount);
  inTexture.FID := FCount-1;
  FList [FCount-1] := inTexture;
end;

procedure avk_TTexmanager.DelById(inId: Integer);
var
  i : Integer;
begin
  if ( inID < 0 ) or ( inID > FCount - 1 ) or ( FCount = 0 ) Then exit;
  FList[ inId ].Destroy;
  //FList[ inId ].Free;

  for i := InID to FCount - 2 do
    begin
      FList[ i ]     := FList[ i + 1 ];
      FList[ i ].FID := i;
    end;

  DEC( FCount );
end;

procedure avk_TTexmanager.ClearAll;
var
  i : Integer;
begin
  for i := 0 to FCount - 1 do
    FList[ i ].Destroy();
  SetLength( FList, 0 );
  FCount := 0;
end;

constructor avk_TTexmanager.Create;
begin
  FCount         := 0;
  FID            := 0;
end;

destructor avk_TTexmanager.Destroy;
begin
  ClearAll;
  inherited Destroy;
end;

end.

