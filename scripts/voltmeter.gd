extends Resistor

# measaures and displays volt in a circuit between two points
class_name Voltmeter


onready var label = $OQ_UILabel

func _ready():
	# an ideal voltmeter has infinite resistance
	resistance = 1000000000000.0
	refresh()


func refresh():
	print("update_text voltmeter ", potential)
	label.set_label_text("%.2f V" % potential)
