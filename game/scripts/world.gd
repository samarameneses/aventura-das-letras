extends Node2D

signal activity_entered(index: int)
signal answer_collected(index: int, choice: String)
signal checkpoint_reached
signal finished
signal motor_fall
signal lava_touched
signal speed_collected
signal assisted_collection(index: int)
signal light_requested(index: int)
var bridge_shape: CollisionShape2D
var bridge_enabled=false
var light_announced=-1
var magnet_target=Vector2.ZERO
const Terrain=preload("res://scripts/adventure_terrain.gd")
var environment
var lava_immunity=0.0
const Player=preload("res://scripts/player.gd")
var level_length=2240
const GROUND_Y=150
var player
var camera: Camera2D
var camera_lead=55.0
var active=true
var choice=0
var current_activity=-1
var selected=false
var answer_locked=false
var question_cooldown=0.0
var tokens: Array=[]
var platform_data: Array=[]
var checkpoint_x=1110.0
var return_x=96.0
var checkpoint_active=false
var power_taken=false
var power_sprite: Sprite2D
var flag: Sprite2D
var marker: Label
var background: Sprite2D
var scenery: Dictionary
var terrain_tint=Color.WHITE
var terrain_texture: Texture2D=preload("res://art/grass.png")
var walk_gate: StaticBody2D
var skipped: Array=[]

func _ready():
 level_length=int(Data.current_stage().length)
 checkpoint_x=float(Data.current_stage().checkpoint)
 camera_lead=25.0 if Data.current_stage().group=="dissilabas" and not Data.speedrun_active else 55.0
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 scenery=Data.current_stage().scenery
 background=Sprite2D.new();background.texture=load("res://art/"+str(scenery.template)+".png")
 background.centered=false;background.region_enabled=true;background.flip_h=bool(scenery.mirror)
 background.region_filter_clip_enabled=true;background.modulate=Color(scenery.tint)
 terrain_tint=Color(scenery.terrain)
 var tex_size=background.texture.get_size()
 var crop_height=minf(tex_size.y,tex_size.x*180.0/320.0)/float(scenery.zoom)
 var crop_size=Vector2(crop_height*320.0/180.0,crop_height)
 background.region_rect=Rect2(Vector2(floorf((tex_size.x-crop_size.x)*float(scenery.view)),tex_size.y-crop_size.y),crop_size)
 background.scale=Vector2(320.0/crop_size.x,180.0/crop_size.y)
 background.z_index=-20;add_child(background)
 environment=Terrain.new();environment.world=self;environment.zones=Terrain.plan(Data.current_stage())
 var stage_number=Data.stages.find(Data.current_stage())
 environment.night=stage_number%3==2;environment.dusk=stage_number%3==1
 if environment.night:
  background.modulate=background.modulate*Color("536b9c");terrain_tint=terrain_tint*Color("839aba")
 elif environment.dusk:
  background.modulate=background.modulate*Color("edb6a0")
 var cuts=[Vector2(975,1007)]
 for zone in environment.zones:
  if zone.kind=="bridge":cuts.append(Vector2(zone.x,zone.x+zone.width))
 cuts.sort_custom(func(a,b):return a.x<b.x)
 var platforms=[];var ground_start=0.0
 for cut in cuts:
  platforms.append([ground_start,150,cut.x-ground_start,70]);ground_start=cut.y
 platforms.append([ground_start,150,level_length-ground_start,70])
 var ground_count=platforms.size()
 platforms.append([245,126,50,10]);platforms.append([575,123,60,10])
 if level_length>1700:platforms.append([1540,125,64,10])
 if Data.speedrun_active:platforms=platforms.slice(0,ground_count)
 for p in platforms:
  platform_data.append(Rect2(p[0],p[1],p[2],p[3]))
  var body=StaticBody2D.new();body.position=Vector2(p[0]+p[2]/2.0,p[1]+p[3]/2.0);body.collision_layer=1
  var collision=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(p[2],p[3]);collision.shape=shape;body.add_child(collision);add_child(body)
 add_child(environment)
 for zone in environment.zones:
  if zone.kind not in ["bridge","log"]:continue
  var body=StaticBody2D.new();body.position=Vector2(zone.x+zone.width/2,153 if zone.kind=="bridge" else 145)
  var collision=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(zone.width,6 if zone.kind=="bridge" else 10)
  collision.shape=shape;body.add_child(collision);add_child(body)
 # Invisible left boundary keeps the character inside the level.
 var wall=StaticBody2D.new();wall.position=Vector2(-8,0)
 var wall_shape=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=Vector2(16,500);wall_shape.shape=rect;wall.add_child(wall_shape);add_child(wall)
 player=Player.new();player.character_id=Data.CHARACTERS[int(Data.profile().character)].id
 player.auto_run=Data.speedrun_active
 player.position=Vector2(float(Data.round_progress().checkpoint),GROUND_Y-3)
 return_x=float(Data.round_progress().checkpoint);checkpoint_active=return_x>=checkpoint_x
 player.fell.connect(respawn);player.jumped.connect(on_jump);add_child(player)
 var bridge=StaticBody2D.new();bridge.position=Vector2(991,155)
 bridge_shape=CollisionShape2D.new();var bridge_rect=RectangleShape2D.new();bridge_rect.size=Vector2(40,10)
 bridge_shape.shape=bridge_rect;bridge_shape.disabled=true;bridge.add_child(bridge_shape);add_child(bridge)
 player.power_activated.connect(func(id):
  if id=="light":light_announced=-1)
 player.has_power=bool(Data.round_progress().get("power_available",false))
 player.power_used.connect(func():Data.round_progress().power_available=false;Data.save_progress())
 camera=Camera2D.new();camera.position=Vector2(player.position.x+camera_lead,90);camera.limit_left=0;camera.limit_right=level_length;camera.limit_top=0;camera.limit_bottom=180
 camera.position_smoothing_enabled=false;add_child(camera)
 for i in range(Data.activities.size()):
  var a=Data.activities[i]
  var group=[]
  for c in range(2):
   var disyllable=a.skill=="disyllable_word"
   var word=disyllable or a.skill=="monosyllable_word"
   var token_width=128.0 if disyllable else 76.0 if word else 44.0
   var token=Sprite2D.new();token.texture=load("res://art/letter.png");token.position=Vector2(float(a.x)+c*80,94);token.scale=Vector2(token_width,44.0)/token.texture.get_size();add_child(token)
   token.visible=not a.id in Data.round_progress().completed
   var label=Label.new();label.text=str(a.options[c]);label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
   var font_size=12 if disyllable else (12 if label.text.length()>=4 else 14) if word else (23 if label.text.length()==1 else 15 if label.text.length()==2 else 12)
   label.add_theme_font_size_override("font_size",font_size);label.add_theme_color_override("font_color",Color("433428"))
   label.position=token.position-Vector2(token_width/2,22);label.size=Vector2(token_width,44);label.visible=token.visible
   if a.skill=="quantity":
    label.text="★ ★" if a.options[c]=="2" else "★ ★\n★"
    label.add_theme_font_size_override("font_size",10)
   add_child(label);group.append({"sprite":token,"label":label,"position":token.position})
  tokens.append(group)
 power_sprite=object_sprite("speed",Vector2(690,132),30)
 power_taken=bool(Data.round_progress().power_collected);power_sprite.visible=not power_taken
 flag=object_sprite("checkpoint",Vector2(checkpoint_x,125),55)
 object_sprite("finish",Vector2(level_length-80,118),77)
 marker=Label.new();marker.text="▼";marker.add_theme_font_size_override("font_size",14);marker.add_theme_color_override("font_color",Color("ffdb6e"));marker.visible=false;add_child(marker)
 queue_redraw()

