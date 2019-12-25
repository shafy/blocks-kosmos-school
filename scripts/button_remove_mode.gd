extends ButtonPressable


class_name ButtonRemoveMode


onready var object_remover_system_node = get_node("/root/Main/ObjectRemoverSystem")


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	# toggle remove_mdoe
	object_remover_system_node.toggle_remove_mode()
