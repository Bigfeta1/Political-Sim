extends Node

const COUNTRY_DIR = "res://Data/Country_Data/"

var country_files := []

func _ready() -> void:
	country_files = find_country_files()
	country_files.sort()

static func find_country_files() -> Array:
	var files := []

	for file_name in DirAccess.get_files_at(COUNTRY_DIR):
		if file_name.ends_with(".json"):
			files.append(COUNTRY_DIR + file_name)

	return files
