extends Spatial


class_name BaseController


signal tool_changed

var tools : Array
var current_tool : int
var joystick_x := 0.0
var joystick_x_prev := 0.0
var palette_visible
var select_default := false

var selected := false setget set_selected, get_selected

onready var palette = $Palette
onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
onready var grab_area_right = get_node(global_vars.CONTR_RIGHT_PATH + "/controller_grab/GrabArea")


func set_selected(new_value):
	selected = new_value
	visible = new_value
	# select first tool by default
	if select_default:
		select_tool(0)


func get_selected():
	return selected


func _ready():
	if palette:
		tools = palette.get_children()
		palette.visible = false
	else:
		print("Error: Palette not found in ", name)
	
	connect("tool_changed", self, "_on_Base_Controller_tool_changed")
	right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
	


func _process(delta):
	if !selected:
		return
	
	joystick_x = right_controller.get_joystick_axis(vr.CONTROLLER_AXIS.JOYSTICK_X)
	var curr_joystick_pos = joystick_position()
	if curr_joystick_pos == 0 and palette.visible:
		palette.visible = false
		
	if curr_joystick_pos > 0:
		palette.visible = true
		select_tool(curr_joystick_pos - 1)
	
	joystick_x_prev = joystick_x


# implement this in child
func _on_Base_Controller_tool_changed():
	pass


# implement this in child
func _on_right_ARVRController_button_pressed(button_number):
	pass


func joystick_position() -> int:
	if joystick_x <= 0.5 and joystick_x >= -0.5:
		return 0
	
	if joystick_x > 0.5 and joystick_x_prev <= 0.5:
		return 1
	
	if joystick_x < -0.5 and joystick_x_prev >= -0.5:
		return 2
	
	return -1


func select_tool(tool_index : int):
	# unselect others
	for t in tools:
		t.select(false)
	
	# check if tool exists
	if tools.size() > tool_index:
		tools[tool_index].select(true)
		current_tool = tool_index
		emit_signal("tool_changed")
