extends Node

const CountryFiles = preload("res://Scripts/Data/country_files.gd")

enum MapSize {
	SMALL,
}

enum MapType {
	RANDOM,
	EARTH,
}

const MAP_DIMENSIONS = {
	MapSize.SMALL: Vector2i(74, 46),
}

var country_files := []
var player_country_id := ""
var player_count := 3
var save_data := {}
var map_size := MapSize.SMALL
var map_type := MapType.EARTH

func _ready() -> void:
	country_files = CountryFiles.find_paths()
	country_files.sort()

func select_country(country_id: String) -> void:
	player_country_id = country_id

func get_map_dimensions() -> Vector2i:
	return MAP_DIMENSIONS[map_size]
