extends BuildingBlockSnappable


class_name VoltageSource


var directional_polarity = SnapArea.Polarity.UNDEFINED
var current := 0.0
var superposition := {"connections": [], "direction": ""}

# in volts
export var potential := 0.0


func get_class():
	return "VoltageSource"

