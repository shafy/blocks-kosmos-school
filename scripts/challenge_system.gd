extends Node


# logic for challenges
class_name ChallengeSystem


signal objective_hit
signal challenge_completed
signal challenge_started
signal challenge_stopped

var all_challenges
var current_challenge
var current_challenge_index = null

onready var measure_controller = get_node(global_vars.MEASURE_CONTR_PATH)
onready var tablet = get_node(global_vars.TABLET_PATH)
onready var all_blocks = get_node(global_vars.ALL_BUILDING_BLOCKS_PATH)
onready var all_measure_points = get_node(global_vars.ALL_MEASURE_POINTS_PATH)


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


func challenge_completed():
	emit_signal("challenge_completed", current_challenge_index)


func start_challenge(challenge_index : int):
	clear_table()
	current_challenge = all_challenges[challenge_index]
	current_challenge_index = challenge_index
	
	setup_tablet()
	emit_signal("challenge_started", current_challenge_index)


func stop_challenge(challenge_index : int):
	tablet.clear_tablet()
	emit_signal("challenge_stopped", current_challenge_index)
	current_challenge = null
	current_challenge_index = null


# returns challenge objectives
func challenge_objectives(challenge_index : int) -> Array:
	if all_challenges[challenge_index]:
		return all_challenges[challenge_index].get_objectives()
	
	return []


# puts correct number of blöcks on tablet for the current challenge
func setup_tablet():
	var current_setup = {
		"Lamps_5o": current_challenge.lamps_5o,
		"Lamps_10o": current_challenge.lamps_10o,
		"Batteries_3v": current_challenge.batteries_3v,
		"Batteries_9v": current_challenge.batteries_9v,
		"Switches": current_challenge.switches,
		"Wires": current_challenge.wires
	}
	tablet.create_setup(current_setup)


# deletes all building blocks that have been spawned
func clear_table():
	var all_blocks_children = all_blocks.get_children()
	for block in all_blocks_children:
		# we have to set null so that deleting them doesn't influence the mini count on the tablet
		block.tablet_pos_id = -1
		block.queue_free()
	
	# also clear measure points
	var all_measure_points_children = all_measure_points.get_children()
	for mp in all_measure_points_children:
		mp.queue_free()
