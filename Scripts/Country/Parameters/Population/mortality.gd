extends Node

signal mortality_changed(new_mortality)

# Each child of AgeBands is an age band (age_band.gd), youngest first. Each child of RiskFactors is a risk factor (risk_factor.gd).
var age_bands
var risk_factors

# Population and deaths per band. LifeExpectancy calibrates against its target when this is set, so the target must be set first.
var mortality: Dictionary

# Share of people at each exposure level per risk factor key. A factor without an entry has no effect.
var risk_prevalence: Dictionary

func initialize(bands, factors):
	age_bands = bands
	risk_factors = factors

#region SETTERS

func set_mortality(value):
	mortality = value
	for band in age_bands.get_children():
		band.population = value["bands"][band.key]["population"]
		band.deaths = value["bands"][band.key]["deaths"]
	mortality_changed.emit(value)

func set_risk_prevalence(value):
	risk_prevalence = value
	for factor in risk_factors.get_children():
		if value.has(factor.key):
			factor.start_prevalence = value[factor.key]
			factor.prevalence = value[factor.key].duplicate()

#endregion

# Each cause's deaths in the band are scaled by every risk factor's multiplier for that cause.
func death_rate(band) -> float:
	var total := 0.0
	for cause in band.deaths:
		var cause_deaths = band.deaths[cause]
		for factor in risk_factors.get_children():
			cause_deaths *= factor.multiplier(cause, band)
		total += cause_deaths
	return total / band.population
