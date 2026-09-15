extends SceneTree
var lab
func _initialize():run.call_deferred()
func frames(n):
 for i in range(n):await process_frame
func mouse_button(pressed: bool):
 var event=InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed
 event.position=lab.start_button.get_global_rect().get_center();event.global_position=event.position
 root.push_input(event,true)
func run():
 lab=load("res://tests/sensor_gap_lab.gd").new();lab.require_sensor=false;root.add_child(lab)
 await frames(5)
 mouse_button(true)
 for i in range(8):lab.refresh_status();await process_frame
 mouse_button(false);await frames(2)
 var started=lab.running
 mouse_button(true);await frames(2);mouse_button(false);await frames(2)
 var paused=not lab.running
 var report={"passed":started and paused,"click_starts":started,"second_click_pauses":paused,"button_disabled":lab.start_button.disabled,"button_rect":str(lab.start_button.get_global_rect())}
 var f=FileAccess.open("res://../evidence/sensor-gap-button.json",FileAccess.WRITE);f.store_string(JSON.stringify(report,"  "));f.close();print(JSON.stringify(report))
 lab.queue_free();await process_frame;quit(0 if report.passed else 1)
