extends GrabbableRemovableRigidBody

# fundamental buildingblock class from which all other (e.g. lamps, voltage sources) inherit
class_name BuildingBlock

onready var outline_bubble_mesh := $OutlineBubble

func _ready():
	# hide outlien bubble to start with
	outline_bubble_mesh.visible = false


# overriding this function from the parent GrabbableRemovableRigidBody
func _on_Object_Remover_System_remove_mode_toggled():
	._on_Object_Remover_System_remove_mode_toggled()
	toggle_outline_bubble()


func toggle_outline_bubble():
	outline_bubble_mesh.visible = !outline_bubble_mesh.visible
