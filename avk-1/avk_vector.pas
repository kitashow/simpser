{Просто для большего понимания, модуль по сути не нужен}
unit avk_vector;

{$mode delphi}

interface

uses
  zgl_math_2d;

//угол точки (от 0 координат)
function VcToAngle(AValue: zglTPoint2D): Single;

//Длина вектора
function VcLength(AValue: zglTPoint2D): Single;

//точка на угол (умножить на длину вектора и вот тебе новая точка)
function VcForAngle(AValue: Single): zglTPoint2D;


implementation

function VcToAngle(AValue: zglTPoint2D): Single;
begin
  Result := m_Angle(AValue.X, AValue.Y, 0, 0);
end;

function VcForAngle(AValue: Single): zglTPoint2D;
begin
  m_SinCos(AValue * deg2rad, Result.Y, Result.X);
  //Result.X := cos(AValue * deg2rad);
  //Result.Y := sin(AValue * deg2rad);
end;

function VcLength(AValue: zglTPoint2D): Single;
begin
  Result := m_Distance(0, 0, AValue.X, AValue.Y);
end;

end.

