extends Node

func run(configurator):
	var save_data = configurator.config.save_data

	if save_data.is_empty():
		return

	var state_manager = configurator.logic.get_system("state_manager")

	state_manager.load_save_data(save_data["round"])
	state_manager.phase_manager.load_save_data(save_data["phase"])
	state_manager.turn_manager.load_save_data(save_data["turn"])

	restore_countries(configurator.logic.get_system("country_manager"), save_data["countries"])

func restore_countries(country_manager, saved_countries: Array) -> void:
	for country in country_manager.country_list.get_children():
		for saved_country in saved_countries:
			if saved_country["id"] == country.data.id:
				country.load_save_data(saved_country)
