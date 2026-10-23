extends Node

signal population_count_changed(new_population_count)

var age_bands
var population_count

func initialize(bands):
	age_bands = bands

func _on_mortality_changed(_new_mortality):
	count_bands()

func count_bands():
	var total := 0.0
	for band in age_bands.get_children():
		total += band.population
	set_population_count(total)

func set_population_count(value):
	population_count = value
	population_count_changed.emit(value)

func get_save_data() -> Dictionary:
	var band_populations := {}
	for band in age_bands.get_children():
		band_populations[band.key] = band.population
	return {
		"population": band_populations,
	}

func load_save_data(data: Dictionary) -> void:
	for band in age_bands.get_children():
		band.population = data["population"][band.key]
	count_bands()
