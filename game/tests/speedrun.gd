extends "res://tests/acceptance.gd"

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/speedrun-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 var Clock=load("res://scripts/run_clock.gd");var clock=Clock.new()
 clock.resume(1000000)
 check(clock.elapsed_ms(2250000)==1250,"clock measures monotonic elapsed time")
 clock.pause(2250000)
 check(clock.elapsed_ms(9000000)==1250,"paused time is excluded")
 clock.resume(9000000);clock.resume(9100000)
 check(clock.stop(9750000)==2000,"resume preserves accumulated time without resetting")
 clock.resume(11000000)
 check(clock.elapsed_ms(13000000)==2000,"finished time stays frozen")
 clock.reset();check(clock.elapsed_ms(15000000)==0 and not clock.running,"retry resets the clock")
 check(Clock.format_time(62345)=="01:02.34","time formats minutes seconds and hundredths")
 # Seed normal progress to prove that the timed attempt never consumes or resets it.
 data.record_answer(data.activities[0].id,"BA",true,false,"buttons")
 var normal=data.profile().stages.duplicate(true);var attempts=data.profile().attempts.duplicate(true);var done=data.profile().completed_stages.duplicate()
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 var speed_button=main.menu_buttons.filter(func(b):return b.text=="Speed Run")
 check(speed_button.size()==1,"main menu has a Speed Run button")
 speed_button[0].pressed.emit();await frames(2)
 check(main.screen=="stages" and main.speedrun_selected,"button opens timed stage selection")
 var family=main.menu_buttons.filter(func(b):return b.text.begins_with("Família B\n"))[0]
 family.pressed.emit();await frames(15)
 check(data.speedrun_active and data.round_progress().completed.is_empty() and main.world.return_x==96,"speed run starts fresh from the beginning")
 check(main.run_clock.running and main.summary.text.begins_with("Tempo"),"timer starts with gameplay and appears in HUD")
 check(data.profile().stages==normal,"starting speed run leaves normal stage untouched")
 var first=data.activities[0]
 main.on_answer(0,first.options[1])
 check(data.round_progress().completed.is_empty(),"wrong response is never counted as a discovery")
 main.start_game();await frames(3)
 main.show_pause();check(not main.run_clock.running,"pause stops the run clock")
 var paused=main.run_clock.elapsed_ms();await frames(10)
 check(main.run_clock.elapsed_ms()==paused,"pause does not add time")
 main.resume_game();check(main.run_clock.running,"continuing resumes the clock")
 main.show_sensor_lost();check(not main.run_clock.running,"sensor disconnect pauses clock")
 main.mode="buttons";main.resume_game();check(main.run_clock.running,"continuing without sensor resumes same run")
 var before_fall=main.run_clock.elapsed_ms()
 main.world.player.position=Vector2(1000,260);await frames(4)
 check(main.run_clock.elapsed_ms()>=before_fall and main.world.player.position.x<120,"fall keeps elapsed time and returns to safe point")
 # Finish without any directional input: only jumps over choices and the gap.
 check(await finish_auto_run(),"timed route completes with jumps and no directional input")
 for a in data.activities:check(a.id in data.round_progress().completed,"automatic route collects "+a.target)
 check(main.screen=="finish" and main.run_clock.finished,"portal stops clock and opens results")
 check(not main.run_result.is_empty() and main.run_result.new_best,"first complete run sets personal record")
 check(data.profile().stages==normal and data.profile().attempts==attempts and data.profile().completed_stages==done,"timed run never modifies normal answers history or completion")
 var record=data.speedrun_record("silabas_b").duplicate()
 main.show_finish();check(data.speedrun_record("silabas_b").runs==record.runs,"result cannot be recorded twice")
 # Explicit record rules use a completed fixture, independent of wall-clock test speed.
 data.begin_speedrun();data.round_progress().completed=data.activities.map(func(a):return a.id);data.complete_stage()
 data.profile().terrain_run_records.silabas_b={"best_ms":10000,"last_ms":10000,"runs":1}
 var slower=data.save_speedrun_result(12000)
 check(not slower.new_best and slower.best_ms==10000,"slower finish keeps the best time")
 data.begin_speedrun();data.round_progress().completed=data.activities.map(func(a):return a.id);data.complete_stage()
 var faster=data.save_speedrun_result(9000)
 check(faster.new_best and faster.best_ms==9000,"faster finish updates best time")
 data.begin_speedrun()
 check(data.save_speedrun_result(1000).is_empty(),"incomplete runs cannot create records")
 main.start_game();await frames(3);main.show_pause()
 var restart=main.menu_buttons.filter(func(b):return b.text=="Reiniciar corrida")[0]
 restart.pressed.emit();await frames(3)
 check(data.round_progress().completed.is_empty() and not main.run_clock.finished,"restart opens another fresh timed attempt")
 data.choose_stage("silabas_c");main.start_game();await frames(2)
 main.show_menu()
 check(data.profile().stage_id=="silabas_b","leaving speed mode restores the original adventure stage")
 check(not data.speedrun_active and not main.speedrun_selected,"return to adventure exits speed mode")
 check(data.round_progress().completed==normal.silabas_b.completed,"normal adventure resumes its saved discoveries")
 data.save_progress();data.state.profiles.convidado=data.fresh_profile();data.load_progress()
 check(data.speedrun_record("silabas_b").best_ms==9000,"personal record survives save and reload")
 check(data.speedrun_record("silabas_c").is_empty(),"records are separate for each stage")
 data.state.profiles.luna=data.fresh_profile();data.select_profile("luna")
 check(data.speedrun_record("silabas_b").is_empty(),"records are separate for each player profile")
 var out=FileAccess.open("res://../evidence/speedrun-tests.json",FileAccess.WRITE)
 out.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));out.close()
 print("SPEEDRUN: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)

func finish_auto_run() -> bool:
 Input.action_release("move_left");Input.action_release("move_right")
 for frame in range(16000):
  if main.screen=="finish":
   Input.action_release("jump");return true
  if main.screen!="playing":
   Input.action_release("jump");return false
  var player=main.world.player
  var jump_now=false
  if player.is_on_floor():
   for zone in main.world.environment.zones:
    if zone.kind in ["lava","log"] and player.position.x>=zone.x-25 and player.position.x<zone.x:jump_now=true
   if player.position.x>=940 and player.position.x<974:jump_now=true
   else:
    for a in data.activities:
     if a.id in data.round_progress().completed or a.id in main.world.skipped:continue
     var target_x=float(a.x)+a.options.find(a.target)*80
     if player.position.x>=target_x-24 and player.position.x<target_x+5:jump_now=true
     break
  if jump_now:Input.action_press("jump")
  else:Input.action_release("jump")
  await frames(1)
 Input.action_release("jump");return false
