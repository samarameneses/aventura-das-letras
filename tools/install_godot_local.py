"""Fetch verified official editor in memory; keep only this Mac's arm64 executable."""
import io, json, hashlib, subprocess, zipfile, struct
def fetch(url):
 return subprocess.check_output(["curl","-L","--fail","--silent","--show-error","--retry","2",url])
from pathlib import Path
root=Path(__file__).resolve().parent/'runtime'
if not (root/'release.json').exists():
 raise SystemExit('Este utilitário requer metadados locais. Instale Godot 4.7.2 pelo site oficial e use tools/run_game.py.')
r=json.loads((root/'release.json').read_text())
name='Godot_v4.7.2-stable_macos.universal.zip'
url=next(a['browser_download_url'] for a in r['assets'] if a['name']==name)
sums=fetch(next(a['browser_download_url'] for a in r['assets'] if a['name']=='SHA512-SUMS.txt')).decode()
expected=next(line.split()[0] for line in sums.splitlines() if line.rstrip().endswith(name))
print('Baixando versão oficial verificada em memória...',flush=True)
data=fetch(url)
assert hashlib.sha512(data).hexdigest()==expected
with zipfile.ZipFile(io.BytesIO(data)) as z:
 raw=z.read('Godot.app/Contents/MacOS/Godot')
 magic,n=struct.unpack_from('>II',raw)
 assert magic==0xcafebabe
 for i in range(n):
  cpu,sub,offset,size,align=struct.unpack_from('>IIIII',raw,8+20*i)
  if cpu==0x100000c:
   dst=root/'Godot.app/Contents/MacOS/Godot';dst.parent.mkdir(parents=True,exist_ok=True)
   old=root/'godot'
   if old.exists():old.unlink()
   dst.write_bytes(raw[offset:offset+size]);dst.chmod(0o755)
   for member in z.infolist():
    if member.filename != 'Godot.app/Contents/MacOS/Godot' and member.filename.startswith('Godot.app/'):
     z.extract(member,root)
   print('Godot arm64 preparado:',size,'bytes',flush=True)
   break
 else:raise RuntimeError('arm64 não encontrado')
(root/'download-verification.json').write_text(json.dumps({'url':url,'version':r['tag_name'],'sha512':expected,'verified':True},indent=2))
