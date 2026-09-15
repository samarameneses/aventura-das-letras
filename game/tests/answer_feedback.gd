extends "res://tests/acceptance.gd"

func run():
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
 data=root.get_node("Data");data.save_path="res://../evidence/answer-feedback-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_z")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 for running in [false,true]:
  main.speedrun_selected=running;main.start_game();await frames(3)
  main.on_answer(0,"ZA");main.on_answer(1,"ZE")
  var completed=data.round_progress().completed.duplicate()
  main.world.player.position.x=1200
  var original_world=main.world
  var position=main.world.player.position
  var wrong=str(data.activities[2].options.filter(func(o):return o!="ZI")[0])
  for i in range(3):
   main.on_answer(2,wrong)
   check(main.world==original_world and main.world.player.position==position and main.screen=="playing","wrong answer keeps position and current world")
   check(data.round_progress().completed==completed,"wrong answer preserves discoveries")
   check(main.answer_effects.error_plays==i+1 and main.answer_effects.sound.playing,"wrong answer plays its sound")
   check(main.feedback.text.contains("Ops!") and main.answer_effects.error_seconds>0,"wrong answer shows short visual feedback")
  check(data.lives_remaining()==3,"third error renews hearts without restart")
  main.on_answer(2,"ZI")
  check(main.answer_effects.particles.size()==340 and main.answer_effects.success_bursts==3,"correct answer launches burst and confetti rain")
  check(main.answer_effects.error_seconds==0 and main.success_banner.visible,"correct answer clears error feedback and celebrates")
  main.on_answer(2,"ZI")
  check(main.answer_effects.success_bursts==3,"duplicate answer cannot trigger another burst")
  if not running and DisplayServer.get_name()!="headless":
   await frames(35);await process_frame;await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/answer-confetti.png"))
  main.show_pause();var count=main.answer_effects.particles.size();await frames(10)
  check(main.answer_effects.particles.size()==count,"confetti pauses with the game")
  main.resume_game();await frames(260)
  check(main.answer_effects.particles.is_empty(),"confetti cleans up after animation")
 main.speedrun_selected=false;main.start_game();await frames(3)
 data.round_progress().lives=0;data.save_progress()
 var discoveries=data.round_progress().completed.duplicate()
 main.start_game();await frames(3)
 check(data.lives_remaining()==3 and data.round_progress().completed==discoveries,"old exhausted save keeps its answers")
 print("ANSWER FEEDBACK: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
