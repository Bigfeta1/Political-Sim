extends RefCounted

enum Terrain {
	LAND,
	WATER,
}

var coordinate: Vector2i
var terrain: int
var neighbours: Array[Vector2i] = []

func _init(cell_coordinate: Vector2i, cell_terrain: int) -> void:
	coordinate = cell_coordinate
	terrain = cell_terrain
