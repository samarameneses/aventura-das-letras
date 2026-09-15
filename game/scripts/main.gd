extends Control

const TitleMenu=preload("res://scripts/title_menu.gd")
const ResponsiveOverlay=preload("res://scripts/responsive_overlay.gd")
var play_surface: Control
const Powers=preload("res://scripts/powers.gd")
var power_buttons: Array=[]
const HudIcon=preload("res://scripts/hud_icon.gd")
var jump_button: Button
var pause_button: Button
var sound_button: Button
var answer_effects
var powers_return="menu"
var power_slot=0
var session_sections=0
var session_discoveries=0
var segment_started_ms=0
const World=preload("res://scripts/world.gd")
const Sensor=preload("res://scripts/sensor.gd")
const RunClock=preload("res://scripts/run_clock.gd")
const CREAM=Color("fbf4df")
const INK=Color("233d38")
const GREEN=Color("326855")
var world
var viewport: SubViewport
var game_display: SubViewportContainer
var menu: Control
var hud: Control
var sensor
var instruction: Label
var feedback: Label
var screen="menu"
var voice_id=""
var active_activity=-1
var helped=false
var feedback_timer=0.0
var waiting_key=""
var controls_return="menu"
var mode="buttons"
var test_mode=false
var menu_buttons: Array=[]
var summary: Label
var lives_label: Label
var success_banner: PanelContainer
var success_title: Label
var success_detail: Label
var success_timer=0.0
var praise_bag: Array=[]
var last_praise=""
var stages_return="menu"
var stage_category="alfabeto"
var speedrun_selected=false
var run_clock=RunClock.new()
var run_result: Dictionary={}
var adventure_stage_before_speedrun=""

func _ready():
 test_mode=OS.get_cmdline_user_args().has("--test")
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var theme=Theme.new()
 theme.default_font_size=20
 self.theme=theme
 play_surface=Control.new();play_surface.size=Vector2(960,540);play_surface.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(play_surface)
 resized.connect(layout_play_surface);layout_play_surface()
 var voices=DisplayServer.tts_get_voices_for_language("pt") if not test_mode else PackedStringArray()
 if not voices.is_empty():voice_id=voices[0]
 if not test_mode:
  for voice in DisplayServer.tts_get_voices():
   if str(voice.get("language","")).replace("_","-").to_lower()=="pt-br":
    voice_id=voice.id
    if "Luciana" in str(voice.get("name","")):break
 sensor=Sensor.new();add_child(sensor)
 sensor.jump_requested.connect(func():
  preload("res://scripts/sensor_diagnostics.gd").record("received",{"event_id":sensor.last_event,"screen":screen})
  if screen=="playing" and world!=null:world.player.sensor_jump=true)
 sensor.connection_lost.connect(func():
  if screen=="finish":return
  if world!=null:Data.record_motor("sensor_disconnect")
  show_sensor_lost())
 sensor.status_changed.connect(func():
  if screen=="sensor":refresh_sensor_status())
 show_menu()
 if OS.get_cmdline_user_args().has("--sensor-usb"):
  if OS.get_cmdline_user_args().has("--speed-run"):
   adventure_stage_before_speedrun=Data.profile().stage_id
   speedrun_selected=true
  show_sensor.call_deferred(false)
 elif OS.get_cmdline_user_args().has("--speed-run"):_start_direct_speedrun.call_deferred()

func _start_direct_speedrun():
 if not is_inside_tree() or screen!="menu":return
 adventure_stage_before_speedrun=Data.profile().stage_id
 speedrun_selected=true;start_game()

func label(text: String, size_px=20, color=INK) -> Label:
 var l=Label.new();l.text=text;l.add_theme_font_size_override("font_size",size_px);l.add_theme_color_override("font_color",color)
 return l

func box(color: Color, border=Color.TRANSPARENT, width=0) -> StyleBoxFlat:
 var b=StyleBoxFlat.new();b.bg_color=color;b.border_color=border;b.set_border_width_all(width)
 b.set_corner_radius_all(8);b.content_margin_left=18;b.content_margin_right=18;b.content_margin_top=12;b.content_margin_bottom=12
 return b

