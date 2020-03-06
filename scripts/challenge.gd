extends Node


# a single challenge
class_name Challenge


# -1 means infinite
export var lamps := -1
export var batteries := -1
export var switches := -1
export var wires := -1

onready var objectives = get_children() setget , get_objectives


func get_objectives():
	return objectives


# checks if objective is hit, if yes, updates it and returns bool
func objective_hit(obj_target_value : float, obj_target_blocks : Array, obj_target_type : int) -> bool:
	var obj_hit = false
	for obj in objectives:
		if obj.target_type != obj_target_type:
			continue
		
		if stepify(obj.target_value, 0.1) != stepify(obj_target_value, 0.1):
			continue
		
		if !obj.target_objects_by_class.empty():
			# check if classes match. all need to match
			var all_matched = true
			for block in obj_target_blocks:
				if block.get_class() != obj.target_objects_by_class:
					all_matched = false
					break
			
			if !all_matched:
				continue
		
		if !obj.target_objects_by_name.empty():
			# check if names match. all need to match
			var all_matched = true
			for block in obj_target_blocks:
				if block.name != obj.target_objects_by_name:
					all_matched = false
					break
			
			if !all_matched:
				continue
		
		if obj.target_type == Objective.TargetType.VOLT and obj.number_of_blocks > 0:
			# if number of blocks defined, check this
			if obj_target_blocks.size() != obj.number_of_blocks:
				continue
			
		# set as true
		obj.set_objective_hit(true)
		obj_hit = true
	
	return obj_hit


func current_hit_objectives() -> Array:
	var return_array = []
	for i in range(objectives.size()):
		if objectives[i].get_objective_hit():
			return_array.append(i)
	
	return return_array


# returns true if all objectives are hit
#func all_objectives_hit():
#	var all_hit = true
#	for obj in objectives:
#		if !obj.get_objective_hit():
#			all_hit = false
#			break
#
#	return all_hit
