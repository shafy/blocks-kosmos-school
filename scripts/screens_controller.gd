extends Spatial


# takes care of logic for screens on tablet
class_name ScreensController


export var initial_screen : String

onready var all_screens = get_children()
onready var initial_screen_node = find_node(initial_screen)
onready var current_screen_name = initial_screen
onready var current_screen_node = initial_screen_node
onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)


func _ready():
	# only make initial screen visible to start
	if initial_screen:
		for screen in all_screens:
			screen.visible = false
		
		initial_screen_node.visible = true


func change_screen(new_screen_name : String):
	# if there's no current challenge going on, change to overview
	if new_screen_name == "ChallengesOverview" and challenge_system.current_challenge:
		# if there's a current challenge, change to that challenge
		change_to_challenge()
		return
		
	var new_screen_node = find_node(new_screen_name)
	if new_screen_node and current_screen_node:
		# hide old screen
		current_screen_node.visible = false
		
		# update current screen
		current_screen_name = new_screen_name
		current_screen_node = new_screen_node
		
		# show new screen
		current_screen_node.visible = true


func change_to_challenge():
	var current_challenge_index = challenge_system.current_challenge_index
	var current_challenge_screen_name = str("Challenge", current_challenge_index + 1)
	change_screen(current_challenge_screen_name)
