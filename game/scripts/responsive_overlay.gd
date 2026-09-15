extends Control
var host
var title=""
var subtitle=""
var content: VBoxContainer
var panel: PanelContainer
var scroll: ScrollContainer
var original_columns: Dictionary={}
var settle_frames=0
var desired_size=Vector2.ZERO
var preferred_width=880.0
var preferred_height=0.0

func _ready():
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 if not is_instance_valid(host.play_surface) or not host.play_surface.visible:
  var bg=TextureRect.new();bg.texture=preload("res://art/primavera-pomar.png");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
  bg.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(bg)
 var shade=ColorRect.new();shade.color=Color(0.05,0.13,0.10,0.65);shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(shade)
 panel=PanelContainer.new();var style=host.box(host.CREAM,host.GREEN,3);style.set_corner_radius_all(2)
 style.content_margin_left=16;style.content_margin_right=16;panel.add_theme_stylebox_override("panel",style);add_child(panel)
 scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;scroll.follow_focus=true;panel.add_child(scroll)
 content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",10);scroll.add_child(content)
 var heading=host.label(title,30);heading.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;content.add_child(heading)
 var sub=host.label(subtitle,16);sub.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;content.add_child(sub)
 resized.connect(func():arrange.call_deferred())
 arrange.call_deferred()

func arrange():
 if not is_inside_tree() or is_queued_for_deletion():return
 var margin=clampf(minf(size.x,size.y)*0.045,10,30)
 var width=minf(preferred_width,size.x-margin*2)
 var height=minf(preferred_height,size.y-margin*2) if preferred_height>0 else size.y-margin*2
 panel.position=Vector2((size.x-width)/2,(size.y-height)/2)
 panel.size=Vector2(width,height)
 desired_size=Vector2(width,height);settle_frames=0
 var inner=width-42
 for grid in content.find_children("*","GridContainer",true,false):
  if not original_columns.has(grid):original_columns[grid]=grid.columns
  var original=int(original_columns[grid])
  grid.columns=(4 if inner>=760 else 2 if inner>=340 else 1) if original==4 else (2 if inner>=560 else 1)
  for child in grid.get_children():
   if child is Control:child.custom_minimum_size.x=0
 for flow in content.find_children("*","HFlowContainer",true,false):
  for child in flow.get_children():
   if child is Button:
    child.custom_minimum_size.x=(inner-10)/2 if flow.name=="PowerSlots" and inner>=550 else inner if flow.name=="PowerSlots" else minf(inner,maxf(100,child.text.length()*8+32))
 for node in content.find_children("*","Button",true,false):node.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 for node in content.find_children("*","Label",true,false):node.autowrap_mode=TextServer.AUTOWRAP_OFF if node.get_parent() is HBoxContainer else TextServer.AUTOWRAP_WORD_SMART
 for node in content.find_children("*","ScrollContainer",true,false):node.custom_minimum_size.x=0
 panel.reset_size();panel.size=Vector2(width,height)

func _process(_delta):
 if not is_visible_in_tree() or desired_size==Vector2.ZERO:return
 if panel.size.distance_to(desired_size)>0.1:panel.size=desired_size
 settle_frames+=1
 if settle_frames in [3,5]:
  var focused=get_viewport().gui_get_focus_owner()
  if is_instance_valid(focused) and is_ancestor_of(focused):scroll.ensure_control_visible(focused)
