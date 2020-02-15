extends Spatial


class_name BaseController

var selected := false setget set_selected, get_selected

func _ready():
	pass


func set_selected(new_value):
	selected = new_value
	visible = new_value

func get_selected():
	return selected
