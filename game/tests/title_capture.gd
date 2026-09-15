extends "res://tests/acceptance.gd"
func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v10-"+name+".png"))
func run():
 data=root.get_node("Data");data.save_path="res://../evidence/menu-capture-progress.json";data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b");data.state.continuous=true
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(8)
 for dimensions in [Vector2i(960,540),Vector2i(1280,720),Vector2i(640,360),Vector2i(390,844),Vector2i(320,568)]:
  root.size=dimensions;await frames(8);main.show_menu();await frames(8)
  main.menu.scroll.scroll_vertical=0;await frames(2)
  await snap("menu-"+str(dimensions.x)+"x"+str(dimensions.y))
 root.size=Vector2i(390,844);await frames(6)
 main.show_powers("menu");await frames(10);main.menu.scroll.scroll_vertical=0;await frames(2);await snap("poderes-vertical")
 main.show_stages("menu","dissilabas");await frames(10);main.menu.scroll.scroll_vertical=0;await frames(2);await snap("fases-vertical")
 root.size=Vector2i(960,540);await frames(6)
 main.show_powers("menu");await frames(10);await snap("poderes-horizontal")
 main.show_menu();main.menu.actions[0].pressed.emit();await frames(12);await snap("jogo-preservado")
 print("NATIVE TITLE CAPTURES COMPLETE")
 main.queue_free();await frames(2);quit()
