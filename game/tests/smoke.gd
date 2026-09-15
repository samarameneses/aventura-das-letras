extends SceneTree
var failures=[]
func _initialize():
 run.call_deferred()
func check(value: bool, message: String):
 if not value:failures.append(message);push_error(message)
 else:print("PASS "+message)
func frames(n: int):
 for i in range(n):await physics_frame
func run():
 var data=root.get_node("Data")
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("jardim_inicio")
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 await frames(3)
 check(main.screen=="menu","menu opens without sensor")
 check(not main.sensor.enabled and main.sensor.udp==null,"no receiver initialized by default")
 main.start_game();await frames(30)
 check(main.world.player.is_on_floor(),"player stands on physical ground")
 var start=main.world.player.position
 Input.action_press("move_right");await frames(45);Input.action_release("move_right")
 check(main.world.player.position.x>start.x+40,"keyboard intent moves player")
 Input.action_press("jump");await frames(1);Input.action_release("jump");await frames(8)
 check(main.world.player.position.y<start.y-15,"jump physically rises")
 await frames(60)
 check(main.world.player.is_on_floor(),"player lands")
 main.world.player.position=Vector2(1000,260);await frames(3)
 check(main.world.player.position.x<120,"fall respawns at checkpoint")
 check(data.profile().attempts[-1].kind=="virtual_fall","fall logged as motor event")
 main.show_pause();await frames(3)
 check(main.screen=="pause" and not main.world.player.active,"pause stops gameplay")
 main.resume_game();await frames(2)
 check(main.world.player.active,"resume restores control")
 var a=data.activities[0]
 main.on_answer(0,a.target)
 main.on_answer(0,a.target)
 check(data.round_progress().completed.count(a.id)==1,"correct collection cannot duplicate")
 check(data.save_progress(),"progress saves successfully")
 main.queue_free();await frames(2)
 var f=FileAccess.open("res://../evidence/smoke.json",FileAccess.WRITE)
 if f:f.store_string(JSON.stringify({"failures":failures,"passed":failures.is_empty()}))
 print("SMOKE: ",failures.size()," failures")
 quit(0 if failures.is_empty() else 1)
