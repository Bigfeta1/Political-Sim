extends Node

const COUNTRY_MANAGER = "res://Scenes/ConfigureRound/country_manager.tscn"

func run(configurator):
	var manager = SceneLoader.instantiate(COUNTRY_MANAGER)
	configurator.logic.add_child(manager)
	configurator.logic.register("country_manager", manager)
	manager.initialize()
