"""Inspect generated sheet alpha and store AtlasTexture regions; never modify PNGs."""
import json,sys,shutil
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parent.parent
job=json.loads((root/sys.argv[1]).read_text())
source=root/job['destination']
name=job['character']+'-'+job['action']+'.png'
out=root/'game/art'/name
if not out.exists():shutil.copy2(source,out)
im=Image.open(source)
assert 'A' in im.getbands(),'Sheet must have real alpha'
regions=[]
for n in range(job['count']):
 col=n%job['columns'];row=n//job['columns']
 x=round(col*im.width/job['columns']);y=round(row*im.height/job['rows'])
 x2=round((col+1)*im.width/job['columns']);y2=round((row+1)*im.height/job['rows'])
 # Bounding box inspection only. Cropping happens at runtime via AtlasTexture.
 alpha=im.getchannel('A').crop((x,y,x2,y2))
 bb=alpha.point(lambda a:255 if a>180 else 0).getbbox()
 assert bb is not None
 a,b,c,d=bb
 regions.append({'file':name,'x':x+a,'y':y+b,'w':c-a,'h':d-b})
p=root/'game/art/animations.json';meta=json.loads(p.read_text()) if p.exists() else {}
meta.setdefault(job['character'],{})[job['action']]=regions
p.write_text(json.dumps(meta,indent=2))
print(job['character'],job['action'],len(regions),'frames indexed; original image unchanged')
