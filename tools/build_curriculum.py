"""Build explicit Portuguese learning content; no artwork is generated here."""
import json
from pathlib import Path

ROOT=Path(__file__).resolve().parent.parent
VOWELS='AEIOU'
LETTER_NAMES=['á','bê','cê','dê','é','éfe','gê','agá','i','jota','cá','éle','ême','êne','ó','pê','quê','érre','ésse','tê','u','vê','dáblio','xis','ípsilon','zê']
STAGES=[]

def add_stage(stage_id,title,group,items,note=''):
    activities=[]
    for i,item in enumerate(items):
        options=[item['target'],items[(i+1)%len(items)]['target']]
        if i%2:options.reverse()
        activities.append(dict(id=stage_id+'_'+str(i+1),options=options,x=400+i*420,**item))
    STAGES.append(dict(id=stage_id,title=title,group=group,note=note,length=400+(len(items)-1)*420+410,
                       checkpoint=1110 if len(items)>2 else 96,activities=activities))

def syllables(family,examples,spoken=None,group='familias',note=''):
    targets=[family+v for v in VOWELS] if isinstance(family,str) else family
    stage_id='silabas_'+(''.join(targets).lower() if not isinstance(family,str) else family.lower()).replace('ç','cedilha')
    items=[]
    for i,target in enumerate(targets):
        sound=(spoken or [family.lower()+v for v in ['á','ê','i','ô','u']])[i]
        example=examples[i]
        context=(' Como em '+example+'.') if example else ''
        items.append(dict(target=target,skill='syllable',instruction='Encontre '+target+'.',
                          spoken='Encontre '+sound+'.'+context,example=example,
                          hint='Olhe para a sílaba '+target+'.'+context))
    title='Família '+family if isinstance(family,str) else ' · '.join(targets)
    add_stage(stage_id,title,group,items,note)

alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
for index,start in enumerate(range(0,26,5)):
    letters=alphabet[start:start+5]
    # Final stage includes Y/Z rather than a single-letter stage with duplicate choices.
    if start==20:letters=alphabet[20:26]
    if start==25:break
    items=[dict(target=ch,skill='letter_name',instruction='Encontre a letra '+ch+'.',
                spoken='Encontre a letra '+LETTER_NAMES[alphabet.index(ch)]+'.',
                hint='Procure uma letra igual a esta: '+ch+'.',example='') for ch in letters]
    add_stage('alfabeto_'+str(index+1).zfill(2),'Alfabeto · '+letters[0]+' a '+letters[-1],'alfabeto',items)

families={
 'B':['bala','bebê','bico','bola','bule'],
 'C':['casa','cebola','cidade','copo','cubo'],
 'D':['dado','dedo','dia','dominó','ducha'],
 'F':['fada','festa','fita','foca','fubá'],
 'G':['gato','gelatina','girafa','gota','gula'],
 'J':['jacaré','jegue','jiló','jogo','juba'],
 'L':['lata','leão','livro','lobo','lua'],
 'M':['mala','mesa','mico','moto','muro'],
 'N':['navio','neve','ninho','novelo','nuvem'],
 'P':['pato','pera','pipa','pote','pulo'],
 'R':['rato','rede','rima','roda','rua'],
 'S':['sapo','selo','sino','sopa','suco'],
 'T':['tatu','telha','tigre','tomate','tucano'],
 'V':['vaca','vela','vida','vovó','vulcão'],
 'X':['xale','xerife','xícara','xodó','xucro'],
 'Z':['zabumba','zebra','zíper','zona','zulu'],
}
for family,examples in families.items():
    note='C e G mudam de som diante de E e I; ouvir a palavra de apoio.' if family in 'CG' else 'X tem outros sons em outras palavras; esta família usa o som de xale.' if family=='X' else ''
    syllables(family,examples,note=note)
