extends Node


# logic for challenges
class_name ChallengeSystem


signal objective_hit
signal challenge_completed

var all_challenges
var current_challenge
var current_challenge_index : int

onready var measure_controller = get_node(global_vars.MEASURE_CONTR_PATH)


func _ready():
	# connect signals
	measure_controller.connect("ampere_measured", self, "_on_Measure_Controller_ampere_measured")
	measure_controller.connect("volt_measured", self, "_on_Measure_Controller_volt_measured")
	
	all_challenges = get_children()


func _on_Measure_Controller_ampere_measured(measure_point):
	if current_challenge:
		var obj_hit = current_challenge.objective_hit(measure_point.get_current(), [measure_point.parent_block], Objective.TargetType.AMPERE)
		
		if obj_hit:
			objective_hit_update()


func _on_Measure_Controller_volt_measured(volt, blocks_array):
	if current_challenge:
		var obj_hit = current_challenge.objective_hit(volt, blocks_array, Objective.TargetType.VOLT)
		
		if obj_hit:
			objective_hit_update()


func objective_hit_update():
	var current_hit_objectives = current_challenge.current_hit_objectives()
	emit_signal("objective_hit", current_challenge_index, current_challenge.current_hit_objectives())
	
	if current_hit_objectives.size() == current_challenge.get_objectives().size():
		challenge_completed()


# connected in button_challenge.gd
func _on_Button_Challenge_challenge_started(challenge_index : int):
	start_challenge(challenge_index)


# connected in button_challenge.gd
func _on_Button_Challenge_challenge_stopped(challenge_index : int):
	stop_challenge(challenge_index)


func challenge_completed():
	emit_signal("challenge_completed", current_challenge_index)


func start_challenge(challenge_index : int):
	current_challenge = all_challenges[challenge_index]
	current_challenge_index = challenge_index


func stop_challenge(challenge_index : int):
	current_challenge = null


# returns challenge objectives
func challenge_objectives(challenge_index : int) -> Array:
	if all_challenges[challenge_index]:
		return all_challenges[challenge_index].get_objectives()
	
	return []
