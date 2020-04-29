extends Spatial


# logic for challenge screen
class_name ChallengeScreen

var BODY_STANDARD_TEXT = "Build a circuit and reach the following objectives to complete this challenge:"
var SIGN_STANDARD_TEXT = "Choose a challenge"
var SIGN_SUCESS_TEXT = "Congratulations, move on to the next challenge..."

export var challenge_index : int

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)
onready var objectives = challenge_system.challenge_objectives(challenge_index)
onready var challenges_done = challenge_system.challenges_done
onready var title_label = $TitleLabel
onready var body_label = $BodyLabel
onready var description_label = $DescriptionLabel
onready var space_text = get_node(global_vars.SPACE_TEXT_PATH)
onready var space_label = space_text.get_node("SpaceLabel")
onready var space_label_title = space_text.get_node("SpaceLabelTitle")
onready var space_label_objectives = space_text.get_node("SpaceLabelObjectives")


func _ready():
	challenge_system.connect("objective_hit", self, "_on_Challenge_System_objective_hit")
	challenge_system.connect("objectives_resetted", self, "_on_Challenge_System_objectives_resetted")
	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")
	challenge_system.connect("challenge_started", self, "_on_Challenge_System_challenge_started")
	challenge_system.connect("challenge_stopped", self, "_on_Challenge_System_challenge_stopped")
	
	title_label.set_label_text(str("Challenge ", challenge_index + 1))
	body_label.set_label_text(BODY_STANDARD_TEXT)
	
	update_text()
	
	reset_visability()


func _on_Challenge_System_objective_hit(new_challenge_index, hit_objective_indices):
	if new_challenge_index != challenge_index:
		return
	
	update_text(hit_objective_indices)


func _on_Challenge_System_challenge_completed(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
	
	body_label.set_label_text("This Challenge is completed!")
	space_label.set_label_text(SIGN_SUCESS_TEXT)
	
	reset_visability()


func _on_Challenge_System_challenge_started(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
		
	var new_text = "**Challenge currently running**\n" + BODY_STANDARD_TEXT
	body_label.set_label_text(new_text)
	
	update_text()


func _on_Challenge_System_objectives_resetted(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
		
	update_text()


func _on_Challenge_System_challenge_stopped(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
	
	body_label.set_label_text(BODY_STANDARD_TEXT)
	space_label.set_label_text(SIGN_STANDARD_TEXT)
	
	reset_visability()


func update_text(hit_objective_indices : Array = []):
	# populate description label
	var new_text : String
	for i in range(objectives.size()):
		if hit_objective_indices.has(i):
			new_text += "[ X ] "
		else:
			new_text += "[   ] "
		
		new_text += objectives[i].description
		new_text += "\n"
		
	description_label.set_label_text(new_text)
	
	# write objectives of challenge also on screen, hide standard text label
	space_label.set_visible(false)
	
	space_label_objectives.set_label_text(new_text)
	space_label_objectives.set_visible(true)
	
	space_label_title.set_label_text(str("Challenge ", challenge_index + 1))	
	space_label_title.set_visible(true)


func reset_visability():
	space_label.set_visible(true)
	space_label_title.set_visible(false)
	space_label_objectives.set_visible(false)
