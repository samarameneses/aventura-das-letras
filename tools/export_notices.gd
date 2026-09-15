extends SceneTree
func _initialize():
 var file=FileAccess.open("res://../release/LICENCAS.txt",FileAccess.WRITE)
 file.store_string("GODOT ENGINE\n\n"+Engine.get_license_text()+"\n\nTHIRD PARTY COMPONENTS\n\n")
 for name in Engine.get_license_info():file.store_string(name+"\n"+Engine.get_license_info()[name]+"\n\n")
 for info in Engine.get_copyright_info():file.store_string(JSON.stringify(info,"  ")+"\n")
 file.close();quit()
