extends "res://tests/acceptance.gd"
func snap(caption):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v12-"+caption+".png"))
func run():
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
 data=root.get_node("Data");data.save_path="res://../evidence/terrain-capture-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.state.continuous=false
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 for pair in [["alfabeto_01","dia"],["alfabeto_02","entardecer"],["alfabeto_03","noite"]]:
  data.choose_stage(pair[0]);main.speedrun_selected=true;main.start_game();await frames(5)
  var w=main.world;var p=w.player
  p.position=Vector2(185,150);await frames(3);w.set_active(false);await snap(pair[1]+"-rio")
  w.set_active(true);p.position=Vector2(647,150);w.lava_immunity=0;await frames(3);w.set_active(false);await snap(pair[1]+"-lava")
  w.set_active(true);p.position=Vector2(1080,150);await frames(3);w.set_active(false);await snap(pair[1]+"-ponte")
 main.queue_free();await frames(2);quit()
