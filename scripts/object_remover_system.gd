extends Node

# handles logic to toggle remove mode
class_name ObjectRemoverSystem

signal remove_mode_toggled

func _ready():
	pass


func toggle_remove_mode():
	emit_signal("remove_mode_toggled")