func button(text: String, callback: Callable, accent=false) -> Button:
 var b=Button.new();b.text=text;b.custom_minimum_size=Vector2(0,43);b.focus_mode=Control.FOCUS_ALL
 b.add_theme_stylebox_override("normal",box(GREEN if accent else Color("e8ebd7")))
 b.add_theme_stylebox_override("hover",box(Color("48886d") if accent else Color("d7e3bf")))
 b.add_theme_stylebox_override("pressed",box(Color("254d40")))
 b.add_theme_stylebox_override("focus",box(Color.TRANSPARENT,Color("efa933"),3))
 b.add_theme_color_override("font_color",CREAM if accent else INK)
 b.add_theme_color_override("font_hover_color",CREAM if accent else INK)
 b.add_theme_color_override("font_focus_color",CREAM if accent else INK)
 b.add_theme_font_size_override("font_size",18)
 b.pressed.connect(callback);b.focus_entered.connect(func():speak(text))
 menu_buttons.append(b)
 return b

func layout_play_surface():
 if not is_instance_valid(play_surface):return
 var factor=minf(size.x/960.0,size.y/540.0)
 play_surface.scale=Vector2.ONE*factor
 play_surface.position=(size-Vector2(960,540)*factor)/2

func new_overlay(title: String, subtitle: String) -> VBoxContainer:
 if is_instance_valid(menu):menu.queue_free();remove_child(menu)
 menu_buttons=[]
 var overlay=ResponsiveOverlay.new();overlay.host=self;overlay.title=title;overlay.subtitle=subtitle
 menu=overlay;add_child(menu)
 return overlay.content

func focus_first():
 if not menu_buttons.is_empty():_focus_control.call_deferred(menu_buttons[0])

func _focus_control(control):
 if is_instance_valid(control) and control.is_inside_tree() and control.is_visible_in_tree() and not control.is_queued_for_deletion():
  control.grab_focus()

func show_menu():
 run_clock.pause();Data.end_speedrun()
 if speedrun_selected and adventure_stage_before_speedrun in Data.stage_index:Data.choose_stage(adventure_stage_before_speedrun)
 speedrun_selected=false;adventure_stage_before_speedrun=""
 screen="menu";mode="buttons";sensor.deactivate()
 if world!=null:world.set_active(false)
 if is_instance_valid(hud):hud.hide()
 play_surface.hide()
 if is_instance_valid(menu):menu.queue_free();remove_child(menu)
 menu_buttons=[]
 var title_screen=TitleMenu.new();title_screen.host=self;menu=title_screen;add_child(menu)

func start_game(continuing=false, carry: Dictionary={}):
 if not continuing:
  run_clock.reset();session_sections=0;session_discoveries=0;segment_started_ms=0
 run_result={}
 if speedrun_selected:Data.begin_speedrun()
 else:Data.end_speedrun()
 Data.activities=Data.current_stage().activities
 if Data.lives_remaining()<=0:
  Data.round_progress().lives=Data.MAX_LIVES;Data.save_progress()
 active_activity=-1;helped=false;success_timer=0
 if is_instance_valid(game_display):game_display.queue_free();play_surface.remove_child(game_display)
 game_display=SubViewportContainer.new();game_display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);game_display.stretch=true;game_display.stretch_shrink=3;game_display.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
 play_surface.add_child(game_display);play_surface.move_child(game_display,0)
 viewport=SubViewport.new();viewport.size=Vector2i(320,180);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS
 game_display.add_child(viewport)
 world=World.new();viewport.add_child(world)
 world.player.configure_sensor_jump(mode=="sensor")
 world.activity_entered.connect(on_activity)
 world.answer_collected.connect(on_answer)
 world.motor_fall.connect(func():Data.record_motor("virtual_fall");toast("Tudo bem! Você voltou ao ponto seguro."))
 world.checkpoint_reached.connect(func():toast("Ponto de retorno salvo!"))
 world.lava_touched.connect(func():
  Data.round_progress().lives=maxi(0,Data.lives_remaining()-1)
  restore_hearts_if_needed();Data.record_motor("lava_contact");update_hud())
 world.speed_collected.connect(func():
  world.player.cooldowns.clear())
 world.assisted_collection.connect(func(index):
  helped=true;on_answer(index,str(Data.activities[index].target)))
 world.light_requested.connect(func(index):
  if active_activity==index:helped=true
  speak(Data.activities[index].spoken))
 world.finished.connect(show_finish)
 if continuing:
  world.player.effects=carry.effects;world.player.cooldowns=carry.cooldowns
  world.player.power_seconds=carry.power_seconds;world.player.has_power=carry.has_power
  world.player.extra_jump=carry.extra_jump
  Data.round_progress().lives=carry.lives
  Data.round_progress().power_available=carry.has_power
  Data.save_progress()
 build_hud()
 restore_hearts_if_needed()
 resume_game()


