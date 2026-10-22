extends Node

var state_manager = preload("res://Scenes/ConfigureRound/state_manager.tscn")

func run(configurator):
	var manager = state_manager.instantiate()
	configurator.logic.add_child(manager)
	configurator.logic.register("state_manager", manager)
