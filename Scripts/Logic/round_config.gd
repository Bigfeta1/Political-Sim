extends Node

const COUNTRY_DIR = "res://Data/Country_Data/"

var country_files := []
var player_country_id := ""
var player_count := 3

func _ready() -> void:
	country_files = find_country_files()
	country_files.sort()

func select_country(country_id: String) -> void:
	player_country_id = country_id

static func find_country_files() -> Array:
	var files := []

	for file_name in DirAccess.get_files_at(COUNTRY_DIR):
		if file_name.ends_with(".json"):
			files.append(COUNTRY_DIR + file_name)

	return files
