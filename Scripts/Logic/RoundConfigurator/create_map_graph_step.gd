extends Node

const MAP_GRAPH = "res://Scenes/ConfigureRound/map_graph.tscn"

func run(configurator):
	var map_graph = SceneLoader.instantiate(MAP_GRAPH)
	configurator.logic.add_child(map_graph)
	configurator.logic.register("map_graph", map_graph)

	var config = configurator.config
	var save_data = config.save_data

	if not save_data.has("map"):
		map_graph.generate(config.get_map_dimensions(), config.map_type)
	else:
		map_graph.load_save_data(save_data["map"])
