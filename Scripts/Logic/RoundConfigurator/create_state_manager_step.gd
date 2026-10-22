extends Node

const STATE_MANAGER = "res://Scenes/ConfigureRound/state_manager.tscn"

func run(configurator):
	var manager = SceneLoader.instantiate(STATE_MANAGER)
	configurator.logic.add_child(manager)
	configurator.logic.register("state_manager", manager)
