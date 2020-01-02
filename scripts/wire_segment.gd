extends BuildingBlock

class_name WireSegment


signal wire_segment_removed


func _exit_tree():
	emit_signal("wire_segment_removed", get_parent())
