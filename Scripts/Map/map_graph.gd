extends Node

const WIDTH = 8
const HEIGHT = 8

const DIRECTIONS = [
	Vector2i(1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(-1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
]

var cells := {}

func generate() -> void:
	cells.clear()

	create_cells()
	connect_neighbours()

#region Cells
func create_cells() -> void:
	for row in HEIGHT:
		for column in WIDTH:
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
