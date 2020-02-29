extends ButtonPressable


# button used to start and stop challenges
class_name ButtonChallenge

signal challenge_started
signal challenge_stopped

enum ActionType {START, STOP}

export(ActionType) var action_type
export var challenge_index : int

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)


func _ready():
	connect("challenge_started", challenge_system, "_on_Button_Challenge_challenge_started")
	connect("challenge_stopped", challenge_system, "_on_Button_Challenge_challenge_stopped")

# overriding the parent function
func button_press(other_area: Area):
	.button_press(other_area)
	
	if action_type == ActionType.START:
		emit_signal("challenge_started", challenge_index)
	else:
		emit_signal("challenge_stopped", challenge_index)
	
	toggle_button_status()
	

func toggle_button_status():
	if action_type == ActionType.START:
		action_type = ActionType.STOP
	else:
		action_type = ActionType.START
