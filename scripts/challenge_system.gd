extends Node


# logic for challenges
class_name ChallengeSystem

var all_challenges
var current_challenge

onready var measure_controller = get_node(global_vars.MEASURE_CONTR_PATH)


func _ready():
	# connect signals
	measure_controller.connect("ampere_measured", self, "_on_Measure_Controller_ampere_measured")
	measure_controller.connect("volt_measured", self, "_on_Measure_Controller_volt_measured")
	
	all_challenges = get_children()
	
	# just as an example
	current_challenge = all_challenges[0]


func _on_Measure_Controller_ampere_measured(measure_point):
	if current_challenge:
		current_challenge.objective_hit(measure_point.get_current(), [measure_point.parent_block], Objective.TargetType.AMPERE)
		if current_challenge.all_objectives_hit():
			challenge_completed()


func _on_Measure_Controller_volt_measured(volt, blocks_array):
	if current_challenge:
		current_challenge.objective_hit(volt, blocks_array, Objective.TargetType.VOLT)
		if current_challenge.all_objectives_hit():
			challenge_completed()


func challenge_completed():
	print("yayy, challenge is completed!")
