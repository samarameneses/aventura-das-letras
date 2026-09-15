extends "res://tests/acceptance.gd"

func snap(name):
 if DisplayServer.get_name()=="headless":return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v111-"+name+".png"))

func verify_buttons(context):
 var outside=[]
 for b in main.menu_buttons:
  if not is_instance_valid(b) or not b.is_visible_in_tree():continue
  b.grab_focus();await frames(3)
  var rect=b.get_global_rect()
  if rect.position.x<0 or rect.end.x>root.size.x+1 or rect.position.y<0 or rect.end.y>root.size.y+1:outside.append(b.text+" "+str(rect))
 check(outside.is_empty(),context+": all buttons reachable and inside screen after focus "+str(outside))

func run():
 root.mode=Window.MODE_WINDOWED
 data=root.get_node("Data");data.save_path="res://../evidence/menu-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 for dimensions in [Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(800,600),Vector2i(640,360),Vector2i(390,844),Vector2i(320,568),Vector2i(2560,1080)]:
  root.size=dimensions;await frames(6)
  var context=str(dimensions.x)+"x"+str(dimensions.y)
  main.show_menu();await frames(5)
  check(main.menu.get_script()==main.TitleMenu and main.menu.actors.size()==4,context+": four animated characters in title menu")
  await verify_buttons(context+" main")
  main.menu.scroll.scroll_vertical=0;main.menu.actions[0].grab_focus();await frames(4)
  if dimensions in [Vector2i(960,540),Vector2i(390,844),Vector2i(640,360),Vector2i(1920,1080)]:await snap("menu-"+context)
  main.show_powers("menu");await frames(6);await verify_buttons(context+" powers")
  if dimensions==Vector2i(390,844):await snap("poderes-vertical")
  main.show_stages("menu","dissilabas");await frames(6);await verify_buttons(context+" phases")
  main.show_settings("menu");await frames(6);await verify_buttons(context+" settings")
  main.show_sensor(false);await frames(4);await verify_buttons(context+" sensor")
  main.mode="buttons";main.sensor.deactivate();main.start_game();await frames(5)
  var surface=main.play_surface.get_global_rect()
  check(surface.position.x>=-1 and surface.position.y>=-1 and surface.end.x<=root.size.x+1 and surface.end.y<=root.size.y+1,context+": entire gameplay and HUD fit screen")
  check(main.viewport.size==Vector2i(320,180),context+": gameplay retains original 16:9 physics view")
  main.show_pause();await frames(5);await verify_buttons(context+" pause")
 root.size=Vector2i(960,540);main.show_menu();await frames(5)
 main.menu.profile_buttons[1].pressed.emit();await frames(4)
 check(data.state.selected_profile=="luna" and main.screen=="menu","profile selection still works")
 main.menu.character_buttons[3].pressed.emit();await frames(4)
 check(data.profile().character==3 and main.menu.actors[3].character_id=="samara","character selection still works and uses existing Samara art")
 main.menu.actions[0].pressed.emit();await frames(5)
 check(main.screen=="playing" and main.world.player.character_id=="samara","primary title button starts selected character")
 main.show_menu();await frames(4);main.menu.actions[1].pressed.emit();await frames(4)
 check(main.screen=="stages" and main.speedrun_selected,"Speed Run remains available in title menu")
 main.show_menu();await frames(3)
 main._focus_control(main.menu.actions[0]);await frames(2)
 check(main.menu.actions[0].has_focus(),"primary action receives keyboard focus")
 var report=FileAccess.open("res://../evidence/responsive-menu-tests.json",FileAccess.WRITE)
 report.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));report.close()
 print("RESPONSIVE MENU: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
