extends KSGrabbableRigidBody


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
var expand_speed := 0.5
var lerp_weight := 0.0
var start_time := 0.0
var mesh_initial_scale : Vector3
var collision_shape_initial_scale : Vector3
var mesh_mini_scale : Vector3
var collision_shape_mini_scale : Vector3
var tablet_pos_id : int

onready var mesh_node = $MeshInstance
onready var collision_shape_node = $CollisionShape
onready var all_building_blocks = get_node(global_vars.ALL_BUILDING_BLOCKS_PATH)
onready var right_controller_grab = get_node(global_vars.CONTR_RIGHT_PATH + "/controller_grab")
onready var left_controller_grab = get_node(global_vars.CONTR_LEFT_PATH + "/controller_grab")
onready var tablet = get_node(global_vars.TABLET_PATH)
onready var main_node = get_node("/root/Main")
onready var scaling_up_sound = $AudioStreamPlayer3DScale

export var label_name : String
export(float) var mini_scale_factor
export(Vector3) var extents_initial
export(NodePath) var mesh_node_path
export(NodePath) var collision_shape_node_path
export(PackedScene) var maxi_scene


func _ready():
	# get nodes and apply the scale factor
	#mesh_node = get_node(mesh_node_path)
	
	connect("visibility_changed", self, "_on_Mini_visibility_changed")
	
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
	
	if !is_visible_in_tree():
		set_process(false)
		set_physics_process(false)


func _process(delta):
	# check if it's moving or not so we only scale up if it's not moving
	if ready_to_scale:
		if linear_velocity.length() < 0.001 and angular_velocity.length() < 0.001:
			scaling_up = true
			if scaling_up_sound:
				scaling_up_sound.play()
		

	
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


func _on_Mini_visibility_changed():
	# make sure we can't interact with this mini if invisible
	if !is_visible_in_tree():
		set_process(false)
		set_physics_process(false)
	else:
		set_process(true)
		set_physics_process(true)


func grab_init(node, grab_type):
	.grab_init(node, grab_type)
	# turn on gravity
	gravity_scale = 1.0
	
	# reparent because else we can't grab it
	var prev_transform = self.global_transform
	var current_parent = get_parent()
	current_parent.remove_child(self)
	main_node.add_child(self)
	global_transform = prev_transform
	
	maximize()


# maximizes a mini
func maximize():
	if is_max or scaling_up:
		return
	
	# scale up
	ready_to_scale = true


func switch_to_maxi():
	# instance maxi node to all_building_blocks node
	var new_maxi = maxi_scene.instance()
	all_building_blocks.add_child(new_maxi)
	
	# set to correct position and rotation
	new_maxi.transform.origin = global_transform.origin
	new_maxi.transform.basis = global_transform.basis
	new_maxi.tablet_pos_id = tablet_pos_id
	# connect delete signal to tablet
	new_maxi.connect("block_deleted", tablet, "_on_Building_Block_block_deleted")
	
	# check if mini still held by controller
	var held_right = false
	var held_left = false
	if grabbed_by:
		if grabbed_by.get_parent().name == global_vars.CONTR_RIGHT_NAME:
			held_right = true
		if grabbed_by.get_parent().name == global_vars.CONTR_LEFT_NAME:
			held_left = true
	
	if held_right:
		right_controller_grab.release_grab_hinge_joint()
		right_controller_grab.start_grab_hinge_joint(new_maxi)
	if held_left:
		left_controller_grab.release_grab_hinge_joint()
		left_controller_grab.start_grab_hinge_joint(new_maxi)
	
	# respawn this mini on the tablet
	tablet.respawn_mini(tablet_pos_id)
	
	# destroy this mini node
	queue_free()
