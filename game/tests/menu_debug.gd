extends "res://tests/acceptance.gd"
func run():
 data=root.get_node("Data");data.save_path="res://../evidence/menu-debug-progress.json";data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 for dimensions in [Vector2i(320,568),Vector2i(640,360)]:
  root.size=dimensions;await frames(5);main.show_menu();await frames(5)
  for b in main.menu_buttons:
   if b.text.contains("Convidado"):print("PROFILE ",root.size," ",b.get_global_rect())
  for action in [func():main.show_settings("menu"),func():main.show_sensor(false),func():main.show_powers("menu")]:
   action.call();await frames(10)
   print("LAYOUT ",root.size," ",main.screen," panel ",main.menu.panel.get_global_rect()," min ",main.menu.panel.get_combined_minimum_size()," scroll ",main.menu.scroll.get_global_rect()," content ",main.menu.content.get_global_rect())
   for child in main.menu.content.get_children():print("CHILD ",child.get_class()," ",child.get_combined_minimum_size()," ",child.get_global_rect())
   main.menu_buttons[0].grab_focus();await frames(5);print("BUTTON ",main.menu_buttons[0].get_global_rect())
 main.queue_free();await frames(2);quit()
