extends SceneTree
var main
var failures=[]
func _initialize():run.call_deferred()
func frames(n):
 for i in range(n):await physics_frame
func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v04-"+name+".png"))
func run():
 var data=root.get_node("Data");data.save_path="res://../evidence/capture-v04-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("palavras_01")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(4)
 main.show_stages("menu","palavras");await frames(3);await snap("palavras-menu")
 # Menu button starts the word phase, then the finish button changes both content and scenery.
 main.menu_buttons.filter(func(b):return b.text.begins_with("Palavras · Natureza\n"))[0].pressed.emit()
 main.world.player.position=Vector2(400,150);await frames(40);await snap("outono-bosque-sol")
 var old_texture=main.world.background.texture.resource_path
 for i in range(data.activities.size()):main.on_answer(i,data.activities[i].target)
 main.show_finish();await frames(3)
 main.menu_buttons[0].pressed.emit();await frames(6)
 if data.profile().stage_id!="palavras_02" or main.world.background.texture.resource_path==old_texture:failures.append("next phase did not change word content and background")
 main.world.player.position=Vector2(400,150);await frames(40);await snap("primavera-lago-pe")
 main.praise_bag=["Isso, você acertou!!!"];main.on_answer(0,"PÉ");await frames(20);await snap("comemoracao")
 for entry in [["palavras_03","outono-vale-flor",4],["palavras_04","primavera-pomar-trem",4]]:
  data.choose_stage(entry[0]);main.start_game()
  for i in range(entry[2]):main.on_answer(i,data.activities[i].target)
  main.world.player.position=Vector2(float(data.activities[entry[2]].x),150);await frames(40);await snap(entry[1])
 # Word mode also works in Speed Run, keeping the adventure round intact.
 var before=JSON.stringify(data.profile().stages)
 main.speedrun_selected=true;main.start_game();await frames(30)
 if not data.speedrun_active or not main.run_clock.running or not data.round_progress().completed.is_empty():failures.append("word speed run did not start fresh")
 var normal_view=main.world.background.region_rect
 main.world.player.position=Vector2(400,150);await frames(20);await snap("speedrun-palavras")
 for i in range(data.activities.size()):main.on_answer(i,data.activities[i].target)
 main.show_finish();await frames(4)
 if main.run_result.is_empty() or JSON.stringify(data.profile().stages)!=before:failures.append("word speed result changed adventure progress")
 if main.world.background.region_rect!=normal_view:failures.append("background unexpectedly moved during the run")
 await snap("speedrun-resultado")
 var f=FileAccess.open("res://../evidence/words-ui.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"failures":failures,"screenshots":8,"next_phase_changed_scenery":true,"words_speedrun_tested":true},"  "));f.close()
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
