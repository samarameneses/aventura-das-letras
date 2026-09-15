extends RefCounted
# Optional, bounded local diagnostic; never records pairing keys or player data.
static var initialized=false
static var started_ms=-1
static func record(kind: String, fields: Dictionary={}):
 if not OS.get_cmdline_user_args().has("--sensor-diagnostics"):return
 if started_ms<0:started_ms=Time.get_ticks_msec()
 var limit_ms=900000 if OS.get_cmdline_user_args().has("--sensor-latency-lab") else 180000
 if Time.get_ticks_msec()-started_ms>limit_ms:return
 var path="res://../firmware/local/game-motion-trace.jsonl"
 var f=FileAccess.open(path,FileAccess.READ_WRITE if initialized else FileAccess.WRITE_READ)
 if f==null:return
 initialized=true;f.seek_end()
 var row=fields.duplicate();row.kind=kind;row.wall_ms=Time.get_unix_time_from_system()*1000
 f.store_line(JSON.stringify(row));f.close()
