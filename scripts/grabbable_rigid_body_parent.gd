extends RigidBody


class_name GrabbableRigidBodyParent

signal grab_started
signal grab_ended


var target_node = null
var empty_parent : RigidBody 
var delta_orientation = Basis();
#var delta_vector = Vector3()
var is_grabbed := false

export var is_grabbable := true


func grab_init(node):
	target_node = node
	# get empty parent, that's the one we want to move
	#var node_basis = node.get_global_transform().basis;
	# get relative position to where the grab was initiated
	#delta_vector = target_node.get_global_transform().origin - get_global_transform().origin
	is_grabbed = true


func grab_release(node):
	is_grabbed = false
	target_node = null


func orientation_follow(state, current_basis : Basis, target_basis : Basis):
	var delta : Basis = target_basis * current_basis.inverse();
	
	var q = Quat(delta);
	var axis = Vector3(q.x, q.y, q.z);

	if (axis.length_squared() > 0.0001):  # bullet fuzzyzero() is < FLT_EPSILON (1E-5)
		axis = axis.normalized();
		var angle = 2.0 * acos(q.w);
		state.set_angular_velocity(axis * (angle / (state.get_step())));
	else:
		state.set_angular_velocity(Vector3(0,0,0));



func position_follow(state, current_position, target_position):
	var dir = target_position - current_position;
	state.set_linear_velocity(dir / state.get_step());


func _integrate_forces(state):
	if (!is_grabbed): return
	
	if (!target_node): return
	
	var target_basis =  target_node.get_global_transform().basis * delta_orientation
	var target_position = target_node.get_global_transform().origin
	position_follow(state, get_global_transform().origin, target_position)
	orientation_follow(state, get_global_transform().basis, target_basis)
