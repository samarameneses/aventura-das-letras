extends Button

# Native pixel shapes share the game's palette; hit areas remain larger than the artwork.
const PATTERNS={
 "speed":["......###...",".....###....","....###.....","...###......","..########..",".....####...",".....###....","....###.....","...###......","..##........"],
 "double_jump":[".....##.....","....####....","...######...","..###..###..",".....##.....",".....##.....","............",".....##.....","....####....","...######...","..###..###..",".....##....."],
 "wings":["##........##","###......###","####....####","#####..#####","############",".##########.","..########..","...######...","....####...."],
 "magnet":[".###....###.",".###....###.",".###....###.",".###....###.",".###....###.",".###....###.",".####..####.","..########..","...######..."],
 "bubble":["....####....","..##....##..",".#..##....#.",".#.#......#.","#..#.......#","#..........#","#..........#",".#........#.",".#........#.","..##....##..","....####...."],
 "bridge":["....####....","..########..",".###....###.","###..##..###","##..####..##","##.##..##.##","##.##..##.##","##.##..##.##"],
 "slow":["....#####...","...#######..","..#########.","..#########.","..#########.","############",".###########","..##....##..","..##....##.."],
 "light":[".....##.....",".....##.....","....####....","....####....","############",".##########.","...######...","....####....","...######...","...##..##...","..##....##.."],
 "jump":[".....##.....","....####....","...######...","..########..",".###.##.###.",".....##.....",".....##.....",".....##.....",".....##.....","............","..########..","..########.."],
 "pause":["..###..###..","..###..###..","..###..###..","..###..###..","..###..###..","..###..###..","..###..###..","..###..###.."],
 "sound":[".....#...#..","....##....#.","...###.#...#","######..#..#","######..#..#","######..#..#","...###.#...#","....##....#.",".....#...#.."]
}
var glyph="jump"
var accent=Color("ffbf49")
var charge=1.0
var active=false

func _ready():
 text="";focus_mode=Control.FOCUS_NONE;mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
 for state_name in ["normal","hover","pressed","disabled","focus"]:
  add_theme_stylebox_override(state_name,StyleBoxEmpty.new())
 mouse_entered.connect(queue_redraw);mouse_exited.connect(queue_redraw)
 button_down.connect(queue_redraw);button_up.connect(queue_redraw)
 resized.connect(queue_redraw)

func set_power(id: String, color: Color, readiness: float, is_active: bool, caption: String):
 tooltip_text=caption
 if glyph==id and accent==color and is_equal_approx(charge,readiness) and active==is_active:return
 glyph=id;accent=color;charge=clampf(readiness,0,1);active=is_active;queue_redraw()

func _draw():
 var pattern=PATTERNS.get(glyph,PATTERNS.light)
 var pixel=4.0 if glyph=="jump" else 3.0
 var origin=(size-Vector2(12,pattern.size())*pixel)/2
 if is_pressed():origin.y+=2
 var tint=accent.lightened(0.22) if is_hovered() or active else accent
 if charge<1 and not active:tint=tint.lerp(Color("718178"),0.65)
 for y in range(pattern.size()):
  for x in range(pattern[y].length()):
   if pattern[y][x]!="#":continue
   var r=Rect2(origin+Vector2(x,y)*pixel,Vector2.ONE*pixel)
   draw_rect(Rect2(r.position+Vector2(0,3)-Vector2.ONE*2,r.size+Vector2.ONE*4),Color("233d38"))
 for y in range(pattern.size()):
  for x in range(pattern[y].length()):
   if pattern[y][x]=="#":draw_rect(Rect2(origin+Vector2(x,y)*pixel,Vector2.ONE*pixel),tint)
 if glyph in ["speed","double_jump","wings","magnet","bubble","bridge","slow","light"]:
  for i in range(8):
   var r=Rect2(Vector2(size.x/2-23+i*6,size.y-9),Vector2(4,3))
   draw_rect(r.grow(1),Color("233d38"))
   draw_rect(r,accent if float(i)/8.0<charge else Color("61756a"))
