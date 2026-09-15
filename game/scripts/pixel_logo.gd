extends Control

const GLYPHS={
 "A":["01110","11011","11011","11111","11011","11011","11011"],
 "V":["11011","11011","11011","11011","11011","01110","00100"],
 "E":["11111","11000","11000","11110","11000","11000","11111"],
 "N":["11001","11101","11101","11011","11011","11011","11001"],
 "T":["11111","11111","00100","00100","00100","00100","00100"],
 "U":["11011","11011","11011","11011","11011","11011","01110"],
 "R":["11110","11011","11011","11110","11100","11010","11011"],
 "D":["11110","11011","11011","11011","11011","11011","11110"],
 "S":["01111","11000","11000","01110","00011","00011","11110"],
 "L":["11000","11000","11000","11000","11000","11000","11111"],
 " ":["00000","00000","00000","00000","00000","00000","00000"]
}

func _ready():
 mouse_filter=Control.MOUSE_FILTER_IGNORE
 resized.connect(queue_redraw)

func _draw():
 var pixel=maxf(2,floorf(minf(size.x/57,size.y/18)))
 var rows=["AVENTURA","DAS LETRAS"]
 for line in range(2):
  var word=rows[line]
  var origin=Vector2((size.x-(word.length()*6-1)*pixel)/2,line*9*pixel+pixel)
  for i in range(word.length()):
   var glyph=GLYPHS[word[i]]
   for y in range(7):
    for x in range(5):
     if glyph[y][x]!="1":continue
     var p=origin+Vector2((i*6+x)*pixel,y*pixel)
     draw_rect(Rect2(p+Vector2(pixel,pixel),Vector2.ONE*pixel),Color("233d38"))
     draw_rect(Rect2(p-Vector2.ONE,Vector2.ONE*(pixel+2)),Color("233d38"))
  for i in range(word.length()):
   var glyph=GLYPHS[word[i]]
   for y in range(7):
    for x in range(5):
     if glyph[y][x]=="1":
      var color=Color("ffd479") if line==0 else Color("fbf4df")
      if y==0:color=color.lightened(0.25)
      draw_rect(Rect2(origin+Vector2((i*6+x)*pixel,y*pixel),Vector2.ONE*pixel),color)
