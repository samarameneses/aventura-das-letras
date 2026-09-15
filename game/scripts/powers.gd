extends RefCounted

const CATALOG=[
 {"id":"speed","name":"Supervelocidade","symbol":"»","duration":6.0,"recharge":10.0,"color":"ffbf49","description":"Corra mais rápido com um rastro dourado."},
 {"id":"double_jump","name":"Pulo duplo","symbol":"↑↑","duration":8.0,"recharge":8.0,"color":"a9e278","description":"Pule e ganhe outro salto no ar, usando o botão de salto ou este poder."},
 {"id":"wings","name":"Asas mágicas","symbol":"~","duration":6.0,"recharge":10.0,"color":"cfb5ff","description":"Abra as asas, salte e plane devagar por alguns segundos."},
 {"id":"magnet","name":"Ímã das letras","symbol":"U","duration":6.0,"recharge":12.0,"color":"ff91af","description":"Atraia a opção pedida quando estiver perto dela."},
 {"id":"bubble","name":"Bolha flutuante","symbol":"○","duration":6.0,"recharge":12.0,"color":"8fe5ed","description":"Flutue dentro de uma bolha para atravessar o vão."},
 {"id":"bridge","name":"Ponte de arco-íris","symbol":"∩","duration":8.0,"recharge":12.0,"color":"f5b1d9","description":"Crie uma ponte colorida sobre o vão."},
 {"id":"slow","name":"Tempo de tartaruga","symbol":"…","duration":8.0,"recharge":10.0,"color":"92cca0","description":"Corra mais devagar para observar as opções e escolher o salto."},
 {"id":"light","name":"Luz das descobertas","symbol":"✦","duration":8.0,"recharge":10.0,"color":"fff08a","description":"Ilumine a opção pedida e ouça sua pronúncia."}
]

static func get_power(id: String) -> Dictionary:
 for power in CATALOG:
  if power.id==id:return power
 return {}

static func valid_loadout(value) -> bool:
 return value is Array and value.size()==2 and value[0]!=value[1] and not get_power(str(value[0])).is_empty() and not get_power(str(value[1])).is_empty()
