extends Node

# the schematic representation and logic of th circuit
class_name Schematic

var all_blocks = {}
var block_passes = {}
var connections = []
var loops_array = []
var unique_elements = 0
var Ab = []
var gauss_solver = GaussSolver.new()

func _ready():
	# just test values, delete later
	var voltage_source1 = VoltageSource.new()
	var voltage_source2 = VoltageSource.new()
	var resistor1 = Resistor.new()
	var resistor2 = Resistor.new()
	var resistor3 = Resistor.new()
	var junction1 = Junction.new()
	var junction2 = Junction.new()
	
	voltage_source1.potential = 5.0
	voltage_source2.potential = 2.0
	resistor1.resistance = 2000.0
	resistor2.resistance = 2000.0
	resistor3.resistance = 1000.0 # this is the superimposed one
	
	all_blocks = {
		1: voltage_source1,
		2: voltage_source2,
		3: resistor1,
		4: resistor2,
		5: resistor3,
		6: junction1,
		7: junction2
	}
	
	connections = [
		[1, 3, "p"],
		[3, 6],
		[6, 4],
		[6, 5],
		[5, 7],
		[7, 1, "n"],
		[4, 2, "p"],
		[2, 7, "n"]
	]
	
	loop_current_method()


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
	
	# initiliaze
	loops_array.clear()
	unique_elements = 0
	
	# 1) loop over keys in the all_blocks dict and take each one as a starting point of the loop
	# 4) stop process when all elements have been included at least once

	# always start with the first element (which should be a VoltageSource)
	var starting_element = all_blocks[1]
	# we also make sure the second element is the same for all loops, so they all go in the same direction
	# (makes things easier)
	var second_element_dict = get_next_element(1, 0)
	var second_element_index = second_element_dict["next_element_index"]
	var second_element_additional_info = second_element_dict["additional_info"]
	
	var second_element = all_blocks[second_element_index]
	
	# here we save if second element is connected to first voltage sources positiv or negative side
	starting_element.connection_side = second_element_additional_info
	
	while unique_elements != all_blocks.size():
		var loop = []
		loop.append(starting_element)
		loop.append(second_element)
		
		var prev_element_index = second_element_index
		var prev_prev_element_index = 1
		
		# get next element using connections dict
		for y in range(connections.size()):
			var next_element_dict = get_next_element(prev_element_index, prev_prev_element_index)
			var next_element_index = next_element_dict["next_element_index"]
			var additional_info = next_element_dict["additional_info"]
			
			if next_element_index == -1:
				print("Element not found in connections array")
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
		
#		if (i == all_blocks.size()):
#			i = 1
#		else:
#			i += 1
	
	#define_loop_directions()
	
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
	var solutions = gauss_solver.solve(Ab)
	print("solutions:", solutions)
	
	# 7) solve for element currents and voltages using Ohm's Law
		

# makes a custom deep copy. if object type doesnt match, returns an empty variable
#func deep_copy(obj: Object) -> Object:
#	var new_obj
#	if obj is VoltageSource:
#		new_obj = VoltageSource.new()
#		new_obj.potential = obj.potential
#		new_obj.loop_number = obj.loop_number
#	elif obj is Resistor:
#		new_obj = Resistor.new()
#		new_obj.resistance = obj.resistance
#		new_obj.loop_number = obj.loop_number
#		new_obj.superposition = obj.superposition
#	elif obj is Junction:
#		new_obj = Junction.new()
#		new_obj.loop_number = obj.loop_number
#
#	return new_obj
		

#func define_loop_directions():
#	# loops can have direction a or b
#	# the first loop has dirction a and is the reference value
#	loop_directions.append("a")
#
#	# if loop starts out from positiv pole of voltage source, it's a
#	# else it's b
##	for i in range(loops_array.size()):
##		if 
#
#	# get the first resistor in the first loop
#	var first_loop_first_resistor
#	for element in loops_array[0]:
#		if element is Resistor:
#			first_loop_first_resistor = element;
#			break;
#
#	# therefore we skip the first loop here
#	for i in range(1, loops_array.size()):
#		for element in loops_array[i]:
#			if element is Resistor:
#				if element == first_loop_first_resistor:
#					loop_directions.append("a")
#				else:
#					loop_directions.append("b")
	

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
							
#							if !direction_checked:
#								# check direction of loops, make sure they go both
#								# in the same (else our calculations won't work later)
#								if loop1[y-1] == loop2[yy-1] and loop1[y-2] == loop2[yy-2]: 
#									print("time to invert")
#									# we invert it after looping through loop2 is done
#									direction_checked = true
				
	
# returns next element index based on connections array
func get_next_element(prev_index: int, prev_prev_index: int) -> Dictionary:
	# randomize order so we don't end up going down same paths
	randomize()
	connections.shuffle()
	var additional_info = ""
	var next_element_index = -1
	for i in range(connections.size()):
		if connections[i][0] == prev_index and connections[i][1] != prev_prev_index:
			next_element_index = connections[i][1]
			if connections[i].size() > 2:
				additional_info = connections[i][2]
			break
		elif connections[i][1] == prev_index and connections[i][0] != prev_prev_index:
			next_element_index = connections[i][0]
			if connections[i].size() > 2:
				additional_info = connections[i][2]
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
		# count unique elements without counting junctions
#		for element in new_loop:
#			if !(element is Junction):
#				unique_elements += 1
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
	
	
# finds a block_type in all_blocks and returns index or -1
#func find_block(block_type) -> int:
#	for i in range(all_blocks.size()):
#		if all_blocks[i] is block_type:
#			return i
#	return -1
