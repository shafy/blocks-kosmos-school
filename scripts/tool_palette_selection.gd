extends Spatial


class_name ToolPaletteSelection

onready var mesh := $MeshInstance

export (Material) var on_material
export (Material) var off_material

func _ready():
	select(false)


func select(new_active : bool):
	if new_active:
		mesh.set_material_override(on_material)
	else:
		mesh.set_material_override(off_material)
