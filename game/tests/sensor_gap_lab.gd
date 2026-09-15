extends Node2D
# Local experiment: camera magnification never changes the player's physics.
const Player=preload("res://scripts/player.gd")
const Sensor=preload("res://scripts/sensor.gd")
const Diagnostics=preload("res://scripts/sensor_diagnostics.gd")
const GROUND=150.0
const GAP_X=180.0
const START_X=55.0
const INK=Color("244d43")
const CREAM=Color("fff5df")
var gap_width=32.0
var player
var sensor
var right_floor
var status_label: Label
var hint: Label
var start_button: Button
var values: Array[Label]=[]
var require_sensor=true
var running=false
var countdown=0.0
var commands=0
var jumps=0
var crossings=0
var returns=0
var last_wait_ms=0
var last_flight_ms=0
var last_range=0.0
var command_at=0
var jump_at=-1
var jump_x=0.0
var crossed_in_air=false
var attempt_complete=false
var next_state_ms=0
var grass=preload("res://art/grass.png")
var backdrop=preload("res://art/primavera-pomar.png")

func _ready():
 var window=get_window()
 window.mode=Window.MODE_WINDOWED;window.size=Vector2i(1100,650);window.position=Vector2i(40,130)
 window.content_scale_size=Vector2i(960,540)
 window.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
 window.content_scale_aspect=Window.CONTENT_SCALE_ASPECT_KEEP
 window.show();window.grab_focus()
 texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 var camera=Camera2D.new();camera.position=Vector2(160,90);camera.zoom=Vector2(3,3);add_child(camera);camera.make_current()
 make_floor(0,GAP_X)
 right_floor=make_floor(GAP_X+gap_width,320-GAP_X-gap_width)
 player=Player.new();player.position=Vector2(START_X,GROUND);add_child(player)
 player.configure_sensor_jump(true);player.auto_run=true;player.button_input_enabled=false;player.set_physics_process(false)
 sensor=Sensor.new();add_child(sensor)
 build_ui()
 sensor.status_changed.connect(refresh_status)
 sensor.connection_lost.connect(func():running=false;player.clear_commands();refresh_status())
 sensor.jump_requested.connect(func():
  commands+=1;command_at=Time.get_ticks_msec()
  Diagnostics.record("received",{"event_id":sensor.last_event,"screen":"gap_lab","running":running and countdown<=0})
  if running and countdown<=0:player.sensor_jump=true)
 player.jumped.connect(func():
  jumps+=1;jump_at=Time.get_ticks_msec();jump_x=player.position.x
  last_wait_ms=jump_at-command_at if command_at>0 else 0)
 if require_sensor:sensor.activate()
 refresh_status()
 if OS.get_cmdline_user_args().has("--lab-preview"):save_preview.call_deferred()

func save_preview():
 await RenderingServer.frame_post_draw
 get_viewport().get_texture().get_image().save_png("res://../evidence/sensor-gap-preview.png")

func make_floor(x: float,width: float):
 var floor=StaticBody2D.new();floor.position=Vector2(x+width/2,GROUND+25)
 var collision=CollisionShape2D.new();var shape=RectangleShape2D.new();shape.size=Vector2(width,50);collision.shape=shape
 floor.add_child(collision);add_child(floor);return floor

func set_gap(width: float):
 gap_width=width
 right_floor.position.x=GAP_X+width+(320-GAP_X-width)/2
 right_floor.get_child(0).shape.size=Vector2(320-GAP_X-width,50)
 reset_attempt();hint.text="Largura ajustada. Experimente o próximo salto.";queue_redraw()

func panel(color: Color) -> StyleBoxFlat:
 var style=StyleBoxFlat.new();style.bg_color=color;style.set_corner_radius_all(10)
 style.content_margin_left=16;style.content_margin_right=16;style.content_margin_top=10;style.content_margin_bottom=10
 return style

func text_label(text: String,size: int,color: Color=INK) -> Label:
 var label=Label.new();label.text=text;label.add_theme_font_size_override("font_size",size);label.add_theme_color_override("font_color",color);return label

