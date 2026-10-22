extends Node

var country_manager = preload("res://Scenes/ConfigureRound/country_manager.tscn")

func run(configurator):
	var manager = country_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("country_manager", manager)
	manager.initialize()
