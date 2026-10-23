extends Node

signal mortality_changed(new_mortality)

var age_bands                    # Each child of AgeBands is an age band (age_band.gd), youngest first.
var risk_factors                 # Each child of RiskFactors is a risk factor (risk_factor.gd).

var mortality: Dictionary        # Population and deaths per band.
var risk_prevalence: Dictionary  # Share of people at each exposure level per risk factor key.

func initialize(bands, factors):
	age_bands = bands
	risk_factors = factors

func set_mortality(value):
	mortality = value
	for band in age_bands.get_children():
		var band_data = value["bands"][band.key]
		band.death_rates = {}
		for cause in band_data["deaths"]:
			band.death_rates[cause] = band_data["deaths"][cause] / band_data["population"]
	mortality_changed.emit(value)

func set_risk_prevalence(value):
	risk_prevalence = value
	for factor in risk_factors.get_children():
		if value.has(factor.key):
			factor.start_prevalence = value[factor.key]
			factor.prevalence = value[factor.key].duplicate()

func death_rate(band) -> float:
	# Called by LifeExpectancy for Life Table calculation
	# Each cause's death rate in the band is scaled by every risk factor's multiplier for that cause.

	var total := 0.0
	for cause in band.death_rates:
		var cause_rate = band.death_rates[cause]
		for factor in risk_factors.get_children():
			cause_rate *= factor.multiplier(cause, band)
		total += cause_rate
	return total
