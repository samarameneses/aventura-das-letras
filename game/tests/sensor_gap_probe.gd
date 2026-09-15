extends SceneTree
var lab
func _initialize():run.call_deferred()
func trial(width: float,should_jump: bool):
 lab.running=false;lab.set_gap(width);lab.running=true
 var initial_returns=lab.returns;var initial_crossings=lab.crossings;var fired=false
 for i in range(400):
  if should_jump and not fired and lab.countdown<=0 and lab.player.position.x>=lab.GAP_X-10:
   fired=true;lab.commands+=1;lab.command_at=Time.get_ticks_msec();lab.player.sensor_jump=true
  await physics_frame
  await process_frame
  if lab.returns>initial_returns or lab.crossings>initial_crossings:break
 lab.running=false
 return {"width":width,"jump_requested":should_jump,"crossed":lab.crossings>initial_crossings,"returned":lab.returns>initial_returns,"range_px":lab.last_range,"flight_ms":lab.last_flight_ms}
func run():
 lab=load("res://tests/sensor_gap_lab.gd").new();lab.require_sensor=false;root.add_child(lab)
 await process_frame
 var no_jump=await trial(32,false)
 var good_jump=await trial(32,true)
 var too_wide=await trial(48,true)
 var passed=no_jump.returned and not no_jump.crossed and good_jump.crossed and not good_jump.returned and too_wide.returned
 var report={"passed":passed,"physical_sensor":false,"no_jump":no_jump,"well_timed_jump":good_jump,"wider_gap":too_wide}
 var f=FileAccess.open("res://../evidence/sensor-gap-physics.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print(JSON.stringify(report))
 lab.queue_free();await process_frame;quit(0 if passed else 1)
