extends Area

# this area snaps the building block (which needs to be its parent) to another snap area
class_name SnapArea


var snap_area_other_area : Area
var snapped := false
var z_difference := 1
var x_difference := 1

onready var parent_block := get_parent()


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "SnapArea" or .is_class(type)


func _ready():
	connect("area_entered", self, "_on_Snap_Area_area_entered")
	connect("area_exited", self, "_on_Snap_Area_area_exited")
	
	# we need to know where snap area is in relation to the parent block on z axis for snapping later on
#	if transform.origin.z < -0.001:
#		z_difference = -1
#
#	# same for x
#	if transform.origin.x < 0:
#		x_difference = -1


func _process(delta):
	if snap_area_other_area and snap_area_other_area.is_class("SnapArea") and !parent_block.is_grabbed and !snapped and !snap_area_other_area.snapped:
		var snap_area_other_area_parent = snap_area_other_area.get_parent()
		
		if !snap_area_other_area_parent:
			return

		if !snap_area_other_area_parent.is_class("BuildingBlock"):
			return
		
		
		# snap to position if other area is still in this area and not grabbed anymore
		if !snap_area_other_area_parent.is_grabbed:
			snapped = true
			snap_area_other_area.snapped = true
			snap_area_other_area.snap_to_block(self)
			snap_area_other_area = null


func _on_Snap_Area_area_entered(area):
	snap_area_other_area = area


func _on_Snap_Area_area_exited(area):
	snap_area_other_area = null
	print("exited")
	snapped = false


# snaps this block to another block
func snap_to_block(other_snap_area: Area):
	print("hihihi")
	# move to far position but in right direction
	parent_block.global_transform.origin += other_snap_area.global_transform.basis.z.normalized() * 1000
	
	# rotate it so that this z-vector is aligned with other areas
	# z-vector, but in the opposite direction
	var look_at_transform = global_transform.looking_at(other_snap_area.global_transform.origin, Vector3(0, 1, 0))
	var other_snap_area_parent = other_snap_area.get_parent()
	
	# update parent building block's rotation
	parent_block.global_transform.basis = look_at_transform.basis
	# rotate by 180° degrees
	parent_block.rotate_y(PI)
	
	# rotate by local y transform also
	parent_block.rotate_y(-rotation.y)
	
	# move to close pos
	# assuming other area's has a CollisionShape child and parent has CollisionShape child
	var this_block_extents = parent_block.get_node("CollisionShape").shape.extents
	var other_snap_area_extents = other_snap_area.get_node("CollisionShape").shape.extents
	var other_block_extents = other_snap_area_parent.get_node("CollisionShape").shape.extents
	
	var move_by_vec = other_snap_area.global_transform.origin - global_transform.origin
	move_by_vec -= other_snap_area.global_transform.basis.z.normalized() * other_snap_area_extents.x * 2
	parent_block.global_transform.origin += move_by_vec
	
