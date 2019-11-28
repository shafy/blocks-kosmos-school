extends Spatial

# this is the tablet the player can display in order to add blocks etc.
class_name Tablet

var positions_array: Array
var tablet_items

export(Array, PackedScene) var tablet_item_scenes

func _ready():
	# get this child node so we can add instanced scenes as children later
	
	tablet_items = $TabletItems
	if !tablet_items:
		print("No Node with name TabletItems found as child of Tablet")
		
	
	# set up positions_array
	var positions = $Positions
	if !positions:
		print("No Node with name Positions found as child of Tablet")
	else:
		positions_array = positions.get_children()
	
		
	# load all tablet item scenes so they can be instanced later
#	for i in range(tablet_item_paths.size()):
#		print("tablet_item_paths[i]: ", tablet_item_paths[i])
		#tablet_item_scenes.append(load(tablet_item_paths[i]))
	
	# assign tablet_item_scenes to the positions and resize them
	for i in range(tablet_item_scenes.size()):
		# instance a new item
		var current_item = tablet_item_scenes[i].instance()
		
		if !(current_item is BuildingBlock):
			print("Make sure that item is a BuildingBlock for Tablet")
			return
		
		tablet_items.add_child(current_item)
		current_item.transform.origin = positions_array[i].transform.origin
		
		# resize
		current_item.make_mini()
		
		
		
