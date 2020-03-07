extends KSButtonPressable


# button used to navigate between screens on tablet
class_name ButtonScreenNav


export var navigate_to : String

onready var screens_controller = get_node(global_vars.ALL_SCREENS_PATH)

# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	screens_controller.change_screen(navigate_to)
	

