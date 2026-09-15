extends SceneTree
func _initialize():run.call_deferred()
func run():
 var data=root.get_node("Data")
 data.save_path="res://../evidence/sensor-autorun-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("alfabeto_01")
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 for i in range(4):await process_frame
 var waiting=main.screen=="sensor" and main.speedrun_selected and main.world==null
 # Calibration is mocked here; actual USB calibration is checked separately.
 main.sensor.set_process(false);main.sensor.is_ready=true;main.start_game()
 await create_timer(0.5).timeout
 var player=main.world.player
 var before=player.position.x
 await create_timer(0.5).timeout
 var moved=player.position.x-before
 main.sensor.jump_requested.emit()
 await physics_frame
 await physics_frame
 var jumped=player.velocity.y<0
 var passed=waiting and player.auto_run and moved>10 and jumped and main.mode=="sensor"
 var f=FileAccess.open("res://../evidence/sensor-autorun.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":passed,"waits_for_calibration":waiting,"automatic_distance":moved,"sensor_signal_jumps":jumped,"physical_sensor":false},"  "));f.close()
 main.queue_free();await process_frame
 quit(0 if passed else 1)
