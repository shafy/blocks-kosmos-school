extends BuildingBlockSnappable

class_name VoltageSource

var directional_polarity = SnapArea.Polarity.UNDEFINED

# in volts
export var potential := 0.0
var current := 0.0

var superposition := {"connections": [], "direction": ""}

func _ready():
	pass
	
	
func get_class():
	return "VoltageSource"
