extends BuildingBlock


# this building block can snap!
class_name BuildingBlockSnappable


signal block_snapped_updated

var moving_to_snap := false setget set_moving_to_snap, get_moving_to_snap
var snapped := false setget set_snapped, get_snapped
var overlapping := false setget set_overlapping, get_overlapping
var snap_speed := 10.0
var snap_timer := 0.0
var snap_start_transform : Transform
var snap_end_transform : Transform
var interpolation_progress : float
var volt_measure_points : Dictionary


onready var held_snap_areas = $HeldSnapAreas
onready var held_snap_areas_children = held_snap_areas.get_children()
onready var all_children = get_children()
onready var snap_sound := $AudioStreamPlayer3DSnap
onready var all_measure_points := get_node(global_vars.ALL_MEASURE_POINTS_PATH)
onready var measure_point_scene = load(global_vars.MEASURE_POINT_FILE_PATH)

export(PackedScene) var snap_particles_scene


# setter and getter functions
func set_moving_to_snap(new_value):
	moving_to_snap = new_value


func get_moving_to_snap():
	return moving_to_snap


func set_snapped(new_value):
	snapped = new_value


func get_snapped():
	return snapped


func set_overlapping(new_value):
	overlapping = new_value


func get_overlapping():
	return overlapping


# this is a hacky workaround because of this issue: https://github.com/godotengine/godot/issues/25252
func is_class(type):
	return type == "BuildingBlockSnappable" or .is_class(type)


func _ready():
	connect_to_snap_area_signals()
	if !is_grabbed:
		show_held_snap_areas(false)


func _process(delta):
	if is_grabbed:
		show_held_snap_areas(true)
	elif !is_grabbed and !overlapping:
		show_held_snap_areas(false)
	
	
	if moving_to_snap:
		overlapping = false
		update_pos_to_snap(delta)
		show_held_snap_areas(false)


func _on_SnapArea_area_snapped():
	update_snapped_status()


func _on_SnapArea_area_unsnapped():
	update_snapped_status()


func update_snapped_status():
	# update status if all areas are unsnapped or min. 1 is snapped
	var snapped_status = false
	
	for child in all_children:
		if child is SnapArea:
			if child.get_snapped():
				snapped_status = true
				break
	
	snapped = snapped_status


func show_held_snap_areas(show: bool) -> void:
	for held_snap_area in held_snap_areas_children:
		if held_snap_area is HeldSnapArea:
			held_snap_area.visible = show


func connect_to_snap_area_signals():	
	for child in all_children:
		if child is SnapArea:
			child.connect("area_snapped", self, "_on_SnapArea_area_snapped")
			child.connect("area_unsnapped", self, "_on_SnapArea_area_unsnapped")


# after it moved to position, we need to check with snap areas are now overlapping
func check_snap_areas() -> void:
	for child in all_children:
		if child is SnapArea:
			if !child.get_snapped():
				child.start_double_check_snap()


# unsnaps all areas (needed for deleting block)
func unsnap_all() -> void:
	var all_children = get_children()
	
	for child in all_children:
		if child is SnapArea:
			child.unsnap_both()


func snap_to_block(this_snap_area: Area, other_snap_area: Area):
	snap_start_transform = global_transform

	var current_other_area_parent_block = other_snap_area.get_parent()
	# move to far position but in right direction
	global_transform.origin += other_snap_area.global_transform.basis.z.normalized() * 1000

	# rotate it so that this z-vector is aligned with other areas
	# z-vector, but in the opposite direction
	global_transform = this_snap_area.global_transform.looking_at(other_snap_area.global_transform.origin, Vector3(0, 1, 0))

	# rotate by 180° degrees
	rotate_y(PI)

	# rotate by local y transform also
	rotate_y(-this_snap_area.rotation.y)

	# move to close pos
	# assuming other area's has a CollisionShape child and parent has CollisionShape child
	var this_snap_area_extents = this_snap_area.get_node("CollisionShape").shape.extents
	var other_snap_area_extents = other_snap_area.get_node("CollisionShape").shape.extents

	var move_by_vec = other_snap_area.global_transform.origin - this_snap_area.global_transform.origin
	move_by_vec -= other_snap_area.global_transform.basis.z.normalized() * (this_snap_area_extents.z - 0.001)
	global_transform.origin += move_by_vec

	# assign back
	snap_end_transform = global_transform
	global_transform = snap_start_transform
	
	set_mode(RigidBody.MODE_KINEMATIC)
