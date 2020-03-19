extends Node

# the schematic representation and logic of th circuit
class_name Schematic

var all_blocks = []
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


func _on_Building_Block_block_deleted(current_block : BuildingBlock):
	remove_block(current_block)


func remove_block(current_block : BuildingBlock) -> void:
	var current_block_index = all_blocks.find(current_block)
	
	if current_block_index == -1:
		return
	
	# remove this block from schematic
	all_blocks.remove(current_block_index)
	
	# disconnect signal
	if (current_block.is_connected("block_deleted", self, "_on_Building_Block_block_deleted")):
		current_block.disconnect("block_deleted", self, "_on_Building_Block_block_deleted")
	
	# remove its connections
	var result_connections = find_connections_by_block(current_block)
	
	for conn in result_connections:
		remove_connection(conn[2])
	
	# re-calculate
	loop_current_method()


# add new blocks to schematic and returns connection id
func add_blocks(
	_building_block1: BuildingBlock,
	_polarity1: int,
	_connection_side1: int,
	_building_block2: BuildingBlock,
	_polarity2: int,
	_connection_side2: int
) -> String:
	
	print("*******")
	print("Adding these two blocks:")
	print("- new block 1 ", _building_block1.name)
	print("- new block 2 ", _building_block2.name)
	
	# add blocks
	add_new_block(_building_block1)
	add_new_block(_building_block2)
	
	# add connection
	# generate random alphanumeric string as connection id
	var random_id := gen_random_connection_id()
	
	# check if random_id already exists in connections array before appending
	while find_connection_by_id(random_id) != -1:
		random_id = gen_random_connection_id()
	
	connections.append([
		{"block": _building_block1, "polarity": _polarity1, "connection_side": _connection_side1},
		{"block": _building_block2,  "polarity": _polarity2, "connection_side": _connection_side2},
		random_id
		])
	
	print("*******")
	print("all_blocks:")
	for block in all_blocks:
		print("- " + block.name)
	print("*******")
	print("conn count ", connections.size())
	print("*******")
	print("all connections:")
	print(connections)
	print("*******")
	for connection in connections:
		print("- " + connection[0]["block"].name + " to " + connection[1]["block"].name)
	
	return random_id


func add_new_block(block) -> void:
	if !all_blocks.has(block):
		# doesn't exist, add
		# it's a voltage source and there's no voltage source otherwise, add to first position
		if block is VoltageSource and !(all_blocks is VoltageSource):
			all_blocks.push_front(block)
		else:
			all_blocks.append(block)
		
		# connect to deletion signal
		if !block.is_connected("block_deleted", self, "_on_Building_Block_block_deleted"):
			block.connect("block_deleted", self, "_on_Building_Block_block_deleted", [CONNECT_DEFERRED])
		
		


# removes connection from schematic
func remove_connection(connection_id : String) -> void:
	# find connection index
	var removed_connection
	var connection_index = find_connection_by_id(connection_id)
	if connection_index != -1:
		removed_connection = connections[connection_index]
		connections.remove(connection_index)
	
		# also remove block(s) that don't have a connection anymore from all_blocks
		var block1 = removed_connection[0]["block"]
		var block2 = removed_connection[1]["block"]
		
		if !block_has_connection(block1):
			var temp_index = all_blocks.find(block1)
			if temp_index != -1:
				remove_block(block1)
		
		if !block_has_connection(block2):
			var temp_index = all_blocks.find(block2)
			if temp_index != -1:
				remove_block(block2)


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


func find_connections_by_block(current_block : BuildingBlock) -> Array:
	var return_array := []
	
	for i in range(connections.size()):
		if connections[i][0]["block"] == current_block:
			return_array.append(connections[i])
		
		if connections[i][1]["block"] == current_block:
			return_array.append(connections[i])
	
	return return_array
	
