extends Node

# manages the logic for the PlacerSystem that shows bubbles where an item can be placed
class_name PlacerSystem

signal bubbles_shown
signal bubbles_hidden
signal bubbles_toggled


func _ready():
	pass


func toggle_bubbles(bubble_name: String):
	emit_signal("bubbles_toggled", bubble_name)
