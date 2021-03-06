extends BaseController


class_name VoltmeterController


signal volt_measured
signal voltmeter_selected
signal voltmeter_unselected

var vm_first_click := false
var vm_second_click := false
var vm_conn_ids_1 : Array

onready var body_label = $BodyLabel
onready var schematic := get_node(global_vars.SCHEMATIC_PATH)
onready var measure_volt_sound = $AudioStreamPlayer3DMeasureVolt


func _on_right_ARVRController_button_pressed(button_number):
	if !selected:
		return
	
	# check for trigger press
	if button_number != vr.CONTROLLER_BUTTON.INDEX_TRIGGER:
		return
	
	# check if is overlapping with a measurepoint
	var areas = grab_area_right.get_overlapping_areas()
	for area in areas:
		var area_parent = area.get_parent()
		if !(area_parent is MeasurePoint) or area_parent.measure_point_type != MeasurePoint.MeasurePointType.CONNECTION:
			continue
		if area_parent.connection_ids.size() > 0:
			handle_vm(area_parent.connection_ids)


# override parent
func _on_Base_Controller_controller_selected():
	._on_Base_Controller_controller_selected()
	body_label.set_label_text("Touch first V-Box and press Trigger")
	emit_signal("voltmeter_selected")


# override parent
func _on_Base_Controller_controller_unselected():
	._on_Base_Controller_controller_selected()
	emit_signal("voltmeter_unselected")


func handle_vm(conn_ids : Array):
	# second click
	if vm_first_click and !vm_second_click:
#		var blocks_array = schematic.get_blocks_between(vm_conn_id_1, conn_id)
		var blocks_between = schematic.get_blocks_between(vm_conn_ids_1, conn_ids)
		var pot_diff = calculate_pot_diff(blocks_between)
		body_label.set_label_text(str(pot_diff, " V"))
		vm_second_click = false
		vm_first_click = false
		if measure_volt_sound:
			measure_volt_sound.play()
		emit_signal("volt_measured", pot_diff, blocks_between)
	elif !vm_first_click:
		# first click
		vm_first_click = true
		vm_second_click = false
		vm_conn_ids_1 = conn_ids
		body_label.set_label_text("Touch second V-Box and press Trigger")


func calculate_pot_diff(blocks_between : Array) -> float:
	var pot_diff = 0.0
	print(blocks_between)
	for block in blocks_between:
		
		print(block.name)
		print(block.invert_volt)
		if block.invert_volt:
			pot_diff += block.potential
		else:
			pot_diff -= block.potential
	
	return pot_diff