func floating_label(text: String, pixels: int, color=CREAM) -> Label:
 var l=label(text,pixels,color)
 l.add_theme_color_override("font_outline_color",INK);l.add_theme_constant_override("outline_size",5)
 l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 return l

func hud_button(icon_id: String, color: Color, at: Vector2, extent: Vector2, caption: String, callback: Callable) -> Button:
 var b=HudIcon.new();b.glyph=icon_id;b.accent=color;b.position=at;b.size=extent;b.tooltip_text=caption
 b.pressed.connect(callback);hud.add_child(b);return b

func build_hud():
 if is_instance_valid(hud):hud.queue_free();play_surface.remove_child(hud)
 hud=Control.new();hud.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);play_surface.add_child(hud)
 answer_effects=load("res://scripts/answer_effects.gd").new();answer_effects.host=self;hud.add_child(answer_effects)
 lives_label=floating_label("",24,Color("ff91af"));lives_label.position=Vector2(24,18);hud.add_child(lives_label)
 summary=floating_label("",13);summary.position=Vector2(24,54);hud.add_child(summary)
 instruction=floating_label("Vamos explorar!",24);instruction.position=Vector2(228,20);instruction.size=Vector2(504,65)
 instruction.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;instruction.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hud.add_child(instruction)
 feedback=floating_label("",18);feedback.position=Vector2(155,90);feedback.size=Vector2(650,60);feedback.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;feedback.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;hud.add_child(feedback)
 success_banner=PanelContainer.new();success_banner.position=Vector2(180,100);success_banner.size=Vector2(600,75);success_banner.add_theme_stylebox_override("panel",StyleBoxEmpty.new());success_banner.mouse_filter=Control.MOUSE_FILTER_IGNORE;hud.add_child(success_banner)
 var success_lines=VBoxContainer.new();success_lines.mouse_filter=Control.MOUSE_FILTER_IGNORE;success_banner.add_child(success_lines)
 success_title=floating_label("",27,Color("fff08a"));success_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;success_lines.add_child(success_title)
 success_detail=floating_label("",18);success_detail.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;success_lines.add_child(success_detail)
 success_banner.hide()
 power_buttons=[]
 for slot in range(2):
  power_buttons.append(hud_button("light",CREAM,Vector2(20+slot*82,438),Vector2(72,76),"",func():
   if screen=="playing":world.player.activate_slot(slot)))
 jump_button=hud_button("jump",Color("a9e278"),Vector2(838,424),Vector2(98,94),"Pular · "+Data.key_label("jump"),func():
  if screen=="playing":world.player.sensor_jump=true)
 pause_button=hud_button("pause",CREAM,Vector2(884,14),Vector2(56,56),"Pausar · "+Data.key_label("pause"),func():
  if screen=="playing":show_pause())
 sound_button=hud_button("sound",Color("ffbf49"),Vector2(816,14),Vector2(56,56),"Ouvir novamente · "+Data.key_label("repeat_instruction"),func():
  if screen=="playing" and active_activity>=0:speak(Data.activities[active_activity].spoken))
 update_hud()

