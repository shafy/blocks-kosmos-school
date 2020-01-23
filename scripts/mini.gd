extends GrabbableRigidBody


class_name Mini


var is_max := false
var scaling_up := false
var ready_to_scale := false
#var mesh_node
var mesh_maxi_scale
#var collision_shape_node
var collision_shape_node_shape
var collision_shape_initial_extents
var collision_shape_maxi_extents
var expand_speed := 2.0
var lerp_weight := 0.0
var start_time := 0.0
var mesh_initial_scale : Vector3
var collision_shape_initial_scale : Vector3
var mesh_mini_scale : Vector3
var collision_shape_mini_scale : Vector3

onready var mesh_node = $MeshInstance
onready var collision_shape_node = $CollisionShape
onready var all_building_blocks = get_node("/root/Main/AllBuildingBlocks")

export(float) var mini_scale_factor
export(Vector3) var extents_initial
export(NodePath) var mesh_node_path
export(NodePath) var collision_shape_node_path

export(PackedScene) var maxi_scene

func _ready():
	connect("body_entered", self, "_on_Mini_body_entered")
	
	var object_remover_system_node = get_node("/root/Main/ObjectRemoverSystem")
	object_remover_system_node.connect("remove_mode_toggled", self, "_on_Object_Remover_System_remove_mode_toggled")
	
	# get nodes and apply the scale factor
	#mesh_node = get_node(mesh_node_path)
	
	if mesh_node and mini_scale_factor != 0.0:
		mesh_initial_scale = mesh_node.scale
		mesh_maxi_scale = mesh_initial_scale / mini_scale_factor
	else:
		print("No Mesh node assigned")

	#collision_shape_node = get_node(collision_shape_node_path)
	if collision_shape_node and mini_scale_factor != 0.0:
		collision_shape_node_shape = collision_shape_node.get_shape()
		
		# we have to set extents initially else they keep getting bigger with each respawn (same resource used)
		collision_shape_node_shape.set_extents(extents_initial)
		collision_shape_maxi_extents = extents_initial / mini_scale_factor
	else:
		print("No CollisionShape node assigned")


func _process(delta):
	# check if it's moving or not so we only scale up if it's not moving
	if ready_to_scale:
		if linear_velocity.length() < 0.001 and angular_velocity.length() < 0.001:
			scaling_up = true
	
	if scaling_up:
		ready_to_scale = false
		# scale up over time as user removes the mini frmo the tablet
		lerp_weight = start_time / expand_speed

		var temp_scale_mesh = lerp(mesh_initial_scale, mesh_maxi_scale, lerp_weight)
		var temp_extents_collision_shape = lerp(extents_initial, collision_shape_maxi_extents, lerp_weight)


		if mesh_node:
			mesh_node.set_scale(temp_scale_mesh)

		if collision_shape_node_shape:
			collision_shape_node_shape.set_extents(temp_extents_collision_shape)

		start_time += delta

		if lerp_weight > 1:
			lerp_weight = 0
			scaling_up = false
			start_time = 0.0
			is_max = true
			switch_to_maxi()


func _on_Object_Remover_System_remove_mode_toggled():
	is_grabbable = !is_grabbable


func _on_Mini_body_entered(body):
	if body.name == "Table":
		maximize()


func grab_init(node):
	.grab_init(node)
	# turn on gravity
	gravity_scale = 1.0


# maximizes a mini
func maximize():
	if is_max or scaling_up or is_grabbed: return
	
	# scale up
	ready_to_scale = true


func switch_to_maxi():
	# instance maxi node to all_building_blocks node
	var new_maxi = maxi_scene.instance()
	all_building_blocks.add_child(new_maxi)
	
	# set to correct position and rotation
	new_maxi.transform.origin = global_transform.origin
	new_maxi.transform.basis = global_transform.basis
	
	# destroy this node
	queue_free()
	
	# respawn this mini on the tablet
	var tablet = get_node("/root/Main/Tablet")
	tablet.refresh()
	

