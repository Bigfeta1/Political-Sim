extends Node3D

@onready var hex_tile_grid = $HexTileGrid
@onready var camera = $Camera3D

func get_tile_bounds() -> Rect2:
	var tiles = hex_tile_grid.get_children()
	var bounds = Rect2(to_ground(tiles[0].global_position), Vector2.ZERO)

	for tile in tiles:
		bounds = bounds.expand(to_ground(tile.global_position))

	return bounds

func to_ground(point: Vector3) -> Vector2:
	return Vector2(point.x, point.z)
