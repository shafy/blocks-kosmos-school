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
	# only the master area executes the following
	if !is_master:
		return
	
	if !snap_area_other_area:
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
		#if parent_block.is_grabbed != other_area_parent_block.is_grabbed:
		# snap
		if initial_grab:
			snap_to_block(snap_area_other_area)
		elif snap_area_other_area.get_initial_grab():
			snap_area_other_area.snap_to_block(self)
		
		snapped = true
		snap_area_other_area.snapped = true
		snapping = false
		initial_grab = false
		snap_area_other_area.set_initial_grab(false)
		
		#parent_block.set_snapping(false)
		#other_area_parent_block.set_snapping(false)
		
		# set up connection in schematic
		connection_id = schematic_add_blocks(parent_block, polarity, other_area_parent_block, snap_area_other_area.polarity)
		snap_area_other_area.connection_id = connection_id
		#snap_area_other_area = null


func _on_Snap_Area_area_entered(area):
	if snapped:
		return
	
	if !area.is_class("SnapArea"):
		return
	
	if area.snapped:
		return
	
	# assign master area
	if (!area.is_master):
		is_master = true
	
	#print (self.name + " is_master: " + str(is_master))
	
	# stop executing if parent is already in the process of snapping
#	if parent_block.get_snapping() == true:
#		return
	
	snap_area_other_area = area
	other_area_parent_block = snap_area_other_area.get_parent()
	
#	if !other_area_parent_block.is_class("BuildingBlock"):
#		snap_area_other_area = null
#		other_area_parent_block = null
#		return
	
	#print("other_area_parent_block ", other_area_parent_block)
	#parent_block.set_snapping(true)


func _on_Snap_Area_area_exited(area):
	if !area.is_class("SnapArea"):
		return
		
	# stop executing if parent is already in the process of snapping
#	if parent_block.get_snapping() == true:
#		return
	
	# can only unsnap if being grabbed away
	if is_master and snapped:
		if parent_block.is_grabbed or other_area_parent_block.is_grabbed:
			snap_area_other_area.unsnap()
			unsnap()
			schematic_remove_connection()
	
		#print("UNSNAP snap_area_other_area ", snap_area_other_area)
		#print("exited blocks " + self.name + " " + parent_block.name + " and " + snap_area_other_area.name)
	
#	parent_block.set_snapping(false)
	if !snapped:
		snap_area_other_area = null
		other_area_parent_block = null
	


# snaps this block to another block
func snap_to_block(other_snap_area: Area):
	var current_other_area_parent_block = other_snap_area.get_parent()
	# move to far position but in right direction
	parent_block.global_transform.origin += other_snap_area.global_transform.basis.z.normalized() * 1000
	
	# rotate it so that this z-vector is aligned with other areas
	# z-vector, but in the opposite direction
	var look_at_transform = global_transform.looking_at(other_snap_area.global_transform.origin, Vector3(0, 1, 0))
	
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
	var other_block_extents = current_other_area_parent_block.get_node("CollisionShape").shape.extents
	
	var move_by_vec = other_snap_area.global_transform.origin - global_transform.origin
	move_by_vec -= other_snap_area.global_transform.basis.z.normalized() * other_snap_area_extents.x * 2
	parent_block.global_transform.origin += move_by_vec


func unsnap():
	#print("unsnapping blocks " + self.name + " " + parent_block.name + " and " + snap_area_other_area.name)
	snapped = false
	is_master = false
	snap_area_other_area = null
	other_area_parent_block = null
	connection_id = ""


# update the schematic with this new connection
func schematic_add_blocks(_building_block1: BuildingBlock, _ai1: String, _building_block2: BuildingBlock, _ai2: String) -> String:
	var return_connection_id = schematic.add_blocks(_building_block1, _ai1, _building_block2, _ai2)
	schematic.loop_current_method()
	
	return return_connection_id


func schematic_remove_connection():
	schematic.remove_connection(connection_id)
	schematic.loop_current_method()
