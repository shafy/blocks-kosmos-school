extends Node

# takes care of the logic for the different typess of controllers
class_name ControllerSystem

enum ControllerType {EDIT, MEASURE}
var controller_type = ControllerType.EDIT

var right_controller_models
var selected_controller

onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
onready var left_controller = get_node(global_vars.CONTR_LEFT_PATH)
onready var tablet = get_node(global_vars.TABLET_PATH)


func _ready():
	if right_controller:
		right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
		right_controller_models = right_controller.get_node("Feature_ControllerModel_Right")
		set_controller_type(controller_type)
	
	if left_controller:
		left_controller.connect("button_pressed", self, "_on_left_ARVRController_button_pressed")
		tablet.visible = false


func _on_right_ARVRController_button_pressed(button_number):
	# check for A button press
	if button_number != vr.CONTROLLER_BUTTON.XA:
		return
	
	roundrobin()


func _on_left_ARVRController_button_pressed(button_number):
	# check for A button press
	if button_number != vr.CONTROLLER_BUTTON.XA:
		return
	
	toggle_tablet()


# switches to the next controller type
func roundrobin() -> void:
	var new_ct = 0
	if controller_type + 1 < ControllerType.size():
		new_ct = controller_type + 1
	set_controller_type(new_ct)


func set_controller_type(new_ct : int) -> void:
	controller_type = new_ct
	# update mesh
	if right_controller_models:
		var all_children = right_controller_models.get_children()
		# hide all
		for child in all_children:
			child.set_selected(false)
		# show the new one. this assumes meshes are in the same order as the enum ControllerType
		selected_controller = right_controller_models.get_child(new_ct)
		selected_controller.set_selected(true)


func toggle_tablet():
	tablet.visible = !tablet.visible
