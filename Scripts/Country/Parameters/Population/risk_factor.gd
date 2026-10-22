extends Node

const RiskFactorFiles = preload("res://Scripts/Data/risk_factor_files.gd")

# The factor's data file in Data/RiskFactors, e.g. "smoking".
@export var key: String

# Bands starting below this age are unaffected.
var min_age
var reference_level

# Relative risk of death per exposure level and cause; causes not listed are unaffected.
var relative_risks: Dictionary

# Share of people at each exposure level, at game start and now. Empty until the country's prevalence is known.
var start_prevalence: Dictionary
var prevalence: Dictionary

func _ready() -> void:
	var data = RiskFactorFiles.read(key)
	min_age = data["min_age"]
	reference_level = data["reference_level"]
	relative_risks = data["relative_risks"]

# How much this factor scales a cause's deaths in a band, compared with game start.
func multiplier(cause: String, band) -> float:
	if prevalence.is_empty() or band.start_age < min_age:
		return 1.0
	return mean_risk(prevalence, cause) / mean_risk(start_prevalence, cause)

# Average relative risk across the population; the reference level has a relative risk of 1.
func mean_risk(shares: Dictionary, cause: String) -> float:
	var risk := 0.0
	for level in shares:
		if level == reference_level:
			risk += shares[level]
		else:
			risk += shares[level] * relative_risks[level].get(cause, 1.0)
	return risk
