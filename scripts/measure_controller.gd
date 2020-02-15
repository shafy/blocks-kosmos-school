extends BaseController


class_name MeasureController

onready var body_label = $BodyLabel
onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
onready var grab_area_right = get_node(global_vars.CONTR_RIGHT_PATH + "/controller_grab/GrabArea")
onready var controller_system


func _ready():
	right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
	

func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a building block
	var bodies = grab_area_right.get_overlapping_bodies()
	for body in bodies:
		if body is Resistor:
			body_label.set_label_text(str(body.current, " A"))
			break
