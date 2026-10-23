extends RefCounted

const MAPS_DIR = "res://Data/Maps/"

static func find_by_id(map_id: String) -> Dictionary:
	var path = MAPS_DIR + map_id + "_land.json"
	if not FileAccess.file_exists(path):
		return {}

	return JSON.parse_string(FileAccess.get_file_as_string(path))

static func find_biomes_by_id(map_id: String) -> Dictionary:
	var path = MAPS_DIR + map_id + "_biomes.json"
	if not FileAccess.file_exists(path):
		return {}

	return JSON.parse_string(FileAccess.get_file_as_string(path))
