extends ButtonPressable


# button used to navigate between screens on tablet
class_name ButtonScreenNav


export var navigate_to : String

onready var all_screens = get_node(global_vars.ALL_SCREENS_PATH)
onready var navigate_to_screen = all_screens.find_node(navigate_to)
# note that button must be direct child of screen
onready var this_screen = get_parent()


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	# navigate to screen if there's one
	if navigate_to_screen and this_screen:
		this_screen.visible = false
		navigate_to_screen.visible = true

