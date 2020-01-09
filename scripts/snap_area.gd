extends Area

# this area snaps the building block (which needs to be its parent) to another snap area
class_name SnapArea


var snap_area_1_other_area : Area
var snapped := false
var z_difference := -1
var x_difference := -1

onready var parent_block := get_parent()


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "SnapArea" or .is_class(type)


func _ready():
	connect("area_entered", self, "_on_Snap_Area_1_area_entered")
	connect("area_exited", self, "_on_Snap_Area_1_area_exited")
	
	# we need to know where snap area is in relation to the parent block on z axis for snapping later on
	if parent_block.transform.origin.z > transform.origin.z:
		z_difference = 1
	else:
		z_difference = -1
		
	# same for x
	if parent_block.transform.origin.x > transform.origin.x:
		x_difference = 1
	else:
		x_difference = -1


func _process(delta):
	if snap_area_1_other_area and snap_area_1_other_area.is_class("SnapArea") and !parent_block.is_grabbed and !snapped and !snap_area_1_other_area.snapped:
		var snap_area_1_other_area_parent = snap_area_1_other_area.get_parent()
		
		if !snap_area_1_other_area_parent:
			return

		if !snap_area_1_other_area_parent.is_class("BuildingBlock"):
			return
		
		
		# snap to position if other area is still in this area and not grabbed anymore
		if !snap_area_1_other_area_parent.is_grabbed:
			snapped = true
			snap_area_1_other_area.snap_to_block(self)
			snap_area_1_other_area = null


func _on_Snap_Area_1_area_entered(area):
	snap_area_1_other_area = area


func _on_Snap_Area_1_area_exited(area):
	snap_area_1_other_area = null


# snaps this block to another block
func snap_to_block(other_snap_area: Area):
	# move to far position but in right direction
	var far_pos = other_snap_area.global_transform.origin + Vector3(0, 0, 1000)
	
	parent_block.global_transform.origin = far_pos
	
	# rotate it so that this z-vector is aligned with other areas
	# z-vector, but in the opposite direction
	var look_at_transform = global_transform.looking_at(other_snap_area.global_transform.origin, Vector3(0, 1, 0))
	var other_snap_area_parent = other_snap_area.get_parent()
	
	# update parent building block's rotation
	parent_block.global_transform.basis = look_at_transform.basis
	
	if z_difference < 0:
		# rotate by 180° degrees
		parent_block.rotate_y(PI)
	
	# move to close pos
	# assuming other area's has a CollisionShape child and parent has CollisionShape child
	var this_block_extents = parent_block.get_node("CollisionShape").shape.extents
	var other_snap_area_extents = other_snap_area.get_node("CollisionShape").shape.extents
	var other_block_extents = other_snap_area_parent.get_node("CollisionShape").shape.extents
	var move_by_vec = Vector3(
		other_block_extents.x + (other_snap_area.x_difference * other_snap_area_extents.x),
		0,
		other_snap_area_extents.z - this_block_extents.z + 0.02
	)
	
	
	var close_pos = other_snap_area.global_transform.origin + move_by_vec
	
	parent_block.global_transform.origin = close_pos
	
	snapped = true
	
	
