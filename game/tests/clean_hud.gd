extends "res://tests/acceptance.gd"

func snap(caption):
 if DisplayServer.get_name()=="headless":return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v11-"+caption+".png"))

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/clean-hud-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 main.speedrun_selected=true;main.start_game();await frames(5)
 main.world.set_active(false);main.on_activity(0)
 check(main.hud.get_children().filter(func(n):return n is Panel).is_empty(),"no top panel obscures the scenery")
 check(main.feedback.text.is_empty(),"no startup controls banner")
 check(main.instruction.text.contains("BA"),"learning target remains visible")
 var controls=main.power_buttons+[main.jump_button,main.pause_button,main.sound_button]
 for b in controls:
  check(b.text.is_empty() and not b.tooltip_text.is_empty(),"icon has a descriptive tooltip without persistent text: "+b.glyph)
  check(b.get_theme_stylebox("normal") is StyleBoxEmpty,"transparent button: "+b.glyph)
 for power in main.Powers.CATALOG:
  data.equip_power(0,power.id);main.update_hud()
  check(main.power_buttons[0].glyph==power.id and main.HudIcon.PATTERNS.has(power.id),"distinct icon: "+power.id)
 data.equip_power(0,"speed");data.equip_power(1,"double_jump");main.update_hud()
 for extent in [Vector2i(960,540),Vector2i(640,360),Vector2i(390,844),Vector2i(1920,1080)]:
  root.size=extent;await frames(5)
  for b in controls:
   var r=b.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,b.size)
   check(Rect2(Vector2.ZERO,Vector2(extent)).encloses(r),"icon remains inside window "+str(extent)+": "+b.glyph)
  await snap("controles-"+str(extent.x)+"x"+str(extent.y))
 root.size=Vector2i(960,540);await frames(4)
 main.world.player.active=true;main.power_buttons[0].pressed.emit();main.update_hud()
 check(main.world.player.effect_active("speed") and main.power_buttons[0].active,"power icon activates equipped power")
 check(main.power_buttons[0].charge<1,"cooldown visible after activation")
 main.jump_button.pressed.emit();check(main.world.player.sensor_jump,"jump icon queues jump")
 main.pause_button.pressed.emit();check(main.screen=="pause" and not main.world.active,"pause icon pauses play")
 main.resume_game();main.world.set_active(false)
 main.on_answer(0,"BA");check(main.success_banner.visible,"positive reinforcement retained")
 check(main.success_banner.get_theme_stylebox("panel") is StyleBoxEmpty,"celebration has no opaque panel")
 await snap("comemoracao")
 var f=FileAccess.open("res://../evidence/clean-hud-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));f.close()
 print("CLEAN HUD: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
