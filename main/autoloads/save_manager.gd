extends Node
const SAVE_FILE_PATH: String = "user://save_file.json"

func save_game() -> void:
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var data: Dictionary = {}
	if save_file:
		for node in get_tree().get_nodes_in_group("Persist"):
			var node_data: Dictionary = node.save()
			data[node.name] = node_data
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)
	save_file.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if save_file:
		var json_text = save_file.get_as_text()
		for node in get_tree().get_nodes_in_group("Persist"):
			var save_file_data = JSON.parse_string(json_text)
			if not save_file_data == null :
				if save_file_data.has(node.name):
					node.load_save_data(save_file_data[node.name])
					
	save_file.close()


func reset_file() -> void:
	DirAccess.remove_absolute(SAVE_FILE_PATH)
