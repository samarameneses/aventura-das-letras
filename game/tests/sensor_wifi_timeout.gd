extends SceneTree
var disconnected=false
func _initialize():run.call_deferred()
func run():
 var sensor=load("res://scripts/sensor.gd").new()
 root.add_child(sensor);sensor.set_process(false)
 sensor.udp=PacketPeerUDP.new();sensor.enabled=true;sensor.is_ready=true
 sensor.connection_lost.connect(func():disconnected=true)
 sensor.last_seen=Time.get_ticks_msec()-900
 sensor._process(0)
 var short_gap_ok=sensor.is_ready and not disconnected
 sensor.last_seen=Time.get_ticks_msec()-1300
 sensor._process(0)
 var long_gap_ok=disconnected and not sensor.is_ready
 var report={"passed":short_gap_ok and long_gap_ok,"brief_gap_preserves_ready":short_gap_ok,"long_gap_disconnects":long_gap_ok,"physical_sensor":false}
 var f=FileAccess.open("res://../evidence/sensor-wifi-timeout.json",FileAccess.WRITE)
 f.store_string(JSON.stringify(report,"  "));f.close()
 print(JSON.stringify(report));sensor.queue_free();await process_frame
 quit(0 if report.passed else 1)
