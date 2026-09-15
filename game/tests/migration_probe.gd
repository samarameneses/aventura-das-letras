extends SceneTree
func _initialize():run.call_deferred()
func run():
 var data=root.get_node("Data")
 var p={"character":3,"checkpoint":1110,"completed":["letra_a","letra_m"],"attempts":[],"finished":false,"help_count":1,"power_collected":true,"power_available":true,"session":2}
 var v={"version":1,"selected_profile":"joao","profiles":{"joao":p},"keys":{},"voice":false}
 var decoded=JSON.parse_string(JSON.stringify(v))
 print("integer membership ",1 in [1,2]," float membership ",1.0 in [1,2])
 print("literal valid ",data.valid_state(v)," decoded valid ",data.valid_state(decoded)," round ",data.valid_round(decoded.profiles.joao,"jardim_inicio"))
 print("version type ",typeof(decoded.version)," numeric ",data.numeric(decoded.version))
 quit()
