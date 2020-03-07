extends Resistor

class_name Lamp

var bulb_material : Material
var power := 0.0
var max_emission := 1.0
var max_power := 30.0

onready var mesh_instance := $MeshInstance


func get_class():
	return "Lamp"


func _ready():
	if mesh_instance:
		# expecting bulb material at index 3
		#bulb_material_non_unique = mesh_instance.get_surface_material(3)
		# use duplicate() to make material unique and reassign later
		#bulb_material = mesh_instance.get_surface_material(3).duplicate()
#		bulb_material = mesh_instance.get_surface_material(3)
#		bulb_material.set_feature(SpatialMaterial.FEATURE_EMISSION, true)
#		bulb_material.set_emission_operator(SpatialMaterial.EMISSION_OP_ADD)
#		bulb_material.set_emission_energy(0.0)
		#mesh_instance.set_surface_material(3, bulb_material)
		pass


func refresh():
	update_power()
	set_emission()

# the power of the lamp in watts
func update_power():
	power = potential * current


func set_emission():
	if bulb_material:
		var current_emission = (power / max_power) * max_emission
		bulb_material.set_emission_energy(min(current_emission, max_emission))
