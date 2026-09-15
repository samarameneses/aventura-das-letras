extends "res://tests/acceptance.gd"

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/sensor-game-jump-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("alfabeto_01")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 main.mode="sensor";main.sensor.set_process(false);main.sensor.is_ready=true;main.speedrun_selected=true
 main.start_game();await frames(4)
 check(main.world.player.jump_time_scale==1.5 and main.world.player.fall_gravity_multiplier==2.0,"real game applies approved sensor physics")
 var first=data.activities[0]
 var target_x=float(first.x)+first.options.find(first.target)*80
 for trial in [{"name":"letter","edge":target_x,"end":target_x+30,"lead":12.0},{"name":"lava","edge":638.0,"end":674.0,"lead":8.0},{"name":"gap","edge":975.0,"end":1025.0,"lead":10.0}]:
  main.start_game();await frames(4)
  var p=main.world.player;p.clear_commands();p.position=Vector2(trial.edge-45,150)
  var fired=false;var failed=false
  for i in range(100):
   if not fired and p.position.x>=trial.edge-trial.lead:
    main.sensor.jump_requested.emit();fired=true
   await frames(1)
   if data.lives_remaining()<3 or p.position.x<trial.edge-50:failed=true;break
   if p.position.x>trial.end and p.is_on_floor():break
  check(fired and not failed and p.position.x>trial.end and p.is_on_floor(),trial.name+": crossed using sensor signal without damage or respawn")
  if trial.name=="letter":check(first.id in data.round_progress().completed,"sensor jump collects correct letter")
 main.show_pause();main.mode="buttons";main.sensor.deactivate();main.resume_game()
 check(main.world.player.jump_time_scale==1.0 and main.world.player.fall_gravity_multiplier==1.0,"continuing without sensor restores manual jump")
 var f=FileAccess.open("res://../evidence/sensor-game-jump.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"physical_sensor":false},"  "));f.close()
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