syllables(['QUA','QUE','QUI','QUO'],['quase','queijo','quilo','quota'],['quá','quê','qui','quó'],'especiais','Q vem acompanhado de U. O U é ouvido em quase e quota; não em queijo e quilo. Não criar QA/QE/QI/QO/QU como família regular.')
syllables('H',['havia','herói','hipopótamo','hotel','humano'],['á','ê','i','ô','u'],'especiais','H inicial não tem som próprio; ouvir a vogal na palavra de apoio.')
syllables(['ÇA','ÇO','ÇU'],['caça','laço','açude'],['sá','sô','su'],'especiais','Ç não é uma letra extra do alfabeto e não ocorre antes de E ou I. As palavras de apoio mostram o uso no interior da palavra.')
syllables(['GUE','GUI'],['foguete','guitarra'],['guê','gui'],'especiais','O U não é pronunciado nestas palavras de apoio; outras palavras exigem contexto.')
syllables('CH',['chave','chegada','chinelo','chocolate','chuva'],['chá','chê','chi','chô','chu'],'digrafos')
syllables('LH',['lhama','lhe','colhi','molho','olhudo'],['lhá','lhê','lhi','lhô','lhu'],'digrafos')
syllables('NH',['unha','conhecer','companhia','nhoque',''],['nhá','nhê','nhi','nhô','nhu'],'digrafos','NHU é uma combinação rara, praticada sem inventar palavra de apoio. Revisão oral de um adulto é recomendada.')
clusters={
 'BL':['nublado','blefe','biblioteca','bloco','blusa'],
 'BR':['braço','breve','briga','broa','bruxa'],
 'CL':['claro','atleta','clima','cloro','clube'],
 'CR':['cravo','creme','criado','crocodilo','cru'],
 'DR':['dragão','drenagem','madrinha','dromedário','drupa'],
 'FL':['flamingo','flecha','conflito','floresta','flutuar'],
 'FR':['fraco','frevo','frito','fronha','fruta'],
 'GL':['glacial','gleba','glicose','globo','glutão'],
 'GR':['gravata','grego','grilo','grosso','grupo'],
 'PL':['placa','pleno','aplicativo','diploma','pluma'],
 'PR':['prato','prego','primo','prova','prumo'],
 'TR':['trator','trevo','trigo','troca','truque'],
}
clusters['CL'][1]='bicicleta'
for family,examples in clusters.items():syllables(family,examples,group='encontros')
add_stage('nomes_kwy','K, W e Y nos nomes','especiais',[
 dict(target=ch,skill='letter_context',instruction='Encontre '+ch+'.',spoken='Encontre a letra '+name+'. Como no nome '+word+'.',hint='Veja a letra '+ch+' no nome '+word+'.',example=word)
 for ch,name,word in [('K','cá','Kátia'),('W','dáblio','William'),('Y','ípsilon','Yuri')]
],'Letras presentes no alfabeto. Em nomes e palavras de outras origens a pronúncia depende do contexto; não gerar famílias regulares artificiais.')
legacy=json.loads((ROOT/'game/content/activities.json').read_text())
word_groups=[
 ('Natureza',['SOL','MAR','LUZ','SOM','COR']),
 ('Dia a dia',['PÉ','MÃO','PÃO','MEL','SAL']),
 ('Bichos e jardim',['BOI','CÃO','RÃ','LÃ','FLOR']),
 ('Descobertas',['CÉU','REI','PAI','MÃE','TREM']),
 ('Pequenas palavras',['CHÁ','PÓ','NÓ','PÁ','GIZ']),
 ('Mais conquistas',['PAZ','VOZ','GOL','BEM','SIM']),
]
for i,(title,words) in enumerate(word_groups):
    add_stage('palavras_'+str(i+1).zfill(2),'Palavras · '+title,'palavras',[
        dict(target=word,skill='monosyllable_word',instruction='Encontre a palavra '+word+'.',
             spoken='Encontre a palavra '+word.lower()+'.',example='',
             hint='Leia '+word+'. Falamos esta palavra em uma só sílaba.') for word in words
    ],'Palavras monossílabas: uma única sílaba falada, mantendo os acentos. Reconhecimento com apoio visual e narração.')
STAGES.append(dict(id='jardim_inicio',title='Jardim das primeiras descobertas',group='extra',note='Fase original preservada com o progresso anterior.',length=2240,checkpoint=1110,activities=legacy))
disyllables=json.loads((ROOT/'game/content/disyllables.json').read_text())
for i,group in enumerate(disyllables['groups']):
    items=[]
    for divided in group['words']:
        parts=divided.split('-')
        assert len(parts)==2 and all(parts),divided
        word=''.join(parts)
        items.append(dict(target=word,skill='disyllable_word',syllables=parts,
            instruction='Encontre a palavra '+word+'.',spoken='Encontre a palavra '+word.lower()+'.',example='',
            hint='Leia em duas partes: '+' · '.join(parts)+'. '+word+' tem duas sílabas.'))
    add_stage('dissilabas_'+str(i+1).zfill(2),'Dissílabas · '+group['title'],'dissilabas',items,
        'Palavras familiares ao cotidiano infantil com duas sílabas. Use a ajuda para ver a divisão silábica.')
