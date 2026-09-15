extends Control

var host
var resuming=false
var panel: PanelContainer
var scroll: ScrollContainer
var content: VBoxContainer
var footer: GridContainer
var steps: GridContainer
var status_card: PanelContainer
var status_title: Label
var status_hint: Label
var ready_button: Button
var heading: Label
var subtitle: Label
var labels: Array[Label]=[]
var step_labels: Array[Label]=[]
var state_key=""

func text_line(text: String, parent: Node, pixels=22) -> Label:
 var l=host.label(text,pixels)
 l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 parent.add_child(l);labels.append(l)
 return l

func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var bg=TextureRect.new();bg.texture=preload("res://art/primavera-pomar.png")
 bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
 bg.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(bg)
 var shade=ColorRect.new();shade.color=Color(0.04,0.13,0.10,0.65);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
 panel=PanelContainer.new();panel.add_theme_stylebox_override("panel",host.box(host.CREAM,host.GREEN,3));add_child(panel)
 var stack=VBoxContainer.new();stack.add_theme_constant_override("separation",18);panel.add_child(stack)
 scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus=true
 scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;stack.add_child(scroll)
 content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",18);scroll.add_child(content)
 var eyebrow=text_line("SPEED RUN · SENSOR" if host.speedrun_selected else "AVENTURA · SENSOR",content,16)
 eyebrow.add_theme_color_override("font_color",host.GREEN)
 heading=text_line("Vamos jogar com movimento!",content,40)
 subtitle=text_line("O personagem corre sozinho. Pule com o sensor e use os poderes." if host.speedrun_selected else "Use o sensor para pular. Os botões também continuam disponíveis.",content)
 steps=GridContainer.new();steps.add_theme_constant_override("h_separation",12);steps.add_theme_constant_override("v_separation",10);content.add_child(steps)
 for item in [["1  Ligue o sensor","Peça ajuda a um adulto."],["2  Deixe parado","Espere o sinal de pronto."],["3  Vamos jogar!","Pule para saltar no jogo."]]:
  var card=PanelContainer.new();card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;card.add_theme_stylebox_override("panel",host.box(Color("e8ebd7")));steps.add_child(card)
  var lines=VBoxContainer.new();lines.add_theme_constant_override("separation",5);card.add_child(lines)
  step_labels.append(text_line(item[0],lines,22));text_line(item[1],lines,18)
 status_card=PanelContainer.new();content.add_child(status_card)
 var status_lines=VBoxContainer.new();status_lines.add_theme_constant_override("separation",6);status_card.add_child(status_lines)
 status_title=text_line("",status_lines,28);status_title.name="SensorStatus"
 status_hint=text_line("",status_lines,20)
 content.move_child(status_card,3)
 footer=GridContainer.new();footer.columns=1;footer.add_theme_constant_override("v_separation",10);footer.add_theme_constant_override("h_separation",10);stack.add_child(footer)
 ready_button=host.button("Jogar com sensor",func():
  if host.sensor.is_ready:
   if resuming and host.world!=null:host.resume_game()
   else:host.start_game(),true)
 ready_button.name="SensorReady";footer.add_child(ready_button)
 var disabled_style=host.box(Color("d9ddce"),Color("b8c2ad"),2)
 ready_button.add_theme_stylebox_override("disabled",disabled_style)
 ready_button.add_theme_color_override("font_disabled_color",Color("55634f"))
 footer.add_child(host.button("Jogar sem sensor",func():
  host.mode="buttons";host.sensor.deactivate()
  if resuming and host.world!=null:host.resume_game()
  else:host.start_game()))
 footer.add_child(host.button("Voltar",func():host.mode="buttons";host.sensor.deactivate();host.show_pause() if resuming and host.world!=null else host.show_menu()))
 for b in host.menu_buttons:
  b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 resized.connect(arrange);refresh();arrange.call_deferred()

func refresh():
 if not is_instance_valid(status_title):return
 var sensor=host.sensor
 var next_key="ready" if sensor.is_ready else "calibrating" if sensor.calibrating else "waiting:"+sensor.status
 if state_key==next_key:return
 state_key=next_key
 ready_button.disabled=not sensor.is_ready
 ready_button.text="Continuar com sensor" if resuming else "Jogar com sensor"
 var fill=Color("f6e6b6")
 if sensor.is_ready:
  status_title.text="Tudo pronto para jogar!"
  status_hint.text="Toque em “Jogar com sensor” para começar." if not resuming else "Toque em “Continuar com sensor” para voltar à brincadeira."
  fill=Color("dbeccb")
 elif sensor.calibrating:
  status_title.text="Só um instante…"
  status_hint.text="Deixe o sensor parado enquanto ele se prepara. O botão será liberado quando estiver pronto."
 else:
  status_title.text="Vamos conectar o sensor"
  status_hint.text="Ligue o dispositivo e aguarde a conexão. Você também pode jogar agora sem sensor." if sensor.status=="Aguardando o dispositivo…" else sensor.status
 status_card.add_theme_stylebox_override("panel",host.box(fill,Color("b4bb85"),2))

func arrange():
 if not is_instance_valid(panel):return
 var wide=size.x>=1500
 var compact=size.x<600 or size.y<480
 footer.columns=3 if size.y<480 and size.x>=600 else 1
 var margin=clampf(minf(size.x,size.y)*0.035,8,32)
 var width=minf(1200 if wide else 960,size.x-margin*2)
 steps.columns=3 if width>=760 else 1
 for l in labels:l.add_theme_font_size_override("font_size",24 if wide else 18 if compact else 21)
 heading.add_theme_font_size_override("font_size",46 if wide else 28 if compact else 36)
 status_title.add_theme_font_size_override("font_size",32 if wide else 23 if compact else 27)
 for l in step_labels:l.add_theme_font_size_override("font_size",26 if wide else 20 if compact else 23)
 for b in host.menu_buttons:
  b.custom_minimum_size.y=68 if wide else 52
  b.add_theme_font_size_override("font_size",28 if wide else 20)
 panel.size.x=width
 var natural=content.get_combined_minimum_size().y+footer.get_combined_minimum_size().y+48
 var height=minf(maxf(natural,240),size.y-margin*2)
 panel.size=Vector2(width,height)
 panel.position=(size-panel.size)/2

func _process(_delta):
 if is_visible_in_tree():arrange()
