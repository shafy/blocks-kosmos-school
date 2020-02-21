extends GrabbableRigidBody


# fundamental buildingblock class from which all other inherit
class_name BuildingBlock


signal block_deleted


onready var outline_bubble_mesh := $OutlineBubble


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "BuildingBlock" or .is_class(type)

func _ready():
	# hide outline bubble to start with
	outline_bubble_mesh.visible = false


func _exit_tree():
	emit_signal("block_deleted", self)
	pass


# overriding this function from the parent GrabbableRemovableRigidBody
func _on_Object_Remover_System_remove_mode_toggled():
	._on_Object_Remover_System_remove_mode_toggled()
	toggle_outline_bubble()


func _on_Object_Remover_System_remove_mode_disabled():
	._on_Object_Remover_System_remove_mode_disabled()
	hide_outline_bubble()


func _on_Object_Remover_System_remove_mode_enabled():
	._on_Object_Remover_System_remove_mode_enabled()
	show_outline_bubble()


func toggle_outline_bubble():
	outline_bubble_mesh.visible = !outline_bubble_mesh.visible


func hide_outline_bubble():
	outline_bubble_mesh.visible = false


func show_outline_bubble():
	outline_bubble_mesh.visible = true

