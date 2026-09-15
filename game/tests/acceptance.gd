extends SceneTree
var failures=[]
var passes=[]
var main
var data
func _initialize():prepare_test.call_deferred()
func prepare_test():
 root.get_node("Data").state.continuous=false
 run()
func check(value: bool, message: String):
 if not value:failures.append(message);push_error(message)
 else:passes.append(message);print("PASS "+message)
func frames(n: int):
 for i in range(n):await physics_frame
func tap(action):
 Input.action_press(action);await frames(1);Input.action_release(action)
func move_to(x: float) -> bool:
 var player=main.world.player
 for i in range(2000):
  if main.screen=="finish":return true
  if absf(player.position.x-x)<2:
   Input.action_release("move_right");Input.action_release("move_left");await frames(10);return true
  Input.action_press("move_right" if player.position.x<x else "move_left")
  Input.action_release("move_left" if player.position.x<x else "move_right")
  if player.is_on_floor() and (absf(player.velocity.x)<3 or (player.position.x>960 and player.position.x<974)):
   Input.action_press("jump")
  else:Input.action_release("jump")
  await frames(1)
 Input.action_release("move_right");Input.action_release("move_left");Input.action_release("jump")
 return false
func packet(s, sequence, event):
 return {"protocol_version":1,"challenge":s.challenge,"session_id":"bench","device_id":"simulated","sequence":sequence,"sent_at_ms":Time.get_unix_time_from_system()*1000,"event":event}
