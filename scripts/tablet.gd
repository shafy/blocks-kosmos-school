extends Spatial

# this is the tablet the player can display in order to add blocks etc.
class_name Tablet


var positions_array: Array
onready var tablet_items = $TabletItems
onready var positions = $Positions

export(Array, PackedScene) var tablet_item_scenes


func _ready():
	# get this child node so we can add instanced scenes as children later
	if !tablet_items:
		print("No Node with name TabletItems found as child of Tablet")
		
	
	# set up positions_array
	if !positions:
		print("No Node with name Positions found as child of Tablet")
	else:
		positions_array = positions.get_children()
	
	refresh()
	

func refresh():
	# destroy all items
	var tablet_items_children = tablet_items.get_children()
	for i in range(tablet_items_children.size()):
		tablet_items_children[i].queue_free()
	
	# instance tablet items
	for i in range(tablet_item_scenes.size()):
		# instance a new item
		var current_item = tablet_item_scenes[i].instance()
		
		if !(current_item is Mini):
			print("Make sure that item is a BuildingBlock for Tablet")
			return
		
		tablet_items.add_child(current_item)
		current_item.transform.origin = positions_array[i].transform.origin
