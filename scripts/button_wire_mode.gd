extends ButtonPressable


class_name ButtonWireMode


onready var placer_system_node = get_node("/root/Main/PlacerSystem")


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	# toggle WirePlug Bubbles
	placer_system_node.toggle_bubbles("WirePlugBubble")
