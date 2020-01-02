extends Node

# the schematic representation and logic of th circuit
class_name Schematic

var all_blocks = []
var block_passes = {}
var connections = []
var loops_array = []
var unique_elements = 0
var Ab = []
var gauss_solver = GaussSolver.new()
var rng = RandomNumberGenerator.new()
var alphanumeric_array = [
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
	"o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
	"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"
]

func _ready():
#	var power_button = get_node("/root/Main/PowerButton")
#	if power_button:
#		power_button.connect("button_pressed", self, "_on_PowerButton_button_pressed")
#	else:
#		print("Didn't find PowerButton in /root/Main/Powerbutton")
	# just test values, delete later
#	var voltage_source1 = VoltageSource.new()
#	var voltage_source2 = VoltageSource.new()
#	var resistor1 = Resistor.new()
#	var resistor2 = Resistor.new()
#	var resistor3 = Resistor.new()
#	var junction1 = Junction.new()
#	var junction2 = Junction.new()
	
#	voltage_source1.potential = 5.0
#	voltage_source2.potential = 2.0
#	resistor1.resistance = 2000.0
#	resistor2.resistance = 2000.0
#	resistor3.resistance = 1000.0 # this is the superimposed one
	
#	all_blocks = [
#		voltage_source1,
#		voltage_source2,
#		resistor1,
#		resistor2,
#		resistor3,
#		junction1,
#		junction2
#	]
	
#	connections = [
#		[{"block_index": 2}, {"block_index": 5}],
#		[{"block_index": 5}, {"block_index": 3}],
#		[{"block_index": 5}, {"block_index": 4}],
#		[{"block_index": 4}, {"block_index": 6}],
#		[{"block_index": 0, "additional_info": "p"}, {"block_index": 2}],
#		[{"block_index": 0, "additional_info": "n"}, {"block_index": 6}],
#		[{"block_index": 1, "additional_info": "p"}, {"block_index": 1}],
#		[{"block_index": 1, "additional_info": "n"}, {"block_index": 6}],
#	]
	
	#loop_current_method()
	pass


func _on_Building_Block_block_deleted(current_block : BuildingBlock) -> void:
	remove_block(current_block)


func remove_block(current_block : BuildingBlock) -> void:
	var current_block_index = all_blocks.find(current_block)
	
	if current_block_index == -1:
		return
	
	# remove this block from schematic
	all_blocks.remove(current_block_index)
	
	# remove its connections
	var result_connections = find_connections_by_block(current_block_index)
	
	for conn in result_connections:
		remove_connection(conn[2])
	
	# re-calculate
	loop_current_method()


# add new blocks to schematic and returns connection id
func add_blocks(_building_block1: BuildingBlock, _ai1: String, _building_block2: BuildingBlock, _ai2: String) -> String:
	# add blocks
	add_new_block(_building_block1)
	add_new_block(_building_block2)
		
	# add connection
	# get indicies to use for connections
	var block1index = all_blocks.find(_building_block1)
	var block2index = all_blocks.find(_building_block2)
	
	# generate random alphanumeric string as connection id
	var random_id := gen_random_connection_id()
	
	# check if random_id already exists in connections array before appending
	while find_connection_by_id(random_id) != -1:
		random_id = gen_random_connection_id()
	
	connections.append([
		{"block_index": block1index, "additional_info": _ai1},
		{"block_index": block2index, "additional_info": _ai2},
		random_id
		])
	
	print("ADDED")
	print("all_blocks: ", all_blocks)
	print("connections: ", connections)
	
	return random_id


func add_new_block(block: BuildingBlock) -> void:
	if !all_blocks.has(block):
		# doesn't exist, add
		# it's a voltage source and there's no voltage source otherwise, add to first position
		if block is VoltageSource and !(all_blocks is VoltageSource):
			all_blocks.push_front(block)
		else:
			all_blocks.append(block)
		
		# connect to deletion signal
		block.connect("block_deleted", self, "_on_Building_Block_block_deleted")


