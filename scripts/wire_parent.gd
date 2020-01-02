extends Spatial

class_name WireParent


signal wire_parent_removed

var connection_id : String
var being_removed := false
var wire_node_1 : Wireable
var wire_node_2 : Wireable

func _exit_tree():
	emit_signal("wire_parent_removed", connection_id)