func update_hud():
 if not is_instance_valid(summary):return
 lives_label.text="♥ ".repeat(Data.lives_remaining())+"♡ ".repeat(Data.MAX_LIVES-Data.lives_remaining())
 summary.text=("Tempo · "+RunClock.format_time(run_clock.elapsed_ms())+"\n" if speedrun_selected else "")+str(session_discoveries+Data.round_progress().completed.size())+" descobertas"
 for slot in range(power_buttons.size()):
  var power=Powers.get_power(str(Data.equipped_powers()[slot]))
  var remaining=float(world.player.cooldowns.get(power.id,0))
  var active=world.player.effect_active(power.id)
  var caption=power.name+" · "+Data.key_label("power" if slot==0 else "power_two")+" · "+("ativo" if active else str(ceili(remaining))+"s" if remaining>0 else "pronto")
  power_buttons[slot].set_power(power.id,Color(power.color),1-remaining/(float(power.duration)+float(power.recharge)),active,caption)

func resume_game():
 restore_hearts_if_needed()
 if mode=="sensor" and not sensor.is_ready:
  show_sensor(true);return
 screen="playing"
 play_surface.show()
 if is_instance_valid(menu):menu.hide()
 if is_instance_valid(hud):hud.show()
 world.player.configure_sensor_jump(mode=="sensor")
 world.set_active(true)
 if speedrun_selected:run_clock.resume()
 update_hud()

func on_activity(index: int):
 active_activity=index;helped=world.player.effect_active("light")
 instruction.text=Data.activities[index].instruction
 speak(Data.activities[index].spoken)

func on_answer(index: int, choice: String):
 if screen!="playing" or index<0 or index>=Data.activities.size():return
 var a=Data.activities[index]
 var correct=choice==a.target
 if not Data.record_answer(a.id,choice,correct,helped,mode):return
 if correct:
  world.mark_completed(index)
  celebrate_answer(a)
  active_activity=-1
  instruction.text="Muito bem! Continue pela fase."
 else:
  success_timer=0;success_banner.hide()
  answer_effects.wrong(answer_effect_origin())
  feedback.text="Ops! Essa não era a resposta.";feedback_timer=1.8
  if restore_hearts_if_needed():return
  if speedrun_selected:
   world.skip_choice(index);active_activity=-1
   instruction.text="Vamos explorar!"
 update_hud()

func restore_hearts_if_needed() -> bool:
 if Data.lives_remaining()>0:return false
 # Errors renew hearts in place, preserving answers, powers and checkpoint.
 Data.round_progress().lives=Data.MAX_LIVES
 Data.save_progress()
 return false

func next_praise() -> String:
 if praise_bag.is_empty():
  praise_bag=Data.positive_feedback.duplicate();praise_bag.shuffle()
  if praise_bag.size()>1 and praise_bag[-1]==last_praise:
   var swap=praise_bag[0];praise_bag[0]=praise_bag[-1];praise_bag[-1]=swap
 last_praise=praise_bag.pop_back()
 return last_praise

func answer_effect_origin() -> Vector2:
 return (world.player.get_global_transform_with_canvas().origin*3-Vector2(0,45)).clamp(Vector2(28,40),Vector2(932,490))

func celebrate_answer(activity: Dictionary):
 answer_effects.celebrate(answer_effect_origin())
 var phrase=next_praise()
 success_title.text=phrase
 success_detail.text=activity.target+(" · como em "+activity.example if not str(activity.get("example","")).is_empty() else " · descoberta concluída!")
 success_banner.modulate=Color.WHITE;success_banner.show();success_timer=3.4
 feedback.text="";feedback_timer=0
 world.player.success_pending=true
 speak(phrase)

func toast(text: String, duration=3.2):
 if is_instance_valid(feedback):feedback.text=text
 feedback_timer=duration
 speak(text)

func speak(text: String):
 if not Data.state.voice or test_mode:return
 if not voice_id.is_empty():
  DisplayServer.tts_stop()
  DisplayServer.tts_speak(text,voice_id,int(Data.state.get("voice_volume",85)),1.0,0.93)

