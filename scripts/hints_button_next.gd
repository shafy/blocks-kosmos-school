extends KSButtonPressable


class_name HintsButtonNext


onready var hint_screen = get_parent()


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	hint_screen.next_page()



