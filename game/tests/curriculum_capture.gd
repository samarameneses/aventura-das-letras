extends SceneTree
var main
func _initialize():run.call_deferred()
func snap(name: String):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v02-"+name+".png"))
func frames(n: int):
 for i in range(n):await physics_frame
func run():
 var data=root.get_node("Data");data.save_path="res://../evidence/capture-v02-progress.json"
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("alfabeto_01")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 await snap("menu")
 main.show_stages("menu","alfabeto");await frames(3);await snap("alphabet-map")
 main.show_stages("menu","familias");await frames(3);await snap("syllable-map")
 # Keyboard focus follows the last item inside the scrollable stage list.
 var scroll=main.menu.find_children("*","ScrollContainer",true,false)[0]
 var items=scroll.find_children("*","Button",true,false)
 items[-1].grab_focus();await frames(4)
 var scrolled=scroll.scroll_vertical>0
 data.choose_stage("silabas_b");main.start_game();main.world.player.position=Vector2(400,150);await frames(10)
 await snap("ba")
 main.praise_bag=["Isso, você acertou!!!"]
 main.on_answer(0,"BA");await frames(28)
 await snap("success")
 data.round_progress().completed=data.activities.map(func(a):return a.id)
 main.show_finish();await frames(10);await snap("finish")
 var next_button=main.menu_buttons[0]
 next_button.pressed.emit();await frames(8)
 var advanced=data.profile().stage_id=="silabas_c" and main.screen=="playing"
 data.choose_stage("silabas_br");main.start_game();main.world.player.position=Vector2(400,150);await frames(10)
 await snap("bra")
 var out=FileAccess.open("res://../evidence/curriculum-ui.json",FileAccess.WRITE)
 out.store_string(JSON.stringify({"stage_list_follows_keyboard_focus":scrolled,"next_button_starts_next_family":advanced,"screenshots":7,"physical_controller_tested":false},"  "));out.close()
 main.queue_free();await frames(2);quit(0 if scrolled and advanced else 1)
