extends Spatial


class_name BaseController


signal tool_changed

var tools : Array
var current_tool : int
var joystick_x := 0.0
var joystick_x_prev := 0.0
var palette_visible

var selected := false setget set_selected, get_selected

onready var palette = $Palette
onready var right_controller = get_node(global_vars.CONTR_RIGHT_PATH)
onready var grab_area_right = get_node(global_vars.CONTR_RIGHT_PATH + "/controller_grab/GrabArea")


func set_selected(new_value):
	selected = new_value
	visible = new_value
	# select first tool per default
	if tools:
		tools[0].select(true)


func get_selected():
	return selected


func _ready():
	if palette:
		tools = palette.get_children()
		palette.visible = false
	else:
		print("Error: Palette not found in ", name)


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
	if tools.size() >= tool_index - 1:
		tools[tool_index].select(true)
		current_tool = tool_index
		emit_signal("tool_changed")
