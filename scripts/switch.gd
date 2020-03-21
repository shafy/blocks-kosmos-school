extends Resistor


class_name Switch

var is_closed := true

onready var rotatable_handle = $RotatableHandle
onready var schematic = get_node("/root/Main/Schematic")

func _process(delta):
	if rotatable_handle:
		var rot_x = rotatable_handle.rotation_degrees.x
		if rot_x > 12.0 and is_closed:
			is_closed = false
			# TODO: case for when there are more than 1 circuits
			if get_snapped():
				schematic.loop_current_method()
		elif rot_x <= 12.0 and !is_closed:
			is_closed = true
			if get_snapped():
				schematic.loop_current_method()
