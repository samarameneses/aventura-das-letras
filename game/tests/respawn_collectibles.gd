extends "res://tests/speedrun.gd"

func visible_choices(index: int) -> bool:
 return main.world.tokens[index].all(func(token):return token.sprite.visible and token.label.visible)

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/respawn-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 data.state.keys={};data.configure_input();data.state.voice=false
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 for stage in ["alfabeto_01","silabas_b","palavras_01","dissilabas_01","jardim_inicio"]:
  for running in [false,true]:
   data.end_speedrun();data.choose_stage(stage);data.reset_round()
   main.speedrun_selected=running;main.start_game();await frames(3)
   var prefix=stage+(" running: " if running else " manual: ")
   var normal=data.profile().stages.duplicate(true)
   main.on_answer(0,str(data.activities[0].target))
   if running:
    var wrong=data.activities[1].options.filter(func(option):return option!=data.activities[1].target)[0]
    main.on_answer(1,str(wrong))
   else:main.world.skip_choice(1)
   var history=(data.speedrun_attempts if running else data.profile().attempts).duplicate(true)
   main.world.answer_locked=true;main.world.question_cooldown=0.8
   # A magnet may have moved a token before the fall.
   main.world.tokens[0][0].sprite.position=Vector2(1000,200)
   main.world.player.position=Vector2(1000,270);await frames(3)
   check(main.world.player.position.x<120,prefix+"fall returns to the start")
   check(visible_choices(0) and visible_choices(1),prefix+"collected and skipped choices reappear")
   check(data.round_progress().completed.is_empty() and main.world.skipped.is_empty(),prefix+"restored choices can be answered again")
   check(main.world.tokens[0][0].sprite.position==main.world.tokens[0][0].position,prefix+"magnet token returns to its original position")
   check(not main.world.answer_locked and main.world.question_cooldown==0,prefix+"retry clears answer lock and cooldown")
   check(main.active_activity==-1 and not main.helped and not main.success_banner.visible,prefix+"retry clears stale activity feedback")
   var attempts=data.speedrun_attempts if running else data.profile().attempts
   check(attempts.slice(0,history.size())==history and attempts[-1].kind=="virtual_fall",prefix+"fall preserves learning history without a reading error")
   if not running:
    var a=data.activities[0]
    var answer_count=data.profile().attempts.size()
    check(await move_to(float(a.x)+a.options.find(a.target)*80),prefix+"restored choice remains reachable")
    await frames(15);await tap("jump");await frames(65)
    check(a.id in data.round_progress().completed and not visible_choices(0) and data.profile().attempts.size()==answer_count+1,prefix+"physical jump recollects restored content")
    main.on_answer(0,str(a.target))
    check(data.profile().attempts.size()==answer_count+1,prefix+"duplicate pickup within the same attempt is ignored")
   else:
    main.on_answer(0,str(data.activities[0].target))
   main.on_answer(1,str(data.activities[1].target))
   main.world.player.position=Vector2(float(data.current_stage().checkpoint)+5,150);await frames(3)
   main.on_answer(2,str(data.activities[2].target));main.world.skip_choice(3)
   main.world.player.has_power=true;data.round_progress().power_available=true
   var lives=data.lives_remaining();var session=data.round_progress().session
   main.world.player.position=Vector2(1700,270);await frames(3)
   check(main.world.return_x==float(data.current_stage().checkpoint) and main.world.player.position.x>1100,prefix+"later fall returns to checkpoint")
   check(data.round_progress().completed==[data.activities[0].id,data.activities[1].id] and not visible_choices(0) and not visible_choices(1),prefix+"progress before checkpoint remains collected")
   check(visible_choices(2) and visible_choices(3) and main.world.skipped.is_empty(),prefix+"collected and skipped content after checkpoint reappears")
   check(data.lives_remaining()==lives and data.round_progress().session==session and main.world.player.has_power,prefix+"retry preserves hearts session and power")
   check(main.summary.text.ends_with("2 descobertas"),prefix+"discovery counter reflects the restored segment")
   if running:
    check(data.profile().stages==normal,prefix+"retry does not modify adventure progress")
    check(await finish_auto_run(),prefix+"restored choices can be collected through the finish")
    check(data.round_progress().completed.size()==data.activities.size() and not main.run_result.is_empty(),prefix+"complete retry qualifies for a speedrun record")
   else:
    data.load_progress();main.start_game();await frames(3)
    check(data.round_progress().completed.size()==2 and visible_choices(2) and visible_choices(3),prefix+"restored segment survives save and reload")
   main.show_menu()
 var report=FileAccess.open("res://../evidence/respawn-collectibles-tests.json",FileAccess.WRITE)
 report.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));report.close()
 print("RESPAWN COLLECTIBLES: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
