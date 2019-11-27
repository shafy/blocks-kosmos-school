extends Spatial
# logic to generate a wire between two points
class_name WireGenerator

enum State {OFF, ON}
var current_state = State.ON
var point1: Vector3
var point2: Vector3
var point1_set = false
var schematic
var building_block1
var additional_info1

func _ready():
	schematic = get_node("/root/Main/Schematic")
	if !schematic:
		print("Schematic node not found. Make sure there's one in root/Main/Schematic'")
	
	point1_set = false

# creat a wire point - if it created the second point, then it also draws the wire
func create_wire_point(new_point: Vector3, building_block: BuildingBlock, additional_info: String):
	if !point1_set:
		point1 = new_point
		point1_set = true
		building_block1 = building_block
		additional_info1 = additional_info
	else:
		if point1 == new_point:
			return
		
		point2 = new_point
		draw_wire()
		update_schematic(building_block1, additional_info1, building_block, additional_info, "add")
		point1_set = false

# generates the wire based on the values of point1 and point2
func draw_wire():
	var line_renderer = LineRenderer.new()
	add_child(line_renderer)
	line_renderer.startThickness = 0.01
	line_renderer.endThickness = 0.01
	line_renderer.points = [point1, point2]

# update the schematic with this new connection
func update_schematic(_building_block1: BuildingBlock, _ai1: String, _building_block2: BuildingBlock, _ai2: String, _schematic_action: String):
	schematic.update_schematic(_building_block1, _ai1, _building_block2, _ai2, _schematic_action)

# signal is emittd by wirable.gd
func _on_Wirable_wire_tapped(new_point: Vector3, building_block: BuildingBlock, additional_info: String):
	# only create new wire point if WireGenerator is ON
	if current_state == State.OFF: return
	create_wire_point(new_point, building_block, additional_info)
