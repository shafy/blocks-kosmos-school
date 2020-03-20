extends Spatial


class_name MeasurePointSystem


# removes a measure point based on connection id
func remove_by_connection_id(connection_id : String):
	var all_measure_points = get_children()
	for mp in all_measure_points:
		if mp.connection_id == connection_id:
			mp.queue_free()

