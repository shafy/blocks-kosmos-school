extends Spatial


# logic for challenge screen
class_name ChallengeScreen


export var challenge_index : int

onready var challenge_system = get_node(global_vars.CHALLENGE_SYSTEM_PATH)
onready var objectives = challenge_system.challenge_objectives(challenge_index)
onready var title_label = $TitleLabel
onready var body_label = $BodyLabel
onready var description_label = $DescriptionLabel


func _ready():
	challenge_system.connect("objective_hit", self, "_on_Challenge_System_objective_hit")
	challenge_system.connect("challenge_completed", self, "_on_Challenge_System_challenge_completed")
	
	title_label.set_label_text(str("Challenge ", challenge_index + 1))
	update_text()


func _on_Challenge_System_objective_hit(new_challenge_index, hit_objective_indices):
	if new_challenge_index != challenge_index:
		return
	
	update_text(hit_objective_indices)


func _on_Challenge_System_challenge_completed(new_challenge_index):
	if new_challenge_index != challenge_index:
		return
	
	body_label.set_label_text("This Challenge is completed!")


func update_text(hit_objective_indices : Array = []):
	# populate description label
	var new_text : String
	for i in range(objectives.size()):
		if hit_objective_indices.has(i):
			new_text += "[s]"
		
		new_text += objectives[i].description
		
		if hit_objective_indices.has(i):
			new_text += "[/s]"
		
		new_text += "\n"
	
	description_label.set_label_text(new_text)
