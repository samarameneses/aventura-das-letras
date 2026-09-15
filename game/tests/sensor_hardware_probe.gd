extends SceneTree
# Bench integration only: this does not load the game or edit player progress.
func _initialize():run.call_deferred()
func run():
 var s=load("res://scripts/sensor.gd").new();root.add_child(s)
 s.activate()
 var start=Time.get_ticks_msec()
 var ready_at=-1
 while Time.get_ticks_msec()-start<16000:
  await process_frame
  if s.is_ready and ready_at<0:ready_at=Time.get_ticks_msec()
  if ready_at>=0 and Time.get_ticks_msec()-ready_at>=3000:break
 var report={"physical_sensor":true,"ready":s.is_ready,"status":s.status,"received":s.received,"discarded":s.discarded,"elapsed_ms":Time.get_ticks_msec()-start,"jump_validation":false}
 var f=FileAccess.open("res://../evidence/esp32-usb-game-calibration.json",FileAccess.WRITE)
 f.store_string(JSON.stringify(report,"  "));f.close()
 var passed=s.is_ready
 s.deactivate();s.queue_free();await process_frame
 quit(0 if passed else 1)
