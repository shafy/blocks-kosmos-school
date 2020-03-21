extends KSButtonPressable


# button used to start and stop challenges
class_name ButtonChallenge


enum ActionType {START, STOP}

export(ActionType) var action_type
export var challenge_index : int

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)


func _ready():
	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")


func _on_Challenge_System_challenge_completed(_challenge_index : int):
	# reset button to START if challenge completed
	if _challenge_index == challenge_index:
		action_type = ActionType.START


# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	if action_type == ActionType.START:
		challenge_system.start_challenge(challenge_index)
	else:
		challenge_system.stop_challenge(challenge_index)
	
	toggle_button_status()
	

func toggle_button_status():
	if action_type == ActionType.START:
		action_type = ActionType.STOP
	else:
		action_type = ActionType.START
