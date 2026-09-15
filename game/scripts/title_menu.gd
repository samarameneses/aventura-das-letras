extends Control

const Logo=preload("res://scripts/pixel_logo.gd")
const Actor=preload("res://scripts/player.gd")
var host
var scroll: ScrollContainer
var board: Control
var logo: Control
var tagline: Label
var profile_title: Label
var character_title: Label
var status: Label
var stage_title: Label
var stage_name: Label
var tips: Label
var profile_buttons: Array=[]
var character_buttons: Array=[]
var actors: Array=[]
var actions: Array=[]
var utilities: Array=[]
var decoration: Array=[]
var elapsed=0.0

func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var bg=TextureRect.new();bg.texture=preload("res://art/primavera-pomar.png")
 bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(bg)
 var shade=ColorRect.new();shade.color=Color(0.07,0.18,0.13,0.28);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(shade)
 scroll=ScrollContainer.new();scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus=true;add_child(scroll)
 board=Control.new();board.size_flags_horizontal=Control.SIZE_EXPAND_FILL;scroll.add_child(board)
 logo=Logo.new();board.add_child(logo)
 tagline=make_label("PULE. DESCUBRA. BRINQUE.",15,Color("fbf4df"))
 profile_title=make_label("QUEM VAI BRINCAR?",13,Color("fbf4df"))
 character_title=make_label("ESCOLHA SEU COMPANHEIRO",13,Color("fbf4df"))
 for p in [["joao","João Miguel"],["luna","Luna"],["convidado","Convidado"]]:
  var selected=Data.state.selected_profile==p[0]
  var b=host.button(("● " if selected else "")+p[1],func():Data.select_profile(p[0]);host.show_menu())
  decorate_button(b,Color("fbf4df") if selected else Color("326855"),not selected,selected)
  board.add_child(b);profile_buttons.append(b)
 for i in range(4):
  var c=Data.CHARACTERS[i];var selected=int(Data.profile().character)==i
  var b=host.button(c.name,func():Data.profile().character=i;Data.save_progress();host.show_menu())
  decorate_button(b,Color("ffe1a0") if selected else Color(0.98,0.96,0.86,0.91),false,selected)
  b.alignment=HORIZONTAL_ALIGNMENT_CENTER;board.add_child(b);character_buttons.append(b)
  var actor=Actor.new();actor.character_id=c.id;actor.active=false;b.add_child(actor)
  actor.set_physics_process(false);actors.append(actor)
  b.mouse_entered.connect(func():actor.sprite.play("celebrate"))
  b.mouse_exited.connect(func():actor.sprite.play("idle"))
  b.focus_entered.connect(func():actor.sprite.play("celebrate"))
  b.focus_exited.connect(func():actor.sprite.play("idle"))
 stage_title=make_label("SUA PRÓXIMA DESCOBERTA",13,Color("ffdf93"))
 stage_name=make_label(Data.current_stage().title,20,Color("fbf4df"))
 var has_progress=not Data.round_progress().completed.is_empty() or float(Data.round_progress().checkpoint)>96
 var start_text="Próxima fase" if Data.round_progress().finished and not Data.next_stage_id().is_empty() else "Jogar de novo" if Data.round_progress().finished else "Continuar aventura" if has_progress else "Começar aventura"
 add_action(start_text,func():
  if Data.round_progress().finished:
   if not Data.next_stage_id().is_empty():Data.choose_stage(Data.next_stage_id())
   if Data.round_progress().finished:Data.reset_round()
  host.start_game(),true)
 add_action("Speed Run",func():
  host.adventure_stage_before_speedrun=Data.profile().stage_id;host.speedrun_selected=true;host.show_stages("menu"))
 add_action("Escolher fase",func():host.show_stages("menu"))
 add_action("Poderes e duração",func():host.show_powers("menu"))
 for entry in [["Com sensor",func():host.show_sensor(false)],["Ajustes",func():host.show_settings("menu")],["Sair",func():Data.save_progress();get_tree().quit()]]:
  var b=host.button(entry[0],entry[1]);decorate_button(b,Color("fbf4df"),false,false);board.add_child(b);utilities.append(b)
 status=make_label(("Aventura contínua" if Data.continuous_play() else "Uma fase por vez")+"  ·  8 superpoderes",13,Color("fbf4df"))
 tips=make_label("Setas ou controle para escolher · Enter para brincar",12,Color("fbf4df"))
 resized.connect(arrange);arrange()
 host._focus_control.call_deferred(actions[0])

func make_label(text: String, px: int, color: Color) -> Label:
 var l=host.label(text,px,color);l.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 l.add_theme_color_override("font_shadow_color",Color("233d38"));l.add_theme_constant_override("shadow_offset_y",2)
 board.add_child(l);return l

