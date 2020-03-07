extends BaseController


class_name EditController


onready var block_lock_system = get_node(global_vars.BLOCK_LOCK_SYSTEM_PATH)
onready var object_remover_system = get_node(global_vars.OBJECT_REMOVER_SYSTEM_PATH)


func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a building block
	if current_tool == 1:
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

func _on_Base_Controller_tool_changed():
	if !selected:
		return
	
	match current_tool:
		0:
			# lock mode
			block_lock_system.toggle_lock()
			object_remover_system.disable_remove_mode()
		1:
			# remover
			object_remover_system.toggle_remove_mode()
			block_lock_system.update_blocks(false)
