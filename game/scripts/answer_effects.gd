extends Control

var host
var particles: Array=[]
var error_seconds=0.0
var error_origin=Vector2.ZERO
var success_bursts=0
var error_plays=0
var sound: AudioStreamPlayer
var error_sound=preload("res://audio/answer_error.wav")
var success_sound=preload("res://audio/answer_success.wav")
var rng=RandomNumberGenerator.new()
const COLORS=[Color("ff668c"),Color("ffe363"),Color("69dcff"),Color("b594ff"),Color("8ce578"),Color("ffad57")]

func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 clip_contents=true
 rng.randomize()
 sound=AudioStreamPlayer.new();sound.volume_db=-6;add_child(sound)

func wrong(origin: Vector2):
 error_plays+=1
 particles.clear()
 error_origin=origin;error_seconds=0.65
 sound.stream=error_sound;sound.play()
 queue_redraw()

func celebrate(origin: Vector2):
 success_bursts+=1;error_seconds=0
 sound.stream=success_sound;sound.play()
 # A burst from the character, followed by a shower across the entire play area.
 for i in range(190):
  var angle=rng.randf_range(-PI,0)
  add_piece(origin,Vector2(cos(angle),sin(angle))*rng.randf_range(130,420),0)
 for i in range(150):
  add_piece(Vector2(rng.randf_range(0,960),-18),Vector2(rng.randf_range(-55,55),rng.randf_range(35,100)),rng.randf_range(0.12,1.4))
 if particles.size()>680:particles=particles.slice(particles.size()-680)
 queue_redraw()

func add_piece(origin: Vector2, velocity: Vector2, delay: float):
 particles.append({"p":origin,"v":velocity,"delay":delay,"age":0.0,"life":rng.randf_range(2.4,3.8),"angle":rng.randf_range(0,TAU),"spin":rng.randf_range(-8,8),"size":rng.randf_range(5,10),"color":COLORS[rng.randi_range(0,COLORS.size()-1)],"shape":rng.randi_range(0,2)})

func _process(delta):
 if not is_visible_in_tree() or host.screen!="playing":return
 if particles.is_empty() and error_seconds<=0:return
 error_seconds=maxf(0,error_seconds-delta)
 for p in particles:
  if p.delay>0:p.delay-=delta;continue
  p.age+=delta;p.v.y+=155*delta;p.v.x*=exp(-0.35*delta)
  p.p+=p.v*delta;p.angle+=p.spin*delta
 particles=particles.filter(func(p):return p.age<p.life and p.p.y<580)
 queue_redraw()

func _draw():
 for p in particles:
  if p.delay>0:continue
  var color: Color=p.color;color.a=minf(1,(p.life-p.age)/0.7)
  draw_set_transform(p.p,p.angle,Vector2(maxf(0.2,absf(cos(p.age*8))),1))
  var s: float=p.size
  if p.shape==0:draw_rect(Rect2(-s/2,-s/4,s,s/2),color)
  elif p.shape==1:draw_circle(Vector2.ZERO,s/3,color)
  else:
   draw_rect(Rect2(-s/2,-s/6,s,s/3),color)
   draw_rect(Rect2(-s/6,-s/2,s/3,s),color)
 draw_set_transform(Vector2.ZERO)
 if error_seconds>0:
  var color=Color("ffac75");color.a=minf(1,error_seconds/0.2)
  var radius=19+(0.65-error_seconds)*18
  draw_arc(error_origin,radius,0,TAU,28,color,3,true)
  draw_line(error_origin-Vector2(7,7),error_origin+Vector2(7,7),color,4,true)
  draw_line(error_origin+Vector2(-7,7),error_origin+Vector2(7,-7),color,4,true)