func show_pause():
 if world==null:return
 run_clock.pause()
 world.set_active(false)
 if mode=="sensor":sensor.suspend()
 screen="pause"
 var v=new_overlay("Pausa no Speed Run" if speedrun_selected else "Uma pausa no jardim", "Cronômetro parado em "+RunClock.format_time(run_clock.elapsed_ms())+". Continue quando quiser." if speedrun_selected else "Seu personagem e suas descobertas continuam aqui.")
 v.add_theme_constant_override("separation",6)
 v.add_child(button("Continuar corrida" if speedrun_selected else "Continuar aventura",resume_game,true))
 v.add_child(button("Continuar sem sensor",func():mode="buttons";sensor.deactivate();resume_game()))
 var choices=HFlowContainer.new();choices.add_theme_constant_override("separation",10);v.add_child(choices)
 var phase_button=button("Reiniciar corrida" if speedrun_selected else "Escolher fase",func():start_game() if speedrun_selected else show_stages("pause"));phase_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;choices.add_child(phase_button)
 var sensor_button=button("Conectar sensor",func():show_sensor(true));sensor_button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;choices.add_child(sensor_button)
 v.add_child(button("Poderes e duração",func():show_powers("pause")))
 v.add_child(button("Ajustar controles e som",func():show_settings("pause")))
 v.add_child(button("Voltar à escolha de personagens",func():Data.save_progress();show_menu()))
 v.add_child(button("Sair do jogo",func():Data.save_progress();get_tree().quit()))
 focus_first()

func show_finish():
 if screen in ["finish","transition"]:return
 if Data.continuous_play():
  finish_continuous_section();return
 var elapsed=run_clock.stop()-segment_started_ms if speedrun_selected else 0
 Data.complete_stage()
 if speedrun_selected:run_result=Data.save_speedrun_result(elapsed)
 screen="finish"
 var next_id=Data.next_stage_id()
 var title="Novo recorde! Você conseguiu!" if speedrun_selected and run_result.get("new_best",false) else "Speed Run concluído!" if speedrun_selected else "Fase concluída. Você conseguiu!"
 var description=Data.current_stage().title+" · "+str(Data.activities.size())+" descobertas. "+("A próxima aventura já está pronta!" if not next_id.is_empty() else "Você chegou ao fim desta trilha!")
 if speedrun_selected:
  description=Data.current_stage().title+"\nVocê chegou! "+str(Data.round_progress().completed.size())+" descobertas nesta corrida. Tempo: "+RunClock.format_time(elapsed)
  if not run_result.is_empty():description+="\nMelhor tempo com todas as descobertas: "+RunClock.format_time(int(run_result.best_ms))
 var v=new_overlay(title,description)
 var art_space=Control.new();art_space.custom_minimum_size=Vector2(0,125);v.add_child(art_space)
 var celebration=AnimatedSprite2D.new();celebration.sprite_frames=world.player.sprite.sprite_frames;celebration.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;art_space.add_child(celebration)
 var adjust=func():
  var clips=world.player.animations_metadata[world.player.character_id].celebrate
  var frame=clips[celebration.frame]
  var ratio=95.0/float(frame.scale_reference_height)
  celebration.scale=Vector2.ONE*ratio;celebration.position=Vector2(art_space.size.x/2,122-frame.h*ratio/2)
 celebration.frame_changed.connect(adjust);art_space.resized.connect(adjust);celebration.play("celebrate");adjust.call_deferred()
 if speedrun_selected:
  v.add_child(button("Jogar outra vez",start_game,true))
  v.add_child(button("Correr em outra fase",func():show_stages("menu")))
  v.add_child(button("Voltar à aventura",show_menu))
  focus_first();return
 if not next_id.is_empty():v.add_child(button("Próxima fase · "+Data.stage_index[next_id].title,func():
  Data.choose_stage(next_id)
  if Data.round_progress().finished:Data.reset_round()
  start_game(),true))
 v.add_child(button("Repetir esta fase",func():Data.reset_round();start_game(),next_id.is_empty()))
 v.add_child(button("Escolher outra fase",func():show_stages("menu")))
 v.add_child(button("Voltar aos personagens",show_menu))
 speak("Muito bem! Você concluiu esta fase.")
 focus_first()

