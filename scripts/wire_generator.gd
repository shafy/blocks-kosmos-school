extends Spatial
# logic to generate a wire between two points
class_name WireGenerator

enum State {OFF, ON}
var current_state = State.ON
var point1: Vector3
var point2: Vector3
var point1_set = false

func _ready():
	pass

# creat a wire point - if it created the second point, then it also draws the wire
func create_wire_point(new_point: Vector3):
	if !point1_set:
		point1 = new_point
		point1_set = true
	else:
		point2 = new_point
		draw_wire()

# generates the wire based on the values of point1 and point2
func draw_wire():
	var line_renderer = LineRenderer.new()
	add_child(line_renderer)
	$LineRenderer.points = [point1, point2]

# signal is emittd by wirable.gd
func _on_Wirable_wire_tapped(new_point: Vector3):
	# only create new wire point if WireGenerator is ON
	if current_state == State.OFF: return
	create_wire_point(new_point)
