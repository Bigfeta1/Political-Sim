extends Node

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

var cells := {}

func generate(dimensions: Vector2i) -> void:
	cells.clear()

	create_cells(dimensions)
	connect_neighbours()

#region Saving
func get_save_data() -> Dictionary:
	var saved_cells := []

	for cell in cells:
		saved_cells.append([cell.x, cell.y])

	return {"cells": saved_cells}

func load_save_data(data: Dictionary) -> void:
	cells.clear()

	for saved_cell in data["cells"]:
		cells[Vector2i(int(saved_cell[0]), int(saved_cell[1]))] = []

	connect_neighbours()
#endregion

#region Cells
func create_cells(dimensions: Vector2i) -> void:
	for row in dimensions.y:
		for column in dimensions.x:
			cells[to_axial(column, row)] = []

func to_axial(column: int, row: int) -> Vector2i:
	return Vector2i(column - floori(row / 2.0), row)
#endregion

#region Neighbours
func connect_neighbours() -> void:
	for cell in cells:
		for direction in DIRECTIONS:
			var neighbour = cell + direction
			if cells.has(neighbour):
				cells[cell].append(neighbour)
#endregion
