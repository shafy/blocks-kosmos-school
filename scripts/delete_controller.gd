extends BaseController


class_name DeleteController


onready var object_remover_system = get_node(global_vars.OBJECT_REMOVER_SYSTEM_PATH)


func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a DeleteBubble
	var areas = grab_area_right.get_overlapping_areas()
	for area in areas:
		var area_parent = area.get_parent()
		
		if !area_parent:
			continue
			
		if !(area_parent is DeleteBubble):
			continue
		# delete
		area_parent.start_remove()
		break


# override parent
func _on_Base_Controller_controller_selected():
	._on_Base_Controller_controller_selected()
	object_remover_system.enable_remove_mode()


# override parent
func _on_Base_Controller_controller_unselected():
	._on_Base_Controller_controller_unselected()
	object_remover_system.disable_remove_mode()
