extends BuildingBlockWireable

class_name VoltageSource

# in volts
export var potential := 0.0

var superposition := {"connections": [], "direction": ""}
var connection_side: = ""

func _ready():
	pass
	
	
func get_class():
	return "VoltageSource"
