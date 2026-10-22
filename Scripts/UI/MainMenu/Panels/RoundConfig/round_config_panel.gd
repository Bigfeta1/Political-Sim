extends Panel

@onready var country_list = $CountryScroll/CountryList

var country_entry_panel = preload("res://Scenes/MainMenu/Panels/round_config_country_container.tscn")

func initialize(config):
	for file_path in config.country_files:
		var country_data = JSON.parse_string(FileAccess.get_file_as_string(file_path))
		var entry = country_entry_panel.instantiate()
		entry.get_node("CountryTitle").text = country_data["country_name"]
		country_list.add_child(entry)
