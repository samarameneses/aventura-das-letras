extends Node

const CHARACTERS = [
 {"id":"joao_miguel","name":"João Miguel","color":Color("98bb62")},
 {"id":"luna","name":"Luna","color":Color("e899b6")},
 {"id":"lucas_engenheiro","name":"Lucas o Engenheiro","color":Color("c8a17c")},
 {"id":"samara","name":"Samara","color":Color("86bbc2")}
]
const Powers=preload("res://scripts/powers.gd")
const DEFAULT_KEYS = {"move_left":KEY_A,"move_right":KEY_D,"jump":KEY_SPACE,"power":KEY_E,"power_two":KEY_Q,"pause":KEY_ESCAPE,"repeat_instruction":KEY_R,"help":KEY_H}
const MAX_LIVES=3
var state: Dictionary = {"version":2,"selected_profile":"joao","profiles":{},"keys":{},"voice":true,"effects":true,"voice_volume":85}
var save_path="user://progress.json"
var activities: Array=[]
var stages: Array=[]
var stage_index: Dictionary={}
var positive_feedback: Array=[]
var last_save_error=""
var migration_source=""
var speedrun_active=false
var speedrun_round: Dictionary={}
var speedrun_attempts: Array=[]
var speedrun_owner=""
var speedrun_stage=""
var speedrun_committed=false

func _ready():
 if OS.get_cmdline_user_args().has("--test") or OS.get_cmdline_user_args().has("--sensor-latency-lab"):
  save_path="res://../evidence/test-progress.json"
 var curriculum=read_json("res://content/curriculum.json")
 stages=curriculum.stages;positive_feedback=curriculum.positive_feedback
 for entry in stages:stage_index[entry.id]=entry
 load_progress();configure_input()

func load_progress():
 for path in [save_path,save_path+".bak"]:
  if not FileAccess.file_exists(path):continue
  var decoded=read_json(path)
  if valid_state(decoded):
   if decoded.version==1:
    migration_source=path;decoded=migrate_v1(decoded)
   state.merge(decoded,true)
   break
 for id in ["joao","luna","convidado"]:
  if not state.profiles.has(id):state.profiles[id]=fresh_profile()
 activities=current_stage().activities

func read_json(path: String):
 var parser=JSON.new()
 if parser.parse(FileAccess.get_file_as_string(path))!=OK:return null
 return parser.data

func numeric(value) -> bool:
 return (value is int or value is float) and is_finite(float(value))

func valid_state(value) -> bool:
 if not value is Dictionary or not numeric(value.get("version")):return false
 # JSON decodes numbers as floats; Array.has() does not coerce them to integers.
 if value.version!=int(value.version) or int(value.version) not in [1,2]:return false
 if not value.get("profiles") is Dictionary or not value.get("keys",{}) is Dictionary:return false
 if value.has("continuous") and not value.continuous is bool:return false
 if value.get("selected_profile","joao") not in ["joao","luna","convidado"]:return false
 for action in value.keys:
  if action not in DEFAULT_KEYS or not numeric(value.keys[action]):return false
 for id in value.profiles:
  var p=value.profiles[id]
  if not p is Dictionary or not p.get("attempts") is Array:return false
  if not numeric(p.get("character")) or p.character!=int(p.character) or int(p.character)<0 or int(p.character)>3:return false
  if p.has("powers") and not Powers.valid_loadout(p.powers):return false
  if value.version==1:
   if not valid_round(p,"jardim_inicio"):return false
  else:
   if p.get("stage_id") not in stage_index or not p.get("stages") is Dictionary:return false
   if not p.get("completed_stages") is Array:return false
   for sid in p.completed_stages:
    if sid not in stage_index:return false
   for sid in p.stages:
    if sid not in stage_index or not valid_round(p.stages[sid],sid):return false
   for records_key in ["speedrun_records","autorun_records","power_run_records","terrain_run_records"]:
    if not p.get(records_key,{}) is Dictionary:return false
    for sid in p.get(records_key,{}):
     var record=p[records_key][sid]
     if sid not in stage_index or not record is Dictionary:return false
     for key in ["best_ms","last_ms","runs"]:
      if not numeric(record.get(key)) or record[key]<=0 or int(record[key])!=record[key]:return false
 return true

func valid_round(p, sid: String) -> bool:
 if not p is Dictionary or not p.get("completed") is Array:return false
 if p.has("lives") and (not numeric(p.lives) or p.lives!=int(p.lives) or p.lives<0 or p.lives>MAX_LIVES):return false
 if not numeric(p.get("checkpoint")):return false
 if float(p.checkpoint) not in [96.0,float(stage_index[sid].checkpoint)]:return false
 var allowed=stage_index[sid].activities.map(func(a):return a.id)
 var seen=[]
 for item in p.completed:
  if item not in allowed or item in seen:return false
  seen.append(item)
 for field in ["finished","power_collected"]:
  if not p.get(field) is bool:return false
 return true

