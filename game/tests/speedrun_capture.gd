extends SceneTree
func _initialize():run.call_deferred()
func frames(n):
 for i in range(n):await physics_frame
func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/speedrun-"+name+".png"))
func run():
 var data=root.get_node("Data");data.save_path="res://../evidence/speedrun-capture-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 await snap("menu")
 main.menu_buttons.filter(func(b):return b.text=="Speed Run")[0].pressed.emit();await frames(3)
 await snap("stages")
 main.menu_buttons.filter(func(b):return b.text.begins_with("Família B\n"))[0].pressed.emit()
 main.world.player.position=Vector2(400,150);await frames(100)
 await snap("playing")
 main.show_pause();await frames(3);await snap("pause");main.resume_game()
 # Result layout fixture only; the physical route is tested separately.
 for i in range(data.activities.size()):main.on_answer(i,data.activities[i].target)
 main.show_finish();await frames(10);await snap("result")
 main.queue_free();await frames(2);quit()
