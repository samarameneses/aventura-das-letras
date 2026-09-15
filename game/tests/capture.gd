extends SceneTree
func _initialize():run.call_deferred()
func snap(file):
 await process_frame
 await RenderingServer.frame_post_draw
 var img=root.get_texture().get_image()
 img.save_png(ProjectSettings.globalize_path("res://../evidence/"+file+".png"))
func run():
 var data=root.get_node("Data");data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 for i in range(10):await process_frame
 await snap("menu")
 main.start_game()
 for i in range(30):await physics_frame
 await snap("phase-start")
 main.world.player.position=Vector2(380,150)
 for i in range(10):await physics_frame
 await snap("activity")
 main.show_pause()
 await snap("pause")
 main.show_settings("pause")
 await snap("settings")
 main.show_menu()
 var previous=main.get_viewport().gui_get_focus_owner()
 var key=InputEventKey.new();key.physical_keycode=KEY_TAB;key.keycode=KEY_TAB;key.pressed=true;Input.parse_input_event(key)
 await process_frame
 key.pressed=false;Input.parse_input_event(key);await process_frame
 var keyboard_ok=main.get_viewport().gui_get_focus_owner()!=previous
 previous=main.get_viewport().gui_get_focus_owner()
 var joy=InputEventJoypadButton.new();joy.button_index=JOY_BUTTON_DPAD_RIGHT;joy.pressed=true;Input.parse_input_event(joy)
 await process_frame
 joy.pressed=false;Input.parse_input_event(joy);await process_frame
 var controller_ok=main.get_viewport().gui_get_focus_owner()!=previous
 for c in range(4):
  data.profile().character=c;main.start_game()
  main.world.player.position=Vector2(380,150)
  for i in range(10):await physics_frame
  await snap("character-"+str(c))
 main.world.player.position=Vector2(2118,150)
 data.round_progress().completed=data.activities.map(func(a):return a.id)
 main.show_finish()
 for i in range(30):await process_frame
 await snap("finish")
 var f=FileAccess.open("res://../evidence/ui.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"keyboard_focus_navigation":keyboard_ok,"synthetic_gamepad_focus_navigation":controller_ok,"physical_controller_tested":false,"voices":DisplayServer.tts_get_voices(),"engine":Engine.get_version_info().string},"  "));f.close()
 quit()
