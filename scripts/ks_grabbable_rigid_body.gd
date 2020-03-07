extends OQClass_GrabbableRigidBody

# makes rigid body grabbable
class_name KSGrabbableRigidBody

var grabbed_by : Node


func grab_init(node, grab_type: int):
	.grab_init(node, grab_type)
	grabbed_by = node


func grab_release():
	.grab_release()
	grabbed_by = null
