extends RefCounted

const RISK_FACTOR_DIR = "res://Data/RiskFactors/"

static func read(key: String) -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(RISK_FACTOR_DIR + key + ".json"))
