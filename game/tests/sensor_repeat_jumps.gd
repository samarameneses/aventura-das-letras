extends SceneTree
var jumps=0
var sequence=0
var event_id=0
var stamp=10000
var sid="first"
var sensor
func _initialize():run.call_deferred()
func packet(event: String):
 sequence+=1;stamp+=500
 var p={"protocol_version":1,"challenge":sensor.challenge,"session_id":sid,"device_id":"test","sequence":sequence,"sent_at_ms":Time.get_unix_time_from_system()*1000,"event":event,"stable":true}
 if event=="jump":event_id+=1;p.event_id=event_id
 return sensor.accept_packet(p,stamp)
func frames(n):
 for i in range(n):await physics_frame
func run():
 sensor=load("res://scripts/sensor.gd").new();root.add_child(sensor)
 sensor.set_process(false);sensor.enabled=true;sensor.challenge="012345678901234567890123"
 var floor=StaticBody2D.new();var collision=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=Vector2(20000,20);collision.shape=rect;floor.position=Vector2(0,170);floor.add_child(collision);root.add_child(floor)
 var player=load("res://scripts/player.gd").new();player.position=Vector2(50,150);player.auto_run=true;root.add_child(player)
 player.configure_sensor_jump(true)
 sensor.jump_requested.connect(func():player.sensor_jump=true)
 player.jumped.connect(func():jumps+=1)
 packet("calibration_start");stamp+=3100;packet("ready")
 await frames(25)
 var accepted=0
 for pair in range(4):
  if packet("jump"):accepted+=1
  await frames(28)
  if packet("jump"):accepted+=1
  await frames(95)
 var repeated=jumps==8
 var repeated_count=jumps
 # A new bridge session starts jump IDs at one after a connection reset.
 sensor.suspend();sensor.set_process(false);sid="second";sequence=0;event_id=0
 packet("calibration_start");stamp+=3100;packet("ready")
 var reconnected=packet("jump")
 await frames(55)
 var reconnect_jumped=jumps==repeated_count+1
 # Pending midair motion must not survive pausing / teleporting.
 packet("jump");await frames(12);packet("jump");await frames(2)
 player.clear_commands();player.active=false;await frames(5);player.active=true
 var count=jumps;await frames(90)
 var clears_pending=jumps==count
 var report={"passed":repeated and reconnected and reconnect_jumped and clears_pending,"accepted_commands":accepted,"expected_repeated_jumps":8,"actual_repeated_jumps":repeated_count,"repeated_jumps_ok":repeated,"new_session_first_jump_accepted":reconnected,"new_session_first_jump_executed":reconnect_jumped,"pause_clears_pending":clears_pending,"physical_sensor":false}
 var f=FileAccess.open("res://../evidence/sensor-repeat-jumps.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print(JSON.stringify(report))
 player.queue_free();floor.queue_free();sensor.queue_free();await process_frame
 quit(0 if report.passed else 1)