#	move_to_snap = true
	moving_to_snap = true


# snaps to the other block over time, updating position and rotation
func update_pos_to_snap(delta: float) -> void:
	snap_timer += delta
	interpolation_progress = snap_timer * snap_speed
	
	if interpolation_progress > 1.0:
		# set final pos
		global_transform = snap_end_transform
		moving_to_snap = false
		snap_timer = 0.0
		check_snap_areas()
		if snap_sound:
			snap_sound.play()
		set_mode(RigidBody.MODE_RIGID)
		return
	
	global_transform = snap_start_transform.interpolate_with(snap_end_transform, interpolation_progress)


# checks if there are still overlapping children or not
func update_overlapping():
	var overlapping_status = false
	
	for child in held_snap_areas_children:
		if child is HeldSnapArea:
			if child.get_overlapping():
				overlapping_status = true
				break
	
	overlapping = overlapping_status


func spawn_measure_point(
	connection_side : int,
	connection_id : String,
	other_block : BuildingBlockSnappable,
	other_connection_side: int,
	snap_area_pos : Vector3
) -> void:
	
	# check if there's already a measure point in this block
	if volt_measure_points.has(connection_side):
		# if yes, add connection id
		volt_measure_points[connection_side].add_connection_id(connection_id)
		update_measure_point_pos(connection_side, snap_area_pos)
		return
	
	# or the other block
	if other_block.volt_measure_points.has(other_connection_side):
		volt_measure_points[connection_side] = other_block.volt_measure_points[other_connection_side]
		volt_measure_points[connection_side].add_connection_id(connection_id)
		update_measure_point_pos(connection_side, snap_area_pos)
		return
	
	# if not, create a new one
	var current_mp = measure_point_scene.instance()
	all_measure_points.add_child(current_mp)
	volt_measure_points[connection_side] = current_mp
	
	# place it
#	var move_by = Vector3(snap_area_pos.x, 0.15, )
#	var extents = get_node("CollisionShape").shape.extents
#	move_by -= global_transform.basis.z.normalized() * extents
#	current_mp.global_transform.origin = global_transform.origin + move_by

	current_mp.global_transform.origin = snap_area_pos + Vector3(0, 0.15, 0)
			
	# update connection_id
	current_mp.set_measure_point_type(MeasurePoint.MeasurePointType.CONNECTION)
	current_mp.add_connection_id(connection_id)
	
	# add reference to other block, too
	other_block.add_measure_point_ref(other_connection_side, current_mp)


# called after the other block spawned the measure point
func add_measure_point_ref(connection_side : int, measure_point: MeasurePoint) -> void:
	volt_measure_points[connection_side] = measure_point


func destroy_measure_point(
	connection_side : int,
	connection_id : String,
	other_block : BuildingBlockSnappable,
	other_connection_side: int
):
	
	# destroy if one connection id, else remove connection id
	if !volt_measure_points.has(connection_side):
		print("Wanted to destroy Measure Point, but none found")
		return
	
	var current_mp = volt_measure_points[connection_side]
	
	if current_mp.connection_ids.size() > 1:
		current_mp.remove_connection_id(connection_id)
	else:
		current_mp.queue_free()
		volt_measure_points.erase(connection_side)
		other_block.volt_measure_points.erase(other_connection_side)


func update_measure_point_pos(connection_side : int, snap_area_pos : Vector3):
	if !volt_measure_points.has(connection_side):
		return
	var old_pos = volt_measure_points[connection_side].global_transform.origin
	var new_pos = lerp(old_pos, snap_area_pos + Vector3(0, 0.15, 0), 0.5)
	volt_measure_points[connection_side].global_transform.origin = new_pos
