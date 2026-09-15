extends "res://tests/acceptance.gd"

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/family-restart-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 data.choose_stage("silabas_b");data.record_answer(data.activities[0].id,"BA",true,false,"buttons")
 var previous=data.round_progress().duplicate(true)
 data.choose_stage("silabas_z")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 for running in [false,true]:
  main.speedrun_selected=running;main.start_game();await frames(3)
  main.on_answer(0,"ZA");main.on_answer(1,"ZE")
  data.round_progress().checkpoint=data.current_stage().checkpoint
  main.world.player.position.x=1200
  var wrong=str(data.activities[2].options.filter(func(o):return o!="ZI")[0])
  main.on_answer(2,wrong);main.on_answer(2,wrong)
  check(data.lives_remaining()==1 and data.round_progress().completed.size()==2,"first two mistakes preserve ZA and ZE")
  main.on_answer(2,wrong);await frames(4)
  check(main.screen=="playing" and data.lives_remaining()==3,"last life restores three hearts without interrupting play")
  check(data.profile().stage_id=="silabas_z" and data.round_progress().completed.size()==2,"losing at ZI preserves ZA and ZE")
  check(main.world.player.position.x>=1200 and data.round_progress().checkpoint==data.current_stage().checkpoint,"third error preserves position and checkpoint")
  for i in range(5):main.on_answer(i,str(data.activities[i].target))
  check(data.round_progress().completed.size()==5,"ZA ZE ZI ZO ZU can all be collected again")
  check(data.profile().stages.silabas_b==previous,"previous family progress is preserved")
 main.speedrun_selected=false;data.end_speedrun();data.reset_round();main.start_game();await frames(3)
 main.on_answer(0,"ZA");data.round_progress().lives=1
 main.world.lava_touched.emit();await frames(4)
 check(data.lives_remaining()==3 and data.round_progress().completed.size()==1,"lava losing final heart preserves family discoveries")
 main.on_answer(0,"ZA");data.round_progress().lives=0;data.save_progress()
 main.show_menu();main.start_game();await frames(4)
 check(data.lives_remaining()==3 and data.round_progress().completed.size()==1,"saved exhausted attempt preserves discoveries")
 data.load_progress()
 check(data.round_progress().completed.size()==1 and data.lives_remaining()==3,"restored hearts and discoveries persist to saved progress")
 print("FAMILY RESTART: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
