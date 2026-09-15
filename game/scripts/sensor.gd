extends Node

signal jump_requested
signal connection_lost
signal status_changed
const PORT=9250
# Match the receiver: measured Wi-Fi pauses reached 716 ms.
const TIMEOUT_MS=1200
var enabled=false
var is_ready=false
var udp: PacketPeerUDP
var last_seen=0
var last_sequence=-1
var last_event=-1
var session=""
var device=""
var challenge=""
var status="Sem sensor"
var last_jump=0
var received=0
var discarded=0
var calibration_start=0
var calibrating=false

func activate():
 deactivate()
 enabled=true
 challenge=Crypto.new().generate_random_bytes(12).hex_encode()
 udp=PacketPeerUDP.new()
 var err=udp.bind(PORT,"127.0.0.1")
 if err!=OK:
  status="A conexão está ocupada. Você pode jogar sem sensor."
 else:status="Aguardando o dispositivo…"
 status_changed.emit()

func deactivate():
 enabled=false
 is_ready=false
 calibrating=false
 session=""
 device=""
 last_sequence=-1
 last_event=-1
 last_seen=0
 if udp!=null:udp.close()
 udp=null
 status="Sem sensor"
 status_changed.emit()

func suspend():
 is_ready=false
 calibrating=false
 challenge=Crypto.new().generate_random_bytes(12).hex_encode()
 last_sequence=-1
 last_event=-1
 session=""
 last_seen=0
 if enabled:status="Calibre para continuar com sensor."
 status_changed.emit()

func _process(_delta):
 if not enabled or udp==null:return
 var budget=64
 while udp.get_available_packet_count()>0 and budget>0:
  budget-=1
  var bytes=udp.get_packet()
  var host=udp.get_packet_ip()
  var port=udp.get_packet_port()
  if bytes.size()>1024 or host!="127.0.0.1":
   discarded+=1
   continue
  var value=JSON.parse_string(bytes.get_string_from_utf8())
  if value is Dictionary and value.get("event","")=="hello":
   udp.set_dest_address(host,port)
   udp.put_packet(JSON.stringify({"event":"challenge","challenge":challenge,"protocol_version":1}).to_utf8_buffer())
   continue
  accept_packet(value,Time.get_ticks_msec())
 if (is_ready or calibrating) and Time.get_ticks_msec()-last_seen>TIMEOUT_MS:
  suspend()
  status="A conexão caiu. Continue pelos botões ou conecte novamente."
  connection_lost.emit()
  status_changed.emit()

func accept_packet(p, now: int) -> bool:
 if not enabled or not p is Dictionary:return false
 if p.get("protocol_version")!=1 or p.get("challenge","")!=challenge:return reject()
 # The local bridge timestamps packets using the computer's wall clock.
 # Clock leaps fail closed; the bridge/device clock is never compared directly.
 var age=Time.get_unix_time_from_system()*1000.0-float(p.get("sent_at_ms",0))
 if age< -50 or age>200:return reject()
 if not p.get("sequence") is float and not p.get("sequence") is int:return reject()
 var seq=int(p.sequence)
 if seq<=last_sequence:return reject()
 var event=str(p.get("event",""))
 if event not in ["calibration_start","heartbeat","ready","jump"]:return reject()
 var sid=str(p.get("session_id",""));var did=str(p.get("device_id",""))
 if sid.is_empty() or did.is_empty():return reject()
 if session.is_empty():
  if event!="calibration_start":return reject()
  session=sid;device=did;calibration_start=now;calibrating=true
 elif session!=sid or device!=did:return reject()
 last_sequence=seq
 last_seen=now
 received+=1
 if event=="calibration_start":
  calibrating=true;is_ready=false;calibration_start=now
  status="Calibrando. Mantenha o dispositivo parado…"
 elif event=="ready" and calibrating and now-calibration_start>=3000:
  if p.get("stable",false)!=true:return reject()
  is_ready=true;calibrating=false;status="Sensor pronto"
 elif event=="jump":
  var eid=int(p.get("event_id",-1))
  if not is_ready or eid<=last_event or now-last_jump<400:return reject()
  last_event=eid;last_jump=now;jump_requested.emit()
 status_changed.emit()
 return true

func reject() -> bool:
 discarded+=1
 return false
