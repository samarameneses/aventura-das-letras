extends "res://tests/speedrun.gd"

func fresh(sid="alfabeto_01"):
 data.choose_stage(sid);main.speedrun_selected=true;main.start_game();await frames(4)

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/terrain-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.state.continuous=false
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(4)
 await fresh()
 var w=main.world;var p=w.player
 var lava=w.environment.zones.filter(func(z):return z.kind=="lava")[0]
 var normal=data.profile().stages.duplicate(true)
 main.feedback.text="";main.feedback_timer=0
 main.on_answer(0,str(data.activities[0].target));main.success_banner.hide()
 var discoveries=data.round_progress().completed.duplicate()
 p.position=Vector2(lava.x+8,150);w.update_environment(0.016)
 check(data.lives_remaining()==2 and p.burn_seconds>0,"lava removes one heart and starts brief fire")
 check(p.position.x>lava.x+lava.width and p.position.x<lava.x+lava.width+30,"lava returns to nearby safe bank")
 check(data.round_progress().completed==discoveries and main.screen=="playing" and main.run_clock.running and not main.menu.visible,"lava preserves discoveries and uninterrupted play")
 check(data.speedrun_attempts[-1].kind=="lava_contact" and not data.speedrun_attempts[-1].has("correct"),"lava contact is motor event, never a reading error")
 p.position=Vector2(lava.x+8,150);w.update_environment(0.016)
 check(data.lives_remaining()==2,"temporary protection prevents repeated damage")
 p.position=Vector2(lava.x+lava.width+30,150)
 main.show_pause();var burn=p.burn_seconds;var immunity=w.lava_immunity;await frames(10)
 check(p.burn_seconds==burn and w.lava_immunity==immunity,"pause freezes fire and immunity")
 main.resume_game()
 for i in range(2):
  w.lava_immunity=0;p.position=Vector2(lava.x+8,150);w.update_environment(0.016)
 check(data.lives_remaining()==3 and data.round_progress().completed==discoveries and main.screen=="playing","last heart renews gently without restarting")
 check(data.profile().stages==normal,"speed-run terrain damage preserves normal adventure saves")
 await fresh();w=main.world;p=w.player
 p.position=Vector2(185,150);await frames(4)
 check(p.wet_seconds>0 and data.lives_remaining()==3,"shallow river wets feet without damage")
 p.position=Vector2(300,150);await frames(145)
 check(p.wet_seconds<=0,"wet feet dry after leaving river")
 await fresh();w=main.world;p=w.player
 var bridge=w.environment.zones.filter(func(z):return z.kind=="bridge")[0]
 p.position=Vector2(bridge.x-15,150);await frames(70)
 check(p.position.x>bridge.x+bridge.width and p.position.y<=151 and data.lives_remaining()==3,"wooden bridge supports walking across real ground gap")
 await fresh();w=main.world;p=w.player
 p.auto_run=false;p.position=Vector2(lava.x-14,150);await frames(3)
 Input.action_press("move_right");Input.action_press("jump");await frames(1);Input.action_release("jump");await frames(65);Input.action_release("move_right")
 check(p.position.x>lava.x+lava.width and data.lives_remaining()==3,"lava is clearable with normal unpowered manual jump")
 await fresh("alfabeto_03");check(main.world.environment.night,"third stage uses night scenery")
 await fresh("alfabeto_02");check(main.world.environment.dusk and not main.world.environment.night,"second stage uses sunset scenery")
 await fresh("alfabeto_01");check(not main.world.environment.night and not main.world.environment.dusk,"first stage uses daylight")
 data.profile().power_run_records={"alfabeto_01":{"best_ms":1,"last_ms":1,"runs":1}}
 check(data.speedrun_record("alfabeto_01").is_empty() and data.valid_state(data.state),"earlier course records are preserved separately")
 var routes=0
 for stage in data.stages:
  await fresh(stage.id)
  var complete=await finish_auto_run()
  check(complete and data.lives_remaining()==3 and data.round_progress().completed.size()==data.activities.size(),stage.id+": all discoveries and terrain crossed using jumps only without damage")
  if complete:routes+=1
 var f=FileAccess.open("res://../evidence/terrain-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"routes":routes},"  "));f.close()
 print("TERRAIN: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
