extends Node

# The band's key in the mortality file, e.g. "30-49".
@export var key: String
@export var start_age: int
# Years the band covers; 0 for the open-ended last band.
@export var width: int

var population
# Deaths in this band per WHO cause name, at game start.
var deaths: Dictionary

# Each cause's deaths are scaled by every risk factor's multiplier for that cause.
func death_rate(risk_factors: Array) -> float:
	var total := 0.0
	for cause in deaths:
		var cause_deaths = deaths[cause]
		for factor in risk_factors:
			cause_deaths *= factor.multiplier(cause, self)
		total += cause_deaths
	return total / population
