extends "res://tests/acceptance.gd"

func run():
 root.mode=Window.MODE_WINDOWED
 data=root.get_node("Data");data.save_path="res://../evidence/sensor-ui-progress.json";data.migration_source=""
 data.state.selected_profile="convidado";data.state.profiles.convidado=data.fresh_profile()
 main=load("res://scenes/main.tscn").instantiate();root.add_child(main);await frames(5)
 main.speedrun_selected=true;main.show_sensor(false);main.sensor.set_process(false)
 for dimensions in [Vector2i(320,568),Vector2i(390,844),Vector2i(640,360),Vector2i(960,540),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1080)]:
  root.size=dimensions;await frames(12)
  for state in ["waiting","calibrating","ready"]:
   main.sensor.is_ready=state=="ready";main.sensor.calibrating=state=="calibrating"
   main.refresh_sensor_status();await frames(10)
   var panel=main.menu.panel.get_global_rect()
   check(panel.position.x>=0 and panel.position.y>=0 and panel.end.x<=root.size.x+1 and panel.end.y<=root.size.y+1,str(dimensions)+state+": panel fits viewport")
   for b in main.menu_buttons:
    var rect=b.get_global_rect()
    check(rect.position.x>=0 and rect.position.y>=0 and rect.end.x<=root.size.x+1 and rect.end.y<=root.size.y+1,str(dimensions)+state+": button visible "+b.text)
   check(main.menu.ready_button.disabled==(state!="ready"),"sensor readiness controls primary action")
   check(main.menu.content.size.x<=main.menu.scroll.size.x+1,"instructions have no horizontal overflow")
   if state=="calibrating" and dimensions in [Vector2i(390,844),Vector2i(1920,1080),Vector2i(640,360)] and DisplayServer.get_name()!="headless":
    main.menu.scroll.scroll_vertical=0
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(ProjectSettings.globalize_path("res://../evidence/sensor-ui-"+str(dimensions.x)+".png"))
 main.sensor.is_ready=false;main.menu_buttons[1].pressed.emit();await frames(5)
 check(main.screen=="playing" and main.mode=="buttons","play without sensor starts game immediately")
 main.show_sensor(true);main.sensor.set_process(false);main.sensor.is_ready=true;main.refresh_sensor_status();main.menu_buttons[0].pressed.emit();await frames(4)
 check(main.screen=="playing" and main.mode=="sensor","ready sensor resumes game")
 print("SENSOR UI: ",passes.size()," passed; ",failures.size()," failed")
 main.queue_free();await frames(2);quit(0 if failures.is_empty() else 1)
