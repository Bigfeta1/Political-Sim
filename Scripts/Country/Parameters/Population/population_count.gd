extends Node

signal population_count_changed(new_population_count)

var age_bands
var settlements
var population_count

func initialize(bands, settlements_node):
	age_bands = bands
	settlements = settlements_node

func _on_band_populations_changed(_new_band_populations):
	count_bands()

func count_bands():
	var total := 0.0
	for band in age_bands.get_children():
		band.population = settlements.band_population(band.key)
		total += band.population
	set_population_count(total)

func set_population_count(value):
	population_count = value
	population_count_changed.emit(value)
