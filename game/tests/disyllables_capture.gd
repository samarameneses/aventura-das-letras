extends "res://tests/speedrun.gd"

func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v05-"+name+".png"))

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/capture-v05-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("palavras_06")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(4)
 main.start_game()
 for i in range(data.activities.size()):main.on_answer(i,data.activities[i].target)
 main.show_finish();await frames(3);main.menu_buttons[0].pressed.emit();await frames(8)
 check(data.profile().stage_id=="dissilabas_01","next button advances from monosyllables to disyllables")
 main.show_stages("pause","dissilabas");await frames(3);await snap("dissilabas-menu")
 check(main.menu_buttons.all(func(b):return b.get_global_rect().end.x<=root.size.x),"seven category tabs and phase buttons fit the window")
 var scroll=main.menu.find_children("*","ScrollContainer",true,false)[0]
 var items=scroll.find_children("*","Button",true,false)
 items[-1].grab_focus();await frames(4)
 check(scroll.scroll_vertical>0,"keyboard reaches the twentieth disyllable phase")
 await snap("ultima-fase")
 items[-1].pressed.emit();await frames(5)
 check(data.profile().stage_id=="dissilabas_20","last phase button starts the correct word set")
 for i in range(2):main.on_answer(i,data.activities[i].target)
 main.world.player.position=Vector2(float(data.activities[2].x),150);await frames(220)
 await snap("brincar-cantar")
 var hint_event=InputEventAction.new();hint_event.action="help";hint_event.pressed=true
 main._unhandled_input(hint_event);await frames(4)
 check(main.helped and main.feedback.text.contains("BRIN · CAR"),"help displays the two syllables of BRINCAR")
 await snap("ajuda-duas-silabas")
 await tap("jump");await frames(65)
 check(data.activities[2].id in data.round_progress().completed and main.success_timer>0,"long word collected by jumping triggers encouragement")
 await snap("comemoracao")
 var normal=JSON.stringify(data.profile().stages)
 main.speedrun_selected=true;main.start_game();await frames(10)
 check(data.speedrun_active and data.round_progress().completed.is_empty(),"disyllable speed run starts with all five words")
 check(await finish_auto_run(),"automatic disyllable route finishes with jumps only")
 check(main.screen=="finish" and not data.speedrun_record("dissilabas_20").is_empty(),"timed disyllables finish and save a record")
 check(JSON.stringify(data.profile().stages)==normal,"word race preserves normal adventure progress")
 await snap("speedrun-resultado")
 var out=FileAccess.open("res://../evidence/disyllables-ui.json",FileAccess.WRITE)
 out.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"screenshots":6},"  "));out.close()
 print("DISYLLABLE UI: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
