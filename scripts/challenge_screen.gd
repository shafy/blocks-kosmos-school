extends Spatial


# logic for challenge screen
class_name ChallengeScreen

var BODY_STANDARD_TEXT = "Build a circuit and reach the following objectives to complete this challenge:"

export var challenge_index : int

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)
onready var objectives = challenge_system.challenge_objectives(challenge_index)
onready var challenges_done = challenge_system.challenges_done
onready var title_label = $TitleLabel
onready var body_label = $BodyLabel
onready var description_label = $DescriptionLabel


func _ready():
	challenge_system.connect("objective_hit", self, "_on_Challenge_System_objective_hit")
	challenge_system.connect("objectives_resetted", self, "_on_Challenge_System_objectives_resetted")
	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")
	challenge_system.connect("challenge_started", self, "_on_Challenge_System_challenge_started")
	challenge_system.connect("challenge_stopped", self, "_on_Challenge_System_challenge_stopped")
	
	title_label.set_label_text(str("Challenge ", challenge_index + 1))
	
	text_for_done_challenges()


func _on_Challenge_System_objective_hit(new_challenge_index, hit_objective_indices):
	if new_challenge_index != challenge_index:
		return
	
	update_text(hit_objective_indices)


func _on_Challenge_System_challenge_completed(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
	
	body_label.set_label_text("This Challenge is completed!")


func _on_Challenge_System_challenge_started(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
		
	var new_text = "**Challenge currently running**\n" + BODY_STANDARD_TEXT
	body_label.set_label_text(new_text)
	
	# reset text
	update_text()


func _on_Challenge_System_objectives_resetted(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
		
	update_text()


func _on_Challenge_System_challenge_stopped(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
		
	text_for_done_challenges()


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


func text_for_done_challenges():
	if challenges_done[str("challenge_", challenge_index + 1)] == true:
		body_label.set_label_text("This Challenge is completed!")
		var new_text : String
		for i in range(objectives.size()):
			new_text += "[ X ] "
			new_text += objectives[i].description
			new_text += "\n"
		
		description_label.set_label_text(new_text)
	else:
		body_label.set_label_text(BODY_STANDARD_TEXT)
		update_text()
		
