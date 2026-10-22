extends Panel

@onready var country_list = $CountryScroll/CountryList

var country_entry_panel = preload("res://Scenes/MainMenu/Panels/round_config_country_container.tscn")

func initialize(config):
	var country_group = ButtonGroup.new()

	for file_path in config.country_files:
		var country_data = JSON.parse_string(FileAccess.get_file_as_string(file_path))
		var entry = country_entry_panel.instantiate()
		entry.get_node("CountryTitle").text = country_data["country_name"]
		entry.button_group = country_group
		country_list.add_child(entry)
