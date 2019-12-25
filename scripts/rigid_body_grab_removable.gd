extends RigidBodyGrab

# adds an "remove" mode so that objects are deleted when grabbed
# to be used with GrabbableRemovableRigidBody
class_name RigidBodyGrabRemovable

var remove_mode := false


func _ready():
	var object_remover_system_node = get_node("/root/Main/ObjectRemoverSystem")
	object_remover_system_node.connect("remove_mode_toggled", self, "_on_Object_Remover_System_remove_mode_toggled")


func _on_Object_Remover_System_remove_mode_toggled():
	remove_mode = !remove_mode


# override from parent RigidBodyGrab
func start_grab_velocity(grabbable_rigid_body: GrabbableRigidBody):
	.start_grab_velocity(grabbable_rigid_body)
	if remove_mode:
		# we need to clear this, else there's a reference to the deleted/freed node
		held_object = null
