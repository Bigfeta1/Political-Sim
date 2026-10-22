extends Node

signal entry_created(entry: Node)

const CountryFiles = preload("res://Scripts/Data/country_files.gd")
const SaveFile = preload("res://Scripts/Data/save_file.gd")

const SAVE_ENTRY = "res://Scenes/MainMenu/Panels/LoadPanel/load_container.tscn"

func initialize(save_list):
	if not FileAccess.file_exists(SaveWriter.SAVE_PATH):
		return

	var save_data = SaveFile.read(SaveWriter.SAVE_PATH)
	var player_country = CountryFiles.find_by_id(SaveFile.find_player_id(save_data))
	create_entry({
		"path": SaveWriter.SAVE_PATH,
		"country_name": player_country.get("country_name", ""),
	}, save_list)

func create_entry(entry_data, save_list):
	var entry = SceneLoader.instantiate(SAVE_ENTRY)
	entry.initialize(entry_data)
	entry_created.emit(entry)
	save_list.add_child(entry)
