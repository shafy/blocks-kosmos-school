extends Area
# allows the object to be connected to by a wire

signal wire_tapped

var parent_building_block

export(String) var polarity

func _ready():
	parent_building_block = get_parent()
	if !(parent_building_block is BuildingBlock):
		print("Parent node was expected to be of type BuildingBlock, but isn't.")
	
	
	connect("area_entered", self, "_on_Wirable_area_entered")
	var wire_generator = get_node("/root/Main/WireGenerator")
	connect("wire_tapped", wire_generator, "_on_Wirable_wire_tapped")

func _on_Wirable_area_entered(area):
	if !(parent_building_block is BuildingBlock) or parent_building_block.is_mini:
		return
	
	# check if it's a left or right controller
	var area_parent = area.get_parent()
	if (area_parent):
		var area_parent_parent = area_parent.get_parent()
		if (area_parent_parent):
			if (area_parent_parent.name == "OQ_LeftController" or area_parent_parent.name == "OQ_RightController"):
				emit_signal("wire_tapped", global_transform.origin, parent_building_block, polarity)
