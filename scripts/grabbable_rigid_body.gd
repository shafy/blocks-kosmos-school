extends RigidBody

class_name GrabbableRigidBody

var target_node = null;
var delta_orientation = Basis();
var delta_position = Vector3();
var is_grabbed := false

func _ready():
	pass
	
func grab_init(node):
	target_node = node
	
	var node_basis = node.get_global_transform().basis;
	is_grabbed = true
	
	#delta_position = get_global_transform().origin - node.get_global_transform().origin;
	#delta_position = node_basis.xform_inv(delta_position);
	
#	delta_orientation = Basis(Vector3(1, 0, 0), deg2rad(40.0)) * Basis(Vector3(0, 0, 1), deg2rad(90.0));
	
func grab_release(node):
	is_grabbed = false
	target_node = null
	pass;


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
	
	var target_basis =  target_node.get_global_transform().basis * delta_orientation;
	var target_position = target_node.get_global_transform().origin# + target_basis.xform(delta_position);
	position_follow(state, get_global_transform().origin, target_position);
	orientation_follow(state, get_global_transform().basis, target_basis);
