extends SceneTree
var failures=[]
func _initialize():run.call_deferred()
func run():
 var data=root.get_node("Data")
 if ProjectSettings.get_setting("application/config/version")!="0.12.0":failures.append("incorrect release version")
 data.save_path=OS.get_executable_path().get_base_dir().path_join("../../../../../evidence/pack-progress.json").simplify_path()
 data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 if data.stages.size()!=68:failures.append("expected 68 stages in release pack")
 data.choose_stage("silabas_b")
 if data.activities.map(func(a):return a.target)!=["BA","BE","BI","BO","BU"]:failures.append("B family missing from pack")
 data.choose_stage("palavras_04")
 if data.activities.map(func(a):return a.target)!=["CÉU","REI","PAI","MÃE","TREM"]:failures.append("word phase missing from pack")
 var words=[]
 for stage in data.stages:
  for a in stage.activities:
   if a.skill=="disyllable_word":words.append(a.target)
 if words.size()!=100:failures.append("100 disyllables missing from pack")
 data.choose_stage("dissilabas_20")
 if data.activities.map(func(a):return a.target)!=["PULAR","ANDAR","BRINCAR","CANTAR","DORMIR"]:failures.append("final disyllable phase missing")
 for stage in data.stages:
  if load("res://art/"+str(stage.scenery.template)+".png")==null:failures.append("missing background: "+stage.id)
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 await process_frame
 for c in range(4):
  data.profile().character=c;main.start_game()
  for i in range(10):await physics_frame
  for action in ["idle","walk","run","jump","fall","land","celebrate"]:
   var frames=main.world.player.sprite.sprite_frames
   for frame in range(frames.get_frame_count(action)):
    if frames.get_frame_texture(action,frame).atlas==null:failures.append(str(c)+action)
 main.show_menu();await process_frame
 if main.menu.get_script()!=main.TitleMenu or main.menu.actors.size()!=4:failures.append("new animated title menu missing")
 var buttons=main.menu_buttons.filter(func(b):return b.text=="Speed Run")
 if buttons.size()!=1:failures.append("speed run button missing from pack")
 else:
  buttons[0].pressed.emit();main.start_game()
  var start_x=main.world.player.position.x
  for i in range(20):await physics_frame
  if not data.speedrun_active or not main.run_clock.running:failures.append("speed run clock did not start in pack")
  if not main.world.player.auto_run or main.world.player.position.x<=start_x+15:failures.append("automatic running missing from pack")
  if data.lives_remaining()!=3 or main.lives_label.text.count("♥")!=3:failures.append("three hearts missing from pack")
  main.world.player.position=Vector2(float(data.activities[0].x)+150,150)
  for i in range(5):await physics_frame
  if main.screen!="playing" or main.world.player.position.x<=float(data.activities[0].x)+150 or data.lives_remaining()!=3:failures.append("missed choice interrupted running")
  var x=main.world.player.position.x
  var a=data.activities[1]
  main.on_answer(1,str(a.options[0] if a.options[0]!=a.target else a.options[1]))
  if main.screen!="playing" or not main.world.active or not main.run_clock.running or main.world.player.position.x!=x:failures.append("wrong answer interrupted play")
  if not a.id in main.world.skipped or not main.feedback.text.is_empty():failures.append("silent continuation failed")
  if main.menu.visible:failures.append("wrong answer opened an overlay")
 if main.power_buttons[0].get_script()!=main.HudIcon or not main.power_buttons[0].text.is_empty():failures.append("icon controls missing from pack")
 if not main.pause_button.get_theme_stylebox("normal") is StyleBoxEmpty:failures.append("opaque HUD buttons in pack")
 if main.Powers.CATALOG.size()!=8 or main.power_buttons.size()!=2:failures.append("eight selectable powers missing")
 data.equip_power(0,"bubble")
 if not main.world.player.activate_slot(0) or not main.world.player.effect_active("bubble"):failures.append("equipped power failed to activate")
 data.state.continuous=true
 main.show_finish()
 for i in range(5):await physics_frame
 if main.screen!="playing" or main.menu.visible or main.session_sections!=1:failures.append("continuous section transition failed")
 if not main.world.player.effect_active("bubble") or not main.run_clock.running:failures.append("continuous transition lost power or clock")
 if main.world.environment.zones.filter(func(z):return z.kind=="lava").is_empty():failures.append("lava missing in exported pack")
 var lava=main.world.environment.zones.filter(func(z):return z.kind=="lava")[0]
 main.world.player.effects.clear();main.world.player.position=Vector2(lava.x+8,150)
 var hearts=data.lives_remaining();main.world.update_environment(0.016)
 if data.lives_remaining()!=hearts-1 or main.world.player.burn_seconds<=0:failures.append("lava damage or fire missing in exported pack")
 if not data.save_progress():failures.append("pack save failed")
 var f=FileAccess.open(data.save_path.get_base_dir()+"/pack-verification-v012.json",FileAccess.WRITE)
 if f:f.store_string(JSON.stringify({"passed":failures.is_empty(),"failures":failures,"characters":4,"stages":data.stages.size(),"source_photos_bundled":false}));f.close()
 main.queue_free();await process_frame
 print("PACK VERIFICATION: ",failures)
 quit(0 if failures.is_empty() else 1)
