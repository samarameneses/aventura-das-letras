extends SceneTree
func _initialize():run.call_deferred()
func run():
 var data=root.get_node("Data");data.save_path="res://../evidence/direct-speedrun-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 for i in range(30):await physics_frame
 var passed=main.screen=="playing" and main.world.player.auto_run and main.world.player.position.x>120 and data.lives_remaining()==3
 var f=FileAccess.open("res://../evidence/direct-speedrun-tests.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":passed}));f.close()
 main.queue_free();await process_frame;quit(0 if passed else 1)
