"""Normalize runtime atlas scale using a neutral pose; no PNG editing."""
import json
from pathlib import Path
root=Path(__file__).resolve().parent.parent
path=root/'game/art/animations.json'
data=json.loads(path.read_text())
for character, actions in data.items():
    cycle=actions['jump_cycle']
    actions['jump']=cycle[:2];actions['fall']=cycle[2:4];actions['land']=cycle[4:]
    for action, frames in actions.items():
        reference=cycle[-1]['h'] if action in ('jump_cycle','jump','fall','land') else actions['celebrate'][0]['h'] if action=='celebrate' else max(f['h'] for f in frames)
        for frame in frames:
            frame['scale_reference_height']=reference
path.write_text(json.dumps(data,indent=2)+'\n')
