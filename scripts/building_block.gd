extends GrabbableRigidBody

# fundamental buildingblock class from which all other (e.g. lamps, voltage sources) inherit
class_name BuildingBlock

var is_mini := false

export(Vector3) var mini_size

# makes this a mini that is used to display it on the tablet
func make_mini():
	is_mini = true
	#scale = mini_size
