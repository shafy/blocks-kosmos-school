extends Node


class_name BlockLockSystem

var blocks_locked := true setget set_blocks_locked, get_blocks_locked

export(NodePath) onready var all_building_blocks = get_node(all_building_blocks)


func set_blocks_locked(new_value):
	blocks_locked = new_value


func get_blocks_locked():
	return blocks_locked


func _ready():
	pass


func _on_BuildingBlockSnappable_block_snapped_updated():
	# lock blocks after a block's snap status has been updated
	update_blocks(true)


func update_blocks(locked: bool):
	blocks_locked = locked
	var new_mode = RigidBody.MODE_STATIC
	if !locked:
		new_mode = RigidBody.MODE_RIGID
	
	# loop through all building blocks and set new mode (if it's snapped)
	var all_building_blocks_children = all_building_blocks.get_children()
	for building_block in all_building_blocks_children:
		if building_block.get_snapped():
			building_block.set_mode(new_mode)
			building_block.is_grabbable = !locked


func toggle_lock():
	update_blocks(!blocks_locked)