func decorate_button(b: Button, color: Color, light_text: bool, selected: bool):
 b.custom_minimum_size=Vector2.ZERO;b.clip_text=true
 b.add_theme_font_size_override("font_size",18)
 for state_name in ["normal","hover","pressed"]:
  var fill=color.lightened(0.12) if state_name=="hover" else color.darkened(0.12) if state_name=="pressed" else color
  var style=StyleBoxFlat.new();style.bg_color=fill;style.border_color=Color("ffe4a1") if selected else Color("233d38")
  style.set_border_width_all(3);style.set_corner_radius_all(2)
  style.shadow_color=Color(0.07,0.18,0.13,0.7);style.shadow_size=0;style.shadow_offset=Vector2(0,5)
  style.content_margin_top=7;style.content_margin_bottom=7;style.content_margin_left=6;style.content_margin_right=6
  b.add_theme_stylebox_override(state_name,style)
 var focus=StyleBoxFlat.new();focus.bg_color=Color.TRANSPARENT;focus.border_color=Color("ffcf68");focus.set_border_width_all(4)
 focus.expand_margin_left=3;focus.expand_margin_right=3;focus.expand_margin_top=3;focus.expand_margin_bottom=3
 b.add_theme_stylebox_override("focus",focus)
 for state_name in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
  b.add_theme_color_override(state_name,Color("fbf4df") if light_text else Color("233d38"))

func add_action(text: String, callback: Callable, primary=false):
 var b=host.button(text,callback,primary);decorate_button(b,Color("ffd479") if primary else Color("326855"),not primary,primary)
 board.add_child(b);actions.append(b)

func place(control: Control, rect: Rect2):
 control.position=rect.position;control.size=rect.size

func arrange():
 if not is_instance_valid(board):return
 var wide=size.x>=600 and size.x/maxf(1,size.y)>1.25
 var margin=clampf(size.x*0.03,16,48)
 var width=minf(size.x-margin*2,1240)
 var u=clampf(width/(900 if wide else 430),0.72,1.3)
 # Desktop menus grow with both available width and height, keeping every action visible.
 if wide and size.x>=1100:
  u=clampf(minf((size.x-margin*2)/900.0,(size.y-32)/490.0),0.72,3.0)
  width=900*u
 var left_width=width*0.54 if wide else width
 var right_width=width*0.38 if wide else minf(width,480)
 var left_x=(size.x-width)/2
 var right_x=left_x+width-right_width if wide else (size.x-right_width)/2
 var logo_h=120*u
 var card_h=144*u if wide else 113*u
 var hero_h=logo_h+104*u+card_h+40*u
 var action_h=maxf(46,54*u)
 var right_h=58*u+action_h*4+10*u*3+50*u+46*u
 var content_h=maxf(hero_h,right_h)+40*u if wide else hero_h+right_h+36*u
 board.custom_minimum_size=Vector2(0,maxf(size.y,content_h))
 var top=maxf(16,(size.y-content_h)/2+16)
 place(logo,Rect2(left_x,top,left_width,logo_h))
 place(tagline,Rect2(left_x,top+logo_h,left_width,24*u))
 var y=top+logo_h+34*u
 place(profile_title,Rect2(left_x,y,left_width,20*u));y+=24*u
 var gap=8*u;var pw=(left_width-gap*2)/3
 for i in range(3):
  place(profile_buttons[i],Rect2(left_x+i*(pw+gap),y,pw,37*u))
  profile_buttons[i].add_theme_font_size_override("font_size",maxi(12,int(15*u)))
 y+=48*u
 place(character_title,Rect2(left_x,y,left_width,20*u));y+=25*u
 var cw=(left_width-gap*3)/4
 for i in range(4):
  var b=character_buttons[i]
  b.add_theme_font_size_override("font_size",maxi(11,int(13*u)))
  b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  for state_name in ["normal","hover","pressed"]:
   var style=b.get_theme_stylebox(state_name);style.content_margin_top=card_h-40*u;style.content_margin_bottom=6
  place(b,Rect2(left_x+i*(cw+gap),y,cw,card_h))
  actors[i].scale=Vector2.ONE*(card_h-48*u)/34
  actors[i].position=Vector2(cw/2,card_h-40*u)
 var right_y=top if wide else y+card_h+25*u
 place(stage_title,Rect2(right_x,right_y,right_width,20*u))
 place(stage_name,Rect2(right_x,right_y+22*u,right_width,32*u));stage_name.add_theme_font_size_override("font_size",int(20*u))
 right_y+=60*u
 for i in range(4):
  place(actions[i],Rect2(right_x,right_y,right_width,action_h))
  actions[i].add_theme_font_size_override("font_size",int((23 if i==0 else 20)*u))
  right_y+=action_h+10*u
 var utility_width=(right_width-12*u)/3
 for i in range(3):
  utilities[i].add_theme_font_size_override("font_size",maxi(12,int(14*u)))
  place(utilities[i],Rect2(right_x+i*(utility_width+6*u),right_y,utility_width,38*u))
 right_y+=48*u
 place(status,Rect2(right_x,right_y,right_width,22*u))
 var bottom=maxf(y+card_h,right_y+22*u)+16*u
 place(tips,Rect2(left_x,bottom,width,28*u))
 board.custom_minimum_size.y=maxf(size.y,bottom+44*u)
 for l in [tagline,profile_title,character_title,stage_title,status,tips]:
  l.add_theme_font_size_override("font_size",maxi(12,int((15 if l==tagline else 13)*u)))
