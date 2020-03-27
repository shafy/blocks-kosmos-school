extends Area

# this area snaps the building block (which needs to be its parent) to another snap area
class_name SnapArea


signal area_snapped
signal area_unsnapped

var snap_area_other_area : Area
var other_area_parent_block
var connection_id : String
var snapping := false
var snap_speed := 10.0
var snap_timer := 0.0
var snap_start_transform : Transform
var snap_end_transform : Transform
var interpolation_progress : float
var moving_connection_added := false
var is_master := false
var measure_point : Node
var start_double_check = false
var double_check_timer = 0.0
var snap_particles_node

var snapped := false setget , get_snapped

onready var parent_block := get_parent()
onready var schematic := get_node(global_vars.SCHEMATIC_PATH) 
onready var all_measure_points := get_node(global_vars.ALL_MEASURE_POINTS_PATH)
onready var measure_point_scene = load(global_vars.MEASURE_POINT_FILE_PATH)


enum Polarity {UNDEFINED, POSITIVE, NEGATIVE}
export (Polarity) var polarity
enum ConnectionSide {A, B}
export (ConnectionSide) var connection_side
enum LocationOnBlock {LENGTH, WIDTH}
export (LocationOnBlock) var location_on_block


func get_snapped():
	return snapped


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "SnapArea" or .is_class(type)


func _process(delta):
	check_for_removal()
	
	if start_double_check:
		double_check_timer += delta
		
		if double_check_timer > 0.25:
			double_check_snap()
			start_double_check = false
			double_check_timer = 0.0


# we use this custom method instead of the area_exited or get_overlapping_areas
# we need to do this because with the small collisionshapes we use
# the area keeps entering and exiting all the time (probably a bug in Godot)
func check_for_removal():
	if !snap_area_other_area:
		return
	
	# we have to do this check because it's possible the other area was deleted in the meantime
	if !is_instance_valid(snap_area_other_area):
		return


	if other_area_distance() < 0.04:
		return
	
	# if distance is greater, remove
	if is_master and snapped:
		snap_area_other_area.unsnap()
		unsnap()
	else:
		snap_area_other_area = null
		other_area_parent_block = null


func unsnap():
	if is_master:
		destroy_measure_point()
		schematic_remove_connection()
	is_master = false
	snapped = false
	snap_area_other_area = null
	other_area_parent_block = null
	connection_id = ""
	moving_connection_added = false
	emit_signal("area_unsnapped")


# unsnaps this and the other block's snap area (called from parent)
func unsnap_both():
	if snap_area_other_area:
		snap_area_other_area.unsnap()
	unsnap()


func setup_connection(_other_area):
	connection_id = schematic_add_blocks(
		parent_block,
		polarity,
		connection_side,
		_other_area.get_parent(),
		_other_area.polarity,
		_other_area.connection_side
	)
	snap_area_other_area.connection_id = connection_id

# double checks if really not overlapping an area
# called from parent after every succesful snap
func start_double_check_snap():
	start_double_check = true


func double_check_snap() -> void:
	var overlapping_areas = get_overlapping_areas()
	for overlapping_area in overlapping_areas:
		if !(overlapping_area as SnapArea):
			return
		
		if !overlapping_area.get_snapped() or !overlapping_area.get_move_to_snap():
			snapped = true
			overlapping_area.snapped = true
			snap_area_other_area = overlapping_area
			overlapping_area.snap_area_other_area = self
			other_area_parent_block = overlapping_area.get_parent()
			overlapping_area.other_area_parent_block = get_parent()
			is_master = true
			setup_connection(overlapping_area)
			spawn_measure_point()
			emit_signal("area_snapped")


func other_area_distance() -> float:
	return get_global_transform().origin.distance_to(snap_area_other_area.get_global_transform().origin)
	
	
# update the schematic with this new connection
func schematic_add_blocks(
	_building_block1: BuildingBlock,
	_polarity1: int,
	_connection_side1: int,
	_building_block2: BuildingBlock,
	_polarity2: int,
	_connection_side2: int
) -> String:
	
	var return_connection_id = schematic.add_blocks(
		_building_block1,
		_polarity1,
		_connection_side1,
		_building_block2,
		_polarity2,
		_connection_side2
	)
	schematic.loop_current_method()
	
	return return_connection_id


func schematic_remove_connection():
	schematic.remove_connection(connection_id)
	schematic.loop_current_method()


# creates a measure point on top of this connection
func spawn_measure_point():
	# instance scene and create node
	measure_point = measure_point_scene.instance()
	all_measure_points.add_child(measure_point)
	
	# place it
	var move_by = Vector3(0, 0.15, 0)
	var extents = get_node("CollisionShape").shape.extents
	move_by -= global_transform.basis.z.normalized() * extents
	measure_point.global_transform.origin = global_transform.origin + move_by
	
	# update connection_id
	measure_point.set_measure_point_type(MeasurePoint.MeasurePointType.CONNECTION)
	measure_point.set_connection_id(connection_id)


func destroy_measure_point():
	if measure_point:
		measure_point.queue_free()
		measure_point = null
