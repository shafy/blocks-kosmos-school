extends Spatial

signal button_pressed


func _ready():
	# connect to signal
	$ButtonArea.connect("area_entered", self, "_on_ButtonArea_area_entered")


func button_press():
	emit_signal("button_pressed")

func _on_ButtonArea_area_entered(area):
	button_press()
