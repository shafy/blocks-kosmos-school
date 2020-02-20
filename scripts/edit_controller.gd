extends BaseController


class_name EditController


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
		if !(body is Resistor):
			return
		match current_tool:
			0:
				# voltmeter
				#body_label.set_label_text(str(body.current, " A"))
				pass
			1:
				# ammeter
				#body_label.set_label_text(str(body.current, " A"))
				pass
		break


#func select_tool(tool_index : int):
#	.select_tool(tool_index)
