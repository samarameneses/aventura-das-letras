#!/usr/bin/env python3
"""Read the local USB diagnostic without writing firmware or changing sensor wiring."""
import argparse,json,math,time
from pathlib import Path
import serial

parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--port',default='/dev/cu.usbserial-0001')
parser.add_argument('--seconds',type=float,default=12)
args=parser.parse_args()
events=[];samples=[]
with serial.Serial(args.port,115200,timeout=.3) as port:
    port.dtr=False;port.rts=False
    start=time.monotonic()
    while time.monotonic()-start<args.seconds:
        line=port.readline()
        try:p=json.loads(line)
        except (ValueError,UnicodeError):continue
        if not isinstance(p,dict):continue
        if p.get('event')=='sample':samples.append(p)
        else:events.append(p)
report={'port':args.port,'events':events,'sample_count':len(samples),'first_samples':samples[:3],'last_samples':samples[-3:]}
if samples:
    magnitudes=[math.sqrt(sum(v*v for v in p['a'])) for p in samples]
    report['acceleration_magnitude_g']={'min':min(magnitudes),'max':max(magnitudes),'mean':sum(magnitudes)/len(magnitudes)}
    report['valid_finite_samples']=all(all(math.isfinite(v) for v in p['a']+p['g']) for p in samples)
output=Path(__file__).resolve().parent.parent/'evidence/mpu-hardware-diagnostic.json'
output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
