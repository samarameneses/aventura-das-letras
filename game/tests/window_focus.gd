extends "res://tests/acceptance.gd"

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/focus-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("dissilabas_01")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 main.speedrun_selected=true;main.start_game();await frames(3)
 var probe=Node.new();main.add_child(probe)
 probe.tree_exiting.connect(func():main._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT))
 main.remove_child(probe);probe.free()
 check(main.screen=="playing" and not main.run_clock.running,"focus loss stops clock without modifying the busy scene tree")
 await frames(3)
 check(main.screen=="pause" and main.menu.is_inside_tree() and main.menu.is_visible_in_tree(),"deferred pause creates a visible attached menu")
 check(not main.world.active,"focus loss pauses the player")
 main.menu_buttons[0].pressed.emit();await frames(3)
 check(main.screen=="playing" and main.world.active and main.run_clock.running,"continue button resumes the same run")
 main._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
 main.show_stages("pause","dissilabas");await frames(3)
 check(main.screen=="stages","queued focus pause does not overwrite a newer screen")
 # Menus may be replaced before their deferred initial focus executes.
 main.show_stages("pause","palavras");main.show_stages("pause","dissilabas");await frames(3)
 check(main.menu_buttons[0].has_focus(),"focus goes to the current menu after rapid replacement")
 main.queue_free();await frames(3)
 var f=FileAccess.open("res://../evidence/window-focus-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));f.close()
 print("WINDOW FOCUS: ",passes.size()," passed; ",failures.size()," failed")
 quit(0 if failures.is_empty() else 1)
