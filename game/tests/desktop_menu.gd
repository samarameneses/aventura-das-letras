extends "res://tests/acceptance.gd"
func run():
 data=root.get_node("Data");data.save_path="res://../evidence/desktop-menu-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(12)
 var usable=DisplayServer.screen_get_usable_rect(root.current_screen).size
 check(root.size.x>=usable.x*0.9 and root.size.y>=usable.y*0.9,"game opens occupying the available Mac screen")
 var primary=main.menu.actions[0]
 check(primary.size.y>70,"desktop primary button exceeds old size cap")
 check(main.menu.character_buttons[0].size.y>187,"desktop characters exceed old size cap")
 check(main.menu.board.custom_minimum_size.y<=root.size.y+1,"whole desktop menu fits without vertical scrolling")
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/v111-menu-desktop.png"))
 var f=FileAccess.open("res://../evidence/desktop-menu-tests.json",FileAccess.WRITE)
 f.store_string(JSON.stringify({"passed":failures.is_empty(),"passes":passes,"failures":failures,"window":str(root.size),"button_size":str(primary.size)},"  "));f.close()
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
