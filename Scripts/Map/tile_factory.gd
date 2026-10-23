extends Node

const HEX = "res://Assets/Tiles/Hex.glb"
const HEX_2 = "res://Assets/Tiles/Hex2.glb"

const TILE_SIZE = 1.0

func build(cells: Dictionary, hex_tile_grid: Node3D) -> void:
	var centre = find_centre(cells)

	for cell in cells:
		hex_tile_grid.add_child(create_tile(cell, centre))

func create_tile(cell: Vector2i, centre: Vector3) -> Node3D:
	var tile = SceneLoader.instantiate(HEX)
	tile.position = to_position(cell) - centre
	return tile

func find_centre(cells: Dictionary) -> Vector3:
	var minimum = Vector3.INF
	var maximum = -Vector3.INF

	for cell in cells:
		var tile_position = to_position(cell)
		minimum = minimum.min(tile_position)
		maximum = maximum.max(tile_position)

	return (minimum + maximum) / 2.0

func to_position(cell: Vector2i) -> Vector3:
	var x = TILE_SIZE * sqrt(3.0) * (cell.x + cell.y / 2.0)
	var z = TILE_SIZE * 1.5 * cell.y
	return Vector3(x, 0.0, z)
