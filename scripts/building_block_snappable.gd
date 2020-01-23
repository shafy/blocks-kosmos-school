extends BuildingBlock


# this building block can snap!
class_name BuildingBlockSnappable


signal block_snapped_updated

var moving_to_snap := false setget set_moving_to_snap, get_moving_to_snap
var snapped := false setget , get_snapped

onready var block_lock_system = get_node("/root/Main/BlockLockSystem")

# setter and getter functions
func set_moving_to_snap(new_value):
	moving_to_snap = new_value


func get_moving_to_snap():
	return moving_to_snap


func get_snapped():
	return snapped


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "BuildingBlockSnappable" or .is_class(type)


func _ready():
	connect_to_snap_area_signals()
	connect("block_snapped_updated", block_lock_system, "_on_BuildingBlockSnappable_block_snapped_updated")

func _on_SnapArea_area_snapped():
	snapped = true
	emit_signal("block_snapped_updated")


func _on_SnapArea_area_unsnapped():
	# only update status if all areas are unsnapped
	var snapped_status = false
	var all_children = get_children()
	
	for child in all_children:
		if child is SnapArea:
			if child.get_snapped():
				snapped_status = true
				break
	
	snapped = snapped_status
	emit_signal("block_snapped_updated")

func connect_to_snap_area_signals():
	var all_children = get_children()
	
	for child in all_children:
		if child is SnapArea:
			child.connect("area_snapped", self, "_on_SnapArea_area_snapped")
			child.connect("area_unsnapped", self, "_on_SnapArea_area_unsnapped")