func object_sprite(file: String, pos: Vector2, size: float) -> Sprite2D:
 var s=Sprite2D.new();s.texture=load("res://art/"+file+".png");s.position=pos;s.scale=Vector2.ONE*(size/s.texture.get_height());add_child(s);return s

func set_active(value: bool):
 active=value
 player.active=value
 if not value:player.clear_commands()

func _physics_process(delta):
 if not active:return
 if player.position.y>240:
  respawn();return
 update_environment(delta)
 update_power_effects(delta)
 question_cooldown=maxf(0,question_cooldown-delta)
 camera.position.x=clampf(roundf(player.position.x+camera_lead),160,level_length-160)
 background.position.x=camera.position.x-160
 player.decision_zone=false
 for i in range(Data.activities.size()):
  var a=Data.activities[i]
  if a.id in Data.round_progress().completed or a.id in skipped:continue
  if Data.speedrun_active and player.position.x>float(a.x)+140:
   skip_choice(i);continue
  if Data.speedrun_active and player.position.x>float(a.x)-240 and current_activity!=i:
   current_activity=i;choice=0;selected=false;activity_entered.emit(i)
  var center=float(a.x)+40
  if player.position.x>center-150 and player.position.x<center+160:
   player.decision_zone=true
   if current_activity!=i:
    current_activity=i;choice=0;selected=false
    activity_entered.emit(i)
   # Horizontal position selects a candidate; the jump executes that choice.
   if player.is_on_floor():
    var closest=0 if absf(player.position.x-float(a.x))<absf(player.position.x-(float(a.x)+80)) else 1
    choice=closest;selected=true
   marker.visible=selected
   marker.position=Vector2(float(a.x)+choice*80-7,58)
   if selected and not answer_locked and not player.is_on_floor() and question_cooldown<=0 and not player.effect_active("magnet"):
    var token=tokens[i][choice]
    if absf(player.position.x-token.position.x)<25 and absf(player.position.y-20-token.position.y)<25:
     question_cooldown=0.8
     answer_locked=true
     answer_collected.emit(i,str(a.options[choice]))
     if not active:return
   # In manual adventure the gate keeps the current choice reachable.
   if not Data.speedrun_active and player.position.x>center+125:
    player.position.x=center+125;player.velocity.x=minf(player.velocity.x,0)
   break
 if not player.decision_zone:marker.visible=false
 if not power_taken and player.position.distance_to(Vector2(690,145))<28:
  power_taken=true;Data.round_progress().power_collected=true;Data.round_progress().power_available=true;player.has_power=true;power_sprite.hide();Data.save_progress();speed_collected.emit()
 if not checkpoint_active and player.position.x>=checkpoint_x:
  checkpoint_active=true;return_x=checkpoint_x;Data.round_progress().checkpoint=checkpoint_x;Data.save_progress();checkpoint_reached.emit()
 if player.position.x>level_length-120 and (Data.speedrun_active or Data.round_progress().completed.size()>=Data.activities.size()):
  active=false;player.celebrate=not Data.continuous_play();finished.emit()

