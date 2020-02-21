extends RigidBody

# makes a rigid body grabbable by OQ_Controller
class_name GrabbableRigidBody

signal grab_started
signal grab_ended


var target_node = null
var delta_orientation = Basis()
var is_grabbed := false
var impulse_offset : Vector3

onready var object_remover_system_node = get_node(global_vars.OBJECT_REMOVER_SYSTEM_PATH)

export var is_grabbable := true
export var is_removable := false

func _ready():
	object_remover_system_node.connect("remove_mode_toggled", self, "_on_Object_Remover_System_remove_mode_toggled")
	object_remover_system_node.connect("remove_mode_disabled", self, "_on_Object_Remover_System_remove_mode_disabled")
	object_remover_system_node.connect("remove_mode_enabled", self, "_on_Object_Remover_System_remove_mode_enabled")


func _on_Object_Remover_System_remove_mode_toggled():
	is_removable = !is_removable


func _on_Object_Remover_System_remove_mode_disabled():
	is_removable = false


func _on_Object_Remover_System_remove_mode_enabled():
	is_removable = true


func grab_init(grab_offset):
	impulse_offset = grab_offset
	#target_node = node
	#var node_basis = node.get_global_transform().basis;
	# get relative position to where the grab was initiated
	#delta_vector = target_node.get_global_transform().origin - get_global_transform().origin
	is_grabbed = true


func grab_release(node):
	is_grabbed = false
	target_node = null
	apply_impulse(impulse_offset, linear_velocity)
	apply_torque_impulse(angular_velocity * 0.001)


func start_remove():
	if is_removable:
		queue_free()


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

#func _physics_process(delta):
#	if is_grabbed:
#		#print("linear_velocity", linear_velocity)

#func _integrate_forces(state):
#	if (!is_grabbed): return
#
#	if (!target_node): return
#
#	var target_basis =  target_node.get_global_transform().basis * delta_orientation
#	var target_position = target_node.get_global_transform().origin
#	position_follow(state, get_global_transform().origin, target_position)
#	orientation_follow(state, get_global_transform().basis, target_basis)
