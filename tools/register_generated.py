"""Copy generated originals and record provenance; no image editing."""
import json, shutil, sys, hashlib
from pathlib import Path
from PIL import Image
root=Path(__file__).resolve().parent.parent
value=json.loads((root/sys.argv[1]).read_text());jobs=value if isinstance(value,list) else [value]
path=root/'assets/manifest.json';manifest=json.loads(path.read_text())
for job in jobs:
 dst=root/job['destination'];dst.parent.mkdir(parents=True,exist_ok=True)
 if not dst.exists():shutil.copy2(job['source'],dst)
 im=Image.open(dst)
 prompt='production/prompts/'+job['id']+'.txt';(root/prompt).write_text(job['prompt']+'\n')
 entry={**job,'prompt_file':prompt,'tool':'image_gen','model_requested':'ChatGPT Image 2.5','model_actual':'not_exposed_by_builtin_tool','active':True,'batch':'implementation','game_ready':False,'review':'visually_inspected_pending_runtime_review','width':im.width,'height':im.height,'alpha_channel':'A' in im.getbands(),'sha256':hashlib.sha256(dst.read_bytes()).hexdigest()}
 manifest=[x for x in manifest if x['id']!=job['id']]+[entry]
 if job['character']!='terrain':
  jpath=root/'production'/('job-'+job['id']+'.json');jpath.write_text(json.dumps(job))
  import subprocess
  subprocess.run([sys.executable,str(root/'tools/index_animation.py'),str(jpath.relative_to(root))],check=True)
 else:shutil.copy2(dst,root/'game/art/grass.png')
path.write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n')
