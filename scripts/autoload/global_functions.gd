extends Node
# grouping of commonly used functions

var vibration_timer := false
var vibration_timer_duration = 0.0
var vibration_timer_counter = 0.0

func _process(delta):
	if vibration_timer:
		vibration_timer_counter += delta
		
		if vibration_timer_counter > vibration_timer_duration:
			stop_all_vibration()
			vibration_timer = false
			vibration_timer_duration = 0.0
			vibration_timer_counter = 0.0


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


func vibrate_controller(intensity : float, controller : Node):
	if !controller or not controller is ARVRController:
		return
	
	controller.set_rumble(intensity)


func vibrate_controller_timed(intensity : float, controller : Node, duration : float):
	vibrate_controller(intensity, controller)
	vibration_timer = true
	vibration_timer_duration = duration
	

func stop_all_vibration():
	var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
	var left_controller = get_node(global_vars.CONTR_LEFT_PATH)
	
	if right_controller:
		right_controller.set_rumble(0)
	
	if left_controller:
		left_controller.set_rumble(0)
