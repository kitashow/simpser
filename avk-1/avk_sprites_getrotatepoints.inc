///////////////////////////////////////////////////////////////////////////////
// X, Y - координаты спрайта
// Width, Height - его размеры
// Angle - угол поворота спрайта
// p0, p1, p2, p3 - вершины спрайта
// http://zengl.org/forum/index.php/topic,177.msg895.html#msg895

function avk_GetRotatePoints(X, Y, Width, Height, Angle: Single): avk_TRotate4Points;
  var
    x1, x2 : Single;
    y1, y2 : Single;
    cX, cY : Single;
    c, s   : Single;
begin

  x1 := -Width / 2;
  y1 := -Height / 2;
  x2 := -x1;
  y2 := -y1;
  cX :=  X + x2;
  cY :=  Y + y2;

  m_SinCos( Angle * deg2rad, s, c );

  Result[0].X := x1 * c - y1 * s + cX;
  Result[0].Y := x1 * s + y1 * c + cY;

  Result[1].X := x2 * c - y1 * s + cX;
  Result[1].Y := x2 * s + y1 * c + cY;

  Result[2].X := x2 * c - y2 * s + cX;
  Result[2].Y := x2 * s + y2 * c + cY;

  Result[3].X := x1 * c - y2 * s + cX;
  Result[3].Y := x1 * s + y2 * c + cY;

end;

function avk_GetRotatePoint (X, Y, XAxle, YAxle, Angle: Single): zglTPoint2D; overload;
var
  x1, x2 : Single;
  y1, y2 : Single;
  cX, cY : Single;
  c, s   : Single;
  FAngle: Single;
begin

  FAngle := m_Angle(X, Y, XAxle, YAxle) + Angle;

  x1 := X - XAxle;
  y1 := Y - YAxle;
  x2 := -x1;
  y2 := -y1;
  //cX :=  X + x2;
  //cY :=  Y + y2;
  cX :=  x1 + x2;
  cY :=  y1 + y2;

  m_SinCos( FAngle * deg2rad, s, c );

  Result.X := (x1 * c - y1 * s + cX) + XAxle;
  Result.Y := (x1 * s + y1 * c + cY) + YAxle;

end;

function avk_GetRotatePoint (X, Y, Angle: Single): zglTPoint2D; overload;
begin
  Result := avk_GetRotatePoint (X, Y, 0, 0, Angle);
end;




