extends Spatial


# takes care of logic for screens on tablet
class_name ScreensController


export var initial_screen : String

onready var all_screens = get_children()
onready var initial_screen_node = find_node(initial_screen)


func _ready():
	# only make initial screen visible to start
	if initial_screen:
		for screen in all_screens:
			screen.visible = false
		
		initial_screen_node.visible = true
		
