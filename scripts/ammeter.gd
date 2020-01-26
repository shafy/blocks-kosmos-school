extends Resistor

# measaures and displays the current in a circuit
class_name Ammeter

onready var label = $OQ_UILabel


func _ready():
	refresh()


func refresh():
	label.set_label_text("%.2f A" % current)
