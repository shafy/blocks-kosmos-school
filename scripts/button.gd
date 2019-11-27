extends Spatial

signal button_pressed

# Called when the node enters the scene tree for the first time.
func _ready():
	# connect to signal
	$ButtonArea.connect("area_entered", self, "_on_ButtonArea_area_entered")


func button_press():
	emit_signal("button_pressed")

func _on_ButtonArea_area_entered(area):
	print("button pressed in button.gd")
	button_press()
