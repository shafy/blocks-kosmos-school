extends Node


# a single objective
class_name Objective


enum TargetType {AMPERE, VOLT}

var objective_hit := false setget set_objective_hit, get_objective_hit

export(String) var title
export(String, MULTILINE) var description
export(TargetType) var target_type
export(float) var target_value
export(String) var target_objects_by_class
export(String) var target_objects_by_name


func set_objective_hit(new_value):
	print("set_objective_hit ", new_value)
	objective_hit = new_value


func get_objective_hit():
	return objective_hit
