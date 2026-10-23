extends Node

const MapCell = preload("res://Scripts/Map/map_cell.gd")
const WaterDataTexture = preload("res://Scripts/Map/water_data_texture.gd")
const WATER_MATERIAL = preload("res://Assets/Shaders/water_tile_material.tres")

const TERRAIN_TILES = {
	MapCell.Terrain.LAND: "res://Scenes/Map/Tiles/land_tile.tscn",
	MapCell.Terrain.WATER: "res://Scenes/Map/Tiles/water_tile.tscn",
}

const TILE_SIZE = 1.0

func build(cells: Dictionary, hex_tile_grid: Node3D) -> void:
	var centre = find_centre(cells)
	configure_water(cells, centre)

	for cell in cells.values():
		hex_tile_grid.add_child(create_tile(cell, centre))

func configure_water(cells: Dictionary, centre: Vector3) -> void:
	WATER_MATERIAL.set_shader_parameter("map_data", WaterDataTexture.build(cells))
	WATER_MATERIAL.set_shader_parameter("map_origin", Vector2(WaterDataTexture.find_origin(cells)))
	WATER_MATERIAL.set_shader_parameter("map_centre", Vector2(centre.x, centre.z))
	WATER_MATERIAL.set_shader_parameter("max_coast_distance", float(WaterDataTexture.MAX_COAST_DISTANCE))

func create_tile(cell, centre: Vector3) -> Node3D:
	var tile = SceneLoader.instantiate(TERRAIN_TILES[cell.terrain])
	tile.position = to_position(cell.coordinate) - centre
	return tile

func find_centre(cells: Dictionary) -> Vector3:
	var minimum = Vector3.INF
	var maximum = -Vector3.INF

	for coordinate in cells:
		var tile_position = to_position(coordinate)
		minimum = minimum.min(tile_position)
		maximum = maximum.max(tile_position)

	return (minimum + maximum) / 2.0

func to_position(coordinate: Vector2i) -> Vector3:
	var x = TILE_SIZE * sqrt(3.0) * (coordinate.x + coordinate.y / 2.0)
	var z = TILE_SIZE * 1.5 * coordinate.y
	return Vector3(x, 0.0, z)
