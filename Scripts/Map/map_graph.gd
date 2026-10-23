extends Node

const MapCell = preload("res://Scripts/Map/map_cell.gd")

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

@onready var terrain_generator = $TerrainGenerator

var cells := {}

func generate(dimensions: Vector2i, map_type: int) -> void:
	cells.clear()

	create_cells(dimensions, map_type)
	connect_neighbours()

#region Saving
func get_save_data() -> Dictionary:
	var saved_cells := []

	for cell in cells.values():
		saved_cells.append([cell.coordinate.x, cell.coordinate.y, cell.terrain, cell.desert_region])

	return {"cells": saved_cells}

func load_save_data(data: Dictionary) -> void:
	cells.clear()

	for saved_cell in data["cells"]:
		var coordinate = Vector2i(int(saved_cell[0]), int(saved_cell[1]))
		cells[coordinate] = MapCell.new(coordinate, int(saved_cell[2]))
		if saved_cell.size() > 3:
			cells[coordinate].desert_region = int(saved_cell[3])

	connect_neighbours()
#endregion

#region Cells
func create_cells(dimensions: Vector2i, map_type: int) -> void:
	var terrain = terrain_generator.generate(dimensions, map_type)
	var desert_regions = terrain_generator.find_desert_regions(map_type)
	var cities = terrain_generator.find_cities(map_type)

	for offset in terrain:
		var coordinate = to_axial(offset.x, offset.y)
		cells[coordinate] = MapCell.new(coordinate, terrain[offset])
		cells[coordinate].desert_region = desert_regions.get(offset, 0)
		cells[coordinate].has_city = cities.has(offset)

func to_axial(column: int, row: int) -> Vector2i:
	return Vector2i(column - floori(row / 2.0), row)
#endregion

#region Neighbours
func connect_neighbours() -> void:
	for cell in cells:
		for direction in DIRECTIONS:
			var neighbour = cell + direction
			if cells.has(neighbour):
				cells[cell].neighbours.append(neighbour)
#endregion