# checks if this block has min 1 connection
func block_has_connection(current_block : BuildingBlock) -> bool:
	for c in connections:
		if c[0]["block"] == current_block or c[1]["block"] == current_block:
			return true
	
	return false


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
	clear_block_attributes()
	loops_array.clear()
	unique_elements = 0
	
	# 1) loop over keys in the all_blocks dict and take each one as a starting point of the loop
	# 4) stop process when all elements have been included at least once

	# always start with the first element (which should be a VoltageSource)
	var starting_element = all_blocks[0]
	if !(starting_element is VoltageSource):
		return
		
	starting_element.directional_polarity = SnapArea.Polarity.POSITIVE
	
	# we need the fail_safe_count because the loop finding process (get_next_element()) is probablistic
	var fail_safe_count = 0
	while unique_elements != all_blocks.size() and fail_safe_count < 10:
		fail_safe_count += 1
		
		var loop = []
		loop.append(starting_element)

		# we always start from the positive side of the voltage source
		var next_element_dict = get_next_element(starting_element, null, SnapArea.Polarity.POSITIVE)
		var next_element = next_element_dict["next_element"]
		var next_element_connection_side = next_element_dict["connection_side"]
		var next_element_polarity = next_element_dict["polarity"]
		
		if !next_element:
			continue
		
		var prev_element = starting_element
		
		for y in range(connections.size()):

			var next_next_element_dict = get_next_element(next_element, prev_element)
			var next_next_element = next_next_element_dict["next_element"]
			var next_next_element_connection_side = next_next_element_dict["connection_side"]
			var next_next_element_conn_side_curr_el = next_next_element_dict["connection_side_current_element"]

			if !next_next_element:
				break
			
			if next_element_connection_side != next_next_element_conn_side_curr_el:
			
				# 2b) if loop comes back to a point other than starting point, discard
				if loop.find(next_element) > 0:
					break
				
				# TODO: not sure if this makes sense
				if next_element is Switch:
					# if the switch is not closed, cancel the loop
					if !next_element.is_closed:
						break
				
				# 2a) if loop comes to starting point, finish this loop
				# check if on negative side of voltage source (because we always start on the pos side)
				if loop.find(next_element) == 0 and next_element_polarity == SnapArea.Polarity.NEGATIVE:
					add_loop(loop)
					break
					
				# if it's a voltage source, save connection side (positive or negative)
				if next_element is VoltageSource:
					next_element.directional_polarity = next_element_polarity
						
				# if all good, append to loop
				loop.append(next_element)
			
			prev_element = next_element
			next_element = next_next_element
			
			next_element_connection_side = next_next_element_dict["connection_side"]
			next_element_polarity = next_next_element_dict["polarity"]
		
		print("unique_elements: ", unique_elements)
		print("all_blocks.size(): ", all_blocks.size())
		print("fail_safe_count: ", fail_safe_count)
	
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
	calculate_element_attributes(loop_current_solutions)


# resets block attributes
func clear_block_attributes():
	for b in all_blocks:
		if b is Resistor:
			b.current = 0.0
			b.potential = 0.0
			
			b.refresh()


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
				element.refresh()
				
				print("element.name: ", element.name)
				print("element.resistance: ", element.resistance)
				print("element.current: ", element.current)
				print("element.potential: ", element.potential)
			
			if element is VoltageSource:
				element.current = loop_currents[i]


# loop through all loops and mark superpositions
func find_superpositions():
	# resistors can share >2 mesh loops (i.e. superimposed) and we have to find those
	for i in range(loops_array.size()):
		var loop1 = loops_array[i]
		for y in range(loop1.size()):
			var element1 = loop1[y]
			if element1 is Resistor or Ammeter:
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


