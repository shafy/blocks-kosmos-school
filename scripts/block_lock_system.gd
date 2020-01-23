extends Spatial


class_name BlockLockSystem


onready var all_building_blocks = get_node("/root/Main/AllBuildingBlocks")
onready var block_lock_button = get_node("/root/Main/Tablet/ButtonLockMode")


func _ready():
	pass


func _on_BuildingBlockSnappable_block_snapped_updated():
	# lock blocks after a block's snap status has been updated
	update_blocks(true)
	# make sure button is in on mode
	block_lock_button.button_turn_on()


func update_blocks(locked: bool):
	var new_mode = RigidBody.MODE_STATIC
	if !locked:
		new_mode = RigidBody.MODE_RIGID
	
	# loop through all building blocks and set new mode (if it's snapped)
	var all_building_blocks_children = all_building_blocks.get_children()
	for building_block in all_building_blocks_children:
		if building_block.get_snapped():
			building_block.set_mode(new_mode)