# Four generated panoramic templates, with a stable, distinct composition for each stage.
# The appended words retain the same scenery even if the curriculum grows later.
themes=[('primavera-pomar','Primavera · Pomar florido','e9fff0'),
        ('outono-bosque','Outono · Bosque dourado','ffd6ac'),
        ('primavera-lago','Primavera · Lago das flores','eeedff'),
        ('outono-vale','Outono · Vale do pôr do sol','ffcab0')]
lights=['ffffff','fff5ea','f0faff','fff0f5','f6ffe9','f1f0ff']
places=[
 ['Pomar florido','Cerejeiras','Jardim das maçãs','Flores ao vento','Colinas verdes','Ponte das flores','Pétalas rosadas','Recanto verde','Trilha perfumada','Sol entre flores','Pomar encantado','Caminho das flores'],
 ['Bosque dourado','Folhas de cobre','Clareira âmbar','Cabaninha','Colinas de outono','Trilha das folhas','Árvores douradas','Refúgio do bosque','Luz dourada','Recanto de outono','Bosque acolhedor','Passeio dourado'],
 ['Lago das flores','Cachoeira','Margem florida','Espelho azul','Jardim lilás','Águas tranquilas','Flores na margem','Refúgio azul','Colinas do lago','Brisa no lago','Lago encantado','Passeio à beira-lago'],
 ['Vale do pôr do sol','Moinho distante','Campos dourados','Colinas de cobre','Árvores vermelhas','Horizonte coral','Vale tranquilo','Luz entre colinas','Trilha dos campos','Brisa de outono','Vale encantado','Fim de tarde'],
]
places[0]+=['Flores da manhã','Jardim da família','Trilha das maçãs','Pomar sereno','Cerejeiras ao sol','Brisa nas flores']
places[1]+=['Bosque dos brinquedos','Folhas ao vento','Caminho de cobre','Árvores ao sol','Clareira das cores','Passeio no bosque']
places[2]+=['Lago da manhã','Margem tranquila','Águas da primavera','Jardim da cachoeira','Colinas azuis','Recanto das flores']
places[3]+=['Vale das brincadeiras','Campos ao entardecer','Colinas douradas','Moinho ao sol','Caminho do vale','Campos de outono']
for i,stage in enumerate(STAGES):
    # Keep all 48 existing compositions, including the legacy garden, unchanged.
    # New stages begin with autumn after the final spring monosyllable stage.
    if stage['group']=='dissilabas':i+=1
    template,title,terrain=themes[i%len(themes)]
    variant=i//len(themes)
    stage['scenery']=dict(id=stage['id'],template=template,title=title.split(' · ')[0]+' · '+places[i%4][variant],
        view=round((variant%6)/5,2),mirror=(variant//6)%2==1,zoom=round(1.12+(variant%3)*0.06+(variant//12)*0.22,2),
        tint=lights[variant%6],terrain=terrain)
# The optional legacy stage stays outside the linear learning sequence.
STAGES.sort(key=lambda s:s['id']=='jardim_inicio')
result=dict(version=1,stages=STAGES,positive_feedback=[
 'Isso, você acertou!!!','Muito bem! Você conseguiu!','Uhu! Você encontrou!',
 'Boa descoberta! Vamos continuar!','Que legal! Mais uma conquista!',
 'Parabéns! Você está aprendendo!','Mandou bem! Vamos para a próxima!',
 'Isso mesmo! Continue explorando!'],sources=[
 'https://ceale.fae.ufmg.br/glossarioceale/verbetes/silaba',
 'https://ceale.fae.ufmg.br/glossarioceale/verbetes/metodo-silabico',
 'https://www.academia.org.br/artigos/novas-letras-k-w-e-y',
 'https://ceale.fae.ufmg.br/glossarioceale/verbetes/convencoes-da-escrita'])
(ROOT/'game/content/curriculum.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
print(len(STAGES),'stages;',sum(len(s['activities']) for s in STAGES),'activities')

if __name__=='__main__':
    ids=[a['id'] for s in STAGES for a in s['activities']]
    assert len(ids)==len(set(ids))
    assert ''.join(a['target'] for s in STAGES if s['group']=='alfabeto' for a in s['activities'])==alphabet
    words=[a for s in STAGES if s['group']=='dissilabas' for a in s['activities']]
    assert len(words)==100 and len({a['target'] for a in words})==100
    assert all(len(a['syllables'])==2 and ''.join(a['syllables'])==a['target'] for a in words)
    for s in STAGES:
        for a in s['activities']:
            assert len(set(a['options']))==2 and a['target'] in a['options']
