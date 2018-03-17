{ TBullet1 }

procedure TBullet1.StartMoveBullet(AStartPoint, AFinishPoint: zglTPoint2D);
begin
  FStartPoint := AStartPoint;
  FFinishPoint := AFinishPoint;
  Position := AStartPoint;

end;

