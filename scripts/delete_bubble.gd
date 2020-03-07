extends Spatial


class_name DeleteBubble


onready var parent_block = get_parent()


func start_remove():
	if parent_block:
		parent_block.queue_free()
