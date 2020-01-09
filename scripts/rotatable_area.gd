extends Area


# makes parent spatial rotatable only
class_name RotatableArea

var current_controller : ARVRController
var current_area : Area
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
export var angular_axis_x_limited := false
export var max_rotation_x_upper := 90.0
export var max_rotation_x_lower := 0.0
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
	current_area = area


func _on_RotatableArea_area_exited(area):
	# reset
	current_controller = null
	follow_controller = false
	current_area = null


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
	# TODO: if > 90 x axis rotation allowed, object flips at 90 degrees. implement better solution
	if !current_area:
		return 
	
	parent_spatial.look_at(current_area.global_transform.origin, Vector3(0, 1, 0) )
	
	# axis locks
	if angular_axis_x_locked:
		parent_spatial.rotation_degrees = Vector3(initial_rotation.x, parent_spatial.rotation_degrees.y, parent_spatial.rotation_degrees.z)
	if angular_axis_y_locked:
		parent_spatial.rotation_degrees = Vector3(parent_spatial.rotation_degrees.x, initial_rotation.y, parent_spatial.rotation_degrees.z)
	if angular_axis_z_locked:
		parent_spatial.rotation_degrees = Vector3(parent_spatial.rotation_degrees.x, parent_spatial.rotation_degrees.y, initial_rotation.z)
	
	# axis limits
	if angular_axis_x_limited:
		var rot_diff = parent_spatial.rotation_degrees.x - initial_rotation.x
		var new_angle = clamp(rot_diff, max_rotation_x_lower, max_rotation_x_upper)
		parent_spatial.rotation_degrees = Vector3(new_angle, parent_spatial.rotation_degrees.y, parent_spatial.rotation_degrees.z)
