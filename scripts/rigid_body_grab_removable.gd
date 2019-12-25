extends RigidBodyGrab

# adds an "remove" mode so that objects are deleted when grabbed
# to be used with GrabbableRemovableRigidBody
class_name RigidBodyGrabRemovable

var remove_mode := true

# override from parent RigidBodyGrab
func start_grab_velocity(grabbable_rigid_body: GrabbableRigidBody):
	.start_grab_velocity(grabbable_rigid_body)
	if remove_mode:
		# we need to clear this, else there's a reference to the deleted/freed node
		held_object = null
