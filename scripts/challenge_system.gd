extends Node


# logic for challenges and hints
class_name ChallengeSystem


signal objective_hit
signal challenge_completed
signal challenge_started
signal challenge_stopped

var all_challenges
var current_challenge
var current_challenge_index = null
var confetti_particles

onready var ammeter_controller = get_node(global_vars.AMMETER_CONTR_PATH)
onready var voltmeter_controller = get_node(global_vars.VOLTMETER_CONTR_PATH)
onready var tablet = get_node(global_vars.TABLET_PATH)
onready var all_blocks = get_node(global_vars.ALL_BUILDING_BLOCKS_PATH)
onready var all_measure_points = get_node(global_vars.ALL_MEASURE_POINTS_PATH)
onready var schematic := get_node(global_vars.SCHEMATIC_PATH) 
onready var challenge_started_sound = $AudioStreamPlayer3DStarted
onready var objective_completed_sound = $AudioStreamPlayer3DObjective
onready var challenge_completed_sound = $AudioStreamPlayer3DCompleted
onready var main_node = get_node("/root/Main")


export(PackedScene) var confetti_particles_scene


func _ready():
	# connect signals
	ammeter_controller.connect("ampere_measured", self, "_on_Measure_Controller_ampere_measured")
	voltmeter_controller.connect("volt_measured", self, "_on_Measure_Controller_volt_measured")
	
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
	elif objective_completed_sound:
		objective_completed_sound.play()


func challenge_completed():
	current_challenge = null
	emit_signal("challenge_completed", current_challenge_index)
	if challenge_completed_sound:
		challenge_completed_sound.play()
	show_confetti()


func start_challenge(challenge_index : int):
	clear_table()
	schematic.clear_schematic()
	current_challenge = all_challenges[challenge_index]
	current_challenge_index = challenge_index
	current_challenge.reset_objectives()
	
	
	setup_tablet()
	emit_signal("challenge_started", current_challenge_index)
	if challenge_started_sound:
		challenge_started_sound.play()
	hide_confetti()
	


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


# returns challenge hints for current challenge
func challenge_hints():
	if current_challenge:
		return current_challenge.get_hints()
	
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


func show_confetti():
	if !confetti_particles_scene:
		return
	
	confetti_particles = confetti_particles_scene.instance()
	main_node.add_child(confetti_particles)
	confetti_particles.global_transform.origin = Vector3(0.16, 0.69, -0.5)
	var confetti_particles_children = confetti_particles.get_children()
	for cf in confetti_particles_children:
		if cf is CPUParticles:
			cf.set_emitting(true)


func hide_confetti():
	if !confetti_particles or !is_instance_valid(confetti_particles):
		return
	
	confetti_particles.queue_free()
	confetti_particles = null
	
