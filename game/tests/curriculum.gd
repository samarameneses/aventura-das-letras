extends "res://tests/acceptance.gd"

func run():
 data=root.get_node("Data")
 data.save_path="res://../evidence/curriculum-progress.json"
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 data.state.keys={};data.configure_input()
 var alphabet="";var syllable_count=0;var all_ids=[];var words=[];var disyllables={}
 for stage in data.stages:
  for a in stage.activities:
   if stage.group=="alfabeto":alphabet+=a.target
   if a.skill=="syllable":syllable_count+=1
   if a.skill=="monosyllable_word":words.append(a.target)
   if a.skill=="disyllable_word":disyllables[a.target]=a.syllables
   all_ids.append(a.id)
 check(alphabet=="ABCDEFGHIJKLMNOPQRSTUVWXYZ","all 26 alphabet letters appear in sequence")
 check(syllable_count==169,"169 syllable combinations present")
 check(all_ids.size()==332 and data.stages.size()==68,"332 activities across 68 stages")
 check(disyllables.size()==100 and data.stages.filter(func(s):return s.group=="dissilabas").size()==20,"100 unique disyllables across 20 stages")
 check(disyllables.keys().all(func(w):return disyllables[w].size()==2 and "".join(disyllables[w])==w),"two non-destructive syllable parts for every disyllable")
 check(disyllables.JARRA==["JAR","RA"] and disyllables.MEIA==["MEI","A"] and disyllables.ARROZ==["AR","ROZ"] and disyllables.BRINCAR==["BRIN","CAR"],"reviewed digraph and vowel divisions preserved")
 check(words==["SOL","MAR","LUZ","SOM","COR","PÉ","MÃO","PÃO","MEL","SAL","BOI","CÃO","RÃ","LÃ","FLOR","CÉU","REI","PAI","MÃE","TREM","CHÁ","PÓ","NÓ","PÁ","GIZ","PAZ","VOZ","GOL","BEM","SIM"],"30 curated monosyllables preserve spelling and accents")
 var unique={}
 for id in all_ids:unique[id]=true
 check(unique.size()==all_ids.size(),"activity IDs unique across stages")
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(3)
 var backgrounds={};var previous_template=""
 # Navigate every stage through actual movement, collisions and jumping.
 for stage in data.stages:
  data.choose_stage(stage.id);data.reset_round()
  main.mode="buttons";main.start_game();await frames(20)
  var bg=main.world.background
  var signature=str(bg.texture.resource_path)+str(bg.region_rect)+str(bg.flip_h)+str(bg.modulate)
  check(not backgrounds.has(signature) and Rect2(Vector2.ZERO,bg.texture.get_size()).encloses(bg.region_rect),stage.id+": distinct background crop within image bounds")
  backgrounds[signature]=true
  check(stage.scenery.template!=previous_template,stage.id+": scenery template changes on advance")
  previous_template=stage.scenery.template
  var collected=true;var fitted=true
  for i in range(data.activities.size()):
   var a=data.activities[i]
   for token in main.world.tokens[i]:
    fitted=fitted and token.label.get_minimum_size().x<=token.label.size.x
    if a.skill=="monosyllable_word":fitted=fitted and token.label.get_minimum_size().x<=46
    if a.skill=="disyllable_word":fitted=fitted and token.label.get_minimum_size().x<=64
   if not await move_to(float(a.x)+a.options.find(a.target)*80):collected=false;break
   await frames(15);await tap("jump");await frames(65)
   if a.id not in data.round_progress().completed:collected=false;break
  check(collected,stage.id+": all choices collected with physical jumps")
  check(fitted,stage.id+": labels fit the token bounds")
  if collected:
   await move_to(main.world.level_length-100);await frames(2)
  check(main.screen=="finish" and data.round_progress().finished,stage.id+": portal completes the stage")
  main.show_menu();await frames(2)
 # Stage and profile isolation, replay, persistence and phase advance.
 data.choose_stage("silabas_b");data.reset_round();main.start_game();await frames(4)
 var a=data.activities[0]
 main.on_activity(0);main.on_answer(0,a.options[1])
 check(data.round_progress().completed.is_empty() and main.success_timer==0,"wrong answer does not celebrate or complete")
 main.helped=true;main.on_answer(0,a.target)
 var praise=main.last_praise
 check(main.success_timer>0 and main.success_banner.visible and main.world.player.success_pending,"correct answer activates banner and character celebration")
 main.on_answer(0,a.target)
 check(main.last_praise==praise and data.round_progress().completed.size()==1,"duplicate collection gives no second celebration")
 check(data.profile().attempts[-1].helped,"hint remains marked in learning record")
 var heard=[]
 for i in range(24):
  var phrase=main.next_praise()
  if not heard.is_empty():check(phrase!=heard[-1],"praise does not repeat immediately "+str(i))
  heard.append(phrase)
 check(data.positive_feedback.all(func(p):return p in heard),"all eight encouragement phrases are used")
 data.choose_stage("silabas_c");data.reset_round()
 check(data.round_progress().completed.is_empty(),"new family starts independently")
 data.choose_stage("silabas_b")
 check(data.round_progress().completed.size()==1,"returning to family preserves its progress")
 data.save_progress()
 data.state.profiles.convidado=data.fresh_profile()
 data.load_progress()
 check(data.profile().stage_id=="silabas_b" and data.round_progress().completed.size()==1,"family and progress persist across reload")
 data.state.profiles.luna=data.fresh_profile();data.select_profile("luna")
 check(data.round_progress().completed.is_empty(),"another player has independent progress")
 data.select_profile("convidado")
 check(data.round_progress().completed.size()==1,"original profile retains its progress")
 data.choose_stage("alfabeto_05")
 check(data.next_stage_id()=="silabas_b","alphabet progression leads to BA BE BI BO BU")
 data.choose_stage("nomes_kwy")
 check(data.next_stage_id()=="palavras_01","existing curriculum continues to word stages")
 data.choose_stage("palavras_06")
 check(data.next_stage_id()=="dissilabas_01","monosyllables advance to disyllables")
 main.show_stages("menu")
 await frames(2)
 check(main.stage_category=="palavras","word stage restores the Palavras tab")
 var word_buttons=main.menu_buttons.filter(func(b):return b.text.contains("Palavras ·"))
 check(word_buttons.size()==6,"Palavras tab exposes all six word phases")
 data.choose_stage("dissilabas_20")
 check(data.next_stage_id().is_empty(),"last disyllable stage ends the learning sequence")
 main.show_stages("menu")
 await frames(2)
 check(main.stage_category=="dissilabas" and main.menu_buttons.filter(func(b):return b.text.contains("Dissílabas ·")).size()==20,"Dissílabas tab exposes all 20 new phases")
 data.choose_stage("silabas_b");data.reset_round()
 check(data.round_progress().completed.is_empty() and not data.round_progress().finished,"replay resets only the chosen stage")
 # Real migration and on-disk preservation of a v1 profile.
 var legacy_round={"character":3,"checkpoint":1110,"completed":["letra_a","letra_m"],"attempts":[{"kind":"virtual_fall"}],"finished":false,"help_count":1,"power_collected":true,"power_available":true,"session":2}
 var legacy={"version":1,"selected_profile":"joao","profiles":{"joao":legacy_round},"keys":{},"voice":false}
 check(data.valid_state(JSON.parse_string(JSON.stringify(legacy))),"serialized v1 format validates before migration")
 data.save_path="res://../evidence/migration-fixture.json"
 var original=JSON.stringify(legacy)
 var file=FileAccess.open(data.save_path,FileAccess.WRITE);file.store_string(original);file.close()
 data.load_progress()
 check(data.state.version==2 and data.profile().character==3,"v1 migrates to v2 preserving character")
 check(data.profile().stage_id=="jardim_inicio" and data.round_progress().checkpoint==1110,"unfinished old stage resumes at its checkpoint")
 check(data.round_progress().completed==["letra_a","letra_m"] and data.round_progress().power_available,"v1 discoveries and unspent power preserved")
 check(data.profile().attempts.size()==1 and not data.state.voice,"v1 attempts and settings preserved")
 check(data.save_progress(),"migrated save writes successfully")
 check(FileAccess.get_file_as_string(data.save_path+".v1.bak")==original,"original v1 save preserved byte-for-byte")
 if data.profile().stages.has("jardim_inicio"):
  var malformed=data.state.duplicate(true);malformed.profiles.joao.stages.jardim_inicio.completed.append("unrelated_id")
  check(not data.valid_state(malformed),"invalid cross-stage completion rejected")
 var out=FileAccess.open("res://../evidence/curriculum-tests.json",FileAccess.WRITE)
 out.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"stages":data.stages.size(),"activities":all_ids.size(),"syllables":syllable_count,"monosyllables":words.size(),"disyllables":disyllables.size(),"unique_backgrounds":backgrounds.size()},"  "));out.close()
 print("CURRICULUM: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
