extends Spatial

class_name RigidBodyGrab

var controller : ARVRController = null;
var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
var grab_mesh : MeshInstance = null;
var held_object_initial_parent : Node

#onready var grabbable_rigid_body_parent_script = load("scripts/grabbable_rigid_body_parent.gd")

enum {	
	GRABTYPE_VELOCITY,
	GRABTYPE_PINJOINT, #!!TODO: not yet working; I first need to figure out how joints work
}
var grab_type = GRABTYPE_VELOCITY;


export var reparent_mesh = false;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	controller.connect("button_pressed", self, "_on_ARVRController_button_pressed")
	controller.connect("button_release", self, "_on_ARVRController_button_release")


func start_grab_velocity(grabbable_rigid_body: GrabbableRigidBody):
	if grabbable_rigid_body.is_grabbed:
		return
	
	grabbable_rigid_body.sleeping = false
	held_object = grabbable_rigid_body
	
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	held_object_initial_parent = held_object.get_parent()
	held_object_initial_parent.remove_child(held_object)
	add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_KINEMATIC)
	
	held_object.grab_init(held_object.to_local(global_transform.origin), self)


func release_grab_velocity():
	
	if !is_instance_valid(held_object):
		return
	
	# keep initial transform
	var initial_transform = held_object.get_global_transform()
	
	# reparent
	remove_child(held_object)
	held_object_initial_parent.add_child(held_object)
	
	held_object.global_transform = initial_transform
	held_object.set_mode(RigidBody.MODE_RIGID)
	
	held_object.grab_release(self)
	
	held_object = null


func start_grab_pinjoint(rigid_body):
	held_object = rigid_body;
	$PinJoint.set_node_a($GrabArea.get_path());
	$PinJoint.set_node_b(held_object.get_path());
	print("Grab PinJoint");
	pass;

func release_grab_pinjoint():
	pass;


func grab():
	if (held_object):
		return
	
	# find the right rigid body to grab
	var grabbable_rigid_body = null;
	var bodies = grab_area.get_overlapping_bodies();
	if len(bodies) > 0:
		for body in bodies:
			if body is GrabbableRigidBody:
					if body.get_mode() == RigidBody.MODE_RIGID and body.is_grabbable and !body.is_removable:
						grabbable_rigid_body = body
					elif body.is_removable:
						body.start_remove()

	if grabbable_rigid_body:
		if (grab_type == GRABTYPE_VELOCITY): start_grab_velocity(grabbable_rigid_body)
		#elif (grab_type == GRABTYPE_PINJOINT): start_grab_pinjoint(rigid_body);	


func release():
	if !held_object:
		return
		
	if (grab_type == GRABTYPE_VELOCITY): release_grab_velocity();
	elif (grab_type == GRABTYPE_PINJOINT): release_grab_pinjoint();


func _on_ARVRController_button_pressed(button_number):
	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		return
	
	# if grab button, grab
	grab()

func _on_ARVRController_button_release(button_number):
	if button_number != vr.CONTROLLER_BUTTON.GRIP_TRIGGER:
		return
	
	# if grab button, grab
	release()
