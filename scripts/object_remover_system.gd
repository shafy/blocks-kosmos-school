extends Node

# handles logic to toggle remove mode
class_name ObjectRemoverSystem

signal remove_mode_toggled
signal remove_mode_disabled
signal remove_mode_enabled

onready var controller_system := get_node(global_vars.CONTROLLER_SYSTEM_PATH)


func _ready():
	controller_system.connect("controller_type_changed", self, "_on_Controller_System_controller_type_changed")


func _on_Controller_System_controller_type_changed():
	disable_remove_mode()


func toggle_remove_mode():
	emit_signal("remove_mode_toggled")


func disable_remove_mode():
	emit_signal("remove_mode_disabled")


func enable_remove_mode():
	emit_signal("remove_mode_enabled")
