extends Node

func run(configurator):
	var country_factory = configurator.logic.get_system("country_manager").country_logic.country_factory
	var turn_manager = configurator.logic.get_system("state_manager").turn_manager

	country_factory.country_created.connect(turn_manager.add_player)
	country_factory.create_country(configurator.config.player_country_id)
