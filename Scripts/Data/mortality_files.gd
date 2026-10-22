extends RefCounted

const MORTALITY_DIR = "res://Data/Mortality/"

# Returns an empty dictionary when no file exists for this id.
static func find_by_id(country_id: String) -> Dictionary:
	var path = MORTALITY_DIR + "mortality_" + country_id + ".json"
	if not FileAccess.file_exists(path):
		return {}

	return JSON.parse_string(FileAccess.get_file_as_string(path))
