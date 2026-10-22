extends Node

signal entry_created(entry: Node)

const COUNTRY_ENTRY = "res://Scenes/MainMenu/Panels/RoundConfig/round_config_country_container.tscn"

func initialize(config, country_list):
	var country_group = ButtonGroup.new()

	for file_path in config.country_files:
		var country_data = JSON.parse_string(FileAccess.get_file_as_string(file_path))
		create_entry(country_data, country_group, country_list)

func create_entry(country_data, country_group, country_list):
	var entry = SceneLoader.instantiate(COUNTRY_ENTRY)
	entry.initialize(country_data, country_group)
	entry_created.emit(entry)
	country_list.add_child(entry)
