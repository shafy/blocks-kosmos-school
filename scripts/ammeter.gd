extends BuildingBlockSnappable

# measaures and displays the current in a circuit
class_name Ammeter


var current := 0.0
var superposition := {"connections": [], "direction": ""}

onready var label = $OQ_UILabel


func _ready():
	update_text()


func update_text():
	label.set_label_text("%.2f A" % current)
