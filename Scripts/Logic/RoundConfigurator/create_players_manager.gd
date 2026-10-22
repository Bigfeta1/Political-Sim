extends Node

func run(configurator):
	var config = configurator.config
	var country_factory = configurator.logic.get_system("country_manager").country_logic.country_factory

	var opponent_count = config.player_count - 1
	var opponent_ids = select_opponents(config, opponent_count)

	create_opponents(country_factory, opponent_ids)

#region Selection
func select_opponents(config, opponent_count: int) -> Array:
	var candidates = get_candidate_ids(config)
	candidates.shuffle()

	return candidates.slice(0, opponent_count)

func get_candidate_ids(config) -> Array:
	var ids := []

	for file_path in config.country_files:
		var country_id = read_country_id(file_path)
		if country_id != config.player_country_id:
			ids.append(country_id)

	return ids

func read_country_id(file_path: String) -> String:
	var country_data = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	return country_data["id"]
#endregion

#region Creation
func create_opponents(country_factory, opponent_ids: Array) -> void:
	for country_id in opponent_ids:
		country_factory.create_country(country_id)
#endregion
