extends Area


# allows the object to be connected to by a wire
class_name Wireable


signal wire_tapped

var parent_building_block
var is_wired := false

export(String) var polarity
export(Array, NodePath) var placer_bubble_node_paths
export(Array, NodePath) var connection_bubble_node_paths

func _ready():
	parent_building_block = get_parent()
	if !(parent_building_block is BuildingBlockWireable):
		print("Parent node was expected to be of type BuildingBlockWireable, but isn't.")
	
	# add itself to parent to let parent know that it exists
	parent_building_block.add_wireable(self)
	
	connect("area_entered", self, "_on_Wirable_area_entered")
	var wire_generator = get_node("/root/Main/WireGenerator")
	connect("wire_tapped", wire_generator, "_on_Wirable_wire_tapped")
	
	# don't show per default
	show_connection_bubbles(false)
	

func _on_Wirable_area_entered(area):
	
	if !(parent_building_block is BuildingBlockWireable):
		return
	
	# don't add wire if already wired
	if is_wired:
		return
	
	# check if it's a left or right controller
	var area_parent = area.get_parent()
	if (area_parent):
		var area_parent_parent = area_parent.get_parent()
		if (area_parent_parent):
			if (area_parent_parent.name == "OQ_LeftController" or area_parent_parent.name == "OQ_RightController"):
				emit_signal("wire_tapped", self, parent_building_block, area, polarity)


func set_wired(_wired):
	is_wired = _wired
	
	parent_building_block.refresh_wireables()
	
	# also activate or deactivate placer bubbles
	for bubble_path in placer_bubble_node_paths:
		var temp_node = get_node(bubble_path)
		temp_node.set_active(!_wired)


func show_connection_bubbles(_show):
	for bubble_path in connection_bubble_node_paths:
		var temp_node = get_node(bubble_path)
		temp_node.visible = _show
