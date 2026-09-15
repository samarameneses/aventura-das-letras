extends "res://tests/speedrun.gd"

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/lives-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("alfabeto_01")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 main.start_game();await frames(3)
 check(data.lives_remaining()==3 and main.lives_label.text.count("♥")==3,"new normal phase shows three hearts")
 main.on_answer(0,"B");check(data.lives_remaining()==2,"wrong letter removes one life")
 main.on_answer(0,"A");main.on_answer(0,"A")
 check(data.lives_remaining()==2 and data.round_progress().completed.size()==1,"correct and duplicate collection keep remaining lives")
 main.show_pause();main.resume_game();main.show_menu();main.start_game();await frames(3)
 check(data.lives_remaining()==2,"pause and menu do not restore lost hearts")
 data.save_progress();data.load_progress()
 check(data.lives_remaining()==2,"normal lives survive save and reload")
 main.on_answer(1,"C");main.on_answer(1,"C")
 check(main.screen=="playing" and data.lives_remaining()==3 and main.world.active,"exhausted hearts renew without stopping the phase")
 check(data.round_progress().completed.size()==1 and not data.round_progress().finished,"renewing hearts preserves discoveries without marking completion")
 main.show_menu();main.start_game();await frames(3)
 check(main.screen=="playing" and data.lives_remaining()==3,"reopening phase continues directly")
 main.world.player.position=Vector2(1000,260);await frames(3)
 check(data.lives_remaining()==3,"falling returns safely without an answer penalty")
 data.round_progress().erase("lives")
 check(data.valid_state(data.state) and data.lives_remaining()==3,"older saves without lives remain compatible")
 var malformed=data.state.duplicate(true);malformed.profiles.convidado.stages.alfabeto_01.lives=-1
 check(not data.valid_state(malformed),"invalid negative life count is rejected")
 # An old manual record is preserved but not compared with the new automatic course.
 data.profile().speedrun_records={"alfabeto_01":{"best_ms":1,"last_ms":1,"runs":1}}
 check(data.speedrun_record("alfabeto_01").is_empty(),"old manual records stay separate from automatic records")
 main.speedrun_selected=true;main.start_game();await frames(15)
 var player=main.world.player;var x=player.position.x
 Input.action_press("move_left");await frames(20);Input.action_release("move_left")
 check(player.auto_run and player.position.x>x+25 and player.sprite.animation=="run","Speed Run moves and animates automatically even with left held")
 var normal_lives=data.profile().stages.alfabeto_01.get("lives",3)
 # One wrong physical jump must only cost one life despite many collision frames.
 for frame in range(400):
  if player.position.x>=456:break
  await frames(1)
 await tap("jump");await frames(40)
 check(data.lives_remaining()==2 and main.screen=="playing" and player.position.x>480,"wrong physical running jump costs one heart and keeps moving")
 check(data.profile().stages.alfabeto_01.get("lives",3)==normal_lives,"running lives are separate from normal adventure")
 main.start_game();await frames(300)
 check(data.lives_remaining()==3 and data.round_progress().completed.is_empty() and main.world.player.position.x>540,"missed options keep moving without losing lives or scoring")
 main.world.player.has_power=true;main.world.player.position=Vector2(660,150);await frames(3)
 await tap("power");await frames(5)
 check(main.world.player.power_seconds>5 and main.world.player.velocity.x>110,"speed power increases automatic running speed")
 # Every existing phase must be finishable using only jump input in the new course.
 var completed=0
 for stage in data.stages:
  data.choose_stage(stage.id);main.start_game();await frames(3)
  var success=await finish_auto_run()
  check(success and data.lives_remaining()==3,stage.id+": automatic run finishes with jumps only and no wrong choices")
  if success:completed+=1
  main.show_menu();await frames(2);main.speedrun_selected=true
 var f=FileAccess.open("res://../evidence/lives-autorun-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"automatic_stages_finished":completed},"  "));f.close()
 print("LIVES AND AUTORUN: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