func finish_continuous_section():
 Data.complete_stage()
 if speedrun_selected:Data.save_speedrun_result(run_clock.elapsed_ms()-segment_started_ms)
 session_discoveries+=Data.round_progress().completed.size();session_sections+=1
 var next_id=Data.next_stage_id()
 if next_id.is_empty():next_id=Data.stages[0].id
 var p=world.player
 var carry={"effects":p.effects.duplicate(),"cooldowns":p.cooldowns.duplicate(),"power_seconds":p.power_seconds,"has_power":p.has_power,"extra_jump":p.extra_jump,"lives":Data.lives_remaining()}
 screen="transition";world.set_active(false)
 advance_continuous.call_deferred(next_id,carry)

func advance_continuous(next_id: String, carry: Dictionary):
 if screen!="transition":return
 Data.choose_stage(next_id)
 if not speedrun_selected and Data.round_progress().finished:Data.reset_round()
 segment_started_ms=run_clock.elapsed_ms()
 start_game(true,carry)

func show_powers(from: String, slot: int=0):
 powers_return=from;power_slot=slot
 run_clock.pause()
 if world!=null:world.set_active(false)
 screen="powers"
 var v=new_overlay("Seus superpoderes", "Escolha dois poderes. Todos estão disponíveis e recarregam sozinhos enquanto você brinca.")
 v.add_theme_constant_override("separation",6)
 var slots=HFlowContainer.new();slots.name="PowerSlots";slots.add_theme_constant_override("separation",10);v.add_child(slots)
 for i in range(2):
  var power=Powers.get_power(str(Data.equipped_powers()[i]))
  slots.add_child(button(("✓ " if slot==i else "")+"Poder "+str(i+1)+" · "+power.name,func():show_powers(from,i),slot==i))
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(0,125);scroll.follow_focus=true;v.add_child(scroll)
 var grid=GridContainer.new();grid.columns=4;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",8);grid.add_theme_constant_override("v_separation",8);scroll.add_child(grid)
 for power in Powers.CATALOG:
  var b=button(power.symbol+"  "+power.name+("  ✓" if power.id in Data.equipped_powers() else ""),func():Data.equip_power(slot,power.id);show_powers(from,slot))
  b.custom_minimum_size=Vector2(190,52);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.tooltip_text=power.description;b.add_theme_font_size_override("font_size",13)
  grid.add_child(b)
 var selected=Powers.get_power(str(Data.equipped_powers()[slot]))
 var description=label(selected.description,15);description.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;v.add_child(description)
 v.add_child(button("Duração: "+("contínua — até você pausar" if Data.continuous_play() else "uma fase por vez"),func():Data.state.continuous=not Data.continuous_play();Data.save_progress();show_powers(from,slot)))
 v.add_child(button("Continuar brincando" if from=="pause" else "Pronto",func():resume_game() if from=="pause" else show_menu(),true))
 focus_first()

