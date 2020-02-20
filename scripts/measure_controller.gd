extends BaseController


class_name MeasureController

var vm_first_click := false
var vm_second_click := false
var vm_first_pot := 0.0

onready var body_label = $BodyLabel
onready var title_label = $TitleLabel

func _ready():
	right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
	connect("tool_changed", self, "_on_Base_Controller_tool_changed")
	

func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a building block
	var bodies = grab_area_right.get_overlapping_bodies()
	for body in bodies:
		if !(body is Resistor):
			return
		match current_tool:
			0:
				# voltmeter
				handle_vm(body.potential)
				
			1:
				# ammeter
				body_label.set_label_text(str(body.current, " A"))
		break


func _on_Base_Controller_tool_changed():
	match current_tool:
		0:
			#voltmeter
			title_label.set_label_text("Voltmeter")
			body_label.set_label_text("Touch first Blöck and press Trigger")
		1:
			# ammeter
			title_label.set_label_text("Ammeter")
			body_label.set_label_text("Touch a Blöck and press Trigger")


func handle_vm(pot : float):
	# second click
	if vm_first_click and !vm_second_click:
		var pot_diff = vm_first_pot - pot
		body_label.set_label_text(str(pot_diff, " V"))
		vm_second_click = true
		vm_first_click = false
	else:
		vm_first_pot = pot
		vm_first_click = true
		vm_second_click = false
		body_label.set_label_text("Touch second Blöck and press Trigger")
