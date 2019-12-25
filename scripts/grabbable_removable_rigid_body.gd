extends GrabbableRigidBody

# adds a "remove" mode to GrabbableRigidBody
# to be used together with ObjectRemoveSystem
class_name GrabbableRemovableRigidBody

var remove_mode := false

export var is_removable := true

func _ready():
	var object_remover_system_node = get_node("/root/Main/ObjectRemoverSystem")
	object_remover_system_node.connect("remove_mode_toggled", self, "_on_Object_Remover_System_remove_mode_toggled")


func _on_Object_Remover_System_remove_mode_toggled():
	remove_mode = !remove_mode


# override from GrabbableRigidBody
func grab_init(node):
	if is_removable and remove_mode:
		remove_rigid_body()
	else:
		# if not in remove mode, call parents function to grab normally
		.grab_init(node)


# override from GrabbableRigidBody
func grab_release(node):
	if !is_removable or !remove_mode:
		.grab_release(node)


func remove_rigid_body():
	queue_free()