func show_stages(from: String, category=""):
 run_clock.pause()
 stages_return=from
 if not category.is_empty():stage_category=category
 elif Data.current_stage().group in ["alfabeto","familias","digrafos","encontros","palavras","dissilabas"]:stage_category=Data.current_stage().group
 else:stage_category="especiais"
 if world!=null:world.set_active(false)
 screen="stages"
 var v=new_overlay("Speed Run · escolha a fase" if speedrun_selected else "Escolha sua próxima descoberta", "Corra automaticamente! Você pula e usa os poderes. Deixe passar uma opção se quiser continuar explorando." if speedrun_selected else "Siga a trilha ou escolha uma fase para praticar. Cada fase guarda seu progresso.")
 var tabs=HFlowContainer.new();tabs.add_theme_constant_override("separation",6);v.add_child(tabs)
 for pair in [["alfabeto","Alfabeto"],["familias","BA, BE…"],["digrafos","CH, LH, NH"],["encontros","BR, PR…"],["especiais","Especiais"],["palavras","Palavras"],["dissilabas","Dissílabas"]]:
  var tab=button(pair[1],func():show_stages(from,pair[0]),stage_category==pair[0]);tab.size_flags_horizontal=Control.SIZE_EXPAND_FILL;tabs.add_child(tab)
  tab.add_theme_font_size_override("font_size",14)
 var scroll=ScrollContainer.new();scroll.custom_minimum_size=Vector2(0,246);scroll.follow_focus=true;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;v.add_child(scroll)
 var grid=GridContainer.new();grid.columns=2;grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",8);scroll.add_child(grid)
 for entry in Data.stages:
  if entry.group!=stage_category and not (stage_category=="especiais" and entry.group=="extra"):continue
  var saved=Data.profile().stages.get(entry.id,{})
  var done=entry.id in Data.profile().completed_stages
  var caption=("✓ " if done else "")+entry.title+"\n"+str(saved.get("completed",[]).size())+" / "+str(entry.activities.size())+" descobertas"
  if speedrun_selected:
   var record=Data.speedrun_record(entry.id)
   caption=entry.title+"\n"+("Recorde: "+RunClock.format_time(int(record.best_ms)) if not record.is_empty() else "Sem recorde ainda")
  caption+="\n"+str(entry.scenery.title)
  var b=button(caption,func():
   Data.choose_stage(entry.id)
   if not speedrun_selected and Data.round_progress().finished:Data.reset_round()
   if mode=="sensor":show_sensor(false)
   else:start_game())
  b.add_theme_font_size_override("font_size",16);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(b)
 v.add_child(button("Voltar",func():show_pause() if from=="pause" else show_menu()))
 focus_first()

func show_settings(from: String):
 run_clock.pause()
 controls_return=from;screen="settings"
 var v=new_overlay("Do seu jeito", "Escolha uma ação para trocar sua tecla. Setas, Enter e Tab continuam disponíveis nos menus.")
 v.add_theme_constant_override("separation",5)
 var grid=GridContainer.new();grid.columns=2;grid.add_theme_constant_override("h_separation",14);grid.add_theme_constant_override("v_separation",7);v.add_child(grid)
 var titles={"move_left":"Andar para a esquerda","move_right":"Andar para a direita","jump":"Pular","power":"Poder 1","power_two":"Poder 2","repeat_instruction":"Ouvir novamente","help":"Pedir uma pista","pause":"Pausar"}
 for action in titles:
  var b=button(titles[action]+": "+Data.key_label(action),func():waiting_key=action;screen="remap";show_remap_message(action))
  b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(b)
 grid.add_child(button("Voz: "+("ligada" if Data.state.voice else "desligada"),func():Data.state.voice=not Data.state.voice;Data.save_progress();show_settings(from)))
 var volume_row=HBoxContainer.new();v.add_child(volume_row);volume_row.add_child(label("Volume da voz",16))
 var volume=HSlider.new();volume.min_value=0;volume.max_value=100;volume.step=5;volume.value=Data.state.get("voice_volume",85);volume.size_flags_horizontal=Control.SIZE_EXPAND_FILL;volume.custom_minimum_size.x=80;volume_row.add_child(volume)
 volume.value_changed.connect(func(value):Data.state.voice_volume=int(value);Data.save_progress())
 if voice_id.is_empty() and not test_mode:v.add_child(label("Voz em português indisponível neste Mac. As instruções escritas continuam ativas.",14))
 v.add_child(label("Controle: direcional para andar · A pular · X / B poderes · Y ouvir · RB pista · Start pausar",14))
 v.add_child(button("Restaurar teclas padrão",func():Data.state.keys={};Data.configure_input();Data.save_progress();show_settings(from)))
 v.add_child(button("Voltar",func():show_pause() if from=="pause" else show_menu(),true))
 for b in menu_buttons:
  b.custom_minimum_size.y=36;b.add_theme_font_size_override("font_size",16)
  for state_name in ["normal","hover","pressed","focus"]:
   var style=b.get_theme_stylebox(state_name).duplicate()
   style.content_margin_top=6;style.content_margin_bottom=6;b.add_theme_stylebox_override(state_name,style)
 focus_first()