# removes connection from schematic
func remove_connection(connection_id : String) -> void:
	# find connection index
	var removed_connection
	var connection_index = find_connection_by_id(connection_id)
	if connection_index != -1:
		removed_connection = connections[connection_index]
		connections.remove(connection_index)
	
		# also remove block(s) that don't have a connection anymore from all_blocks
		var temp_index = removed_connection[0]["block_index"]
		
		if !block_has_connection(temp_index):
			if temp_index != -1:
				all_blocks.remove(temp_index)
		
		# find new index because it might have shifted from removing the previous one
		var block2 = all_blocks[removed_connection[1]["block_index"]]
		temp_index = all_blocks.find(block2)
		if temp_index != -1 and !block_has_connection(temp_index):
			if temp_index != -1:
				all_blocks.remove(temp_index)
	
	print("REMOVED")
	print("all_blocks: ", all_blocks)
	print("connections: ", connections)


func gen_random_connection_id() -> String:
	var random_id : String
	for n in range (9):
		rng.randomize()
		var random_n = rng.randi_range(0, alphanumeric_array.size() - 1)
		random_id += alphanumeric_array[random_n]
	
	return random_id


func find_connection_by_id(connection_id : String) -> int:
	for i in range(connections.size()):
		if connections[i][2] == connection_id:
			return i
	
	return -1


func find_connections_by_block(current_block_index : int) -> Array:
	var return_array := []
	
	for i in range(connections.size()):
		if connections[i][0]["block_index"] == current_block_index:
			return_array.append(connections[i])
		
		if connections[i][1]["block_index"] == current_block_index:
			return_array.append(connections[i])
	
	return return_array
	
# checks if this block has min 1 connection based on its index
func block_has_connection(block_index : int) -> bool:
	for c in connections:
		if c[0]["block_index"] == block_index or c[1]["block_index"]:
			return true
	
	return false


# checks if block already in dictionary
#func find_value_in_dictionary(dict: Dictionary, val) -> int:
#	var i = 0
#	for k in dict:
#		if dict[k] == val:
#			return i
#		i += 1
#
#	return -1

