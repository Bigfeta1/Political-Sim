extends Node

signal life_expectancy_changed(new_life_expectancy)

# Each child of AgeBands is an age band (age_band.gd), youngest first. The last one is open-ended.
var age_bands
var mortality
var open_band

var life_expectancy

# The country's real life expectancy at birth. The open band is calibrated so the life table reproduces it.
var target_life_expectancy

var open_band_start_years
var open_band_start_rate

func initialize(bands, mortality_node):
	age_bands = bands
	mortality = mortality_node
	open_band = age_bands.get_children().back()

# Years lived before the open band and the share of people who reach it, for one person at birth.
func life_table() -> Array:
	var survivors := 1.0
	var years := 0.0
	for band in age_bands.get_children():
		if band == open_band:
			break
		var rate = mortality.death_rate(band)
		var dying = band.width * rate / (1 + band.width / 2.0 * rate)
		var next_survivors = survivors * (1 - dying)
		years += band.width * next_survivors + band.width / 2.0 * (survivors - next_survivors)
		survivors = next_survivors
	return [years, survivors]

#region SETTERS

func set_life_expectancy(value):
	life_expectancy = value
	life_expectancy_changed.emit(value)

#endregion

func _on_mortality_changed(_new_mortality):
	calibrate()
	calculate()

# A flat death rate over the open band overstates the years lived in it, so the band takes the years that reproduce the target.
func calibrate():
	var table = life_table()
	open_band_start_years = (target_life_expectancy - table[0]) / table[1]
	open_band_start_rate = mortality.death_rate(open_band)

# Years lived in the open band scale inversely with its death rate.
func calculate():
	var table = life_table()
	set_life_expectancy(table[0] + table[1] * open_band_start_years * open_band_start_rate / mortality.death_rate(open_band))
