extends Node
const SAVE_FILE_PATH: String = "user://save_file.json"
const BASE_SAVE_FILE_PATH: String = "res://main/base_save_file.json"
const SETTINGS_CONFIG_PATH: String = "user://setting_cfg.json"
var empty_save_file: bool = false

func save_settings(settings_data: Dictionary) -> void:
	var settings_cfg = FileAccess.open(SETTINGS_CONFIG_PATH, FileAccess.WRITE)
	if settings_cfg:
		var json_string = JSON.stringify(settings_data)
		settings_cfg.store_line(json_string)
		settings_cfg.close()

func get_settings_cfg() -> Dictionary:
	if not FileAccess.file_exists(SETTINGS_CONFIG_PATH):
		return {}
	var settings_cfg = FileAccess.open(SETTINGS_CONFIG_PATH, FileAccess.READ)
	var json_text =  settings_cfg.get_as_text()
	if json_text != "":
		var parse_result = JSON.parse_string(json_text)
		if parse_result:
			return parse_result
	return {}
	

func save_game() -> void:
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	var data: Dictionary = {}
	if save_file:
		for node in get_tree().get_nodes_in_group("Persist"):
			var node_data: Dictionary = node.save()
			data[node.name] = node_data
	empty_save_file = false
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)
	save_file.close()


func load_game() -> void:
	var json_text: String
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		empty_save_file = true
		# Copy base save template
		var base_save_file = FileAccess.open(BASE_SAVE_FILE_PATH, FileAccess.READ)
		if base_save_file:
			json_text = base_save_file.get_as_text()
			base_save_file.close()
			
			var new_save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
			if new_save_file:
				new_save_file.store_string(json_text)
				new_save_file.close()
			
			UiManager.reset_saved_ui()
	else:
		# Load existing save
		var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if save_file:
			json_text = save_file.get_as_text()
			save_file.close()
	
	# Apply save data to nodes
	if json_text != "":
		var parse_result = JSON.parse_string(json_text)
		if parse_result:
			for node in get_tree().get_nodes_in_group("Persist"):
				if parse_result.has(node.name):
					node.load_save_data(parse_result[node.name])


func reset_file() -> void:
	DirAccess.remove_absolute(SAVE_FILE_PATH)
	load_game()