func loop_current_method():
	# we're doing circuit analysis using the loop current method (https://en.wikipedia.org/wiki/Mesh_analysis)
	# also on KA: https://www.khanacademy.org/science/electrical-engineering/ee-circuit-analysis-topic/ee-dc-circuit-analysis/a/ee-loop-current-method
	
	# 1) loop over keys in the all_blocks dict and take each one as a starting point of the loop
	# 2a) if loop comes back to starting point, finish this loop
	# 2b) if loop has no more connections or comes back to another point other starting point, discard it
	# 3) compare loop elements to all loops before it. if it doesn't contain at least one different element, discard it
	# 4) stop process when all elements have been included at least once
	# 5) write Kirchhoffs' Voltage Law equations for each loop
	# 6) solve the resulting system
	# 7) solve for element currents and voltages using Ohm's Law
	
	if all_blocks.empty() or connections.empty():
		return
	
	# initiliaze
	loops_array.clear()
	unique_elements = 0
	
	# 1) loop over keys in the all_blocks dict and take each one as a starting point of the loop
	# 4) stop process when all elements have been included at least once

	# always start with the first element (which should be a VoltageSource)
	var starting_element = all_blocks[0]
	# we also make sure the second element is the same for all loops, so they all go in the same direction
	# (makes things easier)
	
	var second_element_dict = get_next_element(0, -1)
	var second_element_index = second_element_dict["next_element_index"]
	var second_element_additional_info = second_element_dict["additional_info"]
	
	var second_element = all_blocks[second_element_index]
	
	# here we save if second element is connected to first voltage sources positiv or negative side
	starting_element.connection_side = second_element_additional_info
	# we need this because the loop finding process (get_next_element()) is probablistic
	var fail_safe_count = 0
	if all_blocks.size() > 2:
		while unique_elements != all_blocks.size() and fail_safe_count < 100:
			fail_safe_count += 1
			
			var loop = []
			loop.append(starting_element)
			loop.append(second_element)
			
			var prev_element_index = second_element_index
			var prev_prev_element_index = 0
			
			# get next element using connections dict
			for y in range(connections.size()):
				var next_element_dict = get_next_element(prev_element_index, prev_prev_element_index)
				var next_element_index = next_element_dict["next_element_index"]
				var additional_info = next_element_dict["additional_info"]
				
				if next_element_index == -1:
					# no next element found
					break
				
				var next_element = all_blocks[next_element_index]
				
				# 2b) if loop has no more connections, discard
				if (!next_element):
					break
				
				# 2b) if loop comes back to a point other than starting point, discard
				if loop.find(next_element) > 0:
					break
				
				# 2a) if loop comes to starting point, finish this loop
				if (loop.find(next_element) == 0):
					if !(next_element is Junction):
						add_loop(loop)
					break
				
				# if it's a voltage source, save connection side (positive or negative)
				if next_element is VoltageSource:
					next_element.connection_side = additional_info
						
				# if all good, append to loop
				loop.append(next_element)
				
				
				prev_prev_element_index = prev_element_index
				prev_element_index = next_element_index
	else:
		# in this case there are only two elements in the circuit
		# check if their connnected in a closed loop
		if connections.size() == 2:
			var loop = []
			loop.append(starting_element)
			loop.append(second_element)
			add_loop(loop)
	
	# define elements that superimpose on each other
	find_superpositions()
	
	# 5) write Kirchhoffs' Voltage Law equations for each loop
	setup_KVL()
	
	for i in range(loops_array.size()):
		print("loop #", i)
		for k in range(loops_array[i].size()):
			var current_el = loops_array[i][k]
			if current_el is VoltageSource:
				print("VS ", current_el.potential)
			elif current_el is Resistor:
				print("R ", current_el.resistance)
			else:
				print("J ", current_el)
			
	print("Ab ", Ab)
	
	# 6) solve the resulting system
	var loop_current_solutions = gauss_solver.solve(Ab)
	print("solutions:", loop_current_solutions)
	
	# 7) solve for element currents and voltages using Ohm's Law
	clear_block_attributes()
	calculate_element_attributes(loop_current_solutions)


# resets block attributes
func clear_block_attributes():
	for b in all_blocks:
		if b is Resistor:
			b.current = 0.0
			b.potential = 0.0
			
			if b is Lamp:
				b.update_light()


# finds currents and voltages for all elements in the circuit based on
# the previously calculated loop currents
func calculate_element_attributes(loop_currents: Array):
	for i in range(loops_array.size()):
		for k in range (loops_array[i].size()):
			var element = loops_array[i][k]
			if element is Resistor:
				var loop_current = 0.0
				if element.superposition["connections"].empty():
					loop_current = loop_currents[i]
				else:
					# else if element is superimposed
					for c in element.superposition["connections"]:
						loop_current += loop_currents[c]
				
				element.current = loop_current
				element.potential = element.resistance * loop_current
				
				if element is Lamp:
					element.update_light()
				
				print("element.resistance: ", element.resistance)
				print("element.current: ", element.current)
				print("element.potential: ", element.potential)

# loop through all loops and mark superpositions
func find_superpositions():
	# resistors can share >2 mesh loops (i.e. superimposed) and we have to find those
	for i in range(loops_array.size()):
		var loop1 = loops_array[i]
		for y in range(loop1.size()):
			var element1 = loop1[y]
			if element1 is Resistor:
				# compare to all loops with index greater
				for ii in range(i+1, loops_array.size()):
					# here we could optimize a bit and avoid checking loops that
					# already have superpositions with each other, but no huge gains
					var loop2 = loops_array[ii]
					var direction_checked = false
					for yy in range(loop2.size()):
						var element2 = loop2[yy]
						if element2 == element1:
							# append superposition loop number if it doesn't already have it
							if !element1.superposition["connections"].has(i):
								element1.superposition["connections"].append(i)
							if !element1.superposition["connections"].has(ii):
								element1.superposition["connections"].append(ii)
									
							# also check direction to know how to calculate later on
							if loop1[y-1] == loop2[yy-1]:
								# same direction
								element1.superposition["direction"] = "same"
							else:
								# different direction
								element1.superposition["direction"] = "different"


