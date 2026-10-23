extends Node

const TileFactory = preload("res://Scripts/Map/tile_factory.gd")

var map_graph
var centre: Vector3
var tiles := {}

func initialize(map_graph_reference):
	map_graph = map_graph_reference
	centre = TileFactory.find_centre(map_graph.cells)
	tiles.clear()

func add_tile(coordinate: Vector2i, tile: Node3D) -> void:
	tiles[coordinate] = tile

func get_cell(coordinate: Vector2i):
	return map_graph.cells.get(coordinate)

func get_tile(coordinate: Vector2i):
	return tiles.get(coordinate)

#region Coordinates
func find_coordinate(grid_position: Vector3) -> Vector2i:
	var map_position = grid_position + centre
	var r = map_position.z / (TileFactory.TILE_SIZE * 1.5)
	var q = map_position.x / (TileFactory.TILE_SIZE * sqrt(3.0)) - r / 2.0
	return round_axial(q, r)

func round_axial(q: float, r: float) -> Vector2i:
	var s = -q - r
	var rounded_q = roundf(q)
	var rounded_r = roundf(r)
	var rounded_s = roundf(s)
	var q_error = absf(rounded_q - q)
	var r_error = absf(rounded_r - r)
	var s_error = absf(rounded_s - s)

	if q_error > r_error and q_error > s_error:
		rounded_q = -rounded_r - rounded_s
	elif r_error > s_error:
		rounded_r = -rounded_q - rounded_s

	return Vector2i(int(rounded_q), int(rounded_r))
#endregion
