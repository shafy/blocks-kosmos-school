extends Area


# makes parent spatial rotatable only
class_name RotatableArea

var current_controller : ARVRController
var right_grab_button_pressed := false
var left_grab_button_pressed := false
var follow_controller := false

onready var right_controller := get_node("/root/Main/OQ_ARVROrigin/OQ_RightController")
onready var left_controller := get_node("/root/Main/OQ_ARVROrigin/OQ_LeftController")
onready var parent_spatial : Spatial = get_parent()
onready var initial_rotation := parent_spatial.rotation_degrees

export var angular_axis_x_locked := false
export var angular_axis_y_locked := false
export var angular_axis_z_locked := false
export var max_rotation_x := 0.0
export var max_rotation_y := 0.0
export var max_rotation_z := 0.0

func _ready():
	connect("area_entered", self, "_on_RotatableArea_area_entered")
	connect("area_exited", self, "_on_RotatableArea_area_exited")
	# connect to controller signals
	right_controller.connect("button_pressed", self, "_on_OQ_RightController_button_pressed")
	right_controller.connect("button_release", self, "_on_OQ_RightController_button_release")
	left_controller.connect("button_pressed", self, "_on_OQ_LeftController_button_pressed")
	left_controller.connect("button_release", self, "_on_OQ_LeftController_button_release")


func _process(delta):
	if !follow_controller and current_controller: 
		if current_controller.name == global_vars.CONTR_RIGHT_NAME and right_grab_button_pressed:
			follow_controller = true
		
		if current_controller.name == global_vars.CONTR_LEFT_NAME and left_grab_button_pressed:
			follow_controller = true
	
	
	if follow_controller:
		update_rotation()


func _on_RotatableArea_area_entered(area):
	# see if area is child of controller
	current_controller = global_functions.controller_node_from_child(area)


func _on_RotatableArea_area_exited(area):
	# reset
	if !right_grab_button_pressed or !left_grab_button_pressed:
		current_controller = null


func _on_OQ_RightController_button_pressed(button):
	if button == vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		right_grab_button_pressed = true


func _on_OQ_RightController_button_release(button):
	if button == vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		right_grab_button_pressed = false
		follow_controller = false

func _on_OQ_LeftController_button_pressed(button):
	if button == vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		left_grab_button_pressed = true


func _on_OQ_LeftController_button_release(button):
	if button == vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		left_grab_button_pressed = false
		follow_controller = false


func update_rotation():
	print("updating rotation")
