extends BaseController


class_name MeasureController

var vm_first_click := false
var vm_second_click := false
var vm_conn_id_1 : String

onready var body_label = $BodyLabel
onready var title_label = $TitleLabel
onready var schematic := get_node(global_vars.SCHEMATIC_PATH) 

func _ready():
	right_controller.connect("button_pressed", self, "_on_right_ARVRController_button_pressed")
	connect("tool_changed", self, "_on_Base_Controller_tool_changed")
	

func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a building block
	var areas = grab_area_right.get_overlapping_areas()
	for area in areas:
		var area_parent = area.get_parent()
		if !(area_parent is MeasurePoint):
			return
		match current_tool:
			0:
				# ammeter
				handle_am(area_parent.get_current())
				
			1:
				# voltmeter
				handle_vm(area_parent.connection_id)
				
		break


func _on_Base_Controller_tool_changed():
	match current_tool:
		0:
			# ammeter
			title_label.set_label_text("Ammeter")
			body_label.set_label_text("Touch a Blöck and press Trigger")
		1:
			#voltmeter
			title_label.set_label_text("Voltmeter")
			body_label.set_label_text("Touch first Blöck and press Trigger")


func handle_vm(conn_id : String):
	
	# second click
	if vm_first_click and !vm_second_click:
		var blocks_array = schematic.get_blocks_between(vm_conn_id_1, conn_id)
		var pot_diff = calculate_pot_diff(blocks_array)
		body_label.set_label_text(str(pot_diff, " V"))
		vm_second_click = true
		vm_first_click = false
	else:
		# first click
		vm_first_click = true
		vm_second_click = false
		vm_conn_id_1 = conn_id
		body_label.set_label_text("Touch second Blöck and press Trigger")


func handle_am(current : float):
	body_label.set_label_text(str(current, " A"))


func calculate_pot_diff(blocks_array) -> float:
	var pot_diff = 0.0
	for block in blocks_array:
		pot_diff + block.potential
	
	return pot_diff
