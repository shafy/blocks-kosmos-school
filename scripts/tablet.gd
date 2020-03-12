extends Spatial

# this is the tablet the player can display in order to add blocks etc.
class_name Tablet


var positions_array: Array
var tablet_config : Array
var all_labels : Array

onready var tablet_items = $Screens/Blocks/TabletItems
onready var positions = $Screens/Blocks/Positions

export (PackedScene) var lamp_5o
export (PackedScene) var lamp_10o
export (PackedScene) var battery_3v
export (PackedScene) var battery_9v
export (PackedScene) var switch
export (PackedScene) var wire
export (PackedScene) var text_label_2d_scene

func _ready():
	# get this child node so we can add instanced scenes as children later
	if !tablet_items:
		print("No Node with name TabletItems found as child of Tablet")
		
	
	# set up positions_array
	if !positions:
		print("No Node with name Positions found as child of Tablet")
	else:
		positions_array = positions.get_children()
	
#	refresh()


func _on_Building_Block_block_deleted(block):
	if block.tablet_pos_id == -1:
		return
		
	# we need to restore / count up on the tablet for this block
	var pos_id = block.tablet_pos_id
	
	if tablet_config[pos_id]["quantity"] == 0:
		spawn_mini(pos_id)
	
	tablet_config[pos_id]["quantity"] += 1
	tablet_config[pos_id]["label_ref"].set_label_text(str(tablet_config[pos_id]["quantity"]))


func create_setup(setup_params : Dictionary):
	var curr_pos = 0
	for k in setup_params.keys():
		if setup_params[k] == 0:
			continue
		
		var config_item = {
			"mini_name": k,
			"quantity": setup_params[k]
		}
		
		tablet_config.append(config_item)
		spawn_mini(curr_pos)
		spawn_label(curr_pos)
		curr_pos += 1


func clear_tablet():
	var tablet_items_children = tablet_items.get_children()
	for i in range(tablet_items_children.size()):
		tablet_items_children[i].queue_free()
	
	for label in all_labels:
		label.queue_free()
	
	tablet_config = []
	all_labels = []


func spawn_mini(mini_pos: int):
	var mini_name = tablet_config[mini_pos]["mini_name"]
	var current_item
	
	match mini_name:
		"Lamps_5o":
			current_item = lamp_5o.instance()
		"Lamps_10o":
			current_item = lamp_10o.instance()
		"Batteries_3v":
			current_item = battery_3v.instance()
		"Batteries_9v":
			current_item = battery_9v.instance()
		"Switches":
			current_item = switch.instance()
		"Wires":
			current_item = wire.instance()
	
	if !(current_item is Mini):
		print("Make sure that item is a BuildingBlock for Tablet")
		return
	
	tablet_items.add_child(current_item)
	current_item.transform.origin = positions_array[mini_pos].transform.origin
	current_item.tablet_pos_id = mini_pos
	tablet_config[mini_pos]["label_name"] = current_item.label_name


func respawn_mini(pos_id : int):
	if tablet_config[pos_id]["quantity"] > 1:
		spawn_mini(pos_id)
		
		# update quantity
		tablet_config[pos_id]["quantity"] -= 1
		
		update_label_text(pos_id)
	elif tablet_config[pos_id]["quantity"] == -1:
		spawn_mini(pos_id)
		


func spawn_label(pos_id : int):
	var mini_quantity = tablet_config[pos_id]["quantity"]
	
	var quantity_label = text_label_2d_scene.instance()
	positions_array[pos_id].add_child(quantity_label)
	
	quantity_label.scale = Vector3(0.7, 0.5, 1)
	quantity_label.transform.origin = Vector3(0, 0, -0.02)
	quantity_label.set_h_align(TextLabel2D.Align.ALIGN_CENTER)
	quantity_label.set_v_align(TextLabel2D.VAlign.VALIGN_BOTTOM)
	quantity_label.set_font_size_multiplier(3)
	quantity_label.set_background_color(Color(0.1, 0.1, 0.1))
	
	tablet_config[pos_id]["label_ref"] = quantity_label
	
	update_label_text(pos_id)
	
	all_labels.append(quantity_label)


func update_label_text(pos_id: int):
	if !tablet_config[pos_id].has("label_ref"):
		return
	var quantity = tablet_config[pos_id]["quantity"]
	if quantity == -1:
		quantity = "∞"
	
	var label_text = str(tablet_config[pos_id]["label_name"], " (", quantity, ")")
	tablet_config[pos_id]["label_ref"].set_label_text(label_text)
