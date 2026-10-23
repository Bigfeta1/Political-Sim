extends Node

const MAP_CONSTRUCTOR = "res://Scenes/ConfigureRound/map_constructor.tscn"

func run(configurator):
	var map_constructor = SceneLoader.instantiate(MAP_CONSTRUCTOR)
	configurator.logic.add_child(map_constructor)
	map_constructor.initialize(configurator.three_d, configurator.logic.get_system("map_graph"))
	map_constructor.construct()
	configurator.logic.remove_child(map_constructor)
	map_constructor.queue_free()
