extends SceneTree
var count=0
var disconnected=false
func _initialize():run.call_deferred()
func run():
 var s=load("res://scripts/sensor.gd").new();root.add_child(s)
 s.jump_requested.connect(func():count+=1)
 s.connection_lost.connect(func():disconnected=true)
 s.activate()
 var start=Time.get_ticks_msec()
 while Time.get_ticks_msec()-start<12000 and not disconnected:
  await process_frame
 var passed=count==1 and disconnected
 var f=FileAccess.open("res://../evidence/sensor-integration.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":passed,"jump_events":count,"disconnect_detected":disconnected,"transport":"real UDP loopback via Python bridge","physical_sensor":false},"  "));f.close()
 s.deactivate();s.queue_free();await process_frame
 quit(0 if passed else 1)
