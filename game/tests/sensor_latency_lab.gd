extends Node
# Opt-in physical test. Uses the real detector, bridge and player on flat ground.
var sensor
var player
var status_label: Label
var metrics: Label
var commands=0
var jumps=0
var last_command_ms=0
var last_jump_ms=0
var last_wait_ms=0
var last_flight_ms=0
var was_floor=true
var next_state_ms=0
const Diagnostics=preload("res://scripts/sensor_diagnostics.gd")
var root: Window
func _ready():
 root=get_window()
 run.call_deferred()
func run():
 root.mode=Window.MODE_WINDOWED
 root.size=Vector2i(1100,650)
 root.position=Vector2i(40,40)
 root.content_scale_size=Vector2i(640,400)
 root.content_scale_mode=Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
 root.show()
 root.grab_focus()
 var scene=Node2D.new();root.add_child(scene)
 var bg=Polygon2D.new();bg.polygon=PackedVector2Array([Vector2.ZERO,Vector2(640,0),Vector2(640,400),Vector2(0,400)]);bg.color=Color("78bdca");scene.add_child(bg)
 var floor=StaticBody2D.new();floor.position=Vector2(320,335)
 var shape=CollisionShape2D.new();var rect=RectangleShape2D.new();rect.size=Vector2(2000,40);shape.shape=rect;floor.add_child(shape);scene.add_child(floor)
 var grass=Polygon2D.new();grass.polygon=PackedVector2Array([Vector2(0,315),Vector2(640,315),Vector2(640,400),Vector2(0,400)]);grass.color=Color("356d58");scene.add_child(grass)
 player=load("res://scripts/player.gd").new();player.position=Vector2(320,315);scene.add_child(player)
 player.fall_gravity_multiplier=2.0
 player.jump_time_scale=1.5
 player.set_physics_process(false)
 sensor=load("res://scripts/sensor.gd").new();scene.add_child(sensor)
 var ui=CanvasLayer.new();scene.add_child(ui)
 var box=VBoxContainer.new();box.position=Vector2(28,22);box.size=Vector2(584,200);box.add_theme_constant_override("separation",10);ui.add_child(box)
 var title=Label.new();title.text="TESTE DE RESPOSTA DO SENSOR";title.add_theme_font_size_override("font_size",24);box.add_child(title)
 status_label=Label.new();status_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;box.add_child(status_label)
 metrics=Label.new();metrics.add_theme_font_size_override("font_size",18);box.add_child(metrics)
 var note=Label.new();note.text="Teste: salto de aproximadamente 400 ms, mantendo a altura.\nSensor: rotação até 450°/s. Registro de até 15 minutos.";note.add_theme_font_size_override("font_size",14);box.add_child(note)
 var reconnect=Button.new();reconnect.text="Reconectar e calibrar";reconnect.pressed.connect(func():sensor.activate());box.add_child(reconnect)
 sensor.status_changed.connect(func():
  status_label.text="PRONTO — suba e desça a placa para testar." if sensor.is_ready else sensor.status+"\nDeixe a placa parada por três segundos.")
 sensor.jump_requested.connect(func():
  commands+=1;last_command_ms=Time.get_ticks_msec()
  Diagnostics.record("received",{"event_id":sensor.last_event,"screen":"latency_lab"})
  player.sensor_jump=true)
 player.jumped.connect(func():
  jumps+=1;last_jump_ms=Time.get_ticks_msec();last_wait_ms=last_jump_ms-last_command_ms)
 sensor.activate()
 get_tree().physics_frame.connect(update_lab)
func update_lab():
 if not is_instance_valid(player):return
 # Keep the real vertical physics; discard walking and power input in this lab.
 player._physics_process(1.0/Engine.physics_ticks_per_second)
 player.position.x=320;player.velocity.x=0
 player.effects.clear();player.power_seconds=0;player.extra_jump=false
 if not was_floor and player.is_on_floor() and last_jump_ms>0:
  last_flight_ms=Time.get_ticks_msec()-last_jump_ms
 was_floor=player.is_on_floor()
 metrics.text="Comandos recebidos: %d    Saltos executados: %d\nEspera no jogo: %d ms    Último salto no ar: %d ms" % [commands,jumps,last_wait_ms,last_flight_ms]
 if Time.get_ticks_msec()>next_state_ms:
  next_state_ms=Time.get_ticks_msec()+1000
  var f=FileAccess.open("res://../evidence/sensor-latency-live.json",FileAccess.WRITE)
  f.store_string(JSON.stringify({"wall_ms":Time.get_unix_time_from_system()*1000,"status":sensor.status,"ready":sensor.is_ready,"received_packets":sensor.received,"commands":commands,"jumps":jumps,"last_wait_ms":last_wait_ms,"last_flight_ms":last_flight_ms,"window_visible":root.visible,"window_position":str(root.position),"window_size":str(root.size),"window_focused":root.has_focus()}));f.close()