func show_remap_message(action: String):
 var v=new_overlay("Pressione a nova tecla", "Ação: "+action+". Esc cancela. Uma tecla não pode executar duas ações.")
 v.add_child(button("Cancelar",func():waiting_key="";show_settings(controls_return)))
 focus_first()

func show_sensor(resuming: bool):
 run_clock.pause()
 if world!=null:world.set_active(false)
 mode="sensor";screen="sensor";sensor.activate()
 if is_instance_valid(menu):menu.queue_free();remove_child(menu)
 menu_buttons=[]
 var setup=load("res://scripts/sensor_setup.gd").new();setup.host=self;setup.resuming=resuming
 menu=setup;add_child(menu)
 _focus_control.call_deferred(menu_buttons[1])

func refresh_sensor_status():
 if is_instance_valid(menu) and menu.has_method("refresh"):menu.refresh()

func show_sensor_lost():
 run_clock.pause()
 if world!=null:world.set_active(false)
 screen="sensor_lost"
 var v=new_overlay("Vamos continuar?", "O dispositivo perdeu a conexão. Suas descobertas estão guardadas.")
 v.add_child(button("Continuar sem sensor",func():mode="buttons";sensor.deactivate();resume_game(),true))
 v.add_child(button("Conectar novamente",func():show_sensor(true)))
 focus_first()

func _process(delta):
 if screen=="playing":update_hud()
 if success_timer>0 and screen=="playing":
  success_timer=maxf(0,success_timer-delta)
  if is_instance_valid(success_banner):
   success_banner.modulate.a=minf(1,success_timer/0.45)
   success_banner.visible=success_timer>0
 if feedback_timer>0:
  feedback_timer-=delta
  if feedback_timer<=0 and is_instance_valid(feedback):feedback.text=""
 if screen=="playing" and not Data.last_save_error.is_empty() and is_instance_valid(feedback):
  feedback.text=Data.last_save_error+" Libere espaço antes de sair."

func _unhandled_input(event):
 if screen=="remap" and event is InputEventKey and event.pressed and not event.echo:
  if event.physical_keycode==KEY_ESCAPE:
   waiting_key="";show_settings(controls_return)
  elif Data.remap(waiting_key,event.physical_keycode):
   waiting_key="";show_settings(controls_return)
  else:
   var v=new_overlay("Escolha outra tecla", "Essa tecla está reservada ou já está em uso. Pressione outra tecla ou Esc para cancelar.")
   v.add_child(button("Cancelar",func():waiting_key="";show_settings(controls_return)))
   speak("Essa tecla já está em uso. Escolha outra.")
  get_viewport().set_input_as_handled();return
 if event.is_action_pressed("pause"):
  if screen=="playing":show_pause()
  elif screen=="pause":resume_game()
  get_viewport().set_input_as_handled()
 if screen=="playing" and event.is_action_pressed("repeat_instruction"):
  if active_activity>=0:speak(Data.activities[active_activity].spoken)
  else:speak("Ande com as setas e pule com o botão de salto.")
 if screen=="playing" and event.is_action_pressed("help") and active_activity>=0:
  helped=true;Data.round_progress().help_count+=1;toast(Data.activities[active_activity].hint,6)
 if event.is_action_pressed("ui_cancel"):
  if screen=="settings":show_pause() if controls_return=="pause" else show_menu()
  elif screen=="stages":show_pause() if stages_return=="pause" else show_menu()
  elif screen=="powers":resume_game() if powers_return=="pause" else show_menu()

func _pause_after_focus_loss():
 if is_inside_tree() and not is_queued_for_deletion() and screen=="playing" and is_instance_valid(world) and world.is_inside_tree():
  show_pause()

func _notification(what):
 if what==NOTIFICATION_APPLICATION_FOCUS_OUT and is_inside_tree() and screen=="playing":
  run_clock.pause()
  _pause_after_focus_loss.call_deferred()
 if what==NOTIFICATION_WM_CLOSE_REQUEST:
  Data.save_progress()
