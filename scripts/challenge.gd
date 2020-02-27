extends Node


# a single challenge
class_name Challenge

var objectives : Array

onready var measure_controller = get_node(global_vars.MEASURE_CONTR_PATH)


# define Objective as inner class. a Challenge has one or more Objectives.
class Objective:
	enum TargetType {AMPERE, VOLT}
	
	var title : String
	var description : String
	var target_type : int
	var target_value : float
	var target_objects_by_name : Array
	var target_object_by_class : Array


func _ready():
	# connect signals
	measure_controller.connect("ampere_measured", self, "_on_Measure_Controller_ampere_measured")
	measure_controller.connect("volt_measured", self, "_on_Measure_Controller_volt_measured")
	
	# example objective
	var objective = Objective.new()
	objective.title = "5 Ampere"
	objective.description = "Create a circuit with 5 Amperes of current"
	objective.target_type = Objective.TargetType.AMPERE
	objective.target_value = 5.0
	
	objectives.append(objective)


func _on_Measure_Controller_ampere_measured(measure_point):
	objective_hit(measure_point.get_current(), [measure_point.parent_block], Objective.TargetType.AMPERE)


func _on_Measure_Controller_volt_measured(volt, blocks_array):
	objective_hit(volt, blocks_array, Objective.TargetType.VOLT)


# checks if objective is hit, if yes, updates it
func objective_hit(obj_target_value : float, obj_target_blocks : Array, obj_target_type : int) -> void:
	for obj in objectives:
		if obj.target_type != obj_target_type:
			continue
		
		if obj.obj_target_value != obj_target_value:
			continue
		
		if !obj.target_object_by_class.empty():
			# check if classes match. all need to match
			pass
		
		if !obj.target_objects_by_name.empty():
			# check if names match. all need to match
			pass
		
		print("objective reached!")
