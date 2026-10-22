extends RefCounted

const COUNTRY_DIR = "res://Data/Country_Data/"

static func find_paths() -> Array:
	var files := []

	for file_name in DirAccess.get_files_at(COUNTRY_DIR):
		if file_name.ends_with(".json"):
			files.append(COUNTRY_DIR + file_name)

	return files

static func read(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

# Returns an empty dictionary when no file has this id.
static func find_by_id(country_id: String) -> Dictionary:
	for path in find_paths():
		var country_data = read(path)
		if country_data["id"] == country_id:
			return country_data

	return {}
