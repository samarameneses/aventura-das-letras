extends RefCounted

var running=false
var finished=false
var accumulated_us=0
var started_us=0

func reset():
 running=false;finished=false;accumulated_us=0;started_us=0

func resume(now_us: int=-1):
 if running or finished:return
 started_us=Time.get_ticks_usec() if now_us<0 else now_us
 running=true

func pause(now_us: int=-1):
 if not running:return
 var now=Time.get_ticks_usec() if now_us<0 else now_us
 accumulated_us+=maxi(0,now-started_us);running=false

func elapsed_ms(now_us: int=-1) -> int:
 var now=Time.get_ticks_usec() if now_us<0 else now_us
 var total=accumulated_us+(maxi(0,now-started_us) if running else 0)
 return int(total/1000)

func stop(now_us: int=-1) -> int:
 pause(now_us);finished=true
 return elapsed_ms(now_us)

static func format_time(milliseconds: int) -> String:
 var hundredths=int(maxi(0,milliseconds)/10)
 return "%02d:%02d.%02d" % [int(hundredths/6000),int(hundredths/100)%60,hundredths%100]
