extends Node

signal entry_created(entry: Node)

const GameConfig = preload("res://Scripts/Logic/round_config.gd")

var save_entry = preload("res://Scenes/MainMenu/Panels/LoadPanel/load_container.tscn")

func initialize(save_list):
	if not FileAccess.file_exists(SaveWriter.SAVE_PATH):
		return

	var save_data = JSON.parse_string(FileAccess.get_file_as_string(SaveWriter.SAVE_PATH))
	create_entry({
		"path": SaveWriter.SAVE_PATH,
		"country_name": find_player_country_name(save_data),
	}, save_list)

func create_entry(entry_data, save_list):
	var entry = save_entry.instantiate()
	entry.initialize(entry_data)
	entry_created.emit(entry)
	save_list.add_child(entry)

func find_player_country_name(save_data) -> String:
	for country in save_data["countries"]:
		if country["is_player"]:
			return find_country_name(country["id"])

	return ""

func find_country_name(country_id) -> String:
	for file_path in GameConfig.find_country_files():
		var country_data = JSON.parse_string(FileAccess.get_file_as_string(file_path))
		if country_data["id"] == country_id:
			return country_data["country_name"]

	return ""