func fresh_round() -> Dictionary:
 return {"checkpoint":96.0,"completed":[],"finished":false,"help_count":0,"power_collected":false,"power_available":false,"session":0,"lives":MAX_LIVES}

func lives_remaining() -> int:
 return int(round_progress().get("lives",MAX_LIVES))

func continuous_play() -> bool:
 return bool(state.get("continuous",true))

func equipped_powers() -> Array:
 return profile().get("powers",["speed","double_jump"]).duplicate()

func equip_power(slot: int, id: String) -> bool:
 if slot not in [0,1] or Powers.get_power(id).is_empty():return false
 var equipped=equipped_powers()
 var other=1-slot
 if equipped[other]==id:equipped[other]=equipped[slot]
 equipped[slot]=id;profile().powers=equipped
 return save_progress()

func fresh_profile() -> Dictionary:
 return {"character":0,"attempts":[],"stage_id":"alfabeto_01","stages":{},"completed_stages":[]}

func migrate_v1(value: Dictionary) -> Dictionary:
 var result=value.duplicate(true);result.version=2
 for id in result.profiles:
  var old=result.profiles[id];var p=fresh_profile()
  p.character=old.character;p.attempts=old.attempts.duplicate(true)
  var saved=fresh_round()
  for key in saved:
   if old.has(key):saved[key]=old[key]
  p.stages.jardim_inicio=saved
  if saved.finished:p.completed_stages.append("jardim_inicio")
  # Keep an unfinished old journey available exactly where it was.
  if not saved.finished and (not saved.completed.is_empty() or saved.checkpoint>96):p.stage_id="jardim_inicio"
  result.profiles[id]=p
 return result

func profile() -> Dictionary:return state.profiles[state.selected_profile]
func current_stage() -> Dictionary:return stage_index[profile().stage_id]
func round_progress() -> Dictionary:
 if speedrun_active:return speedrun_round
 var p=profile()
 if not p.stages.has(p.stage_id):p.stages[p.stage_id]=fresh_round()
 return p.stages[p.stage_id]

func select_profile(id: String):
 if id not in ["joao","luna","convidado"]:return
 state.selected_profile=id;activities=current_stage().activities;save_progress()

func choose_stage(id: String) -> bool:
 if id not in stage_index:return false
 profile().stage_id=id;activities=current_stage().activities
 round_progress();save_progress();return true

func next_stage_id() -> String:
 var sid=profile().stage_id
 if sid=="jardim_inicio":return stages[0].id
 var index=stages.find(stage_index[sid])+1
 if index>=stages.size() or stages[index].id=="jardim_inicio":return ""
 return stages[index].id

func complete_stage():
 round_progress().finished=true
 if speedrun_active:return
 if profile().stage_id not in profile().completed_stages:profile().completed_stages.append(profile().stage_id)
 save_progress()

func reset_round():
 if speedrun_active:
  begin_speedrun();return
 var session=int(round_progress().session)+1
 profile().stages[profile().stage_id]=fresh_round();round_progress().session=session
 save_progress()

func record_answer(id: String, choice: String, correct: bool, helped: bool, mode: String) -> bool:
 var p=profile();var progress=round_progress()
 var matches=activities.filter(func(a):return a.id==id)
 if matches.is_empty() or id in progress.completed or progress.finished or lives_remaining()<=0:return false
 # The content is authoritative, including for callers other than the UI.
 var activity=matches[0]
 if choice not in activity.options or correct!=(choice==activity.target):return false
 var attempt={"activity":id,"stage_id":p.stage_id,"choice":choice,"correct":correct,"helped":helped,"input_mode":mode,"kind":"answer","session":progress.session,"at":Time.get_unix_time_from_system()}
 if speedrun_active:speedrun_attempts.append(attempt)
 else:p.attempts.append(attempt)
 if correct:progress.completed.append(id)
 else:progress.lives=lives_remaining()-1
 if speedrun_active:return true
 if p.attempts.size()>1000:p.attempts.pop_front()
 save_progress();return true

func record_motor(kind: String):
 if speedrun_active:
  speedrun_attempts.append({"kind":kind});return
 var p=profile()
 p.attempts.append({"kind":kind,"stage_id":p.stage_id,"session":round_progress().session,"at":Time.get_unix_time_from_system()})
 if p.attempts.size()>1000:p.attempts.pop_front()
 save_progress()

func begin_speedrun():
 speedrun_active=true;speedrun_round=fresh_round();speedrun_attempts=[]
 speedrun_owner=state.selected_profile;speedrun_stage=profile().stage_id;speedrun_committed=false

