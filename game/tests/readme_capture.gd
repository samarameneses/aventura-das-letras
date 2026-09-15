extends "res://tests/acceptance.gd"

# Render real gameplay states for the README, using an isolated test profile.
# Run with a graphical display and -- --test (never --headless).
func snap(caption: String):
 await process_frame
 await RenderingServer.frame_post_draw
 var path=ProjectSettings.globalize_path("res://../evidence/readme-"+caption+".png")
 var error=root.get_texture().get_image().save_png(path)
 check(error==OK,"saved README capture: "+caption)

func run():
 if not OS.get_cmdline_user_args().has("--test"):
  push_error("Pass -- --test to isolate capture data from player saves.")
  quit(1)
  return
 DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../evidence"))
 if DisplayServer.get_name()=="headless":
  push_error("README captures require a graphical display.")
  quit(1)
  return
 root.mode=Window.MODE_WINDOWED
 root.size=Vector2i(1280,720)
 data=root.get_node("Data")
 data.save_path="res://../evidence/readme-capture-progress.json"
 data.migration_source=""
 data.state.selected_profile="convidado"
 data.state.profiles.convidado=data.fresh_profile()
 data.state.keys={}
 data.configure_input()
 data.state.continuous=false
 data.choose_stage("palavras_04")
 main=load("res://scenes/main.tscn").instantiate()
 root.add_child(main)
 await frames(6)
 main.speedrun_selected=true
 main.start_game()
 await frames(6)
 main.world.player.position=Vector2(335,150)
 await frames(10)
 await snap("corrida-palavras")
 # Use the actual jump/collision/answer flow to collect the first word.
 var player=main.world.player
 player.auto_run=false
 player.position=Vector2(400,150)
 await frames(8)
 await tap("jump")
 var collected=false
 for i in range(80):
  if data.activities[0].id in data.round_progress().completed:
   collected=true
   break
  await frames(1)
 check(collected,"jump collected the correct word")
 if collected:
  check(main.answer_effects.success_bursts>0,"word collection emitted confetti")
  await frames(16)
  await snap("acerto-confetes")
 data.choose_stage("dissilabas_01")
 main.speedrun_selected=true
 main.start_game()
 await frames(6)
 main.world.player.position=Vector2(335,150)
 await frames(10)
 await snap("palavras-dissilabas")
 main.queue_free()
 await frames(2)
 quit(0 if failures.is_empty() else 1)
