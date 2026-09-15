extends SceneTree
func _initialize():run.call_deferred()
func run():
 var floor=StaticBody2D.new();floor.position=Vector2(0,335)
 var shape=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=Vector2(2000,40);shape.shape=rect;floor.add_child(shape);root.add_child(floor)
 var player=load("res://scripts/player.gd").new();player.position=Vector2(100,315);root.add_child(player)
 player.configure_sensor_jump(true)
 for i in range(10):await physics_frame
 var ground=player.position.y;var peak=ground;var frames=0
 player.sensor_jump=true
 await physics_frame
 # Observe after the physics callback has executed.
 await process_frame
 while frames<120:
  frames+=1;peak=minf(peak,player.position.y)
  if player.is_on_floor():break
  await physics_frame
  await process_frame
 var seconds=float(frames)/Engine.physics_ticks_per_second
 var height=ground-peak
 var report={"passed":seconds>=0.38 and seconds<=0.42 and height>41 and height<44,"flight_seconds":seconds,"height_pixels":height,"physical_sensor":false}
 var f=FileAccess.open("res://../evidence/player-fast-fall.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print(JSON.stringify(report))
 player.queue_free();floor.queue_free();await process_frame
 quit(0 if report.passed else 1)
