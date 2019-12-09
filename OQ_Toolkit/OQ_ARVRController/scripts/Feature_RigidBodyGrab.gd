extends Spatial

var controller : ARVRController = null;

var grab_area : Area = null;
var held_object = null;
var held_object_data = {};
onready var main_node = get_node("/root/Main")

var grab_mesh : MeshInstance = null;
export var reparent_mesh = false;

onready var grabbed_object_script = preload("helper_grabbed_RigidBody.gd");


enum {
	GRABTYPE_VELOCITY,
	GRABTYPE_PINJOINT, #!!TODO: not yet working; I first need to figure out how joints work
}

var grab_type = GRABTYPE_VELOCITY;

func _ready():
	controller = get_parent();
	if (not controller is ARVRController):
		vr.log_error(" in Feature_RigidBodyGrab: parent not ARVRController.");
	grab_area = $GrabArea;
	
	#grab_area.connect("area_entered", self, "_on_GrabArea_area_entered")
	# connect to button_pressed signal
	controller.connect("button_pressed", self, "_on_ARVRController_button_pressed")
	controller.connect("button_release", self, "_on_ARVRController_button_release")


#func start_grab_velocity(rigid_body):
#	if (rigid_body.get_script() == grabbed_object_script):
#		print("Double grab... not yet supported for velocity grab");
#	else:
#		held_object = rigid_body;
#		held_object_data["script"] = held_object.get_script();
#		held_object.set_script(grabbed_object_script);
#		held_object.grab_init(self);
#		if (reparent_mesh):
#			for c in held_object.get_children():
#				if (c is MeshInstance):
#					grab_mesh = c;
#					break;
#			if (grab_mesh):
#				print("Found a mesh to grab reparent");
#				held_object.remove_child(grab_mesh);
#				add_child(grab_mesh);
#				grab_mesh.transform = Transform();
#	pass

func start_grab_velocity(grabbable_rigid_body: GrabbableRigidBody):
	if grabbable_rigid_body.is_grabbed:
		return
	
	# parent to main
	var node_parent = grabbable_rigid_body.get_parent()
	
	var temp_global_pos = grabbable_rigid_body.global_transform.origin
	
	node_parent.remove_child(grabbable_rigid_body)
	main_node.add_child(grabbable_rigid_body)
	
	grabbable_rigid_body.global_transform.origin = temp_global_pos
	
	held_object = grabbable_rigid_body
	#
	held_object.grab_init(self)


func release_grab_velocity():
	held_object.grab_release(self)
	held_object = null

#func release_grab_velocity():
#	if (grab_mesh):
#		remove_child(grab_mesh);
#		held_object.add_child(grab_mesh);
#		grab_mesh.transform = Transform();
#		grab_mesh = null;
#
#	held_object.grab_release(self);
#	held_object.set_script(held_object_data["script"]);
#	held_object = null;
	
func start_grab_pinjoint(rigid_body):
	held_object = rigid_body;
	$PinJoint.set_node_a($GrabArea.get_path());
	$PinJoint.set_node_b(held_object.get_path());
	print("Grab PinJoint");
	pass;

func release_grab_pinjoint():
	pass;

#func update_grab():
#	if (held_object == null):
#		if (controller._button_just_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
#			# find the right rigid body to grab
#			var rigid_body = null;
#			var bodies = grab_area.get_overlapping_bodies();
#			if len(bodies) > 0:
#				for body in bodies:
#					if body is RigidBody:
#						rigid_body = body;
#
#			if rigid_body:
#				if (grab_type == GRABTYPE_VELOCITY): start_grab_velocity(rigid_body);
#				elif (grab_type == GRABTYPE_PINJOINT): start_grab_pinjoint(rigid_body);
#
#	else:
#		if (!controller._button_pressed(vr.CONTROLLER_BUTTON.GRIP_TRIGGER)):
#			if (grab_type == GRABTYPE_VELOCITY): release_grab_velocity();
#			elif (grab_type == GRABTYPE_PINJOINT): release_grab_pinjoint();

func grab():
	if (held_object):
		return
	
	# find the right rigid body to grab
	var grabbable_rigid_body = null;
	var bodies = grab_area.get_overlapping_bodies();
	if len(bodies) > 0:
		for body in bodies:
			if body is GrabbableRigidBody:
				grabbable_rigid_body = body

	if grabbable_rigid_body:
		if (grab_type == GRABTYPE_VELOCITY): start_grab_velocity(grabbable_rigid_body)
		#elif (grab_type == GRABTYPE_PINJOINT): start_grab_pinjoint(rigid_body);	


func release():
	if !held_object:
		return
		
	if (grab_type == GRABTYPE_VELOCITY): release_grab_velocity();
	elif (grab_type == GRABTYPE_PINJOINT): release_grab_pinjoint();

#func do_process(dt):
#	if (held_object):
#		#held_object.global_transform = global_transform;
#		held_object.sleeping = false;
#		#held_object.apply_central_impulse(global_transform.origin - held_object.global_transform.origin);
#		pass;
#
	#update_grab()


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
	
	

func _process(dt):
	#do_process(dt);
	pass


func _physics_process(dt):
	#do_process(dt);
	pass;
