extends Node

const RiskFactorFiles = preload("res://Scripts/Data/risk_factor_files.gd")

@export var key: String

var min_age
var reference_level

var relative_risks: Dictionary
var start_prevalence: Dictionary
var prevalence: Dictionary

func _ready() -> void:
	var data = RiskFactorFiles.read(key)
	min_age = data["min_age"]
	reference_level = data["reference_level"]
	relative_risks = data["relative_risks"]

func multiplier(cause: String, band) -> float:
	if prevalence.is_empty() or band.start_age < min_age:
		return 1.0
	return mean_risk(prevalence, cause) / mean_risk(start_prevalence, cause)

func mean_risk(shares: Dictionary, cause: String) -> float:
	var risk := 0.0
	for level in shares:
		if level == reference_level:
			risk += shares[level]
		else:
			risk += shares[level] * relative_risks[level].get(cause, 1.0)
	return risk
