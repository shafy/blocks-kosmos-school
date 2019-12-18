extends Spatial
# logic to generate a wire between two points
class_name WireGenerator

var is_on := false
var raycast := false
var temp_mode := false
var point1: Vector3
var point2: Vector3
var point_temp: Vector3
var point2_object: Node
var point1_set = false
var schematic
var building_block1
var additional_info1
var point1_collision_mask
var wire_radius := 0.004 
var rng
var multiplicator_array = [-1, 1]

func _ready():
	schematic = get_node("/root/Main/Schematic")
	if !schematic:
		print("Schematic node not found. Make sure there's one in root/Main/Schematic'")
	
	var wire_mode_button = get_node("/root/Main/Tablet/WireModeButton")
	
	wire_mode_button.connect("button_pressed", self, "_on_WireModeButton_button_pressed")
	
	point1_set = false
	
	rng = RandomNumberGenerator.new()


func _physics_process(delta):
	if (raycast):
		# get space state
		var space_state = get_world().direct_space_state
		# cast ray that collides with areas and using point1's collision mask
		var p1 = point1
		var p2 = point2
		if temp_mode:
			p2 = point_temp
		
		var result = space_state.intersect_ray(p1, p2, [self], point1_collision_mask, true, true)
		raycast = false
		handle_raycast_result(result)

# creat a wire point - if it created the second point, then it also draws the wire
func create_wire_point(wire_node: Node, building_block: BuildingBlock, additional_info: String):
	var new_point = wire_node.global_transform.origin
	
	if !point1_set:
		point1 = new_point
		point1_set = true
		building_block1 = building_block
		additional_info1 = additional_info
		point1_collision_mask = wire_node.collision_mask
	else:
		if point1 == new_point:
			return
		
		point2 = new_point
		point2_object = wire_node
		raycast()
		update_schematic(building_block1, additional_info1, building_block, additional_info, "add")
		point1_set = false
	
	# mark as wired
	wire_node.is_wired = true

# cast ray to see if there's an obstacle in the direct line between points
func raycast():
	raycast = true


# draws a segment of the wire (wire can be only one segment long)
func create_wire_segment(start_point: Vector3, end_point: Vector3):
	# create new MeshInstance with Cylinder, and size it accordingly
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = CylinderMesh.new()
	
	# resize
	var length = (end_point - start_point).length() / 2
	mesh_instance.scale = Vector3(wire_radius, length, wire_radius)
	
	# reposition and rotate
	var mid_point_vector = start_point.linear_interpolate(end_point, 0.5)
	
	mesh_instance.look_at_from_position(mid_point_vector, end_point, Vector3(0, 0, 1))
	mesh_instance.rotate_y(90 * PI/180)
	
	# add to scene
	add_child(mesh_instance)

# called after a raycast has been executed
func handle_raycast_result(result: Dictionary):
	
	# if it hit nothing, add a short wire segment
	if result.empty():
		if (temp_mode):
			point_temp = point1 + (point1.direction_to(point_temp) * 0.05)
			create_wire_segment(point1, point_temp)
			point1 = point_temp
			temp_mode = false
			raycast()
		else:
			# this should never happen
			print("Raycast didn't hit anything and wasn't in temp_mode")
		return
	
	# if it hit the second point directly, draw a straight wire
	# we check if it's the same object to avoid confusing it with another Wireable
	if result.collider == point2_object:
		create_wire_segment(point1, point2)
		return
	
		# if it hit something else, check the distance
	var dist = point1.distance_to(result.position)
	
	var direction_to_vector
	
	if temp_mode:
		direction_to_vector = point1.direction_to(point_temp)
		temp_mode = false
	else:
		direction_to_vector = point1.direction_to(point2)
	
	if dist > 0.08:
		# in this case add a wire segment that's a little shorter than the distance
		var point2_temp = point1 + (direction_to_vector * (dist - 0.05))
		create_wire_segment(point1, point2_temp)
		point1 = point2_temp
	else:
		# in this case the next object is really close, so move angle of ray cast by random angle
		# and make a new ray cast
		var random_angle = rng.randf_range(15.0, 25.0)
		
		multiplicator_array.shuffle()
		var rotated_vec = direction_to_vector.rotated(Vector3(0,1,0), multiplicator_array[0] * random_angle * PI / 180)
		
		point_temp = point1 + (rotated_vec * dist * 2)
		
		temp_mode = true
	
	raycast()


# update the schematic with this new connection
func update_schematic(_building_block1: BuildingBlock, _ai1: String, _building_block2: BuildingBlock, _ai2: String, _schematic_action: String):
	schematic.update_schematic(_building_block1, _ai1, _building_block2, _ai2, _schematic_action)

# signal is emittd by wirable.gd
func _on_Wirable_wire_tapped(wire_node: Node, building_block: BuildingBlock, additional_info: String):
	# only create new wire point if WireGenerator is ON
	if is_on:
		create_wire_point(wire_node, building_block, additional_info)


func _on_WireModeButton_button_pressed():
	# toggle
	is_on = !is_on
	vr.log_info("is_on: " + str(is_on))
