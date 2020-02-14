extends Node

# takes care of the logic for the different typess of controllers
class_name ControllerSystem

enum ControllerType {EDIT, MEASURE}
var controller_type = ControllerType.EDIT

var right_controller_models
var selected_tool : String
var lock_selection_node
var remove_selection_node
var voltmeter_selection_node
var ammeter_selection_node
var remove_mode_on := false
var lock_mode_on := false
var joystick_x := 0.0
var joystick_x_prev := 0.0

export(NodePath) onready var block_lock_system = get_node(block_lock_system)
export(NodePath) onready var object_remover_system = get_node(object_remover_system)
export(NodePath) onready var edit_palette = get_node(edit_palette)
export(NodePath) onready var measure_palette = get_node(measure_palette)

onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)

func _ready():
	if right_controller:
		right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
		right_controller_models = right_controller.get_node("Feature_ControllerModel_Right")
		set_controller_type(controller_type)
	
	lock_selection_node = edit_palette.get_node("LockSelection")
	remove_selection_node = edit_palette.get_node("RemoveSelection")
	voltmeter_selection_node = measure_palette.get_node("VoltmeterSelection")
	ammeter_selection_node = measure_palette.get_node("AmmeterSelection")
	edit_palette.visible = false
	measure_palette.visible = false


func _process(delta):
	joystick_x = right_controller.get_joystick_axis(0)

	match controller_type:
		ControllerType.EDIT:
			if joystick_position() == 0 and edit_palette.visible:
				edit_palette.visible = false
			
			if joystick_position() == 1:
				edit_palette.visible = true
				select_tool("lock")
			
			if joystick_position() == 2:
				edit_palette.visible = true
				select_tool("remove")
		ControllerType.MEASURE:
			if joystick_position() == 0 and measure_palette.visible:
				measure_palette.visible = false
			
			if joystick_position() == 1:
				measure_palette.visible = true
				select_tool("voltmeter")
				
			if joystick_position() == 2:
				measure_palette.visible = true
				select_tool("ammeter")
				
	joystick_x_prev = joystick_x


func _on_right_ARVRController_button_pressed(button_number):
	# check for A button press
	if button_number != vr.CONTROLLER_BUTTON.XA:
		return
	
	roundrobin()


func joystick_position() -> int:
	if joystick_x <= 0.5 and joystick_x >= -0.5:
		return 0
	
	if joystick_x > 0.5 and joystick_x_prev <= 0.5:
		return 1
	
	if joystick_x < -0.5 and joystick_x_prev >= -0.5:
		return 2
	
	return -1


# selects a tool to use
func select_tool(tool_name : String) -> void:
	match tool_name:
		"lock":
			lock_mode_on = !lock_mode_on
			block_lock_system.update_blocks(!lock_mode_on)
			lock_selection_node.select(lock_mode_on)
			remove_selection_node.select(false)
		"remove":
			object_remover_system.toggle_remove_mode()
			lock_selection_node.select(false)
			remove_mode_on = !remove_mode_on
			remove_selection_node.select(remove_mode_on)
		"voltmeter":
			voltmeter_selection_node.select(true)
			ammeter_selection_node.select(false)
		"ammeter":
			voltmeter_selection_node.select(false)
			ammeter_selection_node.select(true)
	
	selected_tool = tool_name


# switches to the next controller type
func roundrobin() -> void:
	var new_ct = 0
	if controller_type + 1 < ControllerType.size():
		new_ct = controller_type + 1
	set_controller_type(new_ct)


func set_controller_type(new_ct : int) -> void:
	controller_type = new_ct
	# update mesh
	if right_controller_models:
		var all_children = right_controller_models.get_children()
		# hide all
		for child in all_children:
			child.visible = false
		# show the new one. this assumes meshes are in the same order as the enum ControllerType
		var new_mesh = right_controller_models.get_child(new_ct)
		new_mesh.visible = true
