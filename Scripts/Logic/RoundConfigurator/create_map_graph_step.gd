extends Node

const MAP_GRAPH = "res://Scenes/ConfigureRound/map_graph.tscn"

func run(configurator):
	var map_graph = SceneLoader.instantiate(MAP_GRAPH)
	configurator.logic.add_child(map_graph)
	configurator.logic.register("map_graph", map_graph)
	map_graph.generate()