func make_button(text: String,callback: Callable,accent=false) -> Button:
 var button=Button.new();button.text=text;button.custom_minimum_size=Vector2(0,38)
 button.add_theme_font_size_override("font_size",16)
 button.add_theme_stylebox_override("normal",panel(INK if accent else Color("e5ead6")))
 button.add_theme_stylebox_override("hover",panel(Color("407a5d") if accent else Color("d0dec3")))
 button.add_theme_stylebox_override("pressed",panel(Color("d7aa55")))
 button.add_theme_color_override("font_color",CREAM if accent else INK)
 button.pressed.connect(callback);return button

func build_ui():
 var layer=CanvasLayer.new();add_child(layer)
 var top=Panel.new();top.position=Vector2(16,14);top.size=Vector2(928,160);top.add_theme_stylebox_override("panel",panel(CREAM));layer.add_child(top)
 var eyebrow=text_label("AVENTURA DAS LETRAS  /  LABORATÓRIO",12);eyebrow.position=Vector2(34,23);layer.add_child(eyebrow)
 var title=text_label("Um salto de cada vez",28);title.position=Vector2(32,40);layer.add_child(title)
 status_label=text_label("Conectando…",16);status_label.position=Vector2(640,32);status_label.size=Vector2(280,45);status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;layer.add_child(status_label)
 var labels=["TEMPO NO AR","ESPERA NO JOGO","SALTOS / COMANDOS","TRAVESSIAS"]
 for i in range(4):
  var card=Panel.new();card.position=Vector2(30+i*230,91);card.size=Vector2(210,69);card.add_theme_stylebox_override("panel",panel(Color("e8ecd9")));layer.add_child(card)
  var caption=text_label(labels[i],11);caption.position=Vector2(44+i*230,99);layer.add_child(caption)
  var value=text_label("—",26);value.position=Vector2(44+i*230,115);layer.add_child(value);values.append(value)
 var instruction=text_label("Corra sozinho. Pule com o sensor na faixa dourada.",17,CREAM);instruction.position=Vector2(28,186)
 instruction.add_theme_color_override("font_shadow_color",INK);instruction.add_theme_constant_override("shadow_offset_x",1);instruction.add_theme_constant_override("shadow_offset_y",1);layer.add_child(instruction)
 hint=text_label("Escolha a largura e comece quando estiver pronto.",15,CREAM);hint.position=Vector2(28,211);hint.add_theme_color_override("font_shadow_color",INK);hint.add_theme_constant_override("shadow_offset_y",1);layer.add_child(hint)
 var footer=Panel.new();footer.position=Vector2(0,490);footer.size=Vector2(960,50);footer.add_theme_stylebox_override("panel",panel(CREAM));layer.add_child(footer)
 var row=HBoxContainer.new();row.position=Vector2(18,496);row.size=Vector2(924,38);row.add_theme_constant_override("separation",10);layer.add_child(row)
 start_button=make_button("Começar percurso",toggle_running,true);start_button.custom_minimum_size.x=200;row.add_child(start_button)
 row.add_child(make_button("Voltar ao início",reset_attempt))
 var width_label=text_label("Buraco",15);width_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(width_label)
 var selector=OptionButton.new();selector.custom_minimum_size=Vector2(100,38)
 for width in [24,32,40,48]:selector.add_item(str(width)+" px",width)
 selector.select(1);selector.item_selected.connect(func(index):set_gap(float(selector.get_item_id(index))));row.add_child(selector)
 row.add_child(make_button("Reconectar",func():running=false;sensor.activate();refresh_status()))
 var note=text_label("400 ms · sem vidas",13);note.size_flags_horizontal=Control.SIZE_EXPAND_FILL;note.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT;note.vertical_alignment=VERTICAL_ALIGNMENT_CENTER;row.add_child(note)

func refresh_status():
 var ready=not require_sensor or sensor.is_ready
 status_label.text="●  Sensor conectado\nPronto para pular" if ready else "●  "+sensor.status
 status_label.add_theme_color_override("font_color",Color("347854") if ready else Color("a26a30"))
 start_button.disabled=not ready
 start_button.text="Pausar percurso" if running else "Começar percurso"