func update_environment(delta: float):
 lava_immunity=maxf(0,lava_immunity-delta)
 for zone in environment.zones:
  if player.position.x+6<=zone.x or player.position.x-6>=zone.x+zone.width:continue
  if player.position.y<146 or player.position.y>165:continue
  if zone.kind=="water":player.wet_seconds=2.2
  elif zone.kind=="lava" and lava_immunity<=0:
   lava_immunity=2.5;player.burn_seconds=1.2
   # A nearby safe bank preserves the session; auto-run continues on the far side.
   var safe_x=zone.x+zone.width+20 if player.auto_run or player.velocity.x>=0 else zone.x-20
   player.position=Vector2(safe_x,145);player.clear_commands()
   lava_touched.emit()
   return

func mark_completed(index: int):
 for token in tokens[index]:
  token.sprite.hide();token.label.hide()
 marker.hide();current_activity=-1

func skip_choice(index: int):
 # Passing a choice is exploration, never a reading error or a correct answer.
 var id=Data.activities[index].id
 if not id in skipped:skipped.append(id)
 mark_completed(index)

func respawn():
 player.position=Vector2(return_x,GROUND_Y-3);player.clear_commands()
 camera.position.x=clampf(return_x+camera_lead,160,level_length-160)
 current_activity=-1;selected=false;marker.hide()
 motor_fall.emit()

func on_jump():
 answer_locked=false

func update_power_effects(delta: float):
 var wants_bridge=player.effect_active("bridge")
 # Keep the last strip solid until the character has stepped off safely.
 if bridge_enabled and player.position.x>964 and player.position.x<1018 and player.position.y<165:wants_bridge=true
 if wants_bridge!=bridge_enabled:
  bridge_enabled=wants_bridge;bridge_shape.set_deferred("disabled",not bridge_enabled)
 magnet_target=Vector2.ZERO
 if not player.effect_active("light"):light_announced=-1
 for i in range(Data.activities.size()):
  var a=Data.activities[i]
  if a.id in Data.round_progress().completed or a.id in skipped:continue
  var correct_index=a.options.find(a.target)
  for c in range(2):
   var token=tokens[i][c]
   var illuminated=player.effect_active("light") and c==correct_index and absf(player.position.x-token.position.x)<240
   token.sprite.modulate=Color("fff08a") if illuminated else Color.WHITE
   var desired: Vector2=token.position
   if player.effect_active("magnet") and c==correct_index and absf(player.position.x-token.position.x)<125:
    desired=player.position+Vector2(0,-20)
    magnet_target=token.sprite.position
    token.sprite.position=token.sprite.position.move_toward(desired,250*delta)
    if token.sprite.position.distance_to(desired)<12:
     assisted_collection.emit(i)
     break
   else:token.sprite.position=token.sprite.position.move_toward(desired,250*delta)
   token.label.position=token.sprite.position-Vector2(token.label.size.x/2,22)
   if illuminated and light_announced!=i:
    light_announced=i;light_requested.emit(i)
 queue_redraw()

func _draw():
 if bridge_enabled:
  for i in range(5):draw_rect(Rect2(972,149+i*2,38,2),Color(["ff94a5","ffd16b","a7e28b","88d9f5","c9a5ee"][i]))
 if magnet_target!=Vector2.ZERO:draw_line(player.position+Vector2(0,-20),magnet_target,Color("ff91af"),1)
 var tile=terrain_texture
 if tile==null:return
 for r in platform_data:
  for x in range(int(r.position.x),int(r.end.x),32):
   var width=minf(32,r.end.x-x)
   draw_texture_rect_region(tile,Rect2(x,r.position.y,width,minf(32,r.size.y)),Rect2(0,0,tile.get_width()*width/32.0,tile.get_height()*minf(32,r.size.y)/32.0),terrain_tint)
   if r.size.y>32:
    draw_texture_rect_region(tile,Rect2(x,r.position.y+32,width,r.size.y-32),Rect2(0,tile.get_height()*0.4,tile.get_width()*width/32.0,tile.get_height()*0.6),terrain_tint)
