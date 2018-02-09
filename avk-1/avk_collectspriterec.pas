unit avk_collectspriterec;

{$mode objfpc}{$H+}
{$codepage UTF8}

interface
uses
 {$IFNDEF WINDOWS}
 cwstring,
 {$ENDIF}
  Classes//Блин... не избежать
  , avk_gui
  , avk_btype
  , avk_texmanager
  , avk_input
  , zgl_textures
  , zgl_utils
  , zgl_screen
  , zgl_math_2d
  , zgl_font
  , zgl_primitives_2d
  , zgl_collision_2d
  , zgl_fx
  , zgl_text
  , zgl_textures_tga
  , zgl_sprite_2d
  , zgl_types
  , zgl_keyboard
  , zgl_main
  , zgl_camera_2d
  ;

type

avk_TCollectionRecAbotImg = class
protected
  FParent : avk_PRI;
  FList  : array of TArrayOfavk_PRI;
  FIndxLoyar  : array of TArrayOfavk_PRI;
  function GetCount: Integer;
  procedure SetCollisionInRec(const inRec, inVerRec: avk_PRI);
public
  function GetRecAs_zglTCircle(const inRec: avk_PRI):zglTCircle;
  function GetRecAs_zglTLine(const inRec: avk_PRI):zglTLine;
  function GetRecAs_zglTPoint2D(const inRec: avk_PRI):zglTPoint2D;
  function GetRecAs_zglTRect(const inRec: avk_PRI):zglTRect;
public
  function CollizionBtvZone(const inRec, inVerRec: avk_PRI):boolean;
public
  function GetMaxExtId: Integer;//сомнительной нужности
  function GetRecByExtId(const inExtId:Integer):avk_PRI;
  function MakeNextCadre(const inIDPriem : Integer): boolean;//только видимость, не меняет позиции
  function IspectCollizion (const InHostName: String; MakeIvent: boolean = true): boolean;//проверить на коллизии
  function RotateSpr (const InHostName: String; inGraduce: Single; ColUndo: boolean = false):boolean ;//поворот
  function MoveUDSpr (const InHostName: String; inSpead: Single):boolean;//двинуть вперед-назад на точку
  procedure CalcSpr(const InHostName: String; inVisual: zglTRect);//расчет в окне
public
  function  GetMaxLayer (const inName : String = ''): Integer; //если пустой, то вообще макс слой
  procedure InspectFraims;
  function  GetRecById( const inID : Integer ) : avk_RecAboutImg;
  function  GetRecByNum(const inNum : Integer ) : avk_RecAboutImg;
  function  GetIdByName(const inName : String = ''; InId: Integer = -1) : Integer;//если пустое имя, то максимальный ид, если ид и имя не пустые, то следующий в рамках имени
  procedure SetRecById(const inID : Integer; inFraim: avk_RecAboutImg);
  procedure SetRecByNum( inNum : Integer; inFraim: avk_RecAboutImg);
  procedure DelById (inId: Integer);
  function AddNewRec(inRec: avk_RecAboutImg):avk_PRecAboutImg;
  procedure ClearAll;
public
  function GetNextIdInHostName (const inHostName : String = ''; inId: Integer = 0): Integer;
  function GetByHostName (inName : String): avk_TCollectionRecAbotImg;
  function GetMainByHostName (const inName : String = ''): avk_RecAboutImg;
  function GetNextHostName (const inName : String = ''): avk_RecAboutImg;
  function GetCountNames: Integer;
  function RecIsEmpity (inRec: avk_RecAboutImg): boolean;
  procedure DelByHostName (inName : String);
public
  constructor Create;
  destructor Destroy; override;
public
  property Count: Integer read GetCount;
  property CountNames: Integer read GetCountNames;
  property Parent: avk_RecAboutImg read FParent;
  property ListId[InID :Integer]: avk_RecAboutImg read GetRecById;
  property ListNm[InNum :Integer]: avk_RecAboutImg read GetRecByNum;
end;

implementation

end.

