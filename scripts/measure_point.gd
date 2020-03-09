extends Spatial

# helps to measure params for e.g. voltemeter and ammeter
class_name MeasurePoint


var connection_id : String setget set_connection_id, get_connection_id
var parent_block : BuildingBlock

onready var measure_controller := get_node(global_vars.MEASURE_CONTR_PATH)
onready var controller_system := get_node(global_vars.CONTROLLER_SYSTEM_PATH)
onready var cube_ampere := $CubeAmpere
onready var cube_volt := $CubeVolt

enum MeasurePointType {CONNECTION, BLOCK}
export (MeasurePointType) var measure_point_type = MeasurePointType.CONNECTION setget set_measure_point_type, get_measure_point_type


func set_connection_id(new_value):
	connection_id = new_value


func get_connection_id():
	return connection_id


func set_measure_point_type(new_value):
	measure_point_type = new_value
	update_cube_visibility()


func get_measure_point_type():
	return measure_point_type


func _ready():
	visible = false
	if measure_point_type == MeasurePointType.BLOCK:
		parent_block = get_parent()
	
	# connect
	measure_controller.connect("ammeter_selected", self, "_on_Measure_Controller_ammeter_selected")
	measure_controller.connect("voltmeter_selected", self, "_on_Measure_Controller_voltmeter_selected")
	controller_system.connect("controller_type_changed", self, "_on_Controller_System_controller_type_changed")
	
	update_cube_visibility()


func _on_Measure_Controller_ammeter_selected():
	if measure_point_type == MeasurePointType.BLOCK:
		visible = true
	else:
		visible = false


func _on_Measure_Controller_voltmeter_selected():
	if measure_point_type == MeasurePointType.CONNECTION:
		visible = true
	else:
		visible = false


func _on_Controller_System_controller_type_changed():
	visible = false


func get_current() -> float:
	if parent_block and parent_block is BuildingBlock:
		return parent_block.current
	else:
		return 0.0


# either shows ampere or volt cube based on measure point type
func update_cube_visibility() -> void:
	if measure_point_type == MeasurePointType.BLOCK:
		cube_ampere.visible = true
		cube_volt.visible = false
	else:
		cube_ampere.visible = false
		cube_volt.visible = true
	
