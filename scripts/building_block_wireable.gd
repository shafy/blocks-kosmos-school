extends BuildingBlock

# a class of BuildingBlock that can be wired to others
# add Wireable objects as children (they expected BuildingBlockWireable as direct parent)
class_name BuildingBlockWireable


var all_wireables := []


func add_wireable(new_wireable) -> void:
	all_wireables.append(new_wireable)


# goes through all wireables, and if min one of them is still wired, makes block ungrabbable
func refresh_wireables():
	is_grabbable = true
	for w in all_wireables:
		if w.is_wired:
			is_grabbable = false
			break
