extends ButtonPressable


class_name KSButtonPressable


onready var button_click_sound = $AudioStreamPlayer3DClick


func button_press(other_area: Area):
	.button_press(other_area)
	
	# vibrate
	var current_controller = global_functions.controller_node_from_child(hand_area)
	global_functions.vibrate_controller_timed(0.3, current_controller, 0.2)
	
	# play sound on press
	if button_click_sound:
		button_click_sound.play()
