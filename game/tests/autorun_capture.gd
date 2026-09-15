extends "res://tests/speedrun.gd"

func snap(name):
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v08-"+name+".png"))

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/capture-v08-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 main.start_game();main.world.player.position=Vector2(400,150);await frames(12)
 await snap("aventura-vidas")
 main.show_menu();await frames(3)
 main.menu_buttons.filter(func(b):return b.text=="Speed Run")[0].pressed.emit();await frames(3)
 await snap("speedrun-menu")
 main.menu_buttons.filter(func(b):return b.text.begins_with("Família B\n"))[0].pressed.emit();await frames(110)
 check(main.screen=="playing" and main.world.player.position.x>250 and main.world.player.auto_run,"button and phase selection start visible automatic motion")
 check(main.instruction.text.contains("BA"),"running instruction appears before the first jump window")
 await snap("corrida-automatica")
 main.on_answer(0,"BE");await frames(8);await snap("dois-coracoes")
 main.on_answer(1,"BA");main.on_answer(2,"BA");await frames(3)
 await snap("coracoes-sem-interrupcao")
 main.start_game();await frames(3)
 check(await finish_auto_run(),"retry starts a playable automatic run through the finish portal")
 await snap("resultado")
 var f=FileAccess.open("res://../evidence/autorun-ui.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"screenshots":6},"  "));f.close()
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
