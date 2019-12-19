extends ButtonGeneral


class_name ButtonWireMode


onready var placer_system_node = get_node("/root/Main/PlacerSystem")

func _ready():
	pass

# overriding the parent function
func button_press():
	.button_press()
	# toggle WirePlug Bubbles
	placer_system_node.toggle_bubbles("WirePlugBubble")
