extends BaseController


class_name AmmeterController


signal ampere_measured
signal ammeter_selected
signal ammeter_unselected

onready var body_label = $BodyLabel


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
		if !(area_parent is MeasurePoint):
			return
		
		body_label.set_label_text("%.1f A" % area_parent.get_current())
		emit_signal("ampere_measured", area_parent)


# override parent
func _on_Base_Controller_controller_selected():
	._on_Base_Controller_controller_selected()
	body_label.set_label_text("Touch an A-Block and press Trigger")
	emit_signal("ammeter_selected")


# override parent
func _on_Base_Controller_controller_unselected():
	._on_Base_Controller_controller_selected()
	emit_signal("ammeter_unselected")
