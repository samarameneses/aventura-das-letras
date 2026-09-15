extends "res://tests/speedrun.gd"

func snap(name):
 if DisplayServer.get_name()=="headless":return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v09-"+name+".png"))

func fresh(stage="silabas_b"):
 data.choose_stage(stage);main.speedrun_selected=true;main.start_game();await frames(3)

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/powers-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("silabas_b")
 data.state.erase("continuous")
 check(data.continuous_play(),"continuous adventure is enabled by default for old and new saves")
 data.state.continuous=false
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 check(main.Powers.CATALOG.size()==8,"all eight powers are available")
 main.show_powers("menu")
 check(main.screen=="powers" and main.menu_buttons.size()==12,"power selection exposes eight powers two slots duration and return")
 for power in main.Powers.CATALOG:
  check(data.equip_power(0,power.id) and data.equipped_powers()[0]==power.id,"can equip "+power.name)
 check(not data.equip_power(2,"speed") and not data.equip_power(0,"invalid"),"invalid slot and unknown power are rejected")
 data.equip_power(0,"speed");data.equip_power(1,"double_jump");data.equip_power(0,"double_jump")
 check(data.equipped_powers()==["double_jump","speed"],"choosing an equipped power swaps slots without duplicates")
 data.equip_power(0,"speed");data.equip_power(1,"double_jump");data.save_progress();data.load_progress()
 check(data.equipped_powers()==["speed","double_jump"],"selected powers survive save reload")
 main.show_powers("menu");await frames(3);await snap("selecao-poderes")
 main.show_menu();await fresh()
 var player=main.world.player
 player.position=Vector2(150,150);await frames(3)
 await tap("power");await frames(8)
 check(player.effect_active("speed") and player.velocity.x>150,"first power key accelerates character with no pickup required")
 check(not player.activate_slot(0),"active or recharging power cannot be spammed")
 main.show_pause();var cooldown=float(player.cooldowns.speed);await frames(10)
 check(float(player.cooldowns.speed)==cooldown and not player.activate_slot(0),"pause freezes effects recharge and activation")
 main.resume_game()
 player.cooldowns.speed=0;player.effects.speed=0;player.power_seconds=0
 main.power_buttons[0].pressed.emit()
 check(player.effect_active("speed"),"on-screen power button activates equipped power")
 await fresh();player=main.world.player
 await tap("power_two");await frames(8)
 var y=player.position.y
 check(player.effect_active("double_jump") and y<140,"second power key starts first jump")
 await tap("jump");await frames(4)
 check(player.position.y<y and player.velocity.y<0 and not player.extra_jump,"double jump provides exactly one extra airborne jump")
 await fresh();player=main.world.player
 data.equip_power(0,"wings");player.activate_slot(0);await frames(45)
 check(player.effect_active("wings") and player.velocity.y<=35 and not player.is_on_floor(),"wings actually glide with capped descent")
 await snap("asas-magicas")
 await fresh();player=main.world.player
 data.equip_power(0,"bubble");player.position=Vector2(930,150);player.activate_slot(0);await frames(65)
 check(player.position.x>1030 and player.position.y<135 and data.speedrun_attempts.is_empty(),"bubble floats over gap without falling or a reading error")
 await snap("bolha-flutuante")
 await fresh();player=main.world.player
 data.equip_power(0,"bridge");player.position=Vector2(930,150);player.activate_slot(0);await frames(50)
 check(main.world.bridge_enabled and not main.world.bridge_shape.disabled and player.position.x>1015 and player.position.y<155,"rainbow bridge physically supports a running crossing")
 await fresh();player=main.world.player
 data.equip_power(0,"bridge");player.position=Vector2(990,150);player.activate_slot(0);await frames(2)
 player.effects.bridge=0;main.world.update_power_effects(0)
 check(main.world.bridge_enabled,"expiring bridge stays solid while character is on it")
 player.position.x=1050;main.world.update_power_effects(0);await frames(2)
 check(not main.world.bridge_enabled and main.world.bridge_shape.disabled,"bridge disappears after character safely steps off")
 await fresh();player=main.world.player
 data.equip_power(0,"slow");player.activate_slot(0);await frames(10)
 check(player.velocity.x>45 and player.velocity.x<60,"turtle time halves running speed while continuing forward")
 player.position=Vector2(940,150);await frames(3);await tap("jump");await frames(60)
 check(player.position.x>1015 and data.speedrun_attempts.is_empty(),"turtle time preserves enough airborne speed to cross the gap")
 await fresh();player=main.world.player
 data.equip_power(0,"magnet");player.position=Vector2(310,150);player.activate_slot(0);await frames(40)
 check(data.activities[0].id in data.round_progress().completed and data.speedrun_attempts[0].helped and data.speedrun_attempts[0].correct,"magnet attracts only requested option and marks assisted discovery")
 check(data.lives_remaining()==3,"magnet never pulls a wrong option or removes a heart")
 await fresh();player=main.world.player
 data.equip_power(0,"light");player.position=Vector2(310,150);player.activate_slot(0);await frames(3)
 check(main.world.tokens[0][0].sprite.modulate!=Color.WHITE and main.world.tokens[0][1].sprite.modulate==Color.WHITE,"light highlights only requested option")
 check(main.helped and main.world.light_announced==0 and data.round_progress().completed.is_empty(),"light offers a pronunciation hint without auto-answering")
 # Recharge works without needing a pickup or restarting the phase.
 player.effects.light=0;player.cooldowns.light=0.04;await frames(5)
 check(player.activate_slot(0),"powers recharge during play and can be used again")
 main.show_pause();main.show_powers("pause");data.equip_power(1,"magnet")
 var pos=player.position;main.menu_buttons[-1].pressed.emit()
 check(main.screen=="playing" and player.position==pos and data.equipped_powers()[1]=="magnet","changing powers from pause resumes same character position")
 # Three complete consecutive sections, using only jumps, without finish overlays.
 data.state.continuous=true
 await fresh("alfabeto_01")
 var normal=data.profile().stages.duplicate(true)
 var prior_stage=data.profile().stage_id
 var transitions=0
 for frame in range(16000):
  if main.screen not in ["playing","transition"]:break
  if data.profile().stage_id!=prior_stage:
   transitions+=1;prior_stage=data.profile().stage_id
   if transitions==3:break
  player=main.world.player
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
 Input.action_release("jump")
 check(transitions==3 and main.screen=="playing" and not main.menu.visible,"three consecutive sections advance automatically without any finish menu")
 check(main.session_sections==3 and main.session_discoveries==15 and main.run_clock.running and not main.run_clock.finished,"continuous run keeps total discoveries and a single running clock")
 check(data.profile().stages==normal,"continuous speed run keeps adventure discoveries separate")
 check(data.profile().stage_id=="alfabeto_04","continuous route advances curriculum in order")
 await snap("aventura-continua")
 # Effects, recharge and hearts cross the boundary instead of being reset.
 player=main.world.player;data.equip_power(0,"bubble");player.activate_slot(0)
 player.cooldowns.speed=9.0;data.round_progress().lives=2
 var elapsed=main.run_clock.elapsed_ms();main.show_finish();await frames(3)
 check(main.world.player.effect_active("bubble") and float(main.world.player.cooldowns.speed)>8 and data.lives_remaining()==2,"active powers recharge and hearts survive section change")
 check(main.run_clock.elapsed_ms()>=elapsed and main.run_clock.running,"section change never resets total time")
 data.choose_stage("dissilabas_20");main.start_game();main.show_finish();await frames(3)
 check(data.profile().stage_id=="alfabeto_01" and main.screen=="playing","continuous route loops after final curriculum stage without interruption")
 main.show_menu();main.speedrun_selected=false;data.choose_stage("silabas_b");main.start_game();await frames(3)
 for i in range(data.activities.size()):main.on_answer(i,str(data.activities[i].target))
 main.show_finish();await frames(3)
 check(data.profile().stage_id=="silabas_c" and "silabas_b" in data.profile().completed_stages,"normal adventure saves completion and advances continuously")
 main.show_pause();main.show_powers("pause")
 main.menu_buttons.filter(func(b):return b.text.begins_with("Duração:"))[0].pressed.emit()
 check(not data.continuous_play(),"family can select one phase at a time in duration control")
 main.menu_buttons[-1].pressed.emit()
 for i in range(data.activities.size()):main.on_answer(i,str(data.activities[i].target))
 main.show_finish()
 check(main.screen=="finish","single-phase option retains a voluntary endpoint")
 var report=FileAccess.open("res://../evidence/powers-continuity-tests.json",FileAccess.WRITE)
 report.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures},"  "));report.close()
 print("POWERS AND CONTINUITY: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