func end_speedrun():
 speedrun_active=false;speedrun_round={};speedrun_attempts=[];speedrun_committed=false

func speedrun_record(sid: String) -> Dictionary:
 return profile().get("terrain_run_records",{}).get(sid,{})

func save_speedrun_result(milliseconds: int) -> Dictionary:
 if not speedrun_active or speedrun_committed or milliseconds<=0:return {}
 if speedrun_owner!=state.selected_profile or speedrun_stage!=profile().stage_id:return {}
 if not speedrun_round.finished or speedrun_round.completed.size()!=activities.size() or lives_remaining()<=0:return {}
 var old=speedrun_record(speedrun_stage)
 var improved=old.is_empty() or milliseconds<int(old.best_ms)
 var record={"best_ms":milliseconds if improved else int(old.best_ms),"last_ms":milliseconds,"runs":int(old.get("runs",0))+1,"last_character":int(profile().character)}
 if not profile().has("terrain_run_records"):profile().terrain_run_records={}
 profile().terrain_run_records[speedrun_stage]=record;speedrun_committed=true
 save_progress()
 return {"new_best":improved,"best_ms":record.best_ms,"elapsed_ms":milliseconds}

func save_progress() -> bool:
 var temp=save_path+".tmp"
 var file=FileAccess.open(temp,FileAccess.WRITE)
 if file==null:last_save_error="Não foi possível salvar neste momento.";return false
 file.store_string(JSON.stringify(state));file.flush();file.close()
 var base=ProjectSettings.globalize_path(save_path)
 if not migration_source.is_empty():
  var archive=base+".v1.bak"
  if not FileAccess.file_exists(archive):
   if DirAccess.copy_absolute(ProjectSettings.globalize_path(migration_source),archive)!=OK:
    last_save_error="Não foi possível preservar o progresso anterior.";return false
  migration_source=""
 if FileAccess.file_exists(save_path) and valid_state(read_json(save_path)):DirAccess.copy_absolute(base,base+".bak")
 var err=DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),base)
 last_save_error="" if err==OK else "Não foi possível salvar neste momento."
 return err==OK

func configure_input():
 # Preserve old custom bindings if Q was already used before the second power existed.
 if not state.keys.has("power_two"):
  var used=[]
  for action in DEFAULT_KEYS:
   if action!="power_two":used.append(int(state.keys.get(action,DEFAULT_KEYS[action])))
  for candidate in [KEY_Q,KEY_F,KEY_G,KEY_T,KEY_V,KEY_C]:
   if candidate not in used:
    if candidate!=KEY_Q:state.keys.power_two=candidate
    break
 for action in DEFAULT_KEYS:
  if not InputMap.has_action(action):InputMap.add_action(action,0.2)
  InputMap.action_erase_events(action)
  var key=InputEventKey.new()
  key.physical_keycode=int(state.keys.get(action,DEFAULT_KEYS[action]))
  InputMap.action_add_event(action,key)
 # Standard arrow keys always remain available for accessibility.
 for pair in [["move_left",KEY_LEFT],["move_right",KEY_RIGHT]]:
  var key=InputEventKey.new();key.physical_keycode=pair[1];InputMap.action_add_event(pair[0],key)
 var buttons={"jump":JOY_BUTTON_A,"power":JOY_BUTTON_X,"power_two":JOY_BUTTON_B,"pause":JOY_BUTTON_START,"repeat_instruction":JOY_BUTTON_Y,"help":JOY_BUTTON_RIGHT_SHOULDER,"move_left":JOY_BUTTON_DPAD_LEFT,"move_right":JOY_BUTTON_DPAD_RIGHT}
 for action in buttons:
  var event=InputEventJoypadButton.new();event.button_index=buttons[action];InputMap.action_add_event(action,event)
 for pair in [["move_left",-1.0],["move_right",1.0]]:
  var axis=InputEventJoypadMotion.new();axis.axis=JOY_AXIS_LEFT_X;axis.axis_value=pair[1];InputMap.action_add_event(pair[0],axis)

func remap(action: String, code: int) -> bool:
 if action not in DEFAULT_KEYS or code<=0:return false
 if code in [KEY_LEFT,KEY_RIGHT] and action not in ["move_left","move_right"]:return false
 if code in [KEY_TAB,KEY_ENTER,KEY_ESCAPE] and action!="pause":return false
 for other in DEFAULT_KEYS:
  if other!=action and int(state.keys.get(other,DEFAULT_KEYS[other]))==code:return false
 state.keys[action]=code
 configure_input()
 return save_progress()

func key_label(action: String) -> String:
 var code=int(state.keys.get(action,DEFAULT_KEYS[action]))
 return "Espaço" if code==KEY_SPACE else "Esc" if code==KEY_ESCAPE else OS.get_keycode_string(code)
