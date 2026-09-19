extends "res://tests/acceptance.gd"

func fresh(running=false, sensor_jump=false):
 main.speedrun_selected=running
 data.end_speedrun();data.reset_round();main.start_game();await frames(15)
 main.world.player.configure_sensor_jump(sensor_jump)
 main.world.player.auto_run=running
 # Open ground isolates fire contact from raised platforms and activity gates.
 main.world.environment.zones=[{"kind":"lava","x":1800.0,"width":28.0}]
 for i in range(data.activities.size()):main.on_answer(i,str(data.activities[i].target))
 await process_frame

func run():
 data=root.get_node("Data");data.save_path="res://../evidence/lava-jump-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("alfabeto_01")
 data.state.keys={};data.configure_input();data.state.voice=false
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 for running in [false,true]:
  for sensor_jump in [false,true]:
   for boosted in [false,true]:
    for direction in ([1] if running else [1,-1]):
     await fresh(running,sensor_jump)
     var p=main.world.player
     var lava=main.world.environment.zones.filter(func(z):return z.kind=="lava")[0]
     var label="auto=%s sensor=%s speed=%s direction=%s" % [running,sensor_jump,boosted,direction]
     p.position=Vector2(lava.x-5 if direction==1 else lava.x+lava.width+5,150)
     p.velocity=Vector2.ZERO
     var prior_attempts=(data.speedrun_attempts if running else data.profile().attempts).size()
     if boosted:p.power_seconds=5
     if not running:Input.action_press("move_right" if direction==1 else "move_left")
     if sensor_jump:p.sensor_jump=true
     else:Input.action_press("jump")
     await frames(2);Input.action_release("jump")
     check(not p.is_on_floor() and p.position.y<150 and p.velocity.y<0,label+": jump at the edge takes off before fire contact")
     var burned=p.burn_seconds>0 or data.lives_remaining()!=3
     for i in range(80):
      await frames(1)
      burned=burned or p.burn_seconds>0 or data.lives_remaining()!=3
      if p.is_on_floor():break
     Input.action_release("move_right");Input.action_release("move_left")
     check(not burned and p.is_on_floor(),label+": jumping across fire never burns feet or loses hearts")
     check(p.position.x>=lava.x+lava.width-4 if direction==1 else p.position.x<=lava.x+4,label+": lands safely at the far edge")
     var attempts=data.speedrun_attempts if running else data.profile().attempts
     check(not attempts.slice(prior_attempts).any(func(a):return a.kind=="lava_contact"),label+": safe jump records no fire contact")
 # Distinguish descending above the surface from actually landing in the fire.
 await fresh()
 var w=main.world;var p=w.player
 var lava=w.environment.zones.filter(func(z):return z.kind=="lava")[0]
 p.position=Vector2(lava.x+lava.width/2,100);await frames(3)
 p.position.y=147;p.velocity=Vector2(0,5);await frames(2)
 check(not p.is_on_floor() and p.burn_seconds==0 and data.lives_remaining()==3,"low airborne feet do not count as standing in fire")
 await frames(20)
 check(p.burn_seconds>0 and data.lives_remaining()==2,"landing inside the fire still counts as contact")
 # Walking into the obstacle still triggers its normal contact response.
 await fresh();w=main.world;p=w.player
 p.position=Vector2(lava.x-10,150);Input.action_press("move_right");await frames(15);Input.action_release("move_right")
 check(p.burn_seconds>0 and data.lives_remaining()==2 and p.position.x>lava.x+lava.width,"walking into fire still moves the player to the safe bank")
 var report=FileAccess.open("res://../evidence/lava-jump-tests.json",FileAccess.WRITE)
 report.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"physical_sensor":false},"  "));report.close()
 print("LAVA JUMP: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
