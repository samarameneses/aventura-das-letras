extends Node2D

var zones: Array=[]
var night=false
var dusk=false
var elapsed=0.0
var world

static func plan(stage: Dictionary) -> Array:
 var result: Array=[]
 # The lead-in river teaches that water is playful. Later features sit after choices.
 result.append({"kind":"water","x":170.0,"width":74.0})
 var kinds=["lava","bridge","log","water","lava"]
 for i in range(stage.activities.size()):
  var start=float(stage.activities[i].x)+238.0
  var kind=kinds[i%kinds.size()]
  var width=28.0 if kind=="lava" else 24.0 if kind=="log" else 82.0
  if start+width>float(stage.length)-135:continue
  # Preserve the original gap and checkpoint approach.
  if start<1020 and start+width>955:continue
  result.append({"kind":kind,"x":start,"width":width})
 return result

func _physics_process(delta):
 if world==null or not world.active:return
 elapsed+=delta;queue_redraw()

func _draw():
 if world==null:return
 var left=world.camera.position.x-160 if is_instance_valid(world.camera) else 0.0
 if night:
  # Sky details follow the camera; the existing scenery is tinted beneath them.
  var moon=["....####....","..####......",".####.......","####........","####........","####........","####........",".####.......","..#####...##","...########.",".....####..."]
  for y in range(moon.size()):
   for x in range(moon[y].length()):
    if moon[y][x]=="#":draw_rect(Rect2(left+251+x,19+y,1,1),Color("fff3c5"))
  for i in range(14):
   var sx=float((i*47+17)%310);var sy=float((i*19+7)%57)
   draw_rect(Rect2(left+sx,sy,1,1),Color("fff4d2") if i%3 else Color("b2d7ee"))
 for z in zones:
  var x=float(z.x);var w=float(z.width)
  if x+w<left-20 or x>left+340:continue
  match z.kind:
   "water","bridge":
    draw_rect(Rect2(x,150,w,30),Color("26709b"))
    draw_rect(Rect2(x,149,w,5),Color("69d4dd"))
    for i in range(int(w/12)):
     var shift=fmod(elapsed*10+i*12,w-7)
     draw_rect(Rect2(x+shift,154+(i%3)*7,7,1),Color("a1ebed"))
    for bank in [x-3,x+w]:draw_rect(Rect2(bank,148,3,6),Color("c3ba83"))
    if z.kind=="bridge":
     draw_rect(Rect2(x-6,150,w+12,6),Color("694738"))
     for plank in range(int(w/7)+2):
      draw_rect(Rect2(x-6+plank*7,148,6,4),Color("c8965f"))
     for post in [x-3,x+w-2]:
      draw_rect(Rect2(post,132,4,26),Color("72513c"))
      draw_rect(Rect2(post,131,4,3),Color("ddb481"))
     draw_line(Vector2(x,137),Vector2(x+w,137),Color("e3c493"),2)
   "lava":
    draw_rect(Rect2(x,150,w,30),Color("a43131"))
    draw_rect(Rect2(x,148,w,7),Color("f46d32"))
    for i in range(int(w/6)):
     var rise=2+int(sin(elapsed*5+i*2)*2)
     draw_rect(Rect2(x+i*6,149-rise,4,3+rise),Color("ffd477"))
     draw_rect(Rect2(x+i*6+1,162+i%3*4,3,2),Color("ed733d"))
    for bank in [x-4,x+w]:draw_rect(Rect2(bank,148,4,5),Color("674b4a"))
   "log":
    draw_rect(Rect2(x,140,w,10),Color("694738"))
    draw_rect(Rect2(x+2,140,w-4,3),Color("c4935e"))
    draw_rect(Rect2(x+w-5,142,4,7),Color("e0bc7d"))
    draw_rect(Rect2(x+4,146,w-12,1),Color("aa734c"))
