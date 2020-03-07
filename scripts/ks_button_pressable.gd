extends ButtonPressable


class_name KSButtonPressable


func button_press(other_area: Area):
	.button_press(other_area)
	
	# vibrate
	var current_controller = global_functions.controller_node_from_child(hand_area)
	global_functions.vibrate_controller_timed(0.3, current_controller, 0.2)
