extends Button

var save_selector
var config

func initialize(selector, round_config):
	save_selector = selector
	config = round_config

func _pressed() -> void:
	if not save_selector.has_selection:
		return

	config.save_data = JSON.parse_string(FileAccess.get_file_as_string(save_selector.selected_path))
	config.player_country_id = find_player_country_id(config.save_data)

	GameState.state_change_requested.emit(GameState.State.CONFIGURE_ROUND)

func find_player_country_id(save_data) -> String:
	for country in save_data["countries"]:
		if country["is_player"]:
			return country["id"]

	return ""
