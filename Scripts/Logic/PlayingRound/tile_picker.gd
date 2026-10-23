extends Node

const TileFactory = preload("res://Scripts/Map/tile_factory.gd")

var camera
var hex_tile_grid
var tile_directory

func initialize(camera_reference, hex_tile_grid_reference, tile_directory_reference):
	camera = camera_reference
	hex_tile_grid = hex_tile_grid_reference
	tile_directory = tile_directory_reference

func find_coordinate(screen_position: Vector2):
	var point = find_point(screen_position)
	if point == null:
		return null

	var coordinate = tile_directory.find_coordinate(hex_tile_grid.to_local(point))
	return coordinate if tile_directory.get_cell(coordinate) else null

func find_point(screen_position: Vector2):
	var top = Plane(Vector3.UP, hex_tile_grid.global_position.y + TileFactory.TILE_HEIGHT)
	return top.intersects_ray(camera.project_ray_origin(screen_position), camera.project_ray_normal(screen_position))
