extends BuildingBlock

class_name Wire


signal wire_segment_removed


func _exit_tree():
	print("get_parent() ", get_parent())
	emit_signal("wire_segment_removed", get_parent())
