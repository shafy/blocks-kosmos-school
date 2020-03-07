extends Node


class_name WelcomeController


var welcome_text = "Welcome to Blöcks, friend.\nPress X to open your tablet."

onready var space_text = get_node(global_vars.SPACE_TEXT_PATH)
onready var left_controller = get_node(global_vars.CONTR_LEFT_PATH)

func _ready():
	display_welcome_text()
	left_controller.connect("button_pressed", self, "_on_left_ARVRController_button_pressed")


func _on_left_ARVRController_button_pressed(button_number):
	if button_number != vr.CONTROLLER_BUTTON.XA:
		return
	
	# if X button pressed, hide spacetext
	space_text.visible = false

func display_welcome_text():
	if !space_text:
		return
	
	var space_label = space_text.get_node("SpaceLabel")
	if !space_label:
		return
	
	space_label.set_label_text(welcome_text)
