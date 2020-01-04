extends Node

# grouping of commonly used functions


# travels upwards and returns controller node if it hits one, else it returns null
func controller_node_from_child(starting_node : Node):
	var current_node = starting_node
	while current_node.name != "root":
		current_node = current_node.get_parent()
		if current_node:
			if current_node.name == global_vars.CONTR_LEFT_NAME or current_node.name == global_vars.CONTR_RIGHT_NAME:
				return current_node
		else:
			return null
	
	return null