# returns next element index based on connections array
func get_next_element(prev_index: int, prev_prev_index: int) -> Dictionary:
	# randomize order so we don't end up going down same paths
	randomize()
	connections.shuffle()
	var additional_info = ""
	var next_element_index = -1
	for i in range(connections.size()):
		if connections[i][0]["block_index"] == prev_index and connections[i][1]["block_index"] != prev_prev_index:
			next_element_index = connections[i][1]["block_index"]
			if connections[i][1].has("additional_info"):
				additional_info = connections[i][1]["additional_info"]
			break
		elif connections[i][1]["block_index"] == prev_index and connections[i][0]["block_index"] != prev_prev_index:
			next_element_index = connections[i][0]["block_index"]
			if connections[i][0].has("additional_info"):
				additional_info = connections[i][0]["additional_info"]
			break
	
	return {"next_element_index": next_element_index, "additional_info": additional_info}
	
		
# writes Kirchhoff's Voltage Law equations for loops in loops_array
func setup_KVL():
	# we're using gaussian elimination to solve the system
	# therefore, we have to create the augmented matrix Ab first
	Ab = []
	
	for i in range(loops_array.size()):
		# make sure a has the size of number of loops we have
		var a = []
		for k in range(loops_array.size()):
			a.append(0)
		var b = 0
		for y in range(loops_array[i].size()):
			var current_element = loops_array[i][y]
			if !current_element:
				print("Element not found in all_blocks while setting up KVL")
				break
				
			if current_element is VoltageSource:
				# add to last column
				if y > 0:
					if current_element.connection_side == "p":
						b += float(current_element.potential)
					else:
						b -= float(current_element.potential)
				else:
					# if it's the first element, do the inverse
					if current_element.connection_side == "p":
						b -= float(current_element.potential)
					else:
						b += float(current_element.potential)

			elif current_element is Resistor:		
				if !current_element.superposition["connections"].empty():
					
					current_element.superposition["connections"].sort()
					# depending on if the loops go on the same or different directions through
					# superimposed element, add or remove
					# general formula: R * (i(1) + i(2) + i(n) or R * (i(1) - i(2) - i(n))
					
					# here we also care about the direction of the loop current
					# if we started out from the positive side of the voltage source
					# we need to subtract voltages, otherwise add them
					for c in current_element.superposition["connections"]:
						if (current_element.superposition["direction"] == "same"):
							if loops_array[i][0].connection_side == "p":
								a[c] -= float(current_element.resistance)
							else:
								a[c] += float(current_element.resistance)
						else:
							# in this case we still need to add or substract the first one
							if (current_element.superposition["connections"].find(c) == 0):
								if loops_array[i][0].connection_side == "p":
									a[c] -= float(current_element.resistance)
								else:
									a[c] += float(current_element.resistance)
							else:
								if loops_array[i][0].connection_side == "p":
									a[c] += float(current_element.resistance)
								else:
									a[c] -= float(current_element.resistance)
				else:
					if loops_array[i][0].connection_side == "p":
						a[i] -= float(current_element.resistance)
					else:
						a[i] += float(current_element.resistance)
		
		# add b value to the end of a
		a.append(b)
		# append a Ab to form the augmented matrix Ab
		Ab.append(a)
				
			
# 3) adds loops to loops_array if at least one element is different than existing loops		
func add_loop(new_loop: Array):
	# if it's the first loop, just add it
	if loops_array.empty():
		loops_array.append(new_loop)
		unique_elements = new_loop.size()
		return
	
	
	# flatten all loops together for easier comparison
	var flat_loops = []
	for i in range(loops_array.size()):
		flat_loops += loops_array[i]
	
	var loop_unique = true
	for i in range(new_loop.size()):
		# as soon as we find an element that an existing
		# loop doesn't have, append
		# continue comparing so we can increment unique_elements
		if !flat_loops.has(new_loop[i]):
			unique_elements += 1
			if (loop_unique):
				loops_array.append(new_loop)
				loop_unique = false