func toggle_running():
 Diagnostics.record("lab_start_pressed",{"ready":sensor.is_ready,"running_before":running})
 if require_sensor and not sensor.is_ready:return
 running=not running
 if running and player.position.y>GROUND+5:reset_attempt()
 refresh_status()

func reset_attempt():
 player.position=Vector2(START_X,GROUND);player.clear_commands();player.effects.clear();player.power_seconds=0;player.extra_jump=false
 jump_at=-1;crossed_in_air=false;attempt_complete=false;countdown=.8
 Diagnostics.record("lab_reset",{"gap_width":gap_width})

func _physics_process(delta):
 if not is_instance_valid(player):return
 if running and (not require_sensor or sensor.is_ready):
  if countdown>0:countdown=maxf(0,countdown-delta);player.animate("idle")
  else:
   var was_floor=player.is_on_floor()
   player._physics_process(delta)
   player.effects.clear();player.power_seconds=0;player.extra_jump=false
   if player.position.x>=GAP_X and player.position.x<=GAP_X+gap_width and not player.is_on_floor() and player.position.y<GROUND-3:crossed_in_air=true
   if not was_floor and player.is_on_floor() and jump_at>=0:
    last_flight_ms=Time.get_ticks_msec()-jump_at;last_range=player.position.x-jump_x;jump_at=-1
   if not attempt_complete and player.position.x>GAP_X+gap_width+10 and player.is_on_floor() and crossed_in_air:
    crossings+=1;attempt_complete=true;hint.text="Atravessou! Alcance medido: %.0f px. Próxima volta logo adiante." % last_range
    Diagnostics.record("gap_crossed",{"gap_width":gap_width,"range_px":last_range,"flight_ms":last_flight_ms})
   if player.position.y>GROUND+42:
    returns+=1;Diagnostics.record("gap_return",{"gap_width":gap_width});reset_attempt();hint.text="De volta ao início. Experimente outro momento para pular."
   elif player.position.x>300:reset_attempt()
 values[0].text=(str(last_flight_ms)+" ms") if last_flight_ms>0 else "400 ms · alvo"
 values[1].text=(str(last_wait_ms)+" ms") if jumps>0 else "—"
 values[2].text=str(jumps)+" / "+str(commands)
 values[3].text=str(crossings)
 if Time.get_ticks_msec()>next_state_ms:
  next_state_ms=Time.get_ticks_msec()+500
  var window=get_window();var f=FileAccess.open("res://../evidence/sensor-latency-live.json",FileAccess.WRITE)
  f.store_string(JSON.stringify({"wall_ms":Time.get_unix_time_from_system()*1000,"status":sensor.status,"ready":sensor.is_ready,"received_packets":sensor.received,"commands":commands,"jumps":jumps,"crossings":crossings,"returns":returns,"gap_width":gap_width,"running":running,"last_wait_ms":last_wait_ms,"last_flight_ms":last_flight_ms,"last_range_px":last_range,"window_visible":window.visible,"window_focused":window.has_focus()}));f.close()

func _draw():
 draw_texture_rect(backdrop,Rect2(0,0,320,180),false)
 draw_rect(Rect2(GAP_X,GROUND,gap_width,35),Color("203b3c"))
 for segment in [Vector2(0,GAP_X),Vector2(GAP_X+gap_width,320)]:
  var x=segment.x
  while x<segment.y:
   var width=minf(32,segment.y-x);draw_texture_rect(grass,Rect2(x,GROUND,width,32),false);x+=width
 draw_rect(Rect2(GAP_X-20,GROUND-2,14,2),Color("f4c66b"))
 draw_line(Vector2(GAP_X,GROUND+5),Vector2(GAP_X+gap_width,GROUND+5),Color("f4c66b"),1)
 for x in [GAP_X,GAP_X+gap_width]:draw_line(Vector2(x,GROUND+2),Vector2(x,GROUND+8),Color("f4c66b"),1)
 var font=ThemeDB.fallback_font
 draw_string(font,Vector2(GAP_X+gap_width/2-9,GROUND+12),str(int(gap_width))+" px",HORIZONTAL_ALIGNMENT_LEFT,-1,7,CREAM)
