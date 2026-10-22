extends Node

const COUNTRY_DIR = "res://Data/Country_Data/"

const OPTIONS = {
	"player_country": {
		"label": "Your country",
	},
}

var choices := {}
var values := {}

func _ready() -> void:
	var country_ids = find_country_files().keys()
	country_ids.sort()
	choices["player_country"] = country_ids

	for key in choices:
		if not choices[key].is_empty():
			values[key] = choices[key][0]

static func find_country_files() -> Dictionary:
	var files := {}

	for file_name in DirAccess.get_files_at(COUNTRY_DIR):
		if file_name.ends_with(".json"):
			var path = COUNTRY_DIR + file_name
			var country_data = JSON.parse_string(FileAccess.get_file_as_string(path))
			files[country_data["id"]] = path

	return files



func set_value(key, value) -> void:
	if choices.has(key) and choices[key].has(value):
		values[key] = value

func get_value(key):
	return values[key]
