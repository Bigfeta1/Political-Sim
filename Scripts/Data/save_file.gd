extends RefCounted

static func read(path: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path))

static func find_player_id(save_data: Dictionary) -> String:
	for country in save_data["countries"]:
		if country["is_player"]:
			return country["id"]

	return ""
