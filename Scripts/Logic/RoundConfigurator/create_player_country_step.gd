extends Node

func run(configurator):
	var country_factory = configurator.logic.get_system("country_manager").country_logic.country_factory

	var player_country = country_factory.create_country(configurator.config.player_country_id)
	player_country.data.is_player = true
