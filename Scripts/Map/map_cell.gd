extends RefCounted

enum Terrain {
	LAND,
	WATER,
	DESERT,
}

enum Relief {
	FLAT,
	HILL,
	MOUNTAIN,
}

var coordinate: Vector2i
var terrain: int
var desert_region := 0
var has_city := false
var has_river := false
var relief: int = Relief.FLAT
var neighbours: Array[Vector2i] = []

func _init(cell_coordinate: Vector2i, cell_terrain: int) -> void:
	coordinate = cell_coordinate
	terrain = cell_terrain