# returns next element based on connections array
func get_next_element(prev_block: BuildingBlock, prev_prev_block: BuildingBlock, force_polarity: int = 0) -> Dictionary:
	# randomize order so we don't end up going down same paths
	randomize()
	connections.shuffle()
	var polarity = SnapArea.Polarity.UNDEFINED
	var connection_side = null
	var connection_side_current_element = null
	var next_element_block = null
	for i in range(connections.size()):
		if connections[i][0]["block"] == prev_block and connections[i][1]["block"] != prev_prev_block:
			# if there's a forced polarity for voltage source, skip rest of iteration if no match
			if force_polarity != SnapArea.Polarity.UNDEFINED and prev_block is VoltageSource:
				if connections[i][0]["polarity"] != force_polarity:
					continue
				
			next_element_block = connections[i][1]["block"]
			polarity = connections[i][1]["polarity"]
			connection_side = connections[i][1]["connection_side"]
			connection_side_current_element = connections[i][0]["connection_side"]
			break
		elif connections[i][1]["block"] == prev_block and connections[i][0]["block"] != prev_prev_block:
			# if there's a forced polarity for voltage source, skip rest of iteration if no match
			if force_polarity != SnapArea.Polarity.UNDEFINED and prev_block is VoltageSource:
				if connections[i][1]["polarity"] != force_polarity:
					continue
					
			next_element_block = connections[i][0]["block"]
			polarity = connections[i][0]["polarity"]
			connection_side = connections[i][0]["connection_side"]
			connection_side_current_element = connections[i][1]["connection_side"]
			break
	
	return {
		"next_element": next_element_block,
		"polarity": polarity,
		"connection_side": connection_side,
		"connection_side_current_element": connection_side_current_element
	}
	
		
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
					if current_element.directional_polarity == SnapArea.Polarity.POSITIVE:
						b += float(current_element.potential)
					else:
						b -= float(current_element.potential)
				else:
					# if it's the first element, do the inverse
					if current_element.directional_polarity == SnapArea.Polarity.POSITIVE:
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
							if loops_array[i][0].directional_polarity == SnapArea.Polarity.POSITIVE:
								a[c] -= float(current_element.resistance)
							else:
								a[c] += float(current_element.resistance)
						else:
							# in this case we still need to add or substract the first one
							if (current_element.superposition["connections"].find(c) == 0):
								if loops_array[i][0].directional_polarity == SnapArea.Polarity.POSITIVE:
									a[c] -= float(current_element.resistance)
								else:
									a[c] += float(current_element.resistance)
							else:
								if loops_array[i][0].directional_polarity == SnapArea.Polarity.POSITIVE:
									a[c] += float(current_element.resistance)
								else:
									a[c] -= float(current_element.resistance)
				else:
					if loops_array[i][0].directional_polarity == SnapArea.Polarity.POSITIVE:
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


# returns an array of blocks between two given connections
func get_blocks_between(conn_id_1, conn_id_2) -> Array:
	var conn_array = []
	
	# get blocks
	var conn_1_index = find_connection_by_id(conn_id_1)
	if conn_1_index == -1:
		return conn_array
	var conn_1 = connections[conn_1_index]
	var block_1_1 = conn_1[0]["block"]
	var block_1_2 = conn_1[1]["block"]
	
	var conn_2_index = find_connection_by_id(conn_id_2)
	if conn_2_index == -1:
		return conn_array
	var conn_2 = connections[conn_2_index]
	var block_2_1 = conn_2[0]["block"]
	var block_2_2 = conn_2[1]["block"]
	
	# find loop that contains both blocks
	var loop = []
	var block_1_1_index
	var block_2_1_index
	for l in loops_array:
		block_1_1_index = l.find(block_1_1)
		block_2_1_index = l.find(block_2_1)
		if block_1_1_index != -1 and block_2_1_index != 1:
			loop = l
			break
	
	if loop.empty():
		return conn_array
	
	var start_block
	# we need to find out which blocks to include in return value based on order
	# for block 1
	var next_index
	if loop.size() - 1 == block_1_1_index:
		next_index = 0
	else:
		next_index = block_1_1_index + 1
	if loop[next_index] == block_1_2:
		start_block = block_1_2
	else:
		start_block = block_1_1
	
	# for block 2
	var end_block
	if loop.size() - 1 == block_2_1_index:
		next_index = 0
	else:
		next_index = block_2_1_index + 1
	if loop[next_index] == block_2_2:
		end_block = block_2_2
	else:
		end_block = block_2_1
	
#	print("start_block: ", start_block.name)
#	print("end_block: ", end_block.name)
	# now add all the blocks to conn_array, including start and end block
	var running = true
	var i = loop.find(start_block)
	while running:
		var curr_block = loop[i]
		if curr_block == end_block:
			running = false
		else:
			conn_array.append(loop[i])
#			print("added block ", loop[i].name)
		
		if loop.size() - 1 == i:
			i = 0
		else:
			i += 1
	
	return conn_array


# resets schematic
func clear_schematic():
	all_blocks = []
	connections = []
	loops_array = []
	unique_elements = 0
	Ab = []
	gauss_solver = GaussSolver.new()
	rng = RandomNumberGenerator.new()
