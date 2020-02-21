extends Spatial

# helps to measure params for e.g. voltemeter and ammeter
class_name MeasurePoint


var connection_id : String setget set_connection_id, get_connection_id
var parent_block : BuildingBlock

enum MeasurePointType {CONNECTION, BLOCK}
export (MeasurePointType) var measure_point_type = MeasurePointType.CONNECTION setget set_measure_point_type, get_measure_point_type


func set_connection_id(new_value):
	connection_id = new_value


func get_connection_id():
	return connection_id


func set_measure_point_type(new_value):
	measure_point_type = new_value


func get_measure_point_type():
	return measure_point_type


func _ready():
	if measure_point_type == MeasurePointType.BLOCK:
		parent_block = get_parent()


func get_current() -> float:
	if parent_block and parent_block is BuildingBlock:
		return parent_block.current
	else:
		return 0.0
