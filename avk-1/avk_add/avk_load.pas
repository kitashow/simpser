unit avk_load;

{$mode delphi}
{$codepage UTF8}

interface
uses
  {$IFNDEF WINDOWS}
   cwstring,
  {$ENDIF}
  Classes
  , Zipper
  , Coder
  , zgl_file
  , zgl_utils
  , zgl_log
  , avk_gui
  , avk_strings
  ;
type

  { TSourceFileZip }
  TSourceFileZip = class
  private
    procedure DoCreateOutZipStream(Sender: TObject; var AStream: TStream;
      AItem: TFullZipFileEntry);
    procedure DoDoneOutZipStream(Sender: TObject; var AStream: TStream;
      AItem: TFullZipFileEntry);
  public
    MainModule: TStringList;
    ModuleStructure: TStringList;
    procedure ExtractFileFromZip(ZipName, FileName: string);
  public
    function SetMainTextModule(const InName: string): boolean;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  { TSourceRead }

  TSourceRead = class
    FullStr: String;
    NomStr: Integer;
    procedure ParsBySumbol(InStr: UTF8String);
  end;

implementation

{ TSourceRead }

procedure TSourceRead.ParsBySumbol(InStr: UTF8String);
var
TmpStr: UTF8String;
FullLength: Integer;
CKL: Integer;
SubCKL: Integer;
TmpSymb,BlokAsStr: UTF8String;
begin
  TmpStr := avk_TrimLeft(InStr);
  FullLength := utf8_Length(TmpStr);
  for CKL := 1 to FullLength do begin
    TmpSymb := avk_Char(TmpStr,CKL);
    if TmpStr = '"' then begin
      //вернуть блок строкой пока не случиться
      BlokAsStr := '';
      For SubCKL := CKL to FullLength do begin
        TmpSymb := avk_Char(TmpStr,SubCKL);
        if TmpSymb = '"' then Break;
        BlokAsStr := BlokAsStr + TmpSymb;
      end;
      //CKL := SubCKL;
      Continue;//Читаем далее
    end;
  end;
end;


{ TTestZip }

procedure TSourceFileZip.DoCreateOutZipStream(Sender: TObject; var AStream: TStream;
  AItem: TFullZipFileEntry);
begin
  AStream:=TMemorystream.Create;
end;

procedure TSourceFileZip.DoDoneOutZipStream(Sender: TObject; var AStream: TStream;
  AItem: TFullZipFileEntry);
begin
  AStream.Position:=0;
  MainModule.LoadFromStream(Astream);
  Astream.Free;
end;

procedure TSourceFileZip.ExtractFileFromZip(ZipName, FileName: string);
var
  ZipFile: TUnZipper;
  sl:TStringList;
begin
  sl:=TStringList.Create;
  sl.Add(FileName);
  ZipFile := TUnZipper.Create;
  try
    ZipFile.FileName := ZipName;
    ZipFile.OnCreateStream := DoCreateOutZipStream;
    ZipFile.OnDoneStream := DoDoneOutZipStream;
    ZipFile.UnZipFiles(sl);
  finally
    ZipFile.Free;
    sl.Free;
  end;
end;

function TSourceFileZip.SetMainTextModule(const InName: string): boolean;
var
  GetStr: String;
  procedure GoGoLoad;
  begin
    UTF8ToOEM866(GetStr);
    {$IfDef WINDOWS}
    ExtractFileFromZip(Utf8ToAnsi(InName),GetStr);
    {$ELSE}
    ExtractFileFromZip(InName,GetStr);
    {$ENDIF}
  end;

begin
  Result := false;
  GetStr := file_GetName(InName);
  GetStr := GetStr + avk_ModuleExtension;
  GoGoLoad;
  Result := MainModule.Count > 0;
  if not Result then begin
    GetStr := avk_TupicalModuleName1 + avk_ModuleExtension;
    GoGoLoad;
    Result := MainModule.Count > 0;
    if not Result then begin
      GetStr := avk_TupicalModuleName2 + avk_ModuleExtension;
      GoGoLoad;
      Result := MainModule.Count > 0;
    end;
  end;
  if Result then begin
    log_Add('Загружен файл программы по '+InName);
    OEM866ToUTF8(GetStr);
    log_Add('Определен как '+GetStr);
    if avk_find(MainModule.Strings[MainModule.Count - 1],'Конец.') <> 1 then
      MainModule.Add('Конец.');
  end;
end;

constructor TSourceFileZip.Create;
begin
  MainModule := TStringList.Create;
end;

destructor TSourceFileZip.Destroy;
begin
  MainModule.Destroy;
  inherited Destroy;
end;

end.
