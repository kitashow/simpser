//процедуры игрового поля
procedure TMineForm.DoGameField(Sender: TObject);
var
  CKL: Integer;
begin
  For CKL := 0 to MineForm.Count - 1 do
    if MineForm.ListNom[CKL].Name <> 'Выход' then
      MineForm.ListNom[CKL].DeleteMe := true;
  MineForm.Wallpaper := MineForm.TexManager.TexName['Обои игрового поля'];
end;

