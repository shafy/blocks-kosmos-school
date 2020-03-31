extends Spatial

# helps to measure params for e.g. voltemeter and ammeter
class_name MeasurePoint


var connection_ids : Array setget set_connection_ids, get_connection_ids
var parent_block : BuildingBlock

onready var ammeter_controller := get_node(global_vars.AMMETER_CONTR_PATH)
onready var voltmeter_controller := get_node(global_vars.VOLTMETER_CONTR_PATH)
onready var controller_system := get_node(global_vars.CONTROLLER_SYSTEM_PATH)
onready var cube_ampere := $CubeAmpere
onready var cube_volt := $CubeVolt
onready var area := $Area

enum MeasurePointType {CONNECTION, BLOCK}
export (MeasurePointType) var measure_point_type = MeasurePointType.CONNECTION setget set_measure_point_type, get_measure_point_type


func set_connection_ids(new_value):
	connection_ids = new_value


func get_connection_ids():
	return connection_ids


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
	ammeter_controller.connect("ammeter_selected", self, "_on_Ammeter_Controller_ammeter_selected")
	ammeter_controller.connect("ammeter_unselected", self, "_on_Ammeter_Controller_ammeter_unselected")
	voltmeter_controller.connect("voltmeter_selected", self, "_on_Voltmeter_Controller_voltmeter_selected")
	voltmeter_controller.connect("voltmeter_unselected", self, "_on_Voltmeter_Controller_voltmeter_unselected")
	
	update_cube_visibility()


func _on_Ammeter_Controller_ammeter_selected():
	if measure_point_type == MeasurePointType.BLOCK:
		visible = true
		update_monitoring(true)


func _on_Ammeter_Controller_ammeter_unselected():
	if measure_point_type == MeasurePointType.BLOCK:
		visible = false
		update_monitoring(false)


func _on_Voltmeter_Controller_voltmeter_selected():
	if measure_point_type == MeasurePointType.CONNECTION:
		visible = true
		update_monitoring(true)


func _on_Voltmeter_Controller_voltmeter_unselected():
	if measure_point_type == MeasurePointType.CONNECTION:
		visible = false
		update_monitoring(false)


func update_monitoring(is_monitoring: bool) -> void:
	area.set_monitoring(is_monitoring)
	area.set_monitorable(is_monitoring)


func add_connection_id(new_id: String) -> void:
	if !connection_ids.has(new_id):
		connection_ids.append(new_id)


func remove_connection_id(old_id: String) -> void:
	if connection_ids.has(old_id):
		connection_ids.erase(old_id)


func get_current() -> float:
	if parent_block and parent_block is BuildingBlock:
		return parent_block.current
	else:
		return 0.0


# either shows ampere or volt cube based on measure point type
func update_cube_visibility() -> void:
	if !cube_ampere or !cube_volt:
		return
		
	if measure_point_type == MeasurePointType.BLOCK:
		cube_ampere.visible = true
		cube_volt.visible = false
	else:
		cube_ampere.visible = false
		cube_volt.visible = true