func run():
 data=root.get_node("Data")
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile();data.choose_stage("jardim_inicio");data.state.keys={};data.configure_input()
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 check(not main.sensor.enabled,"default mode has no sensor connection")
 check(not data.remap("jump",KEY_E),"duplicate key rejected")
 check(data.remap("jump",KEY_J),"jump can be remapped")
 data.state.keys={};data.configure_input()
 for action in data.DEFAULT_KEYS:
  var events=InputMap.action_get_events(action)
  check(events.any(func(e):return e is InputEventKey) and events.any(func(e):return e is InputEventJoypadButton),"keyboard and controller mapping: "+action)
 for char_index in range(4):
  data.state.profiles.convidado=data.fresh_profile();data.choose_stage("jardim_inicio");data.profile().character=char_index
  main.mode="buttons";main.start_game();await frames(30)
  var player=main.world.player
  var id=data.CHARACTERS[char_index].id
  for action in ["idle","walk","run","jump","fall","land","celebrate"]:
   check(player.sprite.sprite_frames.get_frame_count(action)>0,id+" animation "+action)
  check(player.get_child(0).shape.size==Vector2(14,29),id+" same physical collision box")
  for i in range(data.activities.size()):
   var a=data.activities[i];var target_x=float(a.x)+a.options.find(a.target)*80
   var reached=await move_to(target_x)
   check(reached,id+" reaches "+a.id)
   if not reached:break
   await frames(20)
   await tap("jump");await frames(60)
   check(a.id in data.round_progress().completed,id+" collects "+a.id+" through physical jump")
  if data.round_progress().completed.size()==4:
   await move_to(2140);await frames(3)
   check(main.screen=="finish" and data.round_progress().finished,id+" finishes whole level")
  main.show_menu();await frames(3)
 # Wrong answers and hints are distinct from falls; completed answers cannot duplicate.
 data.state.profiles.convidado=data.fresh_profile();data.choose_stage("jardim_inicio");main.start_game();await frames(5)
 main.on_activity(0);main.on_answer(0,"M")
 check(data.round_progress().completed.is_empty() and not data.profile().attempts[-1].correct,"wrong answer allows retry")
 main.helped=true;main.on_answer(0,"A");main.on_answer(0,"A")
 check(data.profile().attempts.size()==2 and data.profile().attempts[-1].helped,"assistance recorded and duplicate ignored")
 main.world.player.position=Vector2(1115,150);await frames(3)
 check(data.round_progress().checkpoint==1110,"checkpoint saved")
 var completed=data.round_progress().completed.duplicate()
 main.world.player.position=Vector2(1000,270);await frames(3)
 check(main.world.player.position.x>1100 and data.round_progress().completed==completed,"fall returns to checkpoint preserving answers")
 check(data.profile().attempts[-1].kind=="virtual_fall" and not data.profile().attempts[-1].has("correct"),"motor event is not a reading error")
 main.show_pause();var pos=main.world.player.position;await tap("jump");await frames(10)
 check(main.world.player.position==pos,"pause prevents movement")
 main.resume_game();await frames(3)
 check(main.world.player.velocity.y>=0,"paused jump is not replayed")
 data.round_progress().power_collected=true;data.round_progress().power_available=true;main.start_game();await frames(5)
 check(main.world.player.has_power,"unspent power survives reload")
 await tap("power");await frames(1)
 check(not data.round_progress().power_available and main.world.player.power_seconds>5,"power consumes saved charge")
 # Sensor protocol, plus real local UDP handshake.
 var s=main.sensor;s.activate();s.set_process(false)
 var client=PacketPeerUDP.new();var bind_error=client.bind(0,"127.0.0.1")
 check(bind_error==OK,"local UDP test socket opens")
 client.set_dest_address("127.0.0.1",9250);client.put_packet(JSON.stringify({"event":"hello"}).to_utf8_buffer())
 await frames(3);s._process(0);await frames(3)
 check(client.get_available_packet_count()>0,"UDP handshake receives a response")
 if client.get_available_packet_count()>0:
  var reply=JSON.parse_string(client.get_packet().get_string_from_utf8());check(reply.challenge==s.challenge,"UDP challenge matches current connection")
 var now=Time.get_ticks_msec()
 check(s.accept_packet(packet(s,1,"calibration_start"),now),"sensor calibration starts")
 var ready_packet=packet(s,2,"ready");ready_packet.stable=true
 s.accept_packet(ready_packet,now+3100);check(s.is_ready,"stable calibration enables sensor")
 var jump_packet=packet(s,3,"jump");jump_packet.event_id=1
 check(s.accept_packet(jump_packet,now+3500),"fresh jump accepted")
 check(not s.accept_packet(jump_packet,now+3501),"duplicate jump rejected")
 var old=packet(s,4,"jump");old.event_id=2;old.sent_at_ms-=1000
 check(not s.accept_packet(old,now+4000),"late packet rejected")
 main.mode="sensor";main.screen="playing";s.last_seen=Time.get_ticks_msec()-1300;s._process(0)
 check(main.screen=="sensor_lost" and not main.world.player.active,"sensor loss pauses gameplay")
 main.mode="buttons";s.deactivate();main.resume_game()
 check(main.screen=="playing" and data.round_progress().completed==completed,"continue without sensor preserves progress")
 check(not s.accept_packet(packet(s,10,"jump"),now+5000),"packets ignored after switching to buttons")
 client.close()
 # Recover an intact backup; reject nested malformed profile data.
 data.save_progress();data.save_progress()
 var f=FileAccess.open(data.save_path,FileAccess.WRITE);f.store_string("broken");f.close()
 data.load_progress();check(data.round_progress().completed==completed,"corrupt primary recovers backup")
 var malformed=data.state.duplicate(true);malformed.profiles.convidado.character=9
 check(not data.valid_state(malformed),"invalid saved character rejected")
 data.save_progress()
 var report={"passed":failures.is_empty(),"passes":passes,"failures":failures,"physical_hardware_tested":false,"engine":Engine.get_version_info().string}
 var out=FileAccess.open("res://../evidence/acceptance.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"  "));out.close()
 print("ACCEPTANCE: ",passes.size()," passed, ",failures.size()," failed")
 main.queue_free();await frames(2)
 quit(0 if failures.is_empty() else 1)
