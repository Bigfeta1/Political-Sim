extends Node

@onready var tile_factory = $TileFactory

var three_d
var map_graph
var tile_directory

func initialize(three_d_reference, map_graph_reference, tile_directory_reference):
	three_d = three_d_reference
	map_graph = map_graph_reference
	tile_directory = tile_directory_reference

func construct() -> void:
	tile_factory.build(map_graph.cells, three_d.hex_tile_grid, tile_directory)
