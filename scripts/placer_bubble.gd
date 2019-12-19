extends Spatial

# this bubble is shown when triggered from PlacerSystem (based on the name)
class_name PlacerBubble

var active := true

onready var bubble_mesh_node = $BubbleMesh

export var bubble_name : String 

func _ready():
	# get PlacerSystem node
	var placer_system_node = get_node("/root/Main/PlacerSystem")
	# connect to signals
	placer_system_node.connect("bubbles_shown", self, "_on_Placer_System_bubbles_shown")
	placer_system_node.connect("bubbles_hidden", self, "_on_Placer_System_bubbles_hidden")
	placer_system_node.connect("bubbles_toggled", self, "_on_Placer_System_bubbles_toggled")
	
	# hide per default
	hide_bubble()


func _on_Placer_System_bubbles_shown(requested_name: String):
	if requested_name == bubble_name:
		show_bubble()


func _on_Placer_System_bubbles_hidden(requested_name: String):
	if requested_name == bubble_name:
		hide_bubble()


func _on_Placer_System_bubbles_toggled(requested_name: String):
	if requested_name == bubble_name:
		toggle_bubble()


func show_bubble():
	if active:
		bubble_mesh_node.visible = true


func hide_bubble():
	if active:
		bubble_mesh_node.visible = false


func toggle_bubble():
	if active:
		bubble_mesh_node.visible = !bubble_mesh_node.visible

func set_active(_active: bool):
	vr.log_info("yoooo")
	active = _active
	
	if bubble_mesh_node.visible and !_active:
		bubble_mesh_node.visible = false
