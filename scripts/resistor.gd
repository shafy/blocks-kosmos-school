extends BuildingBlock

class_name Resistor

# in ohm
var resistance := 0.0
var superposition := {"connections": [], "direction": ""}

func _ready():
	pass

func get_class():
	return "Resistor"
