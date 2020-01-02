extends Spatial

class_name WireParent


signal wire_parent_removed

var connection_id : String
var being_removed := false
var wire_node_1 : Wireable
var wire_node_2 : Wireable

func _exit_tree():
	
	being_removed = true
	# check if already deleted first
	if is_instance_valid(wire_node_1):
		wire_node_1.set_wired(false)
	
	if is_instance_valid(wire_node_2):
		wire_node_2.set_wired(false)

	emit_signal("wire_parent_removed", connection_id)
