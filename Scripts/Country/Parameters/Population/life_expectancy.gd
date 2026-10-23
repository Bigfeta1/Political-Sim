extends Node

signal life_expectancy_changed(new_life_expectancy)

var age_bands
var open_band
var open_band_start_years
var open_band_start_rate

var mortality
var life_expectancy
var target_life_expectancy

func initialize(bands, mortality_node):
	age_bands = bands
	mortality = mortality_node
	open_band = age_bands.get_children().back()

func _on_mortality_changed(_new_mortality):
	calibrate()
	calculate()

func calibrate():
	var table = life_table()
	open_band_start_years = (target_life_expectancy - table[0]) / table[1]
	open_band_start_rate = mortality.death_rate(open_band)

func calculate():
	var table = life_table()
	set_life_expectancy(table[0] + table[1] * open_band_start_years * open_band_start_rate / mortality.death_rate(open_band))

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

func set_life_expectancy(value):
	life_expectancy = value
	life_expectancy_changed.emit(value)
