extends Node

signal life_expectancy_changed(new_life_expectancy)

# Each child of AgeBands is an age band (age_band.gd), youngest first. The last one is open-ended.
@onready var age_bands = $AgeBands
@onready var risk_factors = $RiskFactors
@onready var open_band = age_bands.get_children().back()

var life_expectancy:
	set(value):
		life_expectancy = value
		life_expectancy_changed.emit(value)

# The country's real life expectancy at birth. The open band is calibrated so the life table reproduces it.
var target_life_expectancy

var open_band_start_years
var open_band_start_rate

# Population and deaths per band. Setting it calibrates against the target, so the target must be set first.
var mortality: Dictionary:
	set(value):
		mortality = value
		for band in age_bands.get_children():
			band.population = value["bands"][band.key]["population"]
			band.deaths = value["bands"][band.key]["deaths"]
		calibrate()
		calculate()

# Share of people at each exposure level per risk factor key. A factor without an entry has no effect.
var risk_prevalence: Dictionary:
	set(value):
		risk_prevalence = value
		for factor in risk_factors.get_children():
			if value.has(factor.key):
				factor.start_prevalence = value[factor.key]
				factor.prevalence = value[factor.key].duplicate()

# Years lived before the open band and the share of people who reach it, for one person at birth.
func life_table() -> Array:
	var survivors := 1.0
	var years := 0.0
	for band in age_bands.get_children():
		if band == open_band:
			break
		var rate = band.death_rate(risk_factors.get_children())
		var dying = band.width * rate / (1 + band.width / 2.0 * rate)
		var next_survivors = survivors * (1 - dying)
		years += band.width * next_survivors + band.width / 2.0 * (survivors - next_survivors)
		survivors = next_survivors
	return [years, survivors]

# A flat death rate over the open band overstates the years lived in it, so the band takes the years that reproduce the target.
func calibrate():
	var table = life_table()
	open_band_start_years = (target_life_expectancy - table[0]) / table[1]
	open_band_start_rate = open_band.death_rate(risk_factors.get_children())

# Years lived in the open band scale inversely with its death rate.
func calculate():
	var table = life_table()
	life_expectancy = table[0] + table[1] * open_band_start_years * open_band_start_rate / open_band.death_rate(risk_factors.get_children())
