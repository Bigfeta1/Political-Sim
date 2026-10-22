extends Button

const SaveFile = preload("res://Scripts/Data/save_file.gd")

var save_selector
var config

func initialize(selector, round_config):
	save_selector = selector
	config = round_config

func _pressed() -> void:
	if not save_selector.has_selection:
		return

	config.save_data = SaveFile.read(save_selector.selected_path)
	config.player_country_id = SaveFile.find_player_id(config.save_data)

	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)
