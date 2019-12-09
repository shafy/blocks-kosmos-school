extends GrabbableRigidBody

# fundamental buildingblock class from which all other (e.g. lamps, voltage sources) inherit
class_name BuildingBlock

#var is_mini := false
#var scaling_up := false
#var mesh_node
#var collision_shape_node
#var collision_shape_node_shape
#var collision_shape_extents
#var collision_shape_initial_extents
#var expand_speed := 2.0
#var lerp_weight := 0.0
#var start_time := 0.0
#var mesh_initial_scale : Vector3
#var collision_shape_initial_scale : Vector3
#var mesh_mini_scale : Vector3
#var collision_shape_mini_scale : Vector3

#export(float) var mini_scale_factor
#export(NodePath) var mesh_node_path
#export(NodePath) var collision_shape_node_path


func _ready():
	#connect("grab_started", self, "_on_Grabbable_Rigid_Body_grab_started")
	#connect("grab_ended", self, "_on_Grabbable_Rigid_Body_grab_started")
	pass
	
# makes this a mini that is used to display it on the tablet
#func make_mini():
#	#is_mini = true
#
#	# get nodes and apply the scale factor
#	mesh_node = get_node(mesh_node_path)
#	if mesh_node:
#		mesh_initial_scale = mesh_node.scale
#		mesh_node.scale *= mini_scale_factor
#		mesh_mini_scale = mesh_node.scale
#	else:
#		print("No Mesh node assigned")
#
#	collision_shape_node = get_node(collision_shape_node_path)
#	if collision_shape_node:
#		collision_shape_node_shape = collision_shape_node.get_shape()
#		collision_shape_initial_extents = collision_shape_node_shape.get_extents()
#		collision_shape_extents = collision_shape_initial_extents * mini_scale_factor
#		collision_shape_node_shape.set_extents(collision_shape_extents)
#	else:
#		print("No CollisionShape node assigned")


#func _on_Grabbable_Rigid_Body_grab_started():
#	# if it's mini, scale it up upon grabing from the tablet
#	if is_mini:
#		scaling_up = true


#func _process(delta):
#	pass
#	if scaling_up:
#		# scale up over time as user removes the mini frmo the tablet
#		lerp_weight = start_time / expand_speed
#
#		var temp_scale_mesh = lerp(mesh_mini_scale, mesh_initial_scale, lerp_weight)
#		var temp_extents_collision_shape = lerp(collision_shape_extents, collision_shape_initial_extents, lerp_weight)
#
#
#		if mesh_node:
#			mesh_node.scale = temp_scale_mesh
#
#		if collision_shape_node:
#			collision_shape_node_shape.set_extents(temp_extents_collision_shape)
#
#		start_time += delta
#
#		if lerp_weight > 1:
#			lerp_weight = 0
#			scaling_up = false
#			is_mini = false
#			start_time = 0.0
