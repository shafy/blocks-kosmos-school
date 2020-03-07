extends Node
# saves and reads from saved file

var file_path = "user://savegame.json"

func _ready():
	# check if file exits
	var save_file = File.new()
	if !save_file.file_exists(file_path):
		# initialize if file doesn't exist
		write_to_file({})


func read_from_file() -> Dictionary:
	# get file content
	var save_file = File.new()
	save_file.open(file_path, File.READ)
	var content = parse_json(save_file.get_as_text())
	save_file.close()
	return content


func write_to_file(new_content : Dictionary) -> void:
	var save_file = File.new()
	var empty_json = to_json(new_content)
	save_file.open(file_path, File.WRITE)
	save_file.store_string(empty_json)
	save_file.close()


func save(key : String, value):
	var content = read_from_file()
	content[key] = value
	write_to_file(content)


func get(key : String):
	var content = read_from_file()
	if content.has(key):
		return content[key]
	else:
		return null
