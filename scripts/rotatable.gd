extends Spatial


# makes parent rigid body (which needs to be a GrabbableRigidBody) rotatable only
class_name Rotatable


onready var parent_rb : GrabbableRigidBody = get_parent()
onready var initial_rotation := parent_rb.rotation_degrees

export var angular_axis_x_locked := false
export var angular_axis_y_locked := false
export var angular_axis_z_locked := false
export var max_rotation_x := 0.0
export var max_rotation_y := 0.0
export var max_rotation_z := 0.0

func _ready():
	 # lock all linear axis
	parent_rb.axis_lock_linear_x = true
	parent_rb.axis_lock_linear_y = true
	parent_rb.axis_lock_linear_z = true
	
	# update angular axis lock based on editor input
	parent_rb.axis_lock_angular_x = angular_axis_x_locked
	parent_rb.axis_lock_angular_y = angular_axis_y_locked
	parent_rb.axis_lock_angular_z = angular_axis_z_locked


func _process(delta):
	# check if we reach max rotation
	pass
