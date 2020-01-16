extends GrabbableRemovableRigidBody


# fundamental buildingblock class from which all other inherit
class_name BuildingBlock


signal block_deleted

var snapping := false setget set_snapping, get_snapping

onready var outline_bubble_mesh := $OutlineBubble


func set_snapping(new_value):
	snapping = new_value


func get_snapping():
	return snapping


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "BuildingBlock" or .is_class(type)

func _ready():
	# hide outlien bubble to start with
	outline_bubble_mesh.visible = false


func _exit_tree():
	emit_signal("block_deleted", self)


# overriding this function from the parent GrabbableRemovableRigidBody
func _on_Object_Remover_System_remove_mode_toggled():
	._on_Object_Remover_System_remove_mode_toggled()
	toggle_outline_bubble()


func toggle_outline_bubble():
	outline_bubble_mesh.visible = !outline_bubble_mesh.visible

