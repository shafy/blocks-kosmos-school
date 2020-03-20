extends KSGrabbableRigidBody


# fundamental buildingblock class from which all other inherit
class_name BuildingBlock


signal block_deleted(block)

var tablet_pos_id := -1

onready var delete_bubble := $DeleteBubble
onready var object_remover_system_node = get_node(global_vars.OBJECT_REMOVER_SYSTEM_PATH)

# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "BuildingBlock" or .is_class(type)


func _ready():
	# connect stuff
	object_remover_system_node.connect("remove_mode_toggled", self, "_on_Object_Remover_System_remove_mode_toggled")
	object_remover_system_node.connect("remove_mode_disabled", self, "_on_Object_Remover_System_remove_mode_disabled")
	object_remover_system_node.connect("remove_mode_enabled", self, "_on_Object_Remover_System_remove_mode_enabled")
	
	# hide delete bubble to start with
	delete_bubble.visible = false

#
#func _exit_tree():
#	emit_signal("block_deleted")


# overriding this function from the parent GrabbableRemovableRigidBody
func _on_Object_Remover_System_remove_mode_toggled():
	toggle_delete_bubble()


func _on_Object_Remover_System_remove_mode_disabled():
	hide_delete_bubble()


func _on_Object_Remover_System_remove_mode_enabled():
	show_delete_bubble()


func toggle_delete_bubble():
	delete_bubble.visible = !delete_bubble.visible


func hide_delete_bubble():
	delete_bubble.visible = false


func show_delete_bubble():
	delete_bubble.visible = true

