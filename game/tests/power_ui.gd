extends "res://tests/acceptance.gd"

func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v10-"+name+".png"))

func visible_buttons_fit(context):
 for b in main.menu_buttons:
  if not is_instance_valid(b) or not b.is_visible_in_tree():continue
  b.grab_focus();await frames(4)
  var rect=b.get_global_rect()
  check(rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=root.size.x+1 and rect.end.y<=root.size.y+1,context+": "+b.text+" fits window")

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/power-ui-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b");data.state.continuous=true
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 await visible_buttons_fit("menu");await snap("menu-atualizado")
 main.menu_buttons.filter(func(b):return b.text=="Poderes e duração")[0].pressed.emit();await frames(5)
 await visible_buttons_fit("powers");await snap("oito-poderes")
 main.show_menu();main.speedrun_selected=true;main.start_game();await frames(5)
 check(main.power_buttons.size()==2 and main.power_buttons[0].is_visible_in_tree(),"two visible activation buttons during play")
 data.equip_power(0,"wings");data.equip_power(1,"bubble")
 main.power_buttons[0].pressed.emit();await frames(20);await snap("asas-em-acao")
 main.world.player.position=Vector2(970,130);main.power_buttons[1].pressed.emit();await frames(5);await snap("bolha-em-acao")
 data.equip_power(0,"bridge");main.world.player.position=Vector2(940,150);main.world.player.effects.clear();main.world.player.activate_slot(0);await frames(3);await snap("ponte-em-acao")
 main.show_pause();await frames(5);await visible_buttons_fit("pause");await snap("pausa-atualizada")
 main.show_settings("pause");await frames(5);await visible_buttons_fit("settings");await snap("controles-atualizados")
 var f=FileAccess.open("res://../evidence/power-ui-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));f.close()
 print("POWER UI: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
