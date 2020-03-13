extends Spatial


class_name BaseController


signal controller_selected
signal controller_unselected

var select_default := false
var selected := false setget set_selected, get_selected

onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
onready var grab_area_right = get_node(global_vars.CONTR_RIGHT_PATH + "/controller_grab/GrabArea")


func set_selected(new_value):
	selected = new_value
	visible = new_value
	
	if new_value:
		emit_signal("controller_selected")
	else:
		emit_signal("controller_unselected")


func get_selected():
	return selected


func _ready():
	right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
	connect("controller_selected", self, "_on_Base_Controller_controller_selected")
	connect("controller_unselected", self, "_on_Base_Controller_controller_unselected")


# implement this in child
func _on_right_ARVRController_button_pressed(button_number):
	pass


# implement this in child
func _on_Base_Controller_controller_selected():
	pass


# implement this in child
func _on_Base_Controller_controller_unselected():
	pass

