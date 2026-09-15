extends "res://tests/speedrun.gd"

func snap(name):
 if DisplayServer.get_name()=="headless":return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v08-"+name+".png"))

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/uninterrupted-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 var normal=data.profile().stages.duplicate(true)
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 main.speedrun_selected=true;main.start_game();await frames(3)
 # No answer jumps: only cross terrain obstacles and the gap, with continuous forward motion and no prompt.
 var previous_x=main.world.player.position.x
 var uninterrupted=true
 for frame in range(3000):
  if main.screen=="finish":break
  if main.screen!="playing" or main.world.player.position.x<previous_x:uninterrupted=false;break
  previous_x=main.world.player.position.x
  var p=main.world.player
  var terrain_jump=p.position.x>=940 and p.position.x<974
  for zone in main.world.environment.zones:
   if zone.kind in ["lava","log"] and p.position.x>=zone.x-25 and p.position.x<zone.x:terrain_jump=true
  if p.is_on_floor() and terrain_jump:Input.action_press("jump")
  else:Input.action_release("jump")
  await frames(1)
 Input.action_release("jump")
 check(uninterrupted and main.screen=="finish","passing every choice reaches portal without rewind or retry prompt")
 check(data.speedrun_attempts.is_empty() and data.round_progress().completed.is_empty(),"skips create neither errors nor correct answers")
 check(data.lives_remaining()==3 and main.world.skipped.size()==5,"skipping all five choices preserves hearts")
 check(main.run_result.is_empty() and data.speedrun_record("silabas_b").is_empty(),"exploration finish does not create an all-discoveries record")
 await snap("chegada-livre")
 main.start_game();await frames(3)
 main.on_answer(0,"BA");main.on_answer(1,"BE")
 var completed=data.round_progress().completed.duplicate()
 main.world.player.position=Vector2(1600,150);await frames(3)
 main.world.player.has_power=true;main.world.player.power_seconds=4.0
 data.round_progress().power_available=true
 var checkpoint=data.round_progress().checkpoint
 var elapsed=main.run_clock.elapsed_ms()
 var session=data.round_progress().session
 var x=main.world.player.position.x
 main.on_answer(3,"BU")
 check(main.screen=="playing" and main.world.active and not main.menu.visible,"wrong answer never opens an overlay or pauses play")
 check(main.world.player.position.x==x and main.run_clock.running,"wrong answer does not rewind or stop the clock")
 check(main.feedback.text.contains("Ops!") and main.feedback_timer>0 and not main.success_banner.visible,"wrong answer gives brief feedback without a retry dialog or false celebration")
 check(data.lives_remaining()==2 and data.speedrun_attempts.size()==3,"wrong answer is recorded once and changes only the small heart counter")
 check(data.activities[3].id in main.world.skipped,"wrong running choice is passed automatically")
 await frames(5)
 check(main.world.player.position.x>x,"automatic running continues after a wrong answer without input")
 check(data.round_progress().completed==completed and data.round_progress().checkpoint==checkpoint and data.round_progress().session==session,"silent continuation preserves discoveries checkpoint and session")
 check(main.world.player.has_power and main.world.player.power_seconds>3,"silent continuation preserves available and active powers")
 await snap("corrida-sem-interrupcao")
 check(await finish_auto_run(),"mixed skipped and correct route remains playable through portal")
 check(data.round_progress().completed.size()==3 and main.run_result.is_empty(),"mixed route counts only actual discoveries and preserves record rules")
 check(data.profile().stages==normal,"gentle running flow leaves normal adventure unchanged")
 await snap("chegada-com-descobertas")
 # Exhaust hearts through three different wrong activities; keep an earlier discovery.
 main.start_game();await frames(3);main.on_answer(0,"BA")
 completed=data.round_progress().completed.duplicate()
 for index in [1,2,3]:
  var a=data.activities[index]
  main.on_answer(index,str(a.options[0] if a.options[0]!=a.target else a.options[1]))
  check(main.screen=="playing" and main.world.active and main.run_clock.running and not main.menu.visible,"wrong answer "+str(index)+" keeps running without a prompt")
 check(data.lives_remaining()==3 and data.round_progress().completed==completed,"third wrong answer silently renews hearts without losing discoveries")
 check(main.feedback.text.contains("Ops!") and data.speedrun_attempts.size()==4,"repeated errors give brief feedback without duplicate history")
 await frames(120)
 check(main.feedback.text.is_empty(),"brief error feedback clears automatically")
 # Manual adventure and a previously saved zero-heart round also stay uninterrupted.
 main.show_menu();main.start_game();await frames(3);main.on_answer(0,"BA")
 main.world.player.has_power=true;data.round_progress().power_available=true
 data.round_progress().checkpoint=data.current_stage().checkpoint
 for i in range(3):main.on_answer(1,"BA")
 check(main.screen=="playing" and not main.menu.visible and main.feedback.text.is_empty(),"manual adventure has no error banner or retry screen")
 check(data.lives_remaining()==3 and data.round_progress().completed.size()==1 and main.world.player.has_power,"manual hearts renew while preserving discoveries and power")
 data.round_progress().lives=0;data.save_progress();main.show_menu();main.start_game();await frames(3)
 check(main.screen=="playing" and data.lives_remaining()==3 and data.round_progress().completed.size()==1,"old exhausted save resumes directly with discoveries preserved")
 check(main.world.return_x==float(data.current_stage().checkpoint) and main.world.player.has_power,"old exhausted save retains checkpoint and available power")
 main.on_answer(1,"BE")
 check(main.success_banner.visible and data.round_progress().completed.size()==2,"correct answers still celebrate and add a discovery")
 await snap("acerto-continua-comemorando")
 var f=FileAccess.open("res://../evidence/uninterrupted-flow-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));f.close()
 print("GENTLE FLOW: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
