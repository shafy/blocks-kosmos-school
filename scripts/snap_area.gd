extends Area

# this area snaps the building block (which needs to be its parent) to another snap area
class_name SnapArea


var snap_area_other_area : Area
var other_area_parent_block : BuildingBlock
var snapped := false
var z_difference := 1
var x_difference := 1
var connection_id : String
var is_master := false
var snapping := false
var move_to_snap := false
var snap_speed := 10.0
var snap_timer := 0.0
var snap_start_transform : Transform
var snap_end_transform : Transform
var interpolation_progress : float
var moving_connection_added := false

var initial_grab := false setget set_initial_grab, get_initial_grab

onready var parent_block := get_parent()
onready var schematic  := get_node("/root/Main/Schematic")

export(String) var polarity


func set_initial_grab(new_value):
	initial_grab = new_value


func get_initial_grab():
	return initial_grab

# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "SnapArea" or .is_class(type)


func _ready():
	connect("area_entered", self, "_on_Snap_Area_area_entered")
	connect("area_exited", self, "_on_Snap_Area_area_exited")


func _process(delta):
	if move_to_snap:
		update_pos_to_snap(delta)
	
	if !snap_area_other_area:
		return
	
	if parent_block.get_moving_to_snap() and !move_to_snap and !moving_connection_added:
		# this happens when the area overlaps with another while being moved to snap
		# but the movement has originated from another area from the same block
		# therefore, don't move but just create connection in schematic
		print(parent_block.name + " " + self.name + " other area " + other_area_parent_block.name + " " + snap_area_other_area.name )
		connection_id = schematic_add_blocks(parent_block, polarity, other_area_parent_block, snap_area_other_area.polarity)
		snap_area_other_area.connection_id = connection_id
		moving_connection_added = true
	
	
	# only the master area executes the following
	if !is_master:
		return
		
	if !snapping and !initial_grab and !snap_area_other_area.get_initial_grab():
		if parent_block.is_grabbed == other_area_parent_block.is_grabbed:
			return
		
		if parent_block.is_grabbed and !other_area_parent_block.is_grabbed:
			initial_grab = true
		elif !parent_block.is_grabbed and other_area_parent_block.is_grabbed:
			snap_area_other_area.set_initial_grab(true)
	
	# start snapping process if one of the blocks has been grabbed initially but was now let go
	if (initial_grab and !parent_block.is_grabbed) or (snap_area_other_area.get_initial_grab() and !other_area_parent_block.is_grabbed):
		snapping = true
	
	# snapping has started
	if snapping:
		# either this or the other block must be ungrabbed
		# snap
		if initial_grab:
			snap_to_block(snap_area_other_area)
		elif snap_area_other_area.get_initial_grab():
			snap_area_other_area.snap_to_block(self)
		
		
		snapping = false
		initial_grab = false
		snap_area_other_area.set_initial_grab(false)
		
		# set up connection in schematic
		connection_id = schematic_add_blocks(parent_block, polarity, other_area_parent_block, snap_area_other_area.polarity)
		snap_area_other_area.connection_id = connection_id
		#snap_area_other_area = null


func _on_Snap_Area_area_entered(area):
	if snapped:
		return
	
	if snapping:
		return
	
	if !area.is_class("SnapArea"):
		return
	
	if area.snapped:
		return
	
	# assign master area
	if (!area.is_master):
		is_master = true
	
	snap_area_other_area = area
	other_area_parent_block = snap_area_other_area.get_parent()
	
	#print(parent_block.name + " " + self.name + " other area " + area.get_parent().name + " " + area.name )


func _on_Snap_Area_area_exited(area):
	if !area.is_class("SnapArea"):
		return
	
	# can only unsnap if being grabbed away
	if is_master and snapped:
		if parent_block.is_grabbed or other_area_parent_block.is_grabbed:
			schematic_remove_connection()
			snap_area_other_area.unsnap()
			unsnap()

	if !snapped:
		snap_area_other_area = null
		other_area_parent_block = null


# snaps this block to another block
func snap_to_block(other_snap_area: Area):
	snap_start_transform = parent_block.global_transform
	
	var current_other_area_parent_block = other_snap_area.get_parent()
	# move to far position but in right direction
	parent_block.global_transform.origin += other_snap_area.global_transform.basis.z.normalized() * 1000
	
	# rotate it so that this z-vector is aligned with other areas
	# z-vector, but in the opposite direction
	parent_block.global_transform = global_transform.looking_at(other_snap_area.global_transform.origin, Vector3(0, 1, 0))
	
	# rotate by 180° degrees
	parent_block.rotate_y(PI)
	
	# rotate by local y transform also
	parent_block.rotate_y(-rotation.y)
	
	# move to close pos
	# assuming other area's has a CollisionShape child and parent has CollisionShape child
	var this_block_extents = parent_block.get_node("CollisionShape").shape.extents
	var other_snap_area_extents = other_snap_area.get_node("CollisionShape").shape.extents
	var other_block_extents = current_other_area_parent_block.get_node("CollisionShape").shape.extents
	
	var move_by_vec = other_snap_area.global_transform.origin - global_transform.origin
	move_by_vec -= other_snap_area.global_transform.basis.z.normalized() * (other_snap_area_extents.x - 0.001) * 2
	parent_block.global_transform.origin += move_by_vec
	
	# assign back
	snap_end_transform = parent_block.global_transform
	parent_block.global_transform = snap_start_transform
	
	# make this and other parent static
	parent_block.set_mode(RigidBody.MODE_STATIC)
	current_other_area_parent_block.set_mode(RigidBody.MODE_STATIC)
	
	move_to_snap = true
	parent_block.set_moving_to_snap(true)


func unsnap():
	snapped = false
	is_master = false
	snap_area_other_area = null
	other_area_parent_block = null
	connection_id = ""
	moving_connection_added = false


# snaps to the other block over time, updating position and rotation
func update_pos_to_snap(delta: float) -> void:
	snap_timer += delta
	interpolation_progress = snap_timer * snap_speed
	
	if interpolation_progress > 1.0:
		parent_block.set_moving_to_snap(false)
		move_to_snap = false
		snap_timer = 0.0
		snapped = true
		snap_area_other_area.snapped = true
		return
	
	parent_block.global_transform = snap_start_transform.interpolate_with(snap_end_transform, interpolation_progress)


# update the schematic with this new connection
func schematic_add_blocks(_building_block1: BuildingBlock, _ai1: String, _building_block2: BuildingBlock, _ai2: String) -> String:
	var return_connection_id = schematic.add_blocks(_building_block1, _ai1, _building_block2, _ai2)
	schematic.loop_current_method()
	
	return return_connection_id


func schematic_remove_connection():
	schematic.remove_connection(connection_id)
	schematic.loop_current_method()
